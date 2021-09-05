local Tile = require "src.letters.tile"

local TileGroup = {}
TileGroup.__index = TileGroup

function TileGroup.new(tiles)
  local self = setmetatable({}, TileGroup)

  self.x = 7
  self.y = 0

  self.cellWidth = Tile.Width
  self.cellHeight = Tile.Height

  self.tile00 = Tile.new(tiles[1])
  self.tile01 = Tile.new(tiles[2])
  self.tile10 = Tile.new(tiles[3])
  self.tile11 = Tile.new(tiles[4])

  self.isHalf = false
  self.isLeftHalf = false
  return self
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

function TileGroup:rotateClockwise()
  if self.isHalf then return end
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
  if self.isHalf then return end
  local temp00 = self.tile10
  local temp01 = self.tile00
  local temp10 = self.tile11
  local temp11 = self.tile01

  self.tile00 = temp00
  self.tile01 = temp01
  self.tile10 = temp10
  self.tile11 = temp11
end

function TileGroup:update(dt)
  self.tile00:update(dt)
  self.tile01:update(dt)
  self.tile10:update(dt)
  self.tile11:update(dt)
end

function TileGroup:draw(x, y, overrideX, overrideY)
  -- TODO: fix this, so we can draw irrespective of whether we're in the  grid
  -- or not.
  local localX = overrideX or self.x
  local localY = overrideY or self.y

  love.graphics.push("all")
  if not self.isHalf or (self.isHalf and self.isLeftHalf) then
    self.tile00:draw(x + (localX * self.cellWidth), y + (localY * self.cellHeight))
    self.tile01:draw(x + (localX * self.cellWidth), y + ((localY + 1) * self.cellHeight))
  end

  if not self.isHalf or (self.isHalf and not self.isLeftHalf) then
    self.tile10:draw(x + ((localX + 1) * self.cellWidth), y + (localY * self.cellHeight))
    self.tile11:draw(x + ((localX + 1) * self.cellWidth), y + ((localY + 1) * self.cellHeight))
  end

  love.graphics.pop()
end
return TileGroup