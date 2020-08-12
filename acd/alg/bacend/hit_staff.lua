local in_list = require("acd.alg.in_list")
local is_subset = require("acd.alg.is_subset")
local is_protocol_match = require("acd.alg.is_protocol_match")

-- hit_staff
--
-- Returns: number
local function hit_staff(staffs,
                         candidate_range, 
                         department_id_list,
                         protocol,
                         skills)
  for _, staff_id in ipairs(candidate_range) do
    
    local staff = staffs[staff_id]

    local cond = in_list(department_id_list, staff.departmentId)

    if cond == true then

      cond = is_protocol_match(staff, protocol)
     
      if cond == true then

        cond = is_subset(staff.skills, skills)

        if cond == true then

          return staff_id

        end

      end

    end

  end

  return ""

end

return hit_staff
