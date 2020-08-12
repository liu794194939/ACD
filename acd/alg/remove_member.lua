-- remove_member
--
-- Returns: nil
local function remove_member(list,
                             value)
  for i, v in ipairs(list) do

    if v == value then

      table.remove(list, i)
      break

    end

  end

end

return remove_member
