local Shader = {}
Shader.__index = Shader

local function lastModified(filePath)
  local info = love.filesystem.getInfo(filePath, "file")
  return info.modtime
end

function Shader.new(shaderPath)
  local self = setmetatable({}, Shader)
  self.watch = {
    [shaderPath] = lastModified(shaderPath),
  }
  self.shaderPath = shaderPath
  self.shader = love.graphics.newShader(shaderPath)
  return self
end

function Shader:changes()
  return self.watch[self.shaderPath] ~= lastModified(self.shaderPath)
end

function Shader:swap()
  local status, message = love.graphics.validateShader(
    false, self.shaderPath
  )

  if status then
    self.shader = love.graphics.newShader(self.shaderPath)
    self.watch[self.shaderPath] = lastModified(self.shaderPath)
    return true
  end

  print(message)
  return false
end

function Shader:update(dt)
  if self:changes() then
    return self:swap()
  end
  return false
end

function Shader:attach()
  love.graphics.setShader(self.shader)
end

function Shader:detach()
  love.graphics.setShader()
end

function Shader:send(variable, value)
  self.shader:send(variable, value)
end

return Shader