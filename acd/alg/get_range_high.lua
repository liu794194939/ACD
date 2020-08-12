-- get_range_high
-- Rank staffs by score, from high to low.
--
-- Returns: table
local function get_range_high(staffs)

  local range = {}
  
  for staff_id, staff in pairs(staffs) do
      
    local pos = 1

    for i, v in ipairs(range) do

      if staff.score > staffs[v].score then
          
        pos = i
        break

      elseif range[i + 1] == nil then
        
        pos = i + 1
        break

      end
    
    end
        
    table.insert(range, pos, staff_id)

  end

  return range

end

return get_range_high
