local Mesh = {}

local function addAll(tbl, ...)
  for i, elem in ipairs({...}) do
    table.insert(tbl, elem)
  end
end

local function vertex(x, y, tw, th)
  -- TODO: Handle colour
  return { x, y, x / tw, y / th, 1, 1, 1}
end

function Mesh.generate(texture, n)
  local verticies = {}
  local triangles = {}

  local tw = texture:getWidth()
  local th = texture:getHeight()

  local xStep = tw / n
  local yStep = th / n

  local vertexIndex = 1

  for x = 0, tw - xStep, xStep do
    for y = 0, th - yStep, yStep do
      table.insert(verticies, vertex(x, y, tw, th))
      table.insert(verticies, vertex(x + xStep, y, tw, th))
      table.insert(verticies, vertex(x + xStep, y + yStep, tw, th))
      table.insert(verticies, vertex(x, y + yStep, tw, th))
      addAll(triangles, vertexIndex, vertexIndex + 1, vertexIndex + 2, vertexIndex, vertexIndex + 2, vertexIndex + 3)
      vertexIndex = vertexIndex + 4
    end
  end

  local result = love.graphics.newMesh(verticies, "triangles")
  result:setVertexMap(triangles)
  result:setTexture(texture)
  return result
end

return Mesh