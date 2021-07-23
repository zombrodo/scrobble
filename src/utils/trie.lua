local TrieNode = {}
TrieNode.__index = TrieNode

local alphabet = "abcdefghijklmnopqrstuvwxyz"

local function getIndex(token)
  local index = 1
  for char in alphabet:gmatch(".") do
    index = index + 1
    if char == token then
      return index
    end
  end
  return -1
end

function TrieNode.new()
  local self = setmetatable({}, TrieNode)
  self.children = {}
  self.isEnd = false
  return self
end

function TrieNode:get(c)
  return self.children[getIndex(c)]
end

function TrieNode:add(c)
  self.children[getIndex(c)] = TrieNode.new()
end

local Trie = {}
Trie.__index = Trie

function Trie.new()
  local self = setmetatable({}, Trie)
  self.root = TrieNode.new()
  self.wordCount = 0
  self.nodeCount = 0
  return self
end

function Trie:insert(word)
  local node = self.root
  for char in word:gmatch(".") do
    if node:get(char) == nil then
      node:add(char)
      self.nodeCount = self.nodeCount + 1
    end

    node = node:get(char)
  end

  node.isEnd = true
  self.wordCount = self.wordCount + 1
end

function Trie:search(word)
  local node = self.root
  for char in word:gmatch(".") do
    if node:get(char) == nil then
      return false
    end
    node = node:get(char)
  end

  return node.isEnd
end

return Trie
