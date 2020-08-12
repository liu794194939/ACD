-- in_list
--
-- Returns: boolean
local function in_list(list,
                       target)
  for _, v in pairs(list) do

    if target == v then

      return true

    end

  end

  return false

end

return in_list
