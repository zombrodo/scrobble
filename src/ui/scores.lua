local Plan = require "lib.plan"
local Container = Plan.Container

local Fonts = require "src.utils.fonts"
local Colour = require "src.utils.colour"
local Letter = require "src.letters.letter"
local TileRank = require "src.letters.tilerank"
local TileWord = require 'src.ui.tileword'

local Scores = Container:extend()

Scores.heading = Fonts.wakuwaku(16)
Scores.value = Fonts.wakuwaku(21)
Scores.colour = Colour.fromHex("#2E2E2E")

function Scores:new(rules)
  local scores = Scores.super.new(self, rules)
  scores.score = 0
  scores.words = {}
  scores.wordsCleared = 0

  scores.longestWord = nil
  scores.longestLength = -math.huge

  -- headings
  scores.scoreText = love.graphics.newText(Scores.heading, "score:")
  scores.comboText = love.graphics.newText(Scores.heading, "combo:")
  scores.wordsText = love.graphics.newText(Scores.heading, "words cleared:")
  scores.lastWordsText = love.graphics.newText(Scores.heading, "last words:")
  scores.longestText = love.graphics.newText(Scores.heading, "longest word:")
  scores.highScoreText = love.graphics.newText(Scores.heading, "high score:")

  scores.comboTilesGathered = 0
  scores.comboAmount = 1

  return scores
end

function Scores:reset()
  self.score = 0
end

function Scores:refresh()
  Scores.super.refresh(self)
  self.canvas = love.graphics.newCanvas(self.w, self.h)
end

function Scores:send(tile)
  self.score = self.score + (TileRank.score(tile.rank) * self.comboAmount)
end

function Scores:addWord(match)
  table.insert(self.words, TileWord.new(match.word, match.ranks))
  self.wordsCleared = self.wordsCleared + 1
  if #match.word > self.longestLength then
    self.longestLength = #match.word
    self.longestWord = match.word
  end
end

function Scores:receive(action, payload)
  if action == "cursor.end" then
    if self.comboTilesGathered > 5 then
      print("Adding 1 to Combo")
      self.comboAmount = self.comboAmount + 1
    else
      print("C-c-combo breaker")
      self.comboAmount = 1
    end

    self.comboTilesGathered = 0
  end

  if action == "tile.gathered" then
    self.comboTilesGathered = self.comboTilesGathered + 1
  end
end

function Scores:update(dt)
  for i, word in ipairs(self.words) do
    word:update(dt)
  end
end

local function pad(score, n)
  local amount = n - #tostring(score)
  return string.rep("0", amount) .. score
end

function Scores:draw()
  love.graphics.push("all")
  love.graphics.setCanvas(self.canvas)
  love.graphics.clear()
  love.graphics.setColor(Scores.colour)
  local currentY = 0
  -- Score
  love.graphics.draw(self.scoreText)
  currentY = currentY + self.scoreText:getHeight()
  love.graphics.print(pad(self.score, 6), Scores.value, 5, currentY + 3)
  currentY = currentY + Scores.value:getHeight() + 3
  -- Combo
  love.graphics.draw(self.comboText, 0, currentY + 5)
  currentY = currentY + Scores.heading:getHeight() + 5
  love.graphics.print("x" .. self.comboAmount, Scores.value, 5, currentY + 3)
  currentY = currentY + Scores.value:getHeight() + 3
  -- Previous Cleared
  love.graphics.draw(self.wordsText, 0, currentY + 5)
  currentY = currentY + Scores.heading:getHeight() + 5
  currentY = currentY + 3
  love.graphics.setColor(1, 1, 1, 1)
  if #self.words > 0 then
    for i = #self.words, #self.words - math.min(self.wordsCleared - 1, 4), -1 do
      self.words[i]:draw(5, currentY)
      currentY = currentY + 20
    end
  end
  love.graphics.pop()
  love.graphics.draw(self.canvas, self.x, self.y)
end

return Scores