local Plan = require "lib.plan"
local Container = Plan.Container
local Rules = Plan.Rules

local Dictionary = require "src.gameplay.dictionary"
local Bag = require "src.gameplay.bag"
local Grid = require "src.gameplay.grid"
local Cursor = require "src.gameplay.cursor"
local Match = require "src.gameplay.match"

local Tile = require "src.letters.tile"

local UpNext = require "src.ui.upnext"
local Scoreboard = require "src.ui.scores"

local EventQueue = require "src.utils.event"
local String = require "src.utils.string"

local SoundManager = require "src.handlers.sound"

local GameScene = {}
GameScene.__index = GameScene

function GameScene.new()
  local self = setmetatable({}, GameScene)
  -- UI
  self.ui = Plan.new()
  -- Game Settings and Controllers
  self.minWordLength = 3
  self.maxWordLength = 7

  self.dictionary = Dictionary.new(self.minWordLength, self.maxWordLength)
  self.bag = Bag.new()

  -- Grid Settings
  self.gridWidth = 16
  self.gridHeight = 12
  self.cellWidth = Tile.Width
  self.cellHeight = Tile.Height

  -- Current Tile
  self.currentTile = self.bag:shift()
  self.dropTimerMax = 0.7
  self.dropTimer = self.dropTimerMax
  self.dropSpeed = 20

  -- Game State
  self.paused = false
  self.matchesBuffer = {}
  self.placementBuffer = {}

  -- Event Queue
  self.eventQueue = EventQueue.new()

  -- Managers
  self.soundManager = SoundManager.new()
  return self
end

function GameScene:enter()
  -- UI and Gameplay Setup
  local upNextRules = Rules.new()
    :addX(Plan.pixel(0))
    :addY(Plan.center())
    :addWidth(Plan.pixel(self.cellWidth * 2))
    :addHeight(Plan.pixel(self.cellHeight * 9))

  self.upNext = UpNext:new(upNextRules, self.bag)

  local gridRules = Rules.new()
    :addX(Plan.pixel(upNextRules:getWidth().value + self.cellWidth / 2))
    :addY(Plan.center())
    :addWidth(Plan.pixel(self.cellWidth * self.gridWidth))
    :addHeight(Plan.pixel(self.cellHeight * self.gridHeight))

  self.grid = Grid:new(
    gridRules,
    self.gridWidth,
    self.gridHeight,
    self.cellWidth,
    self.cellHeight
  )

  local scoreboardRules = Rules.new()
    :addX(Plan.max(self.cellWidth * 4))
    :addY(Plan.center())
    :addWidth(Plan.pixel(self.cellWidth * 4))
    :addHeight(gridRules:getHeight():clone())

  self.scoreboard = Scoreboard:new(scoreboardRules)
  local boardWidth = upNextRules:getWidth().value
    + gridRules:getWidth().value
    + scoreboardRules:getWidth().value
    + self.cellWidth

  local boardRules = Rules.new()
    :addX(Plan.center())
    :addY(Plan.center())
    :addWidth(Plan.pixel(boardWidth))
    :addHeight(Plan.pixel(self.cellHeight * self.gridHeight))

  local board = Container:new(boardRules)
  board:addChild(self.upNext)
  board:addChild(self.grid)
  board:addChild(self.scoreboard)

  self.ui:addChild(board)

  -- Gameplay
  self.cursor = Cursor.new(self.grid.x, self.grid.x + self.grid.w)
  self.dictionary:load("assets/common.txt")

  -- Managers
  self.soundManager:load("assets/placement.mp3", "tile.placement")
  self.soundManager:load("assets/gather.mp3", "tile.gathered")
  self.soundManager:load("assets/word.mp3", "word.found")

  self.eventQueue:register("tile.placement", self.soundManager)
  self.eventQueue:register("word.found", self.soundManager)
  self.eventQueue:register("tile.gathered", self.soundManager)

  self.eventQueue:register("tile.nextGroup", self.upNext)
end

-- Local Helpers

-- Maps each element in `coll` to `fn(element)`. Returns a new map
local function map(fn, coll)
  local result = {}
  for i, elem in ipairs(coll) do
    table.insert(result, fn(elem))
  end
  return result
end

-- Appends tables to one another. This is an inplace operation
local function append(a, b, ...)
  for i, elem in ipairs(b) do
    table.insert(a, elem)
  end

  if ... then
    return append(a, ...)
  end

  return a
end

-- Mapping functions

local function getLetter(w)
  return w.letter
end

local function getIndex(w)
  return w.index
end

-- Places the given coordinates into the placement buffer.
-- Buffer is cleared at the beginning of every update, use this to queue
-- a placement to be considered for word finding actions.
function GameScene:addPlacement(x, y)
  table.insert(self.placementBuffer, { x = x, y = y})
