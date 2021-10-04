local Plan = require "lib.plan"
local Container = Plan.Container
local Rules = Plan.Rules

local Bag = require "src.gameplay.bag"

local TileRank = require "src.letters.tilerank"

local Title = require "src.ui.title"
local Menu = require "src.ui.menu"
local Button = require "src.ui.button"
local DisplayTile = require "src.ui.displayTile"

local GameScene = require "src.scenes.game"

local MenuScene = {}
MenuScene.__index = MenuScene

function MenuScene.new()
  local self = setmetatable({}, MenuScene)
  self.canvas = love.graphics.newCanvas(
    love.graphics.getWidth(),
    love.graphics.getHeight()
  )
  self.bag = Bag.new()
  self.fallingLetters = {}
  return self
end

local function bind(obj, fn)
  return function(...) return obj[fn](obj, ...) end
end

local scales = { 0.5, 1, 1.5, 2, 2.5 }

function MenuScene:spawnTile()
  local x = love.math.random(love.graphics.getWidth())
  local y = -64
  local scale = scales[love.math.random(#scales)]
  local speed = love.math.random(20, 70)
  speed = speed * scale

  local tile = {
    x = x,
    y = y,
    speed = speed,
    tile = DisplayTile.new(self.bag:nextTile(true), TileRank.rank(), scale),
  }

  local timer = Tick.recur(function() tile.y = tile.y + tile.tile:getHeight() end, 0.8)

  tile.timer = timer

  table.insert(self.fallingLetters, tile)


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
  local quitButton = Button:new(buttonRules, "quit", function() end)

  menu:addItems({
    playButton, optionsButton, quitButton
  })

  self.menu = menu
  bottomHalf:addChild(menu:getContainer())
  gutter:addChild(bottomHalf)
  self.ui:addChild(gutter)

  local spawn = bind(self, "spawnTile")
  Tick.recur(spawn, 0.25)
end

function MenuScene:update(dt)
  self.ui:update(dt)
  local toRemove = {}
  for i, group in ipairs(self.fallingLetters) do
    -- group.tile:update(dt)
    -- group.y = group.y + group.speed * dt
    if group.y > love.graphics.getHeight() then
      table.insert(toRemove, i)
    end
  end

  if #toRemove > 0 then
    for i, index in ipairs(toRemove) do
      table.remove(self.fallingLetters, index)
    end
  end
end

function MenuScene:draw()
  love.graphics.push("all")
  local currentCanvas = love.graphics.getCanvas()
  love.graphics.setCanvas(self.canvas)
  love.graphics.clear()
  for i, tile in ipairs(self.fallingLetters) do
    tile.tile:draw(tile.x, tile.y)
  end
  love.graphics.setCanvas(currentCanvas)
  love.graphics.setColor(1, 1, 1, 0.3)
  love.graphics.draw(self.canvas)
  love.graphics.setColor(1, 1, 1, 1)
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