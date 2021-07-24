local TileType = require "src.tiletype"

local Grid = {}
Grid.__index = Grid

function Grid.new(width, height, cellSize)
  local self = setmetatable({}, Grid)
  self.width = width
  self.height = height
  self.cellSize = cellSize

  self.gridOverhang = 0

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

-- TODO: pretty lenient, does no bounds checking?
function Grid:check(x, y)
  return self.items[y] and self.items[y][x] ~= nil
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
  -- Grid
  love.graphics.setColor(love.math.colorFromBytes(8, 20, 30))
  for r = 0, self.height do
    for c = 0, self.width - 1 do
      if c ~= 0 then
        love.graphics.line(
          x + (c * self.cellSize),
          (y - self.gridOverhang),
          x + (c * self.cellSize),
          (y + self.gridOverhang) + (self.height * self.cellSize))
      end
      if r ~= 0 then
        love.graphics.line(
          (x - self.gridOverhang),
          y + (r * self.cellSize),
          (x + self.gridOverhang) + (self.width * self.cellSize),
          y + (r * self.cellSize)
        )
      end
    end
  end

  -- Tiles
  love.graphics.setColor(1, 1, 1, 1)
  for r = 0, self.height - 1 do
    for c = 0, self.width - 1 do
      if self.items[r][c] then
        self.items[r][c]:draw(x + (c * self.cellSize), y + (r * self.cellSize))
      end
    end
  end
  love.graphics.pop()
end

return Grid