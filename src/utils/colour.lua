local Colour = {}

Colour.fromHex = function(hex, alpha)
  if #hex == 7 then
    hex = string.sub(hex, 2)
  end
  local colour = {
    (1/255) * tonumber(string.sub(hex, 1, 2),16),
    (1/255) * tonumber(string.sub(hex, 3, 4),16),
    (1/255) * tonumber(string.sub(hex, 5, 6),16)
  }
  if alpha then
    return Colour.withAlpha(colour, alpha)
  end

  return colour
end

Colour.fromBytes = function (r, g, b, a)
  local colour = {
    r / 255,
    g / 255,
    b / 255
  }
  if a then
    return Colour.withAlpha(colour, a)
  end

  return colour
end

Colour.withAlpha = function(color, alpha)
  return { color[1], color[2], color[3], alpha }
end

return Colour