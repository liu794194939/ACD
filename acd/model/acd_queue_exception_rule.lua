local json = require("dkjson")

local acd_queue_exception_rule = {}

-- get
--
-- Returns: table
function acd_queue_exception_rule.get(cachehd,
                                      tenant_id,
                                      queue_id)
  local rulestr = cachehd:hget("ACD_QUEUE_EXCEPTION_RULE:" .. tenant_id, queue_id)

  if rulestr == nil then
    
    return {}

  end

  -- TODO: fix
  rulestr, _ = json.decode(rulestr)
  local rule, _ = json.decode(rulestr)

  return rule

end

return acd_queue_exception_rule
