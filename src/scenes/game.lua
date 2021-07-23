local GameScene = {}
GameScene.__index = GameScene

function GameScene.new()
  local self = setmetatable({}, GameScene)
  return self
end

function GameScene:enter()
end

function GameScene:update(dt)

end

function GameScene:draw()
  love.graphics.push("all")
  love.graphics.pop()
end

return GameScene