-- find_index
--
-- Returns: number
local function find_index(list,
                          value)
  for i, v in pairs(list) do

    if value == v then

      return i

    end

  end

  return NaN

end

return find_index
