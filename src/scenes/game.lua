local Bag = require "src.bag"
local Dictionary = require "src.dictionary"
local Grid = require "src.grid"

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
  self.width = 7
  self.height = 11
  self.cellSize = 32
  self.grid = Grid.new(self.width, self.height, self.cellSize)
  self.startX = (GAME_WIDTH / 2) - ((self.width * self.cellSize) / 2)
  return self
end

function GameScene:enter()
  self.dictionary:load("assets/dictionary.txt")
end

function GameScene:update(dt)

end

function GameScene:draw()
  love.graphics.push("all")
  self.grid:draw(self.startX, 0)
  love.graphics.pop()
end

return GameScene