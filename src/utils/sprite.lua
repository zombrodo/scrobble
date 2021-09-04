local Sprite = {}
Sprite.__index = Sprite

function Sprite.new(sprite, quad, qw, qh)
  local self = setmetatable({}, Sprite)
  self.sprite = sprite
  self.quad = quad
  self.qh = qh
  self.qw = qw
  return self
end

function Sprite:draw(x, y, r, sx, sy, ox, oy)
  if self.quad then
    love.graphics.draw(self.sprite, self.quad, x, y, r, sx, sy, ox, oy)
  else
    love.graphics.draw(self.sprite, x, y, r, sx, sy, ox, oy)
  end
end

function Sprite:getWidth()
  if self.quad then
    return self.qw
  end
  return self.sprite:getWidth()
end

function Sprite:getHeight()
  if self.quad then
    return self.qh
  end
  return self.sprite:getHeight()
end

return Sprite