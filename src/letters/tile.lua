local Colour = require "src.utils.colour"
local Shader = require "src.utils.shader"
local TileType = require "src.letters.tiletype"
local TileRank = require "src.letters.tilerank"
local TileSprite = require "src.letters.tilesprite"

local Tile = {}
Tile.__index = Tile

Tile.Size = 32
Tile.darkColour = Colour.fromBytes(32, 57, 79)

function Tile.new(tileType)
  local self = setmetatable({}, Tile)
  self.tileType = tileType
  self.rank = TileRank.rank()
  -- TODO: Consider placing these within the bag
  self.clear = TileType.isClearTile()

  if self.clear then
    self.sprite = TileSprite.clearTile(self.rank)
  else
    self.sprite = TileSprite.get(self.tileType, self.rank)
  end

  self.marked = false
  self.gathered = false

  self.scale = 1

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