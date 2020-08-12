local in_list = require("acd.alg.in_list")

-- prior_list
--
-- Returns: table
local function prior_list(list, 
                          frame)
  local inner = {}
  local outer = {}

  for _, v in ipairs(list) do

    if in_list(frame, v) == true then

      table.insert(inner, v)
    
    else

      table.insert(outer, v)

    end

  end

  for _, v in ipairs(outer) do

    table.insert(inner, v)

  end

  return inner

end

return prior_list
