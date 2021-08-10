local Bag = require "src.bag"
local Dictionary = require "src.dictionary"
local Grid = require "src.grid"
local TileGroup = require "src.tilegroup"
local TileType = require "src.tiletype"
local Cursor = require "src.cursor"
local Fonts = require "src.utils.fonts"
local Colour = require "src.utils.colour"

local GameScene = {}
GameScene.__index = GameScene

function GameScene.new()
  local self = setmetatable({}, GameScene)

  -- Dictionary of valid words
  self.minWordLength = 3
  self.maxWordLength = 7
  self.dictionary = Dictionary.new(self.minWordLength, self.maxWordLength)

  -- Bag of letters
  self.bag = Bag.new()

  -- Game grid
  self.width = 16
  self.height = 10
  self.cellSize = 32
  self.grid = Grid.new(self.width, self.height, self.cellSize)
  self.startX = (GAME_WIDTH / 2) - ((self.width * self.cellSize) / 2)
  self.startY = (GAME_HEIGHT / 2) - ((self.height * self.cellSize) / 2)

  -- Cursor
  self.cursor = Cursor.new(
    self.startX,
    self.startX + (self.width * self.cellSize)
  )
  self.lastCheckedColumn = 0

  -- Current Tile Group
  self.tileGroup = TileGroup.new(self.bag, self.cellSize)

  -- Timer
  self.dropTimerMax = 0.5
  self.dropTimer = 2

  -- Text
  self.upNextText = love.graphics.newText(Fonts.montserrat(14), "Up next")

  self.score = 0

  self.scoreText = love.graphics.newText(Fonts.montserrat(14), "Score: 0")
  return self
end

function GameScene:enter()
  self.dictionary:load("assets/dictionary.txt")
end

local function allSubstrings(str)
  -- print("finding substrings for", str)
  local result = {}
  for i = 1, #str do
    for j = i, #str do
      table.insert(result, string.sub(str, i, j))
    end
  end
  return result
end

function GameScene:longestValidWord(words)
  local result = ""
  for i, s in ipairs(words) do
    if self.dictionary:check(s) then
      if #s > #result then
        result = s
      end
    end
  end

  if result ~= "" then
    return result
  end
end

local function map(fn, coll)
  local result = {}
  for i, elem in ipairs(coll) do
    table.insert(result, fn(elem))
  end
  return result
end

local function getLetter(w)
  return w.letter
end

local function getIndicies(w)
  return w.index
end

function GameScene:findWordsColumn(x)
  local column = {}
  for i, list in ipairs(self.grid:column(x)) do
    -- TODO: handle `y` values in the future
    local word = table.concat(map(getLetter, list))
    local indicies = map(getIndicies, list)
    if #word > self.minWordLength then
      local bestWord = self:longestValidWord(allSubstrings(word))
      if bestWord then
        local first, last = string.find(word, bestWord)
        table.insert(
          column,
          {
            word = bestWord,
            gridIndex = x,
            direction = "y",
            first = indicies[first],
            last = indicies[last]
          }
        )
      end
    end
  end
  return column
end

function GameScene:findWordsRow(y)
  local row = {}
  for i, list in ipairs(self.grid:row(y)) do
    -- TODO: handle `x` values in the future
    local word = table.concat(map(getLetter, list))
    local indicies = map(getIndicies, list)
    if #word > self.minWordLength then
      local bestWord = self:longestValidWord(allSubstrings(word))
      if bestWord then
        local first, last = string.find(word, bestWord)
        table.insert(
          row, {
            word = bestWord,
            gridIndex = y,
            direction = "x",
            first = indicies[first],
            last = indicies[last]
          })
      end
    end
  end
  return row
end

-- FIXME: Assumes that the tiles at the indicies exist.
function GameScene:markTiles(results)
  for i, result in ipairs(results) do
    if result.direction == "x" then
      for x = result.first, result.last do
        self.grid:get(x, result.gridIndex).marked = true
      end
    end
    if result.direction == "y" then
      for y = result.first, result.last do
        self.grid:get(result.gridIndex, y).marked = true
      end
    end
  end
end

local function append(a, b, ...)
  for i, elem in ipairs(b) do
    table.insert(a, elem)
  end
  if ... then
    return append(a, ...)
  end

  return a
end

function GameScene:findWords(isHalfSet)
  -- Check Halves
  if isHalfSet then
    local columnWords = {}
    if self.tileGroup.leftHalf then -- if the right was just set, then check right column
      columnWords = self:findWordsColumn(self.tileGroup.x + 1)
    else
      columnWords = self:findWordsColumn(self.tileGroup.x)
    end
    local topRow = self:findWordsRow(self.tileGroup.y)
    local bottomRow = self:findWordsRow(self.tileGroup.y + 1)
    self:markTiles(append(columnWords, topRow, bottomRow))
    return
  end

  -- Check all
  local leftWords = self:findWordsColumn(self.tileGroup.x)
  local rightWords = self:findWordsColumn(self.tileGroup.x + 1)
  local topWords = self:findWordsRow(self.tileGroup.y)
  local bottomWords = self:findWordsRow(self.tileGroup.y + 1)
  self:markTiles(append(leftWords, rightWords, topWords, bottomWords))
