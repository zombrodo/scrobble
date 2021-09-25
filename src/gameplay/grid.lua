local Plan = require "lib.plan"
local Container = Plan.Container

local Colour = require "src.utils.colour"
local Letter = require "src.letters.letter"

local Grid = Container:extend()

function Grid:new(rules, xCells, yCells, cellWidth, cellHeight)
  local grid = Grid.super.new(self, rules)
  grid.xCells = xCells
  grid.yCells = yCells

  grid.cellWidth = cellWidth
  grid.cellHeight = cellHeight

  grid.colour = Colour.fromHex("#c7a582")

  grid.items = {}
  for y = 0, yCells do
    grid.items[y] = {}
  end

  grid.fallingTiles = {}

  return grid
end

function Grid:set(x, y, cell)
  self.items[y][x] = cell
end

function Grid:get(x, y)
  return self.items[y][x]
end

function Grid:check(x, y)
  return self.items[y][x] ~= nil
end

function Grid:mark(x, y)
  self.items[y][x]:mark()
end

function Grid:remove(x, y)
  self.items[y][x] = nil
end

function Grid:anythingLeft(tileGroup)
  if tileGroup.y < 0 then return false end
  return self:check(tileGroup.x - 1, tileGroup.y)
    or self:check(tileGroup.x, tileGroup.y + 1)
end

function Grid:anythingRight(tileGroup)
  if tileGroup.y < 0 then return false end
  return self:check(tileGroup.x + 3, tileGroup.y)
    or self:check(tileGroup.x + 3, tileGroup.y + 1)
end

function Grid:anythingBelow(tileGroup)
  -- If whole group, then
  if not tileGroup.isHalf then
    return self:check(tileGroup.x, tileGroup.y + 2)
      or self:check(tileGroup.x + 1, tileGroup.y + 2)
  end

  -- Else, if tileGroup is the left half
  if tileGroup.isLeftHalf then
    return self:check(tileGroup.x, tileGroup.y + 2)
  end

  -- Else, the tileGroup must be the right half
  return self:check(tileGroup.x + 1, tileGroup.y + 2)
end

function Grid:setGroup(tileGroup)
   -- TODO: tidy this up, combine branches.
   -- Doubly so after adding new detonate code.
   if tileGroup.isHalf then
    if tileGroup.isLeftHalf then
      self:set(tileGroup.x, tileGroup.y, tileGroup.tile00)
      self:set(tileGroup.x, tileGroup.y + 1, tileGroup.tile01)

      if tileGroup.tile00.isSpecialTile then
        self:detonate(tileGroup.x, tileGroup.y, tileGroup.tile00.rank)
      end

      if tileGroup.tile01.isSpecialTile then
        self:detonate(tileGroup.x, tileGroup.y + 1, tileGroup.tile01.rank)
      end
    else
      self:set(tileGroup.x + 1, tileGroup.y, tileGroup.tile10)
      self:set(tileGroup.x + 1, tileGroup.y + 1, tileGroup.tile11)

      if tileGroup.tile10.isSpecialTile then
        self:detonate(tileGroup.x + 1, tileGroup.y, tileGroup.tile10.rank)
      end

      if tileGroup.tile11.isSpecialTile then
        self:detonate(tileGroup.x + 1, tileGroup.y + 1, tileGroup.tile11.rank)
      end
    end
    return
  end

  -- is it on left or right?
  local left = self:check(tileGroup.x, tileGroup.y + 2)
  local right = self:check(tileGroup.x + 1, tileGroup.y + 2)

  local bottom = not (left or right)
  local both = left and right

  if not (both or bottom) then
    tileGroup.isHalf = true
    tileGroup.isLeftHalf = right -- if the right half is set, then we have left
  end

  if left or both or bottom then
    self:set(tileGroup.x, tileGroup.y, tileGroup.tile00)
    self:set(tileGroup.x, tileGroup.y + 1, tileGroup.tile01)
  end

  if right or both or bottom then
    self:set(tileGroup.x + 1, tileGroup.y, tileGroup.tile10)
    self:set(tileGroup.x + 1, tileGroup.y + 1, tileGroup.tile11)
  end

  -- Once everything is set, detonate if needed
  if left or both or bottom then
    if tileGroup.tile00.isSpecialTile then
      self:detonate(tileGroup.x, tileGroup.y, tileGroup.tile00.rank)
    end

    if tileGroup.tile01.isSpecialTile then
      self:detonate(tileGroup.x, tileGroup.y + 1, tileGroup.tile01.rank)
    end
  end

  if right or both or bottom then
    if tileGroup.tile10.isSpecialTile then
      self:detonate(tileGroup.x + 1, tileGroup.y, tileGroup.tile10.rank)
    end

    if tileGroup.tile11.isSpecialTile then
      self:detonate(tileGroup.x + 1, tileGroup.y + 1, tileGroup.tile11.rank)
    end
  end

  -- Return whether or not we should continue
  return not (both or bottom)
