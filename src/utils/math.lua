local MathUtils = {}

function MathUtils.inBounds(x, y, rx, ry, rw, rh)
  return x >= rx and x <= rx + rw and y >= ry and y <= ry + rh
end

return MathUtils