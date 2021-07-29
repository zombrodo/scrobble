local TileType = require "src.tiletype"
local Colour = require "src.utils.colour"

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

function Grid:remove(x, y)
  self.items[y][x] = nil
end

-- FIXME: combine with `column` at some point?
function Grid:row(y)
  local result = {}
  local currentWord = {}
  for x = 0, self.width do
    if self.items[y][x] then
      table.insert(
        currentWord,
        {
          letter = string.lower(TileType.letter(self.items[y][x].tileType)),
          index = x
        }
      )
    else
      if #currentWord > 0 then
        table.insert(result, currentWord)
        currentWord = {}
      end
    end
  end

    -- catch the last one
    if #currentWord > 0 then
      table.insert(result, currentWord)
    end

  return result
end

function Grid:column(x)
  local result = {}
  local currentWord = {}
  for y = 0, self.height do
    if self.items[y][x] then
      table.insert(
        currentWord,
        {
          letter = string.lower(TileType.letter(self.items[y][x].tileType)),
          index = y
        }
      )
    else
      if #currentWord > 0 then
        table.insert(result, currentWord)
        currentWord = {}
      end
    end
  end

  -- catch the last one
  if #currentWord > 0 then
    table.insert(result, currentWord)
  end

  return result
end

function Grid:draw(x, y)
  love.graphics.push("all")
  -- Grid
  -- love.graphics.setColor(Colour.fromBytes(8, 20, 30))
  love.graphics.setColor(Colour.fromBytes(8, 20, 30, 0.7))
  for r = 0, self.height do
        love.graphics.line(
          (x - self.gridOverhang),
          y + (r * self.cellSize),
          (x + self.gridOverhang) + (self.width * self.cellSize),
          y + (r * self.cellSize)
        )
  end

  for c = 0, self.width do
      love.graphics.line(
        x + (c * self.cellSize),
        (y - self.gridOverhang),
        x + (c * self.cellSize),
        (y + self.gridOverhang) + (self.height * self.cellSize))
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