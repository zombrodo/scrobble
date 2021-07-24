local Tile = require "src.tile"

local TileGroup = {}
TileGroup.__index = TileGroup

function TileGroup.new(bag, cellSize)
  local self = setmetatable({}, TileGroup)
  self.x = 6
  self.y = -2
  self.cellSize = cellSize
  self.bag = bag

  -- For split groups.
  self.isHalved = false
  self.leftHalf = false

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
  self.isHalved = false
  self.leftHalf = false
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
  if not self.isHalved then
    return grid:check(self.x, self.y + 2)
      or grid:check(self.x + 1, self.y + 2)
  end

  if self.leftHalf then
    return grid:check(self.x, self.y + 2)
  end

  return grid:check(self.x + 1, self.y + 2)
end

function TileGroup:set(grid)
  -- TODO: tidy this up, combine branches.
  if self.isHalved then
    if self.leftHalf then
      grid:add(self.x, self.y, self.tile00)
      grid:add(self.x, self.y + 1, self.tile01)
    else
      grid:add(self.x + 1, self.y, self.tile10)
      grid:add(self.x + 1, self.y + 1, self.tile11)
    end
    return
  end

  -- is it on left or right?
  local left = grid:check(self.x, self.y + 2)
  local right = grid:check(self.x + 1, self.y + 2)

  local bottom = not (left or right)
  local both = left and right

  if not (both or bottom) then
    self.isHalved = true
    self.leftHalf = right -- if the right half is set, then we have left
  end

  if left or both or bottom then
    grid:add(self.x, self.y, self.tile00)
    grid:add(self.x, self.y + 1, self.tile01)
  end

  if right or both or bottom then
    grid:add(self.x + 1, self.y, self.tile10)
    grid:add(self.x + 1, self.y + 1, self.tile11)
  end

  -- Return whether or not we should continue
  return not (both or bottom)
end

function TileGroup:rotateClockwise()
  if self.isHalved then return end
  local temp00 = self.tile01
  local temp10 = self.tile00
  local temp01 = self.tile11
  local temp11 = self.tile10

  self.tile00 = temp00
  self.tile01 = temp01
  self.tile10 = temp10
  self.tile11 = temp11
end

function TileGroup:rotateAnticlockwise()
  if self.isHalved then return end
  local temp00 = self.tile10
  local temp01 = self.tile00
  local temp10 = self.tile11
  local temp11 = self.tile01

  self.tile00 = temp00
  self.tile01 = temp01
  self.tile10 = temp10
  self.tile11 = temp11
end

function TileGroup:draw(x, y)
  love.graphics.push("all")
  if not self.isHalved or (self.isHalved and self.leftHalf) then
    self.tile00:draw(x + (self.x * self.cellSize), y + (self.y * self.cellSize))
    self.tile01:draw(x + (self.x * self.cellSize), y + ((self.y + 1) * self.cellSize))
  end

  if not self.isHalved or (self.isHalved and not self.leftHalf) then
    self.tile10:draw(x + ((self.x + 1) * self.cellSize), y + (self.y * self.cellSize))
    self.tile11:draw(x + ((self.x + 1) * self.cellSize), y + ((self.y + 1) * self.cellSize))
  end

  love.graphics.pop()
end

return TileGroup