end

function GameScene:dropTile()
  local inBounds = self.tileGroup.y + 3 <= self.height
  local nothingBelow = not self.tileGroup:check(self.grid)
  if inBounds and nothingBelow then
    self.tileGroup:drop()
  else
    local halfSet = self.tileGroup:set(self.grid)
    self:findWords(halfSet)
    if not halfSet then
      self.tileGroup = self.bag:get()
    else
      self.tileGroup:drop() -- drop the half left behind
    end
  end
end

function GameScene:checkCursor()
  local column = self.cursor:getColumn(self.cellSize)
  if column == self.lastCheckedColumn then
    return
  end

  for y = 0, self.height do
    if self.grid:check(column, y) and self.grid:get(column, y).marked then
      -- TODO: Tally score here
      self.grid:get(column, y).gathered = true
      local grid = self.grid
      Tick.delay(function()
        self.score = self.score + TileType.score(grid:get(column, y).tileType)
        grid:remove(column, y)
       end, 1)
    end
  end

  self.lastCheckedColumn = column
end

function GameScene:fall()
  local numChanged = 0
  repeat
    numChanged = 0
    for x = 0, self.width do
      for y = 0, self.height do
        if self.grid:check(x, y) then
          if y + 1 < self.height and not self.grid:check(x, y + 1) then
            self.grid:add(x, y + 1, self.grid:get(x, y))
            self.grid:remove(x, y)
            numChanged = numChanged + 1
          end
        end
      end
    end
  until numChanged < 1
end

function GameScene:update(dt)
  self.cursor:update(dt)
  -- Timer progress
  self.dropTimer = self.dropTimer - dt
  if self.dropTimer <= 0 then
    self.dropTimer = self.dropTimerMax
    self:dropTile()
  end

  if love.keyboard.isDown("space") then
    self.dropTimer = self.dropTimer - (dt * 20)
  end

  -- Cursor Check
  self:checkCursor()

  self:fall()

  -- Tile Update
  for x = 0, self.width do
    for y = 0, self.height do
      if self.grid:check(x, y) then
        self.grid:get(x, y):update(dt)
      end
    end
  end

  -- Update Score
  self.scoreText:set("Score: " .. self.score)
end

function GameScene:keypressed(key)
  if key == "right" then
    local inBounds = (self.tileGroup.x + 3 <= self.width)
    local nothingRight = not (
      self.grid:check(self.tileGroup.x + 3, self.tileGroup.y)
        or self.grid:check(self.tileGroup.x + 3, self.tileGroup.y + 1))
    if inBounds and nothingRight then
      self.tileGroup:right()
    end
  end

  if key == "left" then
    local inBounds = self.tileGroup.x - 1 >= 0
    local nothingLeft = not (
      self.grid:check(self.tileGroup.x - 1, self.tileGroup.y)
        or self.grid:check(self.tileGroup.x - 1, self.tileGroup.y + 1))
    if inBounds and nothingLeft then
      self.tileGroup:left()
    end
  end

  if key == "z" then
    self.tileGroup:rotateAnticlockwise()
  end

  if key == "x" then
    self.tileGroup:rotateClockwise()
  end
end

function GameScene:draw()
  love.graphics.push("all")
  self.grid:draw(self.startX, self.startY)
  self.tileGroup:draw(self.startX, self.startY)
  love.graphics.setColor(Colour.fromBytes(246, 214, 189))
  love.graphics.draw(
    self.upNextText,
    self.startX - 40,
    (love.graphics.getHeight() / 2
      - self.bag.bagCanvas:getHeight() / 2
      -  self.upNextText:getHeight() / 2
      - 10
    ),
    0,
    1,
    1,
    self.upNextText:getWidth() / 2,
    self.upNextText:getHeight() / 2
  )
  love.graphics.draw(
    self.scoreText,
    self.startX + (self.width * self.cellSize) + 40,
    (love.graphics.getHeight() / 2
      - self.bag.bagCanvas:getHeight() / 2
      -  self.scoreText:getHeight() / 2
      - 10
    ),
    0,
    1,
    1,
    self.scoreText:getWidth() / 2,
    self.scoreText:getHeight() / 2
  )
  self.bag:draw(self.startX - 40, love.graphics.getHeight() / 2)
  self.cursor:draw()
  love.graphics.pop()
end

return GameScene