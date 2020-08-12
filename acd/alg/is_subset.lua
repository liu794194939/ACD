-- is_subset
-- Is skills a subset of names?
--
-- Returns: true or false
local function is_subset(names, 
                         skills)
  local count_skills = #skills
  
  if count_skills > #names then 

    return false 

  end
  
  local count_match = 0

  for _, skill in pairs(skills) do

    for _, name in pairs(names) do

      if name == skill then 

        count_match = count_match + 1 

      end

    end

  end
  
  return count_match >= count_skills

end

return is_subset
