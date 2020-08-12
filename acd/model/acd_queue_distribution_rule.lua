local json = require("dkjson")

local acd_queue_distribution_rule = {}

-- get
--
-- Returns: table
function acd_queue_distribution_rule.get(cachehd,
                                         tenant_id,
                                         queue_id)
  local flag = {
    must_served = false,
    served_prior = false,
    multi_prior = false,
    high_prior = false,
    easy_prior = false
  }

  local reply = cachehd:hget("ACD_QUEUE_DISTRIBUTION_RULE:" .. tenant_id, queue_id)
  
  if reply == nil then
    
    return flag

  end

  -- TODO: fix
  local rulestr, _ = json.decode(reply)
  local rules, _ = json.decode(rulestr)
 
  for _, rule in ipairs(rules) do

    if rule.content == 1 then
      
      if rule.label == 0 then

        flag.served_prior = true
      
      elseif rule.label == 1 then
      
        flag.multi_prior = true
      
      elseif rule.label == 2 then
      
        flag.high_prior = true
      
      elseif rule.label == 3 then
      
        flag.easy_prior = true

      end
    
    elseif rule.content == 2 then

      if rule.label == 0 then

        flag.must_served = true
      
      end

    end

  end

  return flag

end

return acd_queue_distribution_rule
