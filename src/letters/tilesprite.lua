local TileSprite = {}

local TileType = require "src.letters.tiletype"
local TileRank = require "src.letters.tilerank"

local alphabet = string.upper("abcdefghijklmnopqrstuvwxyz")

local function tileSheetIndex(tileType)
  local result = string.find(alphabet, TileType.letter(tileType))
  if result > 13 then
    return result - 13
  end

  return result
end

local function onTopRow(tileType)
  return string.find(alphabet, TileType.letter(tileType)) <= 13
end

TileSprite.SpriteSheets = {
  [TileRank.Bronze] = love.graphics.newImage("assets/bronze_tile.png"),
  [TileRank.Silver] = love.graphics.newImage("assets/silver_tile.png"),
  [TileRank.Gold] = love.graphics.newImage("assets/gold_tile.png")
}

-- Internal Sprite Object that abstracts away from quads vs images.

local Sprite = {}
Sprite.__index = Sprite

function Sprite.new(spritesheet, quad)
  local self = setmetatable({}, Sprite)
  self.spritesheet = spritesheet
  self.quad = quad
  return self
end

function Sprite:draw(x, y, r, sx, sy, ox, oy)
  if self.quad then
    love.graphics.draw(self.spritesheet, self.quad, x, y, r, sx, sy, ox, oy)
  else
    love.graphics.draw(self.spritesheet, x, y, r, sx, sy, ox, oy)
  end
end

function Sprite:getWidth()
  if self.quad then
    return 32
  end

  return self.spritesheet:getWidth()
end

function Sprite:getHeight()
  if self.quad then
    return 32
  end

  return self.spritesheet:getHeight()
end


-- tileSize is 33
-- each tile has a 1px gap, right, and bottom

local tileHeight = 32 -- TODO: shift this somewhere else.
local tileWidth = 33

function TileSprite.get(tileType, tileRank)
  local yOffset = 0
  if not onTopRow(tileType) then
    yOffset = tileHeight
  end

  local spritesheet = TileSprite.SpriteSheets[tileRank]
  local tileIndex = tileSheetIndex(tileType) - 1
  local xOffset = (tileIndex - 1)

  return Sprite.new(
    spritesheet,
    love.graphics.newQuad(
      (tileIndex * tileWidth) + xOffset,
      yOffset,
      tileWidth,
      tileHeight,
      spritesheet
    ))
end

TileSprite.ClearTiles = {
  [TileRank.Bronze] = love.graphics.newImage("assets/bronze_clear.png"),
  [TileRank.Silver] = love.graphics.newImage("assets/silver_clear.png"),
  [TileRank.Gold] = love.graphics.newImage("assets/gold_clear.png")
}

function TileSprite.clearTile(tileRank)
  return Sprite.new(TileSprite.ClearTiles[tileRank ])
end

return TileSprite