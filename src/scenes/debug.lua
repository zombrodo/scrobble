local Plan = require "lib.plan"
local Rules = Plan.Rules

local Grid = require "src.gameplay.grid"
local Cursor = require "src.gameplay.cursor"

local Tile = require "src.letters.tile"
local Letter = require "src.letters.letter"

local DebugScene = {}
DebugScene.__index = DebugScene

function DebugScene:reset()
  self.grid:clear()
  self.grid:set(6, 4, Tile.new(Letter.X))
  self.grid:set(7, 4, Tile.new(Letter.Y))
  self.grid:set(8, 4, Tile.new(Letter.D))
  self.grid:set(9, 4, Tile.new(Letter.Q))
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
        local goalY = y + 1
        while not self.grid:check(x, goalY + 1) and (goalY + 1 < self.grid.yCells) do
          goalY = goalY + 1
        end
        self.grid:fallTo(x, y, x, goalY)
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