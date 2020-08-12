local get_candidate_range = require("acd.alg.get_candidate_range")
local get_range_easy = require("acd.alg.get_range_easy")
local get_range_high = require("acd.alg.get_range_high")
local get_range_multi = require("acd.alg.get_range_multi")
local get_range_served = require("acd.alg.get_range_served")
local hit_staff = require("acd.alg.hit_staff")
local remove_member = require("acd.alg.remove_member")
local split_keystr = require("acd.alg.split_keystr")
local split_skillstr = require("acd.alg.split_skillstr")

local acd_queue_response = require("acd.message.acd_queue_response")
local acd_queue_result = require("acd.message.acd_queue_result")

local acd_client_server_status = require("acd.model.acd_client_server_status")
local acd_client = require("acd.model.acd_client")
local acd_client_queue = require("acd.model.acd_client_queue")
local acd_queue = require("acd.model.acd_queue")
local acd_queue_distribution_rule = require("acd.model.acd_queue_distribution_rule")
  
-- get_staffs
--
-- Returns: table, table, table, table
local function get_staffs(cachehd, 
                          tenant_id)  
  -- Get all staffs belong to this tenant.
  local staffs = acd_client_server_status.all(cachehd, tenant_id)
  
  -- Rank staffs.
  local range_multi = get_range_multi(staffs)
  local range_high = get_range_high(staffs)
  local range_easy = get_range_easy(staffs)

  return staffs, range_multi, range_high, range_easy

end

-- expire_client
--
-- Returns: true or false
local function expire_client(cachehd, 
                             tenant_id, 
                             queue_id, 
                             req_id, 
                             entry_time)
  -- Abort in TIMEOUT seconds.
  local TIMEOUT = 15 * 60

  if os.time() - entry_time >= TIMEOUT then

    -- Remove the client from the queue.
    acd_client_queue.remove(cachehd, tenant_id, queue_id, req_id)

    -- Delete the client's information.
    acd_client.delete(cachehd, tenant_id, req_id)

    -- Send message.
    acd_queue_result.send(cachehd, {
      tenantId = tenant_id,
      callId = req_id,
      queueId = queue_id,
      entryTime = entry_time,
      departureTime = os.time(),
      departureReason = "timeout"
    })

    return true

  end

  return false

end

-- dequeue_client
--
-- Returns: table
local function dequeue_client(cachehd, 
                              tenant_id, 
                              queue_id, 
                              req_id,
                              rule, 
                              department_id_list,
                              staffs, 
                              range_multi, 
                              range_high, 
                              range_easy)
  -- Get the client's information.
  local client = acd_client.get(cachehd, tenant_id, req_id)

  if client.client_id == nil then

    return client

  end

  -- Check if the client is expired.
  if expire_client(cachehd, tenant_id, queue_id, req_id, client.entry_time) == true then
  
    return client

  end

  -- Get served staffs' range.
  local range_served = {}
  
  if rule.must_served == true or rule.served_prior == true then

    range_served = get_range_served(staffs, client.client_id)

  end

  -- Get candidate range.
  local candidate_range = get_candidate_range(rule,
                                              range_served,
                                              range_multi,
                                              range_high,
                                              range_easy)
  
  -- There's no candidate.
  if #candidate_range == 0 then

    return client
  
  end

  -- Try to hit a staff.
  staff_id,number = hit_staff(staffs,
                             candidate_range,
                             department_id_list,
                             client.protocol,
                             split_skillstr(client.skills),number)

  -- Failed.
  if staff_id == "" then

    return client

  end

  -- Get the staff's information.
  local staff = staffs[staff_id]

  -- Try to occupy the staff.
  local ok = acd_client_server_status.occupy(cachehd, 
                                             tenant_id, 
                                             staff_id, 
                                             client.protocol)

  -- Occupy failed.
  if ok == false then

    return client
  
  end

  -- Remove the client from the queue.
  local count = acd_client_queue.remove(cachehd, tenant_id, queue_id, req_id)
  
  -- Update the client's information.
  client.dequeued_at = os.time()
  client.staff_id = staff_id
  client.access_number = staff.accessNumber

  local is_dequeued = acd_client.dequeue(cachehd, tenant_id, req_id, 
                                         client.dequeued_at, 
                                         client.staff_id, 
                                         client.access_number)

  -- The client is gone.
  if count == 0 or is_dequeued == false then

    -- Set the staff free.
    acd_client_server_status.free(cachehd, tenant_id, staff_id, client.protocol)

    return client

  end

  staffs[staff_id] = nil
  remove_member(range_multi, staff_id)
  remove_member(range_high, staff_id)
  remove_member(range_easy, staff_id)
  
  if client.protocol ~= "hotline" then

    acd_client.delete(cachehd, tenant_id, req_id)
  
  end

  -- Send message.
  acd_queue_result.send(cachehd, {
    tenantId = tenant_id,
    callId = req_id,
    queueId = queue_id,
    entryTime = client.entry_time,
    departureTime = client.dequeued_at,
    departureReason = "normal"
  })
    
  acd_queue_response.send(cachehd, {
    tenantId = tenant_id,
    uniqueIden = req_id,
    customerId = client.client_id,
    serverType = client.protocol,
    resultCode = 0,
    jobNumber = staff_id
  })
  
  return client

end

-- dequeue_clients
--
-- Returns: table
local function dequeue_clients(cachehd, 
                               tenant_id, 
                               queue_id, 
                               staffs, 
                               range_multi, 
                               range_high, 
                               range_easy)
  -- Get the queue's match rule.
  local rule = acd_queue_distribution_rule.get(cachehd, tenant_id, queue_id)

  -- Get department id list.
  local queue = acd_queue.get(cachehd, tenant_id, queue_id)
  local department_id_list = queue.departmentIds

  local req_id_list = acd_client_queue.all_members(cachehd, tenant_id, queue_id)

  local dequeued_clients = {}

  for _, req_id in ipairs(req_id_list) do
  
    local client = dequeue_client(cachehd, tenant_id, queue_id, req_id,
                                  rule, department_id_list,
                                  staffs, range_multi, range_high, range_easy)

    if client.staff_id ~= nil and client.staff_id ~= "" then

      table.insert(dequeued_clients, client)

    end

  end

  return dequeued_clients

end

-- dequeue
--
-- Returns: table
local function dequeue(cachehd,
                       tenant_id)
  local staffs, range_multi, range_high, range_easy = get_staffs(cachehd, 
                                                                 tenant_id)

  -- Get all queues belong to the tenant.
  local keys = acd_client_queue.get_by_tenant(cachehd, tenant_id)

  local dequeued_clients = {}

  for _, keystr in ipairs(keys) do

    local key = split_keystr(keystr)
    local queue_id = key[3]

    local clients = dequeue_clients(cachehd, tenant_id, queue_id,
                                    staffs, range_multi, range_high, range_easy)
 
    for _, client in ipairs(clients) do

      table.insert(dequeued_clients, client)

    end

  end

  return dequeued_clients

end

return dequeue
