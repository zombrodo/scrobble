local MinLength = require "src.gameplay.effects.minlength"

local Effect = {}
Effect.__index = Effect

function Effect.new(game)
  local self = setmetatable({}, Effect)
  self.game = game
  self.currentEffect = nil

  self.cooldown = 90
  self.runtime = 30
  self.canSpawn = false
  self.currentTimer = 0
  return self
end

function Effect:isEffectRunning()
  return self.currentEffect ~= nil
end

function Effect:effectText()
  return self.currentEffect:effectText()
end

function Effect:spawn()
  if self.currentEffect ~= nil then
    return
  end
  -- TODO: Replace with more
  local newEffect = MinLength.new(4)
  newEffect:enable(self.game)
  self.currentEffect = newEffect
  self.canSpawn = false
end

function Effect:expire()
  if self.currentEffect == nil then
    return
  end

  self.currentEffect:disable(self.game)
  self.currentEffect = nil
end

function Effect:receive(action, payload)
  if action == "effect.spawn" then
    if not payload and self.canSpawn then
      self:spawn()
    end
    -- TODO: Handle chosen effects
  end
end

function Effect:update(dt)
  if self.canSpawn == false then
    self.currentTimer = self.currentTimer + dt
    if self.currentEffect and self.currentTimer >= self.runtime then
      print("Effect Complete!")
      self:expire()
    end

    if self.currentTimer >= self.cooldown then
      print("Allowing Effects to spawn again  ")
      self.canSpawn = true
      self.currentTimer = 0
    end
  end
end

function Effect:draw()
end

return Effect
