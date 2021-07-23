local TileType = require "src.tiletype"

local Grid = {}
Grid.__index = Grid

function Grid.new(width, height, cellSize)
  local self = setmetatable({}, Grid)
  self.width = width
  self.height = height
  self.cellSize = cellSize

  self.items = {}
  for y = 0, self.height do
    self.items[y] = {}
  end
  return self
end

function Grid:add(x, y, tile)
  self.items[y][x] = tile
end

function Grid:get(x, y)
  return self.items[y][x]
end

function Grid:check(x, y)
  return self.items[y][x] ~= nil
end

function Grid:row(y)
  local result = {}
  for x = 0, self.width do
    table.insert(
      result,
      string.lower(TileType.letter(self.items[y][x].tileType))
    )
  end
  return result
end

function Grid:column(x)
  local result
  for y = 0, self.height do
    table.insert(
      result,
      string.lower(TileType.letter(self.items[y][x].tileType))
    )
  end
  return result
end

function Grid:draw(x, y)
  love.graphics.push("all")
  for r = 0, self.height do
    for c = 0, self.width do
      self.items[r][c]:draw(x + (c * self.cellSize), y + (r * self.cellSize))
    end
  end
  love.graphics.pop()
end

return Grid