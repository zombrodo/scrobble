local Plan = require "lib.plan"
local Container = Plan.Container

local Letter = require "src.letters.letter"
local StringUtils = require "src.utils.string"
local TileRank = require "src.letters.tilerank"
local DisplayTile = require "src.ui.displayTile"

local Title = Container:extend()

local function getRank(index)
  local order = ((index - 1) % 3) + 1
  if order == 1 then
    return TileRank.Bronze
  end

  if order == 2 then
    return TileRank.Silver
  end

  if order == 3 then
    return TileRank.Gold
  end
end

local function asDisplayTiles(text)
  local sprites = {}
  for i, char in ipairs(StringUtils.tokens(text)) do
    table.insert(sprites, DisplayTile.new(Letter.fromChar(char), getRank(i)))
  end
  return sprites
end

local function markRandomTiles(tiles)
  for i, tile in ipairs(tiles) do
    if love.math.random() > 0.6 then
      tile:mark()
    else
      tile:unmark()
    end
  end
end

local function startTilePicker(tiles)
  Tick.recur(function() markRandomTiles(tiles) end, 1.5)
end

function Title:new(rules, text)
  local title = Title.super.new(self, rules)
  title.tiles = asDisplayTiles(text)
  title.width = 0
  for i, tile in ipairs(title.tiles) do
    title.width = title.width + tile:getWidth()
  end
  title.gutter = 5
  title.width = title.width + (#title.tiles * title.gutter)
  title.height = title.tiles[1]:getHeight()

  -- markRandomTiles(title.tiles)
  -- startTilePicker(title.tiles)

  return title
end

function Title:getWidth()
  return self.width
end

function Title:getHeight()
  return self.height
end

function Title:update(dt)
  Title.super.update(self, dt)
  for i, tile in ipairs(self.tiles) do
    tile:update(dt)
  end
end

function Title:draw()
  Title.super.draw(self)
  local x = self.x
  local y = self.y
  for i, tile in ipairs(self.tiles) do
    tile:draw(x, y)
    x = (x + tile:getWidth()) + self.gutter
  end
end

return Title