-- is_protocol_match
--
-- Return true or false.
local function is_protocol_match(staff,
                                 protocol)
  local staff_status = staff[protocol .. "Status"]
 
  if staff_status ~= nil and staff_status == "idle" then
    
    if protocol == "online" then
      
      if staff.imServiceUpperLimit > staff.imCurrServiceCount then
        
        return true

      end

    elseif protocol == "hotline" then

      if staff.accessNumber ~= nil and staff.accessNumber ~= "" then

        return true

      end

    else

      return true

    end
    
  end

  return false

end

return is_protocol_match
