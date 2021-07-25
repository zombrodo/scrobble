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

function GameScene:dropTile()
  local inBounds = self.tileGroup.y + 3 <= self.height
  local nothingBelow = not self.tileGroup:check(self.grid)
  if inBounds and nothingBelow then
    self.tileGroup:drop()
  else
    local halfSet = self.tileGroup:set(self.grid)
    if not halfSet then
      self.tileGroup:reset()
    else
      self.tileGroup:drop() -- drop the half left behind
    end
  end
end

local function allSubstrings(str)
  print("finding substrings for", str)
  local result = {}
  for i = 1, #str do
    for j = i, #str do
      table.insert(result, string.sub(str, i, j))
    end
  end
  return result
end

function GameScene:winningWord(words)
  local result = ""
  for i, s in ipairs(words) do
    if self.dictionary:check(s) then
      if #s > #result then
        result = s
      end
    end
  end

  if result ~= "" then
    print("Winning word: ", result)
    return result
  end
end

function GameScene:findWords(wordList)
  local result = {}
  for i, list in ipairs(wordList) do
    local word = table.concat(list)
    if #word > self.minWordLength then
      local bestWord = self:winningWord(allSubstrings(word))
      if bestWord then
        table.insert(result, bestWord)
      end
    end
  end
  return result
end

function GameScene:checkCursor()
  local column = self.cursor:getColumn(self.cellSize)
  if column == self.lastCheckedColumn then
    return
  end
  -- Column check
  self:findWords(self.grid:column(column))
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