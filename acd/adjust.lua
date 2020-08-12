local compare = require("acd.alg.compare")
local is_valid_exc_rule = require("acd.alg.is_valid_exc_rule")

local acd_queue = require("acd.model.acd_queue")
local acd_queue_exception_rule = require("acd.model.acd_queue_exception_rule")
local acd_client_queue = require("acd.model.acd_client_queue")
local acd_client_server_status = require("acd.model.acd_client_server_status")

-- adjust
--
-- Returns: nil
local function adjust(cachehd,
                      tenant_id,
                      queue_id)
  -- Get the rule.
  local rules = acd_queue_exception_rule.get(cachehd, tenant_id, queue_id)

  -- Get numbers.
  local numbers = {}
  local capacity = 0

  if #rules > 0 then

    local count_waiting_clients, avg_waiting_time = acd_client_queue.info(cachehd, tenant_id, queue_id)
    local count_all, count_vacant, count_busy = acd_client_server_status.info(cachehd, tenant_id)

    numbers = { count_waiting_clients, avg_waiting_time, count_waiting_clients, avg_waiting_time }
    
    local queue = acd_queue.get(cachehd, tenant_id, queue_id)
    
    capacity = queue.capacity

  end

  for _, rule in ipairs(rules) do

    if is_valid_exc_rule(rule) == true then

      -- Get the compare function and oprands.
      local compare_func = compare[rule.ruleRange]
      local number = numbers[rule.rule + 1]
      local compare_number = 0

      if rule.ruleNumberType == 0 then

        compare_number = tonumber(rule.ruleValue)

      elseif rule.ruleNumberType == 1 then

        if rule.rule == 0 then

          compare_number = tonumber(rule.ruleValue) * capacity / 100

        elseif rule.rule == 3 or rule.rule == 4 then

          -- numbers[3] is count_all.
          compare_number = tonumber(rule.ruleValue) * numbers[3] / 100

        end

      end

      -- Get the count of clients to move.
      local count = 0

      if rule.operateNumberType == 0 then

        count = tonumber(rule.operateValue)

      elseif rule.operateNumberType == 1 then

        -- numbers[1] is count_waiting_clients.
        count = tonumber(rule.operateValue) * numbers[1] / 100
        count = math.floor(count)

      end

      -- Compare.
      if compare_func(number, compare_number) == true then

        if rule.option == 0 then
          
          -- Move clients.
          acd_client_queue.move(cachehd, tenant_id, queue_id, count, rule.target)
          
        elseif rule.option == 1 then

          -- Empty the queue.
          acd_client_queue.empty(cachehd, tenant_id, queue_id)

        end
    
      end
    
    end

  end

  return nil

end

return adjust
