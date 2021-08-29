local Plan = require "lib.plan"
local Container = Plan.Container
local Rules = Plan.Rules

local Grid = require "src.gameplay.grid"
local Cursor = require "src.gameplay.cursor"
local Dictionary = require "src.gameplay.dictionary"
local Bag = require "src.gameplay.bag"
local Match = require "src.gameplay.match"

local UpNext = require "src.ui.upnext"

local Tile = require "src.letters.tile"
local TileType = require "src.letters.tiletype"

local String = require "src.utils.string"

local GameScene = {}
GameScene.__index = GameScene

function GameScene.new()
  local self = setmetatable({}, GameScene)
  self.ui = Plan.new()

  self.minWordLength = 3
  self.maxWordLength = 7

  self.dictionary = Dictionary.new(self.minWordLength, self.maxWordLength)
  self.bag = Bag.new()
  self.currentTile = self.bag:shift() -- stateful get

  self.dropTimerMax = 0.5
  self.dropTimer = self.dropTimerMax * 8
  self.dropSpeed = 20

  self.paused = false

  self.lastColumnChecked = -1
  return self
end

function GameScene:enter()
  -- Grid setup
  local gridWidth = 16
  local gridHeight = 10
  local cellSize = 32

  local upNextRules = Rules.new()
  upNextRules:addX(Plan.pixel(0))
    :addY(Plan.center())
    :addWidth(Plan.pixel(2 * cellSize))
    :addHeight(Plan.pixel(9 * cellSize))

  self.upNext = UpNext:new(upNextRules, self.bag)

  local gridRules = Rules.new()
  gridRules:addX(Plan.pixel(upNextRules:getWidth().value + 16))
    :addY(Plan.center())
    :addWidth(Plan.pixel(cellSize * gridWidth))
    :addHeight(Plan.pixel(cellSize * gridHeight))

  self.grid = Grid:new(gridRules, gridWidth, gridHeight, cellSize)

  local boardRules = Rules.new()
  boardRules:addX(Plan.center())
    :addY(Plan.center())
    :addWidth(Plan.pixel(upNextRules:getWidth().value + gridRules:getWidth().value))
    :addHeight(Plan.pixel(cellSize * gridHeight))

  local board = Container:new(boardRules)
  board:addChild(self.upNext)
  board:addChild(self.grid)
  self.ui:addChild(board)
  -- Cursor
  self.cursor = Cursor.new(self.grid.x, self.grid.x + self.grid.w)
  -- Dictionary
  self.dictionary:load("assets/dictionary.txt")
end

local function map(fn, coll)
  local result = {}
  for i, elem in ipairs(coll) do
    table.insert(result, fn(elem))
  end
  return result
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

local function getLetter(w)
  return w.letter
end

local function getIndex(w)
  return w.index
end

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

function GameScene:__findWords(letters, index, direction)
  local result = {}
  for i, list in ipairs(letters) do
    local word = table.concat(map(getLetter, list))
    local indicies = map(getIndex, list)
    if #word > self.minWordLength then
      local bestWord = self:__longestValidWord(String.allSubstrings(word))
      if bestWord then
        print(bestWord)
        local first, last = string.find(word, bestWord)
        table.insert(
          result,
          Match.new(bestWord, index, direction, indicies[first], indicies[last])
        )
      end
    end
  end
  return result
end

function GameScene:__findWordsRow(y)
  return self:__findWords(self.grid:getRow(y), y, "x")
end

function GameScene:__findWordsColumn(x)
  return self:__findWords(self.grid:getColumn(x), x, "y")
end

function GameScene:__markTiles(results)
  for i, result in ipairs(results) do
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
  end
end

function GameScene:findWords(wasHalfSet)
  if wasHalfSet then
    local columnWords = {}
    -- If the right was just set, then only check right column
    if self.currentTile.isLeftHalf then
      columnWords = self:__findWordsColumn(self.currentTile.x + 1)
    else
      columnWords = self:__findWordsColumn(self.currentTile.x)
    end
    local topRow = self:__findWordsRow(self.currentTile.y)
    local bottomRow = self:__findWordsRow(self.currentTile.y + 1)
    self:__markTiles(append(columnWords, topRow, bottomRow))
    -- bail out
    return
  end
  -- Check all
  local leftWords = self:__findWordsColumn(self.currentTile.x)
  local rightWords =self:__findWordsColumn(self.currentTile.x + 1)
  local topWords = self:__findWordsRow(self.currentTile.y)
  local bottomWords = self:__findWordsRow(self.currentTile.y + 1)
  self:__markTiles(append(leftWords, rightWords, topWords, bottomWords))
end

function GameScene:dropTile()
  local inBounds = self.currentTile.y + 3 <= self.grid.yCells
  local nothingBelow = not self.grid:anythingBelow(self.currentTile)
  if inBounds and nothingBelow then
    self.currentTile:drop()
  else
    local wasHalfSet = self.grid:setGroup(self.currentTile)
    self:findWords(wasHalfSet)
    if not wasHalfSet then
      self.currentTile = self.bag:get()
      self.upNext:shift()
    else
      self.currentTile:drop()
    end
  end
end

function GameScene:checkCursor()
  local column = self.cursor:getColumn(Tile.Size)
  if column == self.lastCheckedColumn then
    return
  end
  self.lastCheckedColumn = column

  for y = 0, self.grid.yCells do
    if self.grid:check(column, y) and self.grid:get(column, y).marked then
      self.grid:get(column, y):gather()
      local grid = self.grid
      Tick.delay(function()
        grid:remove(column, y)
      end, 0.4)
    end
  end
end

function GameScene:fall()
  for x = 0, self.grid.xCells do
    for y = 0, self.grid.yCells - 2 do
      if self.grid:check(x, y) and not self.grid:check(x, y + 1) then
        local goalY = y + 1
        while not self.grid:check(x, goalY + 1)
          and not self.grid:reserved(x, goalY + 1)
          and (goalY + 1 < self.grid.yCells) do
          goalY = goalY + 1
        end
        self.grid:fallTo(x, y, x, goalY)
      end
    end
  end
end

function GameScene:update(dt)
  if self.paused then
    dt = 0
  end
  self.ui:update(dt)
  self.cursor:update(dt)

  self.dropTimer = self.dropTimer - dt
  if self.dropTimer <= 0 then
    self.dropTimer = self.dropTimerMax
    self:dropTile()
  end

  if love.keyboard.isDown("space") then
    self.dropTimer = self.dropTimer - (dt * self.dropSpeed)
  end

  self:checkCursor()
  self:fall()

  for x = 0, self.grid.xCells do
    for y = 0, self.grid.yCells do
      if self.grid:check(x, y) then
        self.grid:get(x, y):update(dt)
      end
    end
  end
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
  -- TODO: The origins seem off for this one :thonk:
  self.currentTile:draw(
    self.grid.x + Tile.Size / 2,
    self.grid.y + Tile.Size / 2
  )
  love.graphics.pop()
end

return GameScene