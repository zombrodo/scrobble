local Trie = require "src.utils.trie"
local Letter = require "src.letters.letter"

local Dictionary = {}
Dictionary.__index = Dictionary

local function frequencies(word)
  local result = {}
  for c in word:gmatch(".") do
    if result[c] == nil then
      result[c] = 0
    end
    result[c] = result[c] + 1
  end
  return result
end

local function validWord(word)
  local freqs = frequencies(word)
  for c in word:gmatch(".") do
    if freqs[c] > Letter.Frequencies[Letter.fromChar(c)] then
      return false
    end
  end
  return true
end

function Dictionary.new(minLength, maxLength)
  local self = setmetatable({}, Dictionary)
  self.maxLength = maxLength or 7
  self.minLength = minLength or 3
  self.trie = nil
  return self
end

function Dictionary:load(path)
  local i = 0
  self.trie = Trie.new()
  for word in love.filesystem.lines(path) do
    if #word <= self.maxLength
      and #word >= self.minLength
      and validWord(word)
    then
      self.trie:insert(word)
      i = i + 1
    end
  end

  print("Dictionary Loaded: ", i, "words")
  print("Trie Words:", self.trie.wordCount)
  print("Trie Nodes:", self.trie.nodeCount)
end

function Dictionary:check(word)
  return self.trie:search(word)
end

return Dictionary
