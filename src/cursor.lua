local Cursor = {}
Cursor.__index = Cursor

function Cursor.new(startX, endX)
  local self = setmetatable({}, Cursor)
  self.startX = startX
  self.currentX = startX
  self.endX = endX
  self.speed = 100
  return self
end

function Cursor:update(dt)
  self.currentX = self.currentX + self.speed * dt
  if self.currentX >= self.endX then
    self.currentX = self.startX
  end
end

function Cursor:getColumn(cellSize)
  return math.floor((self.currentX - self.startX) / cellSize)
end

function Cursor:draw()
  love.graphics.push("all")
  love.graphics.line(self.currentX, 128, self.currentX, GAME_HEIGHT - 128)
  love.graphics.pop()
end

return Cursor