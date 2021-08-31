local Colour = require "src.utils.colour"

local TileType = {}

TileType.A = "tile/A"
TileType.B = "tile/B"
TileType.C = "tile/C"
TileType.D = "tile/D"
TileType.E = "tile/E"
TileType.F = "tile/F"
TileType.G = "tile/G"
TileType.H = "tile/H"
TileType.I = "tile/I"
TileType.J = "tile/J"
TileType.K = "tile/K"
TileType.L = "tile/L"
TileType.M = "tile/M"
TileType.N = "tile/N"
TileType.O = "tile/O"
TileType.P = "tile/P"
TileType.Q = "tile/Q"
TileType.R = "tile/R"
TileType.S = "tile/S"
TileType.T = "tile/T"
TileType.U = "tile/U"
TileType.V = "tile/V"
TileType.W = "tile/W"
TileType.X = "tile/X"
TileType.Y = "tile/Y"
TileType.Z = "tile/Z"
TileType.Blank = "tile/blank"

TileType.frequencies = {
  [ TileType.A ] = 9,
  [ TileType.B ] = 2,
  [ TileType.C ] = 2,
  [ TileType.D ] = 4,
  [ TileType.E ] = 12,
  [ TileType.F ] = 2,
  [ TileType.G ] = 3,
  [ TileType.H ] = 2,
  [ TileType.I ] = 9,
  [ TileType.J ] = 1,
  [ TileType.K ] = 1,
  [ TileType.L ] = 4,
  [ TileType.M ] = 2,
  [ TileType.N ] = 6,
  [ TileType.O ] = 8,
  [ TileType.P ] = 2,
  [ TileType.Q ] = 1,
  [ TileType.R ] = 6,
  [ TileType.S ] = 4,
  [ TileType.T ] = 6,
  [ TileType.U ] = 4,
  [ TileType.V ] = 2,
  [ TileType.W ] = 2,
  [ TileType.X ] = 1,
  [ TileType.Y ] = 2,
  [ TileType.Z ] = 1,
  [ TileType.Blank ] = 2
}

TileType.scores = {
  [ TileType.A ] = 1,
  [ TileType.B ] = 3,
  [ TileType.C ] = 3,
  [ TileType.D ] = 2,
  [ TileType.E ] = 1,
  [ TileType.F ] = 4,
  [ TileType.G ] = 2,
  [ TileType.H ] = 4,
  [ TileType.I ] = 1,
  [ TileType.J ] = 8,
  [ TileType.K ] = 5,
  [ TileType.L ] = 1,
  [ TileType.M ] = 3,
  [ TileType.N ] = 1,
  [ TileType.O ] = 1,
  [ TileType.P ] = 3,
  [ TileType.Q ] = 10,
  [ TileType.R ] = 1,
  [ TileType.S ] = 1,
  [ TileType.T ] = 1,
  [ TileType.U ] = 1,
  [ TileType.V ] = 4,
  [ TileType.W ] = 4,
  [ TileType.X ] = 8,
  [ TileType.Y ] = 3,
  [ TileType.Z ] = 10,
  [ TileType.Blank ] = 0
}

TileType.ScoreMode = {}
TileType.ScoreMode.Scrabble = "score/scrabble"
TileType.ScoreMode.Rank = "score/rank"

TileType.score = function(tileType)
  return TileType.scores[tileType]
end

TileType.Rank = {}
TileType.Rank.Bronze = 1
TileType.Rank.Silver = 2
TileType.Rank.Gold = 3

TileType.rank = function(tileType)
  local r = love.math.random()
  if r <= 0.5 then
    return TileType.Rank.Bronze
  end
  if r <= 0.833 then
    return TileType.Rank.Silver
  end

  return TileType.Rank.Gold
end

TileType.bomb = function(tileType)
  local r = love.math.random()
  if r > 0.95 then
    return true
  end
  return false
end

TileType.rankColour = function(rank)
  if rank == TileType.Rank.Bronze then
    return Colour.fromHex("#D88A58", 1)
  end

  if rank == TileType.Rank.Silver then
    return Colour.fromHex("#B9BFC2", 1)
  end

  if rank == TileType.Rank.Gold then
    return Colour.fromHex("#F6D409", 1)
  end
end

local function split(str, sep)
  local result = {}
  string.gsub(
    str,
    string.format("([^%s]+)", sep),
    function(c) table.insert(result, c) end
  )
  return result
end

TileType.letter = function(tileType)
  return split(tileType, "/")[2]
end

-- Please don't tell anyone how I live - Lenny
TileType.fromChar = function(char)

  if char == "a" then
    return TileType.A
  end

  if char == "b" then
    return TileType.B
  end

  if char == "c" then
    return TileType.C
  end

  if char == "d" then
    return TileType.D
  end

  if char == "e" then
    return TileType.E
  end

  if char == "f" then
    return TileType.F
  end

  if char == "g" then
    return TileType.G
  end

  if char == "h" then
    return TileType.H
  end

  if char == "i" then
    return TileType.I
  end

  if char == "j" then
    return TileType.J
  end

  if char == "k" then
    return TileType.K
  end

  if char == "l" then
    return TileType.L
  end

  if char == "m" then
    return TileType.M
  end

  if char == "n" then
    return TileType.N
  end

  if char == "o" then
    return TileType.O
  end

  if char == "p" then
    return TileType.P
  end

  if char == "q" then
    return TileType.Q
  end

  if char == "r" then
    return TileType.R
  end

  if char == "s" then
    return TileType.S
  end

  if char == "t" then
    return TileType.T
  end

  if char == "u" then
    return TileType.U
  end

  if char == "v" then
    return TileType.V
  end

  if char == "w" then
    return TileType.W
  end

  if char == "x" then
    return TileType.X
  end

  if char == "y" then
    return TileType.Y
  end

  if char == "z" then
    return TileType.Z
  end
end


return TileType
