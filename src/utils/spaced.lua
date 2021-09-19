local Plan = require "lib.plan"
local Container = Plan.Container
local Rules = Plan.Rules

local EvenlySpaced = {}

function EvenlySpaced.horizontal(rules, items, gutter)
  gutter = gutter or 0
  local numItems = #items
  local rootContainer = Container:new(rules)
  for i, item in ipairs(items) do
    local itemContainer = Container:new(
      Rules.new()
        :addX(Plan.relative((i - 1) * (1 / #numItems)))
        :addY(Plan.pixel(0))
        :addWidth(Plan.relative(1 / #numItems))
        :addHeight(Plan.parent())
    )

    item.rules:addX(Plan.pixel(gutter))
      :addY(Plan.pixel(gutter))
      :addWidth(Plan.max(gutter * 2))
      :addHeight(Plan.max(gutter * 2))

    itemContainer:addChild(item)
    rootContainer:addChild(itemContainer)
  end

  return rootContainer
end

function EvenlySpaced.vertical(rules, items, gutter)
  gutter = gutter or 0
  local numItems = #items
  local rootContainer = Container:new(rules)

  for i, item in ipairs(items) do
    local itemContainer = Container:new(
      Rules.new()
        :addY(Plan.relative((i - 1) * (1 / numItems)))
        :addX(Plan.pixel(0))
        :addHeight(Plan.relative(1 / numItems))
        :addWidth(Plan.parent())
    )

    item.rules:addX(Plan.pixel(gutter))
      :addY(Plan.pixel(gutter))
      :addWidth(Plan.max(gutter * 2))
      :addHeight(Plan.max(gutter * 2))

    itemContainer:addChild(item)
    rootContainer:addChild(itemContainer)
  end

  return rootContainer
end

return EvenlySpaced
