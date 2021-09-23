local Match = {}
Match.__index = Match

Match.Y = "y"
Match.X = "x"

function Match.new(word, index, direction, first, last)
  local self = setmetatable({}, Match)
  self.word = word
  self.length = #word
  self.index = index
  self.direction = direction
  self.first = first
  self.last = last
  self.ranks = {}
  return self
end

function Match:equals(other)
  return self.word == other.word
    and self.index == other.index
    and self.direction == other.direction
    and self.first == other.first
    and self.last == other.last
end

function Match:remove(x, y, tile)
  if self.direction == "x" then
    self.ranks[(self.last - x) + 1] = tile.rank
    if x >= self.first and x <= self.last then
      self.length = self.length - 1
    end
  end
  if self.direction == "y" then
    print("y index", self.first - y)
    self.ranks[(self.last - y) + 1] = tile.rank
    if y >= self.first and y <= self.last then
      self.length = self.length - 1
    end
  end
end

function Match:isCleared()
  return self.length == 0
end

return Match
