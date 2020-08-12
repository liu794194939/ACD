-- flatten_list
-- Flatten a 2D list.
--
-- Returns: table
local function flatten_list(list)

  local new_list = {}

  for p in ipairs(list) do

    for q in ipairs(p) do

      table.insert(new_list, q)

    end

  end

  return new_list

end

return flatten_list
