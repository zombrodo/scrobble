local MinLength = {}
MinLength.__index = MinLength

function MinLength.new(newMin)
  local self = setmetatable({}, MinLength)
  self.old = 3
  self.amount = newMin
  return self
end

function MinLength:enable(game)
  self.old = game.minWordLength
  game.minWordLength = self.amount
end

function MinLength:disable(game)
  game.minWordLength = self.old
end

function MinLength:effectText()
  return "No words less than " .. self.amount .. " letters."
end

function MinLength:update(dt)
end

function MinLength:draw()
end

return MinLength