end

function Grid:detonate(x, y, rankType)
  self:get(x, y):mark()
  -- check sides
  if self:check(x - 1, y)
    and self:get(x - 1, y).rank == rankType
    and not self:get(x - 1, y).marked then
    self:detonate(x - 1, y, rankType)
  end

  if self:check(x + 1, y)
    and self:get(x + 1, y).rank == rankType
    and not self:get(x + 1, y).marked then
    self:detonate(x + 1, y, rankType)
  end

  if self:check(x, y - 1)
    and self:get(x, y - 1).rank == rankType
    and not self:get(x, y - 1).marked then
    self:detonate(x, y - 1, rankType)
  end

  if self:check(x, y + 1)
    and self:get(x, y + 1).rank == rankType
    and not self:get(x, y + 1).marked then
    self:detonate(x, y + 1, rankType)
  end
end

function Grid:__getIndexedTile(x, y, index)
  if self:check(x, y) then
    local tile = self:get(x, y)
    return {
      isSpecial = tile.letter == Letter.Special,
      letter = Letter.toChar(tile.letter),
      index = index
    }
  end
end

function Grid:getRow(y)
  local result = {}
  local currentWord = {}
  for x = 0, self.xCells do
    local tile = self:__getIndexedTile(x, y, x)
    if tile and not tile.isSpecial then
      table.insert(currentWord, tile)
    else
      if #currentWord > 0 then
        table.insert(result, currentWord)
        currentWord = {}
      end
    end
  end
  -- Catch any stragglers
  if #currentWord > 0 then
    table.insert(result, currentWord)
  end
  return result
end

function Grid:getColumn(x)
  local result = {}
  local currentWord = {}
  for y = 0, self.yCells do
    local tile = self:__getIndexedTile(x, y, y)
    if tile and not tile.isSpecial then
      table.insert(currentWord, tile)
    else
      if #currentWord > 0 then
        table.insert(result, currentWord)
        currentWord = {}
      end
    end
  end
  -- Catch any stragglers
  if #currentWord > 0 then
    table.insert(result, currentWord)
  end

  return result
end

function Grid:reserved(x, y)
  for i, fallingTile in ipairs(self.fallingTiles) do
    if y == fallingTile.goal then
      return true
    end
  end
  return false
end

function Grid:finishFalling(y)
  local index = -1
  for i, fallingTile in ipairs(self.fallingTiles) do
    if fallingTile.goal == y then
      index = i
    end
  end

  if index ~= -1 then
    table.remove(self.fallingTiles, index)
  end
end

function Grid:fallTo(startX, startY, endX, endY)
  local tile = self:get(startX, startY)
  local grid = self
  self:remove(startX, startY)
  local fallingTile = {
    tile = tile, x = startX, y = startY, goal = endY
  }
  table.insert(self.fallingTiles, fallingTile)
  Flux.to(fallingTile, 0.2, { y = endY })
    :ease("expoout")
    :oncomplete(function()
    grid:finishFalling(endY)
    grid:set(endX, endY, tile)
  end)
end

function Grid:update(dt)
  for y = 0, self.yCells do
    for x = 0, self.xCells do
      if self.items[y][x] then
        self.items[y][x]:update(dt)
      end
    end
  end
end

function Grid:draw()
  love.graphics.push("all")
  love.graphics.setLineWidth(3)
  -- Grid
  love.graphics.setColor(self.colour)
  for r = 0, self.yCells do
        love.graphics.line(
          self.x,
          self.y + (r * self.cellHeight),
          self.x + (self.xCells * self.cellWidth),
          self.y + (r * self.cellHeight)
        )
  end

  for c = 0, self.xCells do
      love.graphics.line(
        self.x + (c * self.cellWidth),
        self.y,
        self.x + (c * self.cellWidth),
        self.y + (self.yCells * self.cellHeight))
  end

  -- Tiles
  love.graphics.setColor(1, 1, 1, 1)
  for r = 0, self.yCells - 1 do
    for c = 0, self.xCells - 1 do
      if self.items[r][c] then
        self.items[r][c]:draw(
          self.x + (c * self.cellWidth) + self.cellWidth / 2,
          self.y + (r * self.cellHeight) + self.cellHeight / 2
        )
      end
    end
  end

    -- Falling Tiles
  for i, fallingTile in ipairs(self.fallingTiles) do
    fallingTile.tile:draw(
      self.x + (fallingTile.x * self.cellWidth) + self.cellWidth / 2,
      self.y + (fallingTile.y * self.cellHeight) + self.cellHeight / 2
    )
  end
  love.graphics.pop()
end

function Grid:clear()
  self.items = {}
  for y = 0, self.yCells do
    self.items[y] = {}
  end
end

return Grid
