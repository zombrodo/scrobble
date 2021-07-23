local Bag = require "src.bag"
local Dictionary = require "src.dictionary"
local Grid = require "src.grid"
local Tile = require "src.tile"
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
    self.tileGroup:set(self.grid)
    self.tileGroup:reset()
  end
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
end

function GameScene:keypressed(key)
  if key == "right" then
    if self.tileGroup.x + 3 <= self.width then
      self.tileGroup:right()
    end
  end

  if key == "left" then
    if self.tileGroup.x - 1 >= 0 then
      self.tileGroup:left()
    end
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