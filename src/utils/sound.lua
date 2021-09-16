local SoundBank = {}
SoundBank.__index = SoundBank

function SoundBank.new()
  local self = setmetatable({}, SoundBank)
  self.sounds = {}
  return self
end

function SoundBank:load(sound, tag)
  local source = love.audio.newSource(sound, "static")
  self.sounds[tag] = source
end

function SoundBank:play(tag, shouldPlayIfAlreadyPlaying)
  if self.sounds[tag]:isPlaying() and shouldPlayIfAlreadyPlaying then
    self.sounds[tag]:clone():play()
  else
    self.sounds[tag]:play()
  end
end

function SoundBank:stop(tag)
  self.sounds[tag]:stop()
end

return SoundBank