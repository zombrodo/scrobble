local Bag = require "src.bag"
local Dictionary = require "src.dictionary"
local Grid = require "src.grid"
local Tile = require "src.tile"

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

  -- Current tile
  return self
end

function GameScene:enter()
  self.dictionary:load("assets/dictionary.txt")
  for x = 0, self.width do
    for y = 0, self.height do
      self.grid:add(x, y, Tile.new(self.bag:get()))
    end
  end
end

function GameScene:update(dt)

end

function GameScene:draw()
  love.graphics.push("all")
  self.grid:draw(self.startX, self.startY)
  love.graphics.pop()
end

return GameScene