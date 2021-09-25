local SoundBank = require "src.utils.sound"

local SoundManager = {}
SoundManager.__index = SoundManager

function SoundManager.new()
  local self = setmetatable({}, SoundManager)
  self.soundBank = SoundBank.new()
  return self
end

function SoundManager:load(sound, tag)
  self.soundBank:load(sound, tag)
end

function SoundManager:receive(action, payload)
  if action == "tile.placement" then
    self.soundBank:play("tile.placement")
  end

  if action == "tile.gathered" then
    self.soundBank:play("tile.gathered", true)
  end

  if action == "word.found" then
    self.soundBank:play("word.found")
  end
end

return SoundManager