-- TODO: Match this code up with Title, since they're basically the same.
local String = require "src.utils.string"
local DisplayTile = require "src.ui.displayTile"
local Letter = require "src.letters.letter"
local TileRank = require "src.letters.tilerank"


local TileWord = {}
TileWord.__index = TileWord

local function asDisplayTiles(text, ranks)
  local sprites = {}
  for i, char in ipairs(String.tokens(text)) do
    print(text, ranks[i])
    local tile = DisplayTile.new(Letter.fromChar(char), ranks[i], 0.5)
    table.insert(sprites, tile)
  end
  return sprites
end

function TileWord.new(text, ranks)
  local self = setmetatable({}, TileWord)
  self.text = text
  self.tiles = asDisplayTiles(text, ranks)
  self.toShow = 5
  return self
end

function TileWord:update(dt)
  for i, tile in ipairs(self.tiles) do
    tile:update(dt)
  end
end

function TileWord:draw(x, y)
  love.graphics.push("all")
  for i, tile in ipairs(self.tiles) do
    tile:draw(x, y)
    x = (x + tile:getWidth())
  end
  love.graphics.pop()
end

return TileWord