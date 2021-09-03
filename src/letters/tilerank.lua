local Colour = require "src.utils.colour"

local TileRank = {}

TileRank.Bronze = "rank/bronze"
TileRank.Silver = "rank/silver"
TileRank.Gold = "rank/gold"

TileRank.rank = function()
  local r = love.math.random()

  if r <= 0.5 then
    return TileRank.Bronze
  end

  if r <= 0.833 then
    return TileRank.Silver
  end

  return TileRank.Gold
end

TileRank.colour = function(rank)
  if rank == TileRank.Bronze then
    return Colour.fromHex("#FFB078", 1)
  end

  if rank == TileRank.Silver then
    return Colour.fromHex("#B1B1B1", 1)
  end

  if rank == TileRank.Gold then
    return Colour.fromHex("#E9C708", 1)
  end
end

return TileRank