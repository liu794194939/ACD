local in_list = require("acd.alg.in_list")
local is_subset = require("acd.alg.is_subset")
local is_protocol_match = require("acd.alg.is_protocol_match")
local json=require("dkjson")
-- hit_staff
--
-- Returns: number
local function hit_staff(staffs,
                         candidate_range, 
                         department_id_list,
                         protocol,
                         skills,number)
  if number==nil then
     number=0
  end
  if number>=#candidate_range then
     number=0
  end
  for i, staff_id in ipairs(candidate_range) do
    if i>number then
    local staff = staffs[staff_id]
  
    local cond = in_list(department_id_list, staff.departmentId)
    if cond == true then
      cond = is_protocol_match(staff, protocol)
      if cond == true then
        cond = is_subset(staff.skills, skills)

        if cond == true then
          return staff_id,i

        end

      end

    end
  end

  end

  return "",0

end

return hit_staff
