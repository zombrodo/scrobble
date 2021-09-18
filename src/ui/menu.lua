local Plan = require "lib.plan"
local Container = Plan.Container

local Menu = Container:extend()

function Menu:new(rules)
  local menu = Menu.super.new(self, rules)
  return menu
end

return Menu