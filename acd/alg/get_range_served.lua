local in_list = require("acd.alg.in_list")

-- get_range_served
--
-- Returns: table
local function get_range_served(staffs,
                                client_id)
  local range = {}
  
  for staff_id, staff in pairs(staffs) do

    if in_list(staff.served_clients, client_id) then

      table.insert(range, staff_id)

    end

  end

  return range

end

return get_range_served
