local json = require("dkjson")

local acd_queue_sort_rule = {}

-- get
--
-- Returns: table
function acd_queue_sort_rule.get(cachehd,
                                 tenant_id,
                                 queue_id)
  local flag = {
    client_class = { {}, {}, {}, {} },
    district = { {}, {}, {}, {} },
    entry_time = {}
  }
  
  local reply = cachehd:hget("ACD_QUEUE_SORT_RULE:" .. tenant_id, queue_id)
 
  if reply == nil then

    return flag

  end

  -- TODO: fix
  reply, _ = json.decode(reply) 
  local rules, _ = json.decode(reply) 
  
  for _, rule in pairs(rules) do

    if rule.condition == 0 then

      if rule.ruleRange == "equals" then

        if rule.option == 0 then

          table.insert(flag.client_class[2], 1, rule.value)

        elseif rule.option == 1 then

          table.insert(flag.client_class[3], rule.value)

        elseif rule.option == 2 then

          table.insert(flag.client_class[1], 1, rule.value)

        elseif rule.option == 3 then

          table.insert(flag.client_class[4], rule.value)

        end

      end

    elseif rule.condition == 1 then

      if rule.ruleRange == "equals" then

        if rule.option == 0 then

          table.insert(flag.district[2], 1, rule.value)

        elseif rule.option == 1 then

          table.insert(flag.district[3], rule.value)

        elseif rule.option == 2 then

          table.insert(flag.district[1], 1, rule.value)

        elseif rule.option == 3 then

          table.insert(flag.district[4], rule.value)

        end

      end

    elseif rule.condition == 2 then

      table.insert(flag.entry_time, { rule.ruleRange, tonumber(rule.value), rule.option })

    end

  end
 
  return flag

end

return acd_queue_sort_rule
