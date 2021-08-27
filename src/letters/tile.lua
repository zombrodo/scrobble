local TileType = require "src.letters.tiletype"
local Fonts = require "src.utils.fonts"
local Colour = require "src.utils.colour"
local Shader = require "src.utils.shader"

local Tile = {}
Tile.__index = Tile

Tile.Size = 32

Tile.sprite = love.graphics.newImage("assets/tile.png")
Tile.outline = love.graphics.newImage("assets/tile_outline.png")
Tile.letterFont = Fonts.montserrat(25)
Tile.scoreFont = Fonts.montserrat(10)
Tile.textColor = Colour.fromBytes(32, 57, 79)

function Tile.new(tileType)
  local self = setmetatable({}, Tile)
  self.tileType = tileType
  self.letter = love.graphics.newText(
    Tile.letterFont,
    TileType.letter(tileType)
  )
  self.shouldOffsetScore = TileType.score(tileType) < 9
  self.score = love.graphics.newText(
    Tile.scoreFont,
    TileType.score(tileType)
  )
  self.marked = false
  self.gathered = false

  self.scale = 1
  self.letterScale = 1

  self.shader = Shader.new("assets/tile.glsl")

  self.elapsed = 0
  return self
end

function Tile:gather()
  self.gathered = true
  -- Flux.to(self, 0.99, { scale = 1.3 }):ease("backout")
end

function Tile:update(dt)
  self.shader:update(dt)
  if self.gathered then
    -- self.letterScale = math.max(self.scale * 0.75)
    self.elapsed = self.elapsed + dt
    self.shader:send("totalTime", self.elapsed)
  end
end

function Tile:draw(x, y)
  love.graphics.push("all")
  -- TODO: replace with sprites, and remove magic number trickery
  if self.marked then
    love.graphics.setColor(Tile.textColor)
  else
    love.graphics.setColor(1, 1, 1, 1)
  end
  -- Tile background
  love.graphics.draw(
    Tile.sprite,
    x,
    y,
    0,
    self.scale,
    self.scale,
    Tile.sprite:getWidth() / 2,
    Tile.sprite:getHeight() / 2
  )
  -- Tile Letter
  if self.marked then
    love.graphics.setColor(Colour.fromHex("#f6d6bd"))
  else
    love.graphics.setColor(Tile.textColor)
  end
  love.graphics.draw(self.letter,
    x + ((Tile.sprite:getWidth() / 3) + 2),
    y + ((Tile.sprite:getHeight() / 2) - 1),
    0, self.scale, self.scale,
    Tile.sprite:getWidth() / 2 + self.letter:getWidth() / 2,
    Tile.sprite:getHeight() / 2 + self.letter:getHeight() / 2)

  -- Score
  -- If we need to offset, then add 4 pixels, otherwise add nuthin'
  local offset = (self.shouldOffsetScore and 4) or 0

  love.graphics.draw(self.score,
    x + (Tile.sprite:getWidth() / 2) + 5 + offset,
    y + ((Tile.sprite:getHeight() / 2) + 2),
    0,
    self.scale,
    self.scale,
    Tile.sprite:getWidth() / 2,
    Tile.sprite:getHeight() / 2
  )


  if self.gathered then
  love.graphics.setShader(self.shader.shader)
  love.graphics.setColor(1, 1, 1, 0)
  -- Overlay for wipe effect
  love.graphics.draw(
    Tile.sprite,
    x,
    y,
    0,
    self.scale,
    self.scale,
    Tile.sprite:getWidth() / 2,
    Tile.sprite:getHeight() / 2
  )
  end

  love.graphics.pop()
end

return Tile