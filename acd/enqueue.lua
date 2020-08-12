local json = require("dkjson")

local rate_client = require("acd.alg.rate_client")
local select_queue = require("acd.alg.select_queue")

local acd_queue_response = require("acd.message.acd_queue_response")
local acd_queue_result = require("acd.message.acd_queue_result")

local acd_attribution = require("acd.model.acd_attribution")
local acd_client = require("acd.model.acd_client")
local acd_client_queue = require("acd.model.acd_client_queue")
local acd_customer_type = require("acd.model.acd_customer_type")
local acd_queue = require("acd.model.acd_queue")
local acd_queue_sort_rule = require("acd.model.acd_queue_sort_rule")

-- enqueue_client
--
-- Returns: number
local function enqueue_client(cachehd, 
                              req)
  local tenant_id = req.tenantId
  local req_id = req.uniqueIden
  local client_id = req.customerId
  local client_class = ""
  local district = ""
  local entry_time = tonumber(req.entryTime)
  local protocol = req.serverType
  local skills = req.skills

  -- Check if it is a duplicate request.
  local client = acd_client.get(cachehd, tenant_id, req_id)

  if client.client_id ~= nil then

    print(os.date("%Y-%m-%d %H:%M:%S"), "duplicate request:", json.encode(req))

    return 1

  end

  -- Get the client's class.
  client_class = acd_customer_type.get(cachehd, tenant_id, client_id)

  -- Get the client's attribution.
  if protocol == "hotline" then

    district = acd_attribution.get(cachehd, client_id)

  end

  -- Get all queues.
  local queues = acd_queue.all_queues(cachehd, tenant_id)
 
  if #queues == 0 then

    print(os.date("%Y-%m-%d %H:%M:%S"), "there's no queue for entering")

    return 1

  end

  -- Find the client a queue.
  local queue_id = select_queue(queues, skills)

  -- Failed to find a queue.
  if queue_id == "" then 

    print(os.date("%Y-%m-%d %H:%M:%S"), "failed to select a queue for the request:", json.encode(req))

    return 1

  end
  
  -- Get the insertion rule.
  local rule = acd_queue_sort_rule.get(cachehd, tenant_id, queue_id)

  -- Get all clients in the choosed queue.
  local clients = acd_client_queue.get_members(cachehd, tenant_id, queue_id)
  
  -- Collect fields to compare.
  local compare_fields = {
    client_class = client_class,
    district = district,
    entry_time = entry_time
  }
 
  -- Give the client a score.
  local score = 0

  local reference, difference = rate_client(rule, clients, compare_fields)

  if reference ~= nil then

    -- Calculate the client's score.
    score = acd_client_queue.get_score(cachehd, tenant_id, queue_id, reference) + difference

  end

  local dequeued_at = ""
  local staff_id = ""
  local access_number = ""

  -- Cache the client's information.
  acd_client.create(cachehd, tenant_id, req_id, client_id, client_class, 
                    district, entry_time, protocol, skills, queue_id, 
                    dequeued_at, staff_id, access_number)
  
  -- Enqueue the client.                  
  acd_client_queue.insert(cachehd, tenant_id, queue_id, req_id, score)
  
  return 0

end

-- enqueue
--
-- Returns: number
local function enqueue(cachehd, 
                       req)
  local ok = enqueue_client(cachehd, req)

  acd_queue_response.send(cachehd, {
    tenantId = req.tenantId,
    uniqueIden = req.uniqueIden,
    customerId = req.customerId,
    serverType = req.serverType,
    resultCode = ok,
    jobNumber = ""
  })
  
  if ok ~= 0 then

    acd_queue_result.send(cachehd, {
      tenantId = req.tenantId,
      callId = req.uniqueIden,
      queueId = "",
      entryTime = req.entryTime,
      departureTime = os.time(),
      departureReason = "enqueue failure"
    })
      
  end

  return ok

end

return enqueue
