local Queue = require "src.utils.queue"

local EventQueue = {}
EventQueue.__index = EventQueue

function EventQueue.new()
  local self = setmetatable({}, EventQueue)
  self.maxTimeSpent = 0.08
  self.eventQueue = Queue.new()
  self.listeners = {}
  return self
end

function EventQueue:register(action, listener)
  if not self.listeners[action] then
    self.listeners[action] = {}
  end

  table.insert(self.listeners[action], listener)
end

function EventQueue:fire(action, payload)
  self.eventQueue:enqueue({ action = action, payload = payload})
end

function EventQueue:update(dt)
  local consumeStart = love.timer.getTime()
  while not self.eventQueue:isEmpty()
    and (love.timer.getTime() - consumeStart) < self.maxTimeSpent do
    local event = self.eventQueue:dequeue()
    if self.listeners[event.action] then
      for i, handler in ipairs(self.listeners[event.action]) do
        handler:receive(event.action, event.payload)
      end
    end
  end

  if not self.eventQueue:isEmpty() then
    print("WARNING: Didn't make it all the way through the event queue: " .. #self.eventQueue.items .. " remain.")
  end
end

return EventQueue