local Plan = require "lib.plan"
local Container = Plan.Container
local Rules = Plan.Rules

local Letter = require "src.letters.letter"
local StringUtils = require "src.utils.string"
local TileRank = require "src.letters.tilerank"
local Tile = require "src.letters.tile"

local Title = Container:extend()

local function asTileSprites(text)
  local sprites = {}
  for i, char in ipairs(StringUtils.tokens(text)) do
    local sprite, _ = Letter.sprite(
      Letter.fromChar(char), TileRank.Bronze, Tile.Width, Tile.Height
    )
    table.insert(sprites, sprite)
  end
  return sprites
end

function Title:new(rules, text)
  local title = Title.super.new(self, rules)
  title.sprites = asTileSprites(text)
  title.width = 0
  for i, sprite in ipairs(title.sprites) do
    title.width = title.width + sprite:getWidth()
  end
  title.width = title.width + (#title.sprites * 5)
  title.height = title.sprites[1]:getWidth()
  return title
end

function Title:getWidth()
  return self.width
end

function Title:getHeight()
  return self.height
end

function Title:draw()
  Title.super.draw(self)
  local x = self.x
  local y = self.y
  for i, sprite in ipairs(self.sprites) do
    sprite:draw(x, y)
    x = (x + sprite:getWidth()) + 5
  end
end

return Title