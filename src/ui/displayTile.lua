local Letter = require "src.letters.letter"
local Tile = require "src.letters.tile"
local Shader = require "src.utils.shader"
local Mesh = require "src.utils.mesh"

local DisplayTile = {}
DisplayTile.__index = DisplayTile

function DisplayTile.new(letter, rank)
  local self = setmetatable({}, DisplayTile)
  self.letter = letter
  self.rank = rank
  self.scale = 2
  self.width = Tile.Width * self.scale
  self.height = Tile.Height * self.scale
  self.sprite, self.markedSprite = Letter.sprite(self.letter, self.rank, Tile.Width, Tile.Height)
  self.mesh = Mesh.generate(self.sprite.canvas, 50)
  self.markedMesh = Mesh.generate(self.markedSprite.canvas, 50)
  self.marked = false
  self.shader = Shader.new("assets/boil.glsl")
  self.shader:send("extraRandom", love.math.random())
  self.rot = 0
  self.timeElapsed = 0
  return self
end

function DisplayTile:mark()
  self.marked = true
end

function DisplayTile:unmark()
  self.marked = false
end

function DisplayTile:getWidth()
  return self.width
end

function DisplayTile:getHeight()
  return self.height
end

function DisplayTile:update(dt)
  self.shader:update(dt)
  self.timeElapsed = self.timeElapsed + dt
  self.shader:send("timeElapsed", self.timeElapsed)
end

function DisplayTile:draw(x, y)
  love.graphics.push("all")
  self.shader:attach()
  if self.marked then
    love.graphics.draw(self.markedMesh, x, y, self.rot, self.scale, self.scale)
  else
    love.graphics.draw(self.mesh, x, y, self.rot, self.scale, self.scale)
  end
  self.shader:detach()
  love.graphics.pop()
end

return DisplayTile