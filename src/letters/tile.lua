local Colour = require "src.utils.colour"
local Shader = require "src.utils.shader"
local Mesh = require "src.utils.mesh"
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
  self.mesh = Mesh.generate(self.sprite.canvas, 50)
  self.scale = 1

  self.marked = false
  self.gathered = false

  self.shader = Shader.new("assets/tile.glsl")
  self.lineBoil = Shader.new("assets/boil.glsl")
  self.lineBoil:send("extraRandom", love.math.random())
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
  self.lineBoil:update(dt)
  self.elapsed = self.elapsed + dt
  if self.gathered then
    self.shader:send("totalTime", self.elapsed)
  end
  self.lineBoil:send("timeElapsed", self.elapsed)
end

function Tile:draw(x, y)
  love.graphics.push("all")

  if self.marked then
    -- TODO: Come up with "Marked Tile" state
    love.graphics.setColor(Tile.darkColour)
  end
  self.lineBoil:attach()
  -- Tile
  love.graphics.draw(
    self.mesh,
    x,
    y,
    0,
    self.scale,
    self.scale,
    self.sprite:getWidth() / 2,
    self.sprite:getHeight() / 2
  )
  self.lineBoil:detach()

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