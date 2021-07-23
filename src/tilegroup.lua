local Tile = require "src.tile"

local TileGroup = {}
TileGroup.__index = TileGroup

function TileGroup.new(bag, cellSize)
  local self = setmetatable({}, TileGroup)
  self.x = 6
  self.y = -2
  self.cellSize = cellSize
  self.bag = bag
  self.isHalf = false
  self:reset()
  return self
end

function TileGroup:reset()
  self.x = 6
  self.y = -2
  self.tile00 = Tile.new(self.bag:get())
  self.tile01 = Tile.new(self.bag:get())
  self.tile10 = Tile.new(self.bag:get())
  self.tile11 = Tile.new(self.bag:get())
end

function TileGroup:drop()
  self.y = self.y + 1
end

function TileGroup:left()
  self.x = self.x - 1
end

function TileGroup:right()
  self.x = self.x + 1
end

function TileGroup:check(grid)
  return grid:check(self.x, self.y + 2) or
    grid:check(self.x + 1, self.y + 2)
end

function TileGroup:set(grid)
  grid:add(self.x, self.y, self.tile00)
  grid:add(self.x, self.y + 1, self.tile01)
  grid:add(self.x + 1, self.y, self.tile10)
  grid:add(self.x + 1, self.y + 1, self.tile11)
end

function TileGroup:draw(x, y)
  love.graphics.push("all")
  self.tile00:draw(x + (self.x * self.cellSize), y + (self.y * self.cellSize))
  self.tile01:draw(x + (self.x * self.cellSize), y + ((self.y + 1) * self.cellSize))
  self.tile10:draw(x + ((self.x + 1) * self.cellSize), y + (self.y * self.cellSize))
  self.tile11:draw(x + ((self.x + 1) * self.cellSize), y + ((self.y + 1) * self.cellSize))
  love.graphics.pop()
end

return TileGroup