local in_list = require("acd.alg.in_list")

-- filter_list
--
-- Returns: table
local function filter_list(list, 
                           frame)
  local other = {}

  for _, v in ipairs(list) do

    if in_list(frame, v) == true then

      table.insert(other, v)

    end

  end

  return other

end

return filter_list
