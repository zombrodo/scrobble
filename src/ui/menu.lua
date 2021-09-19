local Math = require "src.utils.math"
local EvenlySpaced = require "src.utils.spaced"

local Menu = {}
Menu.__index = Menu

function Menu.new(rules)
  local self = setmetatable({}, Menu)
  self.container = nil
  self.containerRules = rules
  self.buttons = {}
  return self
end

function Menu:addItem(item)
  table.insert(self.buttons, item)
  self:refreshContainer()
end

function Menu:addItems(items)
  for _, item in ipairs(items) do
    table.insert(self.buttons, item)
  end
  self:refreshContainer()
end

function Menu:refreshContainer()
  self.container = EvenlySpaced.vertical(self.containerRules, self.buttons, 2)
end

function Menu:getContainer()
  return self.container
end

function Menu:onClick(x, y)
  for _, button in ipairs(self.buttons) do
    if Math.inBounds(x, y, button.x, button.y, button.w, button.h) then
      button:onClick()
    end
  end
end

return Menu