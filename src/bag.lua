local TileType = require "src.tiletype"

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
  self:refill()
  return self
end

function Bag:get()
  local letter = table.remove(self.items)
  if #self.items == 0 then
    self:refill()
  end
  return letter
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

return Bag