end

-- Drops any hovering tiles to the closest free tile below that is either
-- atop another tile, or the bottom of the grid. This action is asynchronous,
-- and will complete at an unknown time.
function GameScene:fall()
  for x = 0, self.grid.xCells do
    for y = 0, self.grid.yCells - 2 do -- Don't check the bottom row
      -- If we're a tile, and there's nothing below us
      if self.grid:check(x, y) and not self.grid:check(x, y + 1) then
        -- Find the destination cell
        local goalY = y + 1
        while not self.grid:check(x, goalY + 1)
          and not self.grid:reserved(x, goalY + 1)
          and (goalY + 1 < self.grid.yCells) do
            -- While there's free space below us, inch the goal a little further
            goalY = goalY + 1
          end
        self.grid:fallTo(x, y, x, goalY)
        -- NOTE: If the placement is getting all weird, then this is what is
        -- causing it
        self:addPlacement(x, goalY)
      end
    end
  end
end

-- Drops the current TileGroup down one, placing the tiles if it should.
-- Handles cases where only half the tile was set.
--
-- Note: this does not trigger a word find action.
--
-- Note: TileGroups do not live in the grid. This can cause issues if not
-- careful!
function GameScene:dropTile()
  local inBounds = self.currentTile.y + 3 <= self.grid.yCells
  local nothingBelow = not self.grid:anythingBelow(self.currentTile)
  -- If we're still in the grid, and there's nothing below us, then we can
  -- safely drop one tile lower.
  if inBounds and nothingBelow then
    self.currentTile:drop()
  else
    -- Otherwise, we must have something below us, lets try set the tile.
    local wasHalfSet = self.grid:setGroup(self.currentTile)
    self.eventQueue:fire(
      "tile.placement",
      { placed = self.currentTile, wasHalfSet = wasHalfSet }
    )
    -- Pass to the buffer where to look next check
    -- If the currentTile is the left half, then we have just set the right.
    if (wasHalfSet and self.currentTile.isLeftHalf) or not wasHalfSet then
      self:addPlacement(self.currentTile.x + 1, self.currentTile.y)
      self:addPlacement(self.currentTile.x + 1, self.currentTile.y + 1)
    end
    -- If the currentTile is not the left half, then we have just set the left.
    if (wasHalfSet and not self.currentTile.isLeftHalf) or not wasHalfSet then
      self:addPlacement(self.currentTile.x, self.currentTile.y)
      self:addPlacement(self.currentTile.x, self.currentTile.y + 1)
    end

    if not wasHalfSet then
      -- If we set everything, pop the new tile off of the bag
      self.eventQueue:fire("tile.nextGroup", self.currentTile)
      self.currentTile = self.bag:get()
    else
      -- Continue to drop the half that didn't collide
      self.currentTile:drop()
    end
  end
end

-- Finds the longest valid word in the list of provided words.
-- Returns nil if none found, otherwise the winning word.
function GameScene:__longestValidWord(words)
  local result = ""
  for i, word in ipairs(words) do
    if self.dictionary:check(word) then
      if #word > #result then
        result = word
      end
    end
  end

  if result ~= "" then
    return result
  end
end

-- Returns a table containing the ranks of the found tiles in order.
-- Used primarily for the display on the right hand side.
function GameScene:__findRanksForMatch(index, direction, first, last)
  local ranks = {}
  for i = first, last do
    if direction == "x" then
      table.insert(ranks, self.grid:get(i, index).rank)
    end
    if direction == "y" then
      table.insert(ranks, self.grid:get(index, i).rank)
    end
  end
  return ranks
end

-- Attempts to find words from the given letters. Returns a list of `Match`
-- tables which provide information on what was found.
function GameScene:__findWords(letters, index, direction)
  local result = {}
  for i, list in ipairs(letters) do
    -- Build a string out of the letters found
    local word = table.concat(map(getLetter, list))
    print("checking for words in ", word)
    -- Make sure to hold onto the indicies though, so we we know what to clear
    local indicies = map(getIndex, list)
    -- Don't bother if it's < minWordLength
    if #word > self.minWordLength then
      -- Find the longest valid word, then mark its position
      local bestWord = self:__longestValidWord(String.allSubstrings(word))
      if bestWord then
        print("Longest valid word: ", bestWord)
        local first, last = string.find(word, bestWord)
        local ranks = self:__findRanksForMatch(
          index,
          direction,
          indicies[first],
          indicies[last]
        )
        table.insert(
          result,
          Match.new(
            bestWord,
            index,
            direction,
            indicies[first],
            indicies[last],
            ranks
        ))
      end
    end
  end
  print("check finished")
  return result
