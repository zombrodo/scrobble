local Plan = require "lib.plan"
local Container = Plan.Container

local Math = require "src.utils.math"
local Fonts = require "src.utils.fonts"
local Sprite = require "src.utils.sprite"
local Mesh = require "src.utils.mesh"
local Shader = require "src.utils.shader"

local Button = Container:extend()

function Button:new(rules, text, onClick)
  local button = Button.super.new(self, rules)
  button.onClickHandler = onClick
  button.text = text
  button.textObj = love.graphics.newText(Fonts.wakuwaku(48), text)
  local sprite = Sprite.new(button.textObj)
  button.mesh = Mesh.generate(sprite.canvas, 50)
  button.shader = Shader.new("assets/boil.glsl")
  button.shader:send("extraRandom", love.math.random())
  button.scale = 1
  button.timeElapsed = 0
  return button
end

function Button:update(dt)
  Button.super.update(self, dt)
  local mouseX, mouseY = love.mouse.getPosition()
  if Math.inBounds(mouseX, mouseY, self.x, self.y, self.w, self.h) then
    self.scale = 1.3
  else
    self.scale = 1
  end
  self.timeElapsed = self.timeElapsed + dt
  self.shader:send("timeElapsed", self.timeElapsed)
end

function Button:onClick()
  self.onClickHandler()
end

function Button:draw()
  love.graphics.setColor(0, 0, 0, 1)
  self.shader:attach()
  love.graphics.draw(
    self.mesh,
    self.x + self.w / 2,
    self.y + self.h / 2,
    0,
    self.scale,
    self.scale,
    self.textObj:getWidth() / 2,
    self.textObj:getHeight() / 2
  )
  self.shader:detach()
end

return Button