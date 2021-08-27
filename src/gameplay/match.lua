local Match = {}
Match.__index = Match

Match.Y = "y"
Match.X = "x"

function Match.new(word, index, direction, first, last)
  local self = setmetatable({}, Match)
  self.word = word
  self.index = index
  self.direction = direction
  self.first = first
  self.last = last
  return self
end

return Match