end

function GameScene:__findWordsRow(y)
  return self:__findWords(self.grid:getRow(y), y, "x")
end

function GameScene:__findWordsColumn(x)
  return self:__findWords(self.grid:getColumn(x), x, "y")
end

function GameScene:___alreadyFound(match)
  print("checking match for", match.word)
  for i, m in ipairs(self.matchesBuffer) do
    if m:equals(match) then
      print("it has already been found")
      return true
    end
  end
  print("it hasn't been found")
  return false
end

function GameScene:__markTiles(results)
  for i, result in ipairs(results) do
    if not self:___alreadyFound(result) then
      if result.direction == "x" then
        for x = result.first, result.last do
          self.grid:mark(x, result.index)
        end
      end
      if result.direction == "y" then
        for y = result.first, result.last do
          self.grid:mark(result.index, y)
        end
      end
      table.insert(self.matchesBuffer, result)
      self.eventQueue:fire("word.found")
    end
  end
end

-- Performs a check on all locations in the placement buffer to see if any words
-- were found. Marks those tiles for removal on next cursor pass.
function GameScene:findWords()
  local words = {}
  for i, position in ipairs(self.placementBuffer) do
    append(
      words,
      self:__findWordsRow(position.y),
      self:__findWordsColumn(position.x)
    )
  end
  -- Only attempt to mark if we actually found anything.
  if #words > 0 then
    self:__markTiles(words)
  end
end

function GameScene:__removeMatch(x, y)
  local toRemove = {}
  for i, match in ipairs(self.matchesBuffer) do
    match:remove(x, y)
    if match:isCleared() then
      print("Removing the last letter for ", match.word)
      self.scoreboard:addWord(match)
      table.insert(toRemove, i)
    end
  end

  for i, index in ipairs(toRemove) do
    table.remove(self.matchesBuffer, index)
  end
end

function GameScene:checkCursor()
  local column = self.cursor:getColumn(Tile.Width)
  if column == self.lastCheckedColumn then
    return
  end
  self.lastCheckedColumn = column
  -- FIXME: Swap out to use event queue
  for y = 0, self.grid.yCells do
    if self.grid:check(column, y) and self.grid:get(column, y).marked then
      self.grid:get(column, y):gather()
      local grid = self.grid
      local eventQueue = self.eventQueue
      local scoreboard = self.scoreboard
      local game = self
      Tick.delay(function()
        game:__removeMatch(column, y)
        scoreboard:send(grid:get(column, y))
        grid:remove(column, y)
        eventQueue:fire("tile.gathered")
      end, 0.1)
    end
  end
end

function GameScene:update(dt)
  if self.paused then
    dt = 0
  end
  -- Clear the placement buffer. This tracks what tiles have been placed
  -- this update.
  self.placementBuffer = {}

  self.ui:update(dt)

  -- Game Actions
  -- Drop any hovering tiles
  self:fall()

  -- Drop the group
  self.dropTimer = self.dropTimer - dt
  if self.dropTimer <= 0 then
    self.dropTimer = self.dropTimerMax
    self:dropTile()
  end
  -- Check for any new words
  self:findWords()

  if love.keyboard.isDown("space") then
    self.dropTimer = self.dropTimer - (dt * self.dropSpeed)
  end

  -- Shift the cursor and check
  self:checkCursor()
  self.cursor:update(dt)

  -- Check the queue for things to do
  self.eventQueue:update(dt)

  -- Update grid for visual effects
  self.grid:update(dt)
end

function GameScene:__moveRight()
  local inBounds = (self.currentTile.x + 3 <= self.grid.xCells)
  local nothingRight = not self.grid:anythingRight(self.currentTile)
  if inBounds and nothingRight then
    self.currentTile:right()
  end
end

function GameScene:__moveLeft()
  local inBounds = self.currentTile.x -1 >= 0
  local nothingLeft = not self.grid:anythingLeft(self.currentTile)
  if inBounds and nothingLeft then
    self.currentTile:left()
  end
end

function GameScene:keypressed(key)
  if key == "a" or key == "left" then
    self:__moveLeft()
  end

  if key == "d" or key == "right" then
    self:__moveRight()
  end

  if key == "z" then
    self.currentTile:rotateAnticlockwise()
  end

  if key == "x" then
    self.currentTile:rotateClockwise()
  end

  if key == "p" then
    self.paused = not self.paused
  end
end

function GameScene:draw()
  love.graphics.push("all")
  self.ui:draw()
  self.cursor:draw()

  self.currentTile:draw(
    self.grid.x + Tile.Width / 2,
    self.grid.y + Tile.Height / 2
  )
  love.graphics.pop()
end

return GameScene