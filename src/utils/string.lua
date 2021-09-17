local String = {}

function String.allSubstrings(str)
  local result = {}
  for i = 1, #str do
    for j = i, #str do
      table.insert(result, string.sub(str, i, j))
    end
  end
  return result
end

function String.split(str, sep)
  local result = {}
  string.gsub(
    str,
    string.format("([^%s]+)", sep),
    function(c) table.insert(result, c) end
  )
  return result
end

function String.tokens(str)
  local result = {}
  for char in string.gmatch(str, ".") do
    table.insert(result, char)
  end
  return result
end

return String