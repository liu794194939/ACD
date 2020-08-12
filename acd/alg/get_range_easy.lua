-- get_range_easy
-- Rank staffs by working seconds, from easy to busy.
--
-- Returns: table
local function get_range_easy(staffs)

  local range = {}
  
  for staff_id, staff in pairs(staffs) do
      
    local pos = 1

    for i, v in ipairs(range) do

      if staff.jobDuration < staffs[v].jobDuration then
          
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

return get_range_easy
