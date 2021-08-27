local Plan = require "lib.plan"
local Rules = Plan.Rules

local Grid = require "src.gameplay.grid"
local Cursor = require "src.gameplay.cursor"

local Tile = require "src.letters.tile"
local TileType = require "src.letters.tiletype"

local DebugScene = {}
DebugScene.__index = DebugScene

function DebugScene:reset()
  self.grid:clear()
  self.grid:set(6, 9, Tile.new(TileType.T))
  self.grid:get(6, 9).marked = true
  self.grid:set(7, 9, Tile.new(TileType.I))
  self.grid:get(7, 9).marked = true
  self.grid:set(8, 9, Tile.new(TileType.R))
  self.grid:get(8, 9).marked = true
  self.grid:set(9, 9, Tile.new(TileType.E))
  self.grid:get(9, 9).marked = true

  self.grid:set(6, 8, Tile.new(TileType.X))
  self.grid:set(7, 8, Tile.new(TileType.Y))
  self.grid:set(8, 8, Tile.new(TileType.D))
  self.grid:set(9, 8, Tile.new(TileType.Q))
end

function DebugScene.new()
  local self = setmetatable({}, DebugScene)
  local gridWidth = 16
  local gridHeight = 10
  local cellSize = 32
  self.ui = Plan.new()
  local gridRules = Rules.new()
  gridRules:addX(Plan.center())
    :addY(Plan.center())
    :addWidth(Plan.pixel(gridWidth * cellSize))
    :addHeight(Plan.pixel(gridHeight * cellSize))
  self.grid = Grid:new(gridRules, gridWidth, gridHeight, cellSize)
  self.ui:addChild(self.grid)

  self:reset()

  self.stepping = true
  self.lastDt = 0

  return self
end

function DebugScene:enter()
  self.cursor = Cursor.new(self.grid.x, self.grid.x + self.grid.w)
  self.cursor.speed = 150
end

function DebugScene:checkCursor()
  local column = self.cursor:getColumn(Tile.Size)
  if column == self.lastCheckedColumn then
    return
  end
  self.lastCheckedColumn = column

  for y = 0, self.grid.yCells do
    if self.grid:check(column, y) and self.grid:get(column, y).marked then
      self.grid:get(column, y):gather()
      local grid = self.grid
      Tick.delay(function()
        print("Removing", column, y)
        grid:remove(column, y)
      end, 0.7)
    end
  end
end

function DebugScene:fall()
  for x = 0, self.grid.xCells do
    for y = 0, self.grid.yCells - 2 do
      if self.grid:check(x, y) and not self.grid:check(x, y + 1) then
        print("shifting", x, y, "down to", x, y + 1)
        local tile = self.grid:get(x, y)
        self.grid:set(x, y + 1, tile)
        self.grid:remove(x, y)
      end
    end
  end
end

function DebugScene:step(dt)
  self.ui:update(dt)
  self.cursor:update(dt)
  self:checkCursor()
  if self.cursor.justCompleted then
    self:reset()
  end

  for x = 0, self.grid.xCells do
    for y = 0, self.grid.yCells do
      if self.grid:check(x, y) then
        self.grid:get(x, y):update(dt)
      end
    end
  end

  self:fall()
end


function DebugScene:update(dt)
  if not self.stepping then
    self:step(dt)
  end
  self.lastDt = dt
end

function DebugScene:keypressed(key)
  if key == "p" then
    self.stepping = not self.stepping
  end

  if key == "o" then
    self:step(self.lastDt)
  end
end

function DebugScene:draw()
  love.graphics.push("all")
  self.ui:draw()
  self.cursor:draw()
  love.graphics.pop()
end

return DebugScene