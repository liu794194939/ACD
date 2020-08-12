-- split_skillstr
--
-- Returns: table
local function split_skillstr(skillstr)

  local skills = {}

  for v in string.gmatch(skillstr, "[^,]+") do

    table.insert(skills, v)

  end   
 
  return skills

end

return split_skillstr
