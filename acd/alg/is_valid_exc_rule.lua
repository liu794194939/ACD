-- is_valid_exc_rule
--
-- Returns: true or false
local function is_valid_exc_rule(rule)
  
  if rule.rule == 1 or rule.rule == 2 then
  
    if rule.ruleNumberType == 1 then

      return false

    end

  end

  if rule.option == 0 then
  
    if rule.target == nil then

      return false

    end
  
  end

  if rule.ruleNumberType ~= 0 and rule.ruleNumberType ~= 1 then

    return false

  end
  
  if rule.operateNumberType ~= 0 and rule.operateNumberType ~= 1 then

    return false

  end

  if tonumber(rule.ruleValue) <= 0 then

    return false

  end

  if tonumber(rule.operateValue) <= 0 then

    return false

  end

  return true

end

return is_valid_exc_rule
