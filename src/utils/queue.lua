local Queue = {}
Queue.__index = Queue

function Queue.new()
  local self = setmetatable({}, Queue)
  self.items = {}
  return self
end

function Queue:dequeue()
  return table.remove(self.items, 1)
end

function Queue:peek(index)
  return self.items[index]
end

function Queue:enqueue(item)
  table.insert(self.items, item)
end

return Queue
