local Shader = {}
Shader.__index = Shader

local function lastModified(filePath)
  local info = love.filesystem.getInfo(filePath, "file")
  return info.modtime
end

function Shader.new(pixelPath)
  local self = setmetatable({}, Shader)
  self.watch = {
    [pixelPath] = lastModified(pixelPath),
  }
  self.pixelPath = pixelPath
  self.shader = love.graphics.newShader(pixelPath)
  return self
end

function Shader:changes()
  return self.watch[self.pixelPath] ~= lastModified(self.pixelPath)
end

function Shader:swap()
  local status, message = love.graphics.validateShader(
    false, self.pixelPath
  )

  if status then
    self.shader = love.graphics.newShader(self.pixelPath)
    self.watch[self.pixelPath] = lastModified(self.pixelPath)
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

function Shader:send(variable, value)
  self.shader:send(variable, value)
end

return Shader