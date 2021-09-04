local Plan = require "lib.plan"
local Container = Plan.Container

local Tile = require "src.letters.tile"
local Colour = require "src.utils.colour"

local UpNext = Container:extend()

local tileGroupHeight = Tile.Height * 2

function UpNext:new(rules, bag)
  local upNext = UpNext.super.new(self, rules)
  upNext.colour = Colour.fromBytes(246, 214, 189)
  upNext.shader = love.graphics.newShader("assets/fade.glsl")
  upNext.bag = bag

  -- Transition vars
  upNext.yOffset = 0
  upNext.yOffsetMax = 80

  return upNext
end

function UpNext:refresh()
  UpNext.super.refresh(self)
  self.canvas = love.graphics.newCanvas(self.w, self.h)
end

function UpNext:complete()
  self.bag:shift()
  self.yOffset = 0
end

function UpNext:shift()
  local s = self
  Flux.to(self, 0.2, { yOffset = self.yOffsetMax })
    :oncomplete(function() s.complete(s) end)
end

function UpNext:draw()
  love.graphics.push("all")
  local currentCanvas = love.graphics.getCanvas()
  love.graphics.setCanvas(self.canvas)
  love.graphics.clear()
  for i = 0, 4 do
    self.bag:getUpNext(i)
      :draw(Tile.Width / 2, ((i * tileGroupHeight) + (i * Tile.Height / 2) + Tile.Height / 2) - self.yOffset, 0, 0)
  end
  love.graphics.setCanvas(currentCanvas)
  love.graphics.setShader(self.shader)
  love.graphics.draw(self.canvas, self.x, self.y)
  love.graphics.setShader()
  love.graphics.pop()
end

return UpNext