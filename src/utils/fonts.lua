local Fonts = {}

function Fonts.montserrat(size)
  return love.graphics.newFont("assets/montserrat.ttf", size)
end

function Fonts.futomaru(size)
  return love.graphics.newFont("assets/futomaru401.ttf", size)
end

return Fonts
