local Queue = require "src.utils.queue"
local Letter = require "src.letters.letter"
local TileGroup = require "src.letters.tilegroup"

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
  self.letters = {}
  self.upNext = Queue.new()
  self:refill()

  self.upNext:enqueue(self:nextGroup())
  self.upNext:enqueue(self:nextGroup())
  self.upNext:enqueue(self:nextGroup())
  self.upNext:enqueue(self:nextGroup())
  self.upNext:enqueue(self:nextGroup())
  self.upNext:enqueue(self:nextGroup())
  self.upNext:enqueue(self:nextGroup())
  return self
end

function Bag:refill()
  local bag = {}
  for letter, quantity in pairs(Letter.Frequencies) do
    for i = 1, quantity do
      table.insert(bag, letter)
    end
  end
  self.items = shuffle(bag)
end

local function spawnSpecialTile()
  return love.math.random() > 0.95
end

function Bag:nextTile()
  if spawnSpecialTile() then
    return Letter.Special
  end

  local letter = table.remove(self.items)
  if #self.items == 0 then
    self:refill()
  end
  return letter
end

function Bag:nextGroup()
  return TileGroup.new({
    self:nextTile(),
    self:nextTile(),
    self:nextTile(),
    self:nextTile()
  })
end

function Bag:get()
  self.upNext:enqueue(self:nextGroup())
  return self.upNext:peek(1)
end

function Bag:shift()
  return self.upNext:dequeue()
end

function Bag:getUpNext(i)
  return self.upNext:peek(i + 1)
end

return Bag