local Plan = require "lib.plan"
local Container = Plan.Container
local Rules = Plan.Rules

local Title = require "src.ui.title"
local Menu = require "src.ui.menu"
local Button = require "src.ui.button"

local GameScene = require "src.scenes.game"

local MenuScene = {}
MenuScene.__index = MenuScene

function MenuScene.new()
  local self = setmetatable({}, MenuScene)
  return self
end

function MenuScene:enter()
  self.ui = Plan.new()
  local gutter = Container:new(Plan.RuleFactory.pixelGutter(20))
  local topHalf = Container:new(Plan.RuleFactory.half("top"))
  -- Title
  local titleRules = Rules.new()
    :addX(Plan.center())
    :addY(Plan.center())
    :addWidth(Plan.auto())
    :addHeight(Plan.auto())

  local title = Title:new(titleRules, "wordfall")
  topHalf:addChild(title)
  gutter:addChild(topHalf)
  -- Buttons
  local bottomHalf = Container:new(Plan.RuleFactory.half("bottom"))

  local menuRules = Rules.new()
    :addX(Plan.center())
    :addY(Plan.pixel(0))
    :addWidth(Plan.relative(0.2))
    :addHeight(Plan.relative(0.8))

  local menu = Menu.new(menuRules)

  local buttonRules = Rules.new()
    :addX(Plan.center())
    :addY(Plan.pixel(0))
    :addWidth(Plan.pixel(300))
    :addHeight(Plan.pixel(60))

  local playButton = Button:new(buttonRules, "play", function() SceneManager:enter(GameScene.new()) end)
  local optionsButton = Button:new(buttonRules, "options", function() end)
  local aboutButton = Button:new(buttonRules, "about", function() end)
  local quitButton = Button:new(buttonRules, "quit", function() end)

  menu:addItems({
    playButton, optionsButton, aboutButton, quitButton
  })

  self.menu = menu
  bottomHalf:addChild(menu:getContainer())
  gutter:addChild(bottomHalf)
  self.ui:addChild(gutter)
end

function MenuScene:update(dt)
  self.ui:update(dt)
end

function MenuScene:draw()
  love.graphics.push("all")
  self.ui:draw()
  love.graphics.pop()
end

function MenuScene:keypressed(key, scanCode)

end

function MenuScene:mousepressed(x, y, button)
  if button == 1 then
    self.menu:onClick(x, y)
  end
end

return MenuScene