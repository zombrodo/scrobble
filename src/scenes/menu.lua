local Plan = require "lib.plan"
local Container = Plan.Container
local Rules = Plan.Rules

local Title = require "src.ui.title"

local MenuScene = {}
MenuScene.__index = MenuScene

function MenuScene.new()
  local self = setmetatable({}, MenuScene)
  return self
end

function MenuScene:enter()
  self.ui = Plan.new()

  local titleRules = Rules.new()
    :addX(Plan.center())
    :addY(Plan.center())
    :addWidth(Plan.auto())
    :addHeight(Plan.auto())

  self.title = Title:new(titleRules, "scrobble")
  self.ui:addChild(self.title)
end

function MenuScene:update(dt)
  self.ui:update(dt)
end

function MenuScene:draw()
  love.graphics.push("all")
  self.ui:draw()
  love.graphics.pop()
end

return MenuScene