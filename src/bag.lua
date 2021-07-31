local TileType = require "src.tiletype"
local TileGroup = require "src.tilegroup"
local Queue = require "src.utils.queue"

local Bag = {}
Bag.__index = Bag

local function shuffle(tbl)
  for i = #tbl, 2, -1 do
    local j = love.math.random(i)
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
  return tbl
end

function Bag.new()
  local self = setmetatable({}, Bag)
  self.items = {}
  self.upNext = Queue.new()
  self:refill()
  -- Keep Four TileGroups in the Queue
  self.upNext:enqueue(TileGroup.new(self, 32))
  self.upNext:enqueue(TileGroup.new(self, 32))
  self.upNext:enqueue(TileGroup.new(self, 32))
  self.upNext:enqueue(TileGroup.new(self, 32))

  self.bagCanvas = love.graphics.newCanvas(64, 296)
  self.bagShader = love.graphics.newShader("assets/fade.glsl")
  return self
end

function Bag:__get()
  local letter = table.remove(self.items)
  if #self.items == 0 then
    self:refill()
  end
  return letter
end

function Bag:get()
  self.upNext:enqueue(TileGroup.new(self, 32))
  return self.upNext:dequeue()
end

function Bag:refill()
  local bag = {}
  for tileType, quantity in pairs(TileType.frequencies) do
    for i = 1, quantity do
      if tileType ~= TileType.Blank then
        table.insert(bag, tileType)
      end
    end
  end
  self.items = shuffle(bag)
end

function Bag:draw(x, y)
  love.graphics.push("all")
  local currentCanvas = love.graphics.getCanvas()
  love.graphics.setCanvas(self.bagCanvas)
  local tileGroupHeight = 64
  for i = 0, 3 do
    local tileGroup = self.upNext:peek(i + 1)
    tileGroup:draw(0, i * tileGroupHeight + (i * 10), 0, 0)
  end
  love.graphics.setCanvas(currentCanvas)
  love.graphics.setShader(self.bagShader)
  love.graphics.draw(
    self.bagCanvas,
    x,
    y,
    0,
    1,
    1,
    self.bagCanvas:getWidth() / 2,
    self.bagCanvas:getHeight() / 2
  )
  love.graphics.setShader()
  love.graphics.pop()
end

return Bag