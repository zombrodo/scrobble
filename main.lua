love.graphics.setDefaultFilter("nearest", "nearest")

GAME_WIDTH = 1280
GAME_HEIGHT = 720

Tick = require "lib.tick"
Flux = require "lib.flux"

local Roomy = require "lib.roomy"

local GameScene = require "src.scenes.game"
local DebugScene = require "src.scenes.debug"
local MenuScene = require "src.scenes.menu"

local Colour = require "src.utils.colour"
SceneManager = nil

local mainCanvas

function love.load()
  mainCanvas = love.graphics.newCanvas(GAME_WIDTH, GAME_HEIGHT)
  SceneManager = Roomy.new()
  SceneManager:hook({exclude = { "draw" }})
  SceneManager:enter(MenuScene.new())
end

function love.update(dt)
  Tick.update(dt)
  Flux.update(dt)
end

function love.draw()
  love.graphics.clear(0, 0, 0)
  love.graphics.push("all")
  love.graphics.setCanvas(mainCanvas)
  love.graphics.clear(Colour.fromHex("#f6d2ac"))
  SceneManager:emit("draw")
  love.graphics.pop()
  local scale = math.floor(math.min(
    love.graphics.getHeight() / mainCanvas:getHeight(),
    love.graphics.getWidth() / mainCanvas:getWidth()
  ) + 0.5)
  love.graphics.draw(
    mainCanvas,
    love.graphics.getWidth() / 2,
    love.graphics.getHeight() / 2,
    0,
    scale,
    scale,
    mainCanvas:getWidth() / 2,
    mainCanvas:getHeight() / 2
  )
end