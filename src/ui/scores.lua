local Plan = require "lib.plan"
local Container = Plan.Container

local Letter = require "src.letters.letter"
local TileRank = require "src.letters.tilerank"
local Scores = Container:extend()

function Scores:new(rules)
  local scores = Scores.super.new(self, rules)
  scores.score = 0
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
  self.score = self.score + TileRank.score(tile.rank)
end

function Scores:update(dt)
end

function Scores:draw()
  love.graphics.push("all")
  love.graphics.setCanvas(self.canvas)
  love.graphics.clear()
  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.print(self.score)
  love.graphics.pop()
  love.graphics.draw(self.canvas, self.x, self.y)
end

return Scores