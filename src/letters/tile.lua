local Colour = require "src.utils.colour"
local Shader = require "src.utils.shader"

local Letter = require 'src.letters.letter'
local TileRank = require "src.letters.tilerank"

local Tile = {}
Tile.__index = Tile

Tile.Width = 32
Tile.Height = 32


Tile.darkColour = Colour.fromBytes(32, 57, 79)

function Tile.new(letter)
  local self = setmetatable({}, Tile)
  self.letter = letter
  self.rank = TileRank.rank()
  -- TODO: Consider placing these within the bag
  self.isSpecialTile = letter == Letter.Special

  self.sprite = Letter.sprite(self.letter, self.rank, Tile.Width, Tile.Height)
  self.scale = 1

  self.marked = false
  self.gathered = false

  self.shader = Shader.new("assets/tile.glsl")
  self.elapsed = 0
  return self
end

function Tile:gather()
  self.gathered = true
end

function Tile:mark()
  self.marked = true
end

function Tile:update(dt)
  self.shader:update(dt)
  if self.gathered then
    self.elapsed = self.elapsed + dt
    self.shader:send("totalTime", self.elapsed)
  end
end

function Tile:draw(x, y)
  love.graphics.push("all")

  if self.marked then
    -- TODO: Come up with "Marked Tile" state
    love.graphics.setColor(Tile.darkColour)
  end

  -- Tile
  self.sprite:draw(
    x,
    y,
    0,
    self.scale,
    self.scale,
    self.sprite:getWidth() / 2,
    self.sprite:getHeight() / 2
  )

  -- Overlay for wipe effect
  if self.gathered then
    love.graphics.setShader(self.shader.shader)
    love.graphics.setColor(1, 1, 1, 0)
    self.sprite:draw(
      x,
      y,
      0,
      self.scale,
      self.scale,
      self.sprite:getWidth() / 2,
      self.sprite:getHeight() / 2
    )
  end

  love.graphics.pop()
end

return Tile