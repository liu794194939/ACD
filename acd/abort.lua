local json = require("dkjson")

local acd_queue_result = require("acd.message.acd_queue_result")

local acd_client = require("acd.model.acd_client")
local acd_client_queue = require("acd.model.acd_client_queue")
local acd_client_server_status = require("acd.model.acd_client_server_status")

-- abort
--
-- Returns: number
local function abort(cachehd,
                     req)
  local tenant_id = req.tenantId
  local req_id = req.uniqueIden

  local client = acd_client.get(cachehd, tenant_id, req_id)

  if client.client_id == nil then

    print(os.date("%Y-%m-%d %H:%M:%S"), "failed to abort nonexistent request:", json.encode(req))

    return 1

  end

  -- Remove the client from the queue.
  acd_client_queue.remove(cachehd, tenant_id, client.queue_id, req_id)

  -- Delete the client's information.
  acd_client.delete(cachehd, tenant_id, req_id)
 
  -- If the client is already matched with a staff, free the staff.
  if client.staff_id ~= "" then

    acd_client_server_status.free(cachehd, tenant_id, client.staff_id, client.protocol)

  end

  -- Send message.
  acd_queue_result.send(cachehd, {
    tenantId = tenant_id,
    callId = req_id,
    queueId = client.queue_id,
    entryTime = client.entry_time,
    departureTime = os.time(),
    departureReason = "giveup"
  })

  return 0

end

return abort
