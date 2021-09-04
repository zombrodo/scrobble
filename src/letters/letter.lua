local String = require "src.utils.string"
local Sprite = require "src.utils.sprite"
local TileRank = require "src.letters.tilerank"

local Letter = {}

Letter.A = "letter/a"
Letter.B = "letter/b"
Letter.C = "letter/c"
Letter.D = "letter/d"
Letter.E = "letter/e"
Letter.F = "letter/f"
Letter.G = "letter/g"
Letter.H = "letter/h"
Letter.I = "letter/i"
Letter.J = "letter/j"
Letter.K = "letter/k"
Letter.L = "letter/l"
Letter.M = "letter/m"
Letter.N = "letter/n"
Letter.O = "letter/o"
Letter.P = "letter/p"
Letter.Q = "letter/q"
Letter.R = "letter/r"
Letter.S = "letter/s"
Letter.T = "letter/t"
Letter.U = "letter/u"
Letter.V = "letter/v"
Letter.W = "letter/w"
Letter.X = "letter/x"
Letter.Y = "letter/y"
Letter.Z = "letter/z"
Letter.Special = "letter/special"

Letter.char = {
  ["a"] = Letter.A,
  ["b"] = Letter.B,
  ["c"] = Letter.C,
  ["d"] = Letter.D,
  ["e"] = Letter.E,
  ["f"] = Letter.F,
  ["g"] = Letter.G,
  ["h"] = Letter.H,
  ["i"] = Letter.I,
  ["j"] = Letter.J,
  ["k"] = Letter.K,
  ["l"] = Letter.L,
  ["m"] = Letter.M,
  ["n"] = Letter.N,
  ["o"] = Letter.O,
  ["p"] = Letter.P,
  ["q"] = Letter.Q,
  ["r"] = Letter.R,
  ["s"] = Letter.S,
  ["t"] = Letter.T,
  ["u"] = Letter.U,
  ["v"] = Letter.V,
  ["w"] = Letter.W,
  ["x"] = Letter.X,
  ["y"] = Letter.Y,
  ["z"] = Letter.Z,
}

Letter.Frequencies = {
  [ Letter.A ] = 9,
  [ Letter.B ] = 2,
  [ Letter.C ] = 2,
  [ Letter.D ] = 4,
  [ Letter.E ] = 12,
  [ Letter.F ] = 2,
  [ Letter.G ] = 3,
  [ Letter.H ] = 2,
  [ Letter.I ] = 9,
  [ Letter.J ] = 1,
  [ Letter.K ] = 1,
  [ Letter.L ] = 4,
  [ Letter.M ] = 2,
  [ Letter.N ] = 6,
  [ Letter.O ] = 8,
  [ Letter.P ] = 2,
  [ Letter.Q ] = 1,
  [ Letter.R ] = 6,
  [ Letter.S ] = 4,
  [ Letter.T ] = 6,
  [ Letter.U ] = 4,
  [ Letter.V ] = 2,
  [ Letter.W ] = 2,
  [ Letter.X ] = 1,
  [ Letter.Y ] = 2,
  [ Letter.Z ] = 1,
}

function Letter.fromChar(char)
  return Letter.char[string.lower(char)]
end

function Letter.toChar(letter)
  return String.split(letter, "/")[2]
end

Letter.Spritesheets = {
  [TileRank.Bronze] = love.graphics.newImage("assets/bronze_tile.png"),
  [TileRank.Silver] = love.graphics.newImage("assets/silver_tile.png"),
  [TileRank.Gold]   = love.graphics.newImage("assets/gold_tile.png")
}

Letter.SpecialTiles = {
  [TileRank.Bronze] = love.graphics.newImage("assets/bronze_clear.png"),
  [TileRank.Silver] = love.graphics.newImage("assets/silver_clear.png"),
  [TileRank.Gold] = love.graphics.newImage("assets/gold_clear.png")
}

local alphabet = "abcdefghijklmnopqrstuvwxyz"
local halfway = 13

local function isFirstRow(letter)
  return string.find(alphabet, Letter.toChar(letter)) <= halfway
end

local function getIndex(letter)
  local index = string.find(alphabet, Letter.toChar(letter))
  if index > halfway then
    return index - halfway
  end
  return index
end

local function get(letter, rank, tileWidth, tileHeight)
  if letter == Letter.Special then
    return Sprite.new(Letter.SpecialTiles[rank])
  end

  local yOffset = 0
  if not isFirstRow(letter) then
    yOffset = tileHeight + 1
  end

  local spritesheet = Letter.Spritesheets[rank]
  local tileIndex = getIndex(letter) - 1
  local xOffset = tileIndex - 1

  local quad = love.graphics.newQuad(
    (tileIndex * tileWidth) + xOffset,
    yOffset,
    tileWidth,
    tileHeight,
    spritesheet
  )
  return Sprite.new(spritesheet, quad, tileWidth, tileHeight)
end

function Letter.sprite(letter, rank, tileWidth, tileHeight)
  return get(letter, rank, tileWidth, tileHeight)
end

return Letter