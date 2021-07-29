local TileType = require "src.tiletype"
local Fonts = require "src.utils.fonts"

local Tile = {}
Tile.__index = Tile

Tile.Size = 32

Tile.sprite = love.graphics.newImage("assets/tile.png")
Tile.letterFont = Fonts.montserrat(25)
Tile.scoreFont = Fonts.montserrat(10)
Tile.textColor = { love.math.colorFromBytes(32, 57, 79) }

function Tile.new(tileType)
  local self = setmetatable({}, Tile)
  self.tileType = tileType
  self.letter = love.graphics.newText(
    Tile.letterFont,
    TileType.letter(tileType)
  )
  self.scoreOffset = TileType.score(tileType) < 9
  self.score = love.graphics.newText(
    Tile.scoreFont,
    TileType.score(tileType)
  )
  self.marked = false
  self.gathered = false

  self.scale = 1

  return self
end

function Tile:update(dt)
end

function Tile:draw(x, y)
  love.graphics.push("all")
  -- Reader beware: If you're reading this, then I haven't swapped out the
  -- generated tiles with sprite-based ones.
  -- In that case, I _swear_ I don't normally use so many magic numbers!
  -- FIXME: swap with sprites
  if self.marked then
    love.graphics.setColor(1, 1, 1, 0.3)
  else
    love.graphics.setColor(1, 1, 1, 1)
  end

  love.graphics.draw(Tile.sprite, x, y, 0, self.scale, self.scale)
  love.graphics.setColor(Tile.textColor)
  love.graphics.draw(self.letter,
    x + ((Tile.sprite:getWidth() / 3) + 2),
    y + ((Tile.sprite:getHeight() / 2) - 1),
    0, self.scale, self.scale,
    self.letter:getWidth() / 2,
    self.letter:getHeight() / 2)

  -- If we need to offset, then add 4 pixels, otherwise add nuthin'
  local offset = (self.scoreOffset and 4) or 0

  love.graphics.draw(self.score,
    x + (Tile.sprite:getWidth() / 2) + 5 + offset,
    y + ((Tile.sprite:getHeight() / 2) + 2), 0, self.scale, self.scale
  )
  love.graphics.pop()
end

return Tile