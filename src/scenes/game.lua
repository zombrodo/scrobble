local Bag = require "src.bag"
local Dictionary = require "src.dictionary"
local Grid = require "src.grid"
local TileType = require "src.tiletype"
local TileGroup = require "src.tilegroup"
local Cursor = require "src.cursor"

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
  self.dropTimerMax = 0.8
  self.dropTimer = self.dropTimerMax

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
    -- print("Winning word: ", result)
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

function GameScene:findWordsColumn(x)
  local column = {}
  for i, list in ipairs(self.grid:column(x)) do
    -- TODO: handle `y` values in the future
    local word = table.concat(map(getLetter, list))
    if #word > self.minWordLength then
      local bestWord = self:longestValidWord(allSubstrings(word))
      if bestWord then
        table.insert(column, bestWord)
      end
    end
  end
  return column
end

function GameScene:findWordsRow(y)
  local row = {}
  for i, list in ipairs(self.grid:row(y)) do
    print(i)
    -- TODO: handle `x` values in the future
    local word = table.concat(map(getLetter, list))
    if #word > self.minWordLength then
      local bestWord = self:longestValidWord(allSubstrings(word))
      if bestWord then
        table.insert(row, bestWord)
      end
    end
  end

  return row
end

local function printResults(results)
  for i, result in ipairs(results) do
    print(result)
  end
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
    print("======= BEGIN HALF")
    print("-- Column --")
    printResults(columnWords)
    print("-- Top row --")
    printResults(topRow)
    print("-- Bottom row --")
    printResults(bottomRow)
    return
  end

  -- Check all
  local leftWords = self:findWordsColumn(self.tileGroup.x)
  local rightWords = self:findWordsColumn(self.tileGroup.x + 1)
  local topWords = self:findWordsRow(self.tileGroup.y)
  local bottomWords = self:findWordsRow(self.tileGroup.y + 1)

  print("======= BEGIN FULL")
  print("-- Left Column --")
  printResults(leftWords)
  print("-- Right Column --")
  printResults(rightWords)
  print("-- Top Row --")
  printResults(topWords)
  print("-- Bottom Row --")
  printResults(bottomWords)
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
      self.tileGroup:reset()
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
  -- self:findWords(column)
  self.lastCheckedColumn = column
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
  self.cursor:draw()
  love.graphics.pop()
end

return GameScene