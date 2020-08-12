local split_keystr = require("acd.alg.split_keystr")

local acd_client = {}

-- create
--
-- Returns: true or false
function acd_client.create(cachehd, 
                           tenant_id, 
                           req_id,
                           client_id,
                           client_class,
                           district,
                           entry_time,
                           protocol,
                           skills,
                           queue_id,
                           dequeued_at,
                           staff_id,
                           access_number)
  local key = "ACD_CLIENT:" .. tenant_id .. ":" .. req_id
  
  local reply = cachehd:hmset(key, "req_id", req_id, "client_id", client_id, 
                              "client_class", client_class, "district", district, "entry_time", entry_time, 
                              "protocol", protocol, "skills", skills, "enqueued_at", os.time(), "queue_id", queue_id, 
                              "dequeued_at", "", "staff_id", "", "access_number", "")
 
  return reply

end

-- get
--
-- Returns: table
function acd_client.get(cachehd, 
                        tenant_id, 
                        req_id)
  local key = "ACD_CLIENT:" .. tenant_id .. ":" .. req_id

  local client = cachehd:hgetall(key)

  if client.client_id ~= nil then

    client.entry_time = tonumber(client.entry_time)
    client.enqueued_at = tonumber(client.enqueued_at)
  
  end

  return client

end

-- delete
--
-- Returns: number
function acd_client.delete(cachehd, 
                           tenant_id, 
                           req_id)
  local key = "ACD_CLIENT:" .. tenant_id .. ":" .. req_id

  local reply = cachehd:del(key)
  
  return reply

end

-- get_by_tenant
--
-- Returns: table
function acd_client.get_by_tenant(cachehd,
                                  tenant_id)
  local keys = cachehd:keys("ACD_CLIENT:" .. tenant_id .. ":*")
  
  local clients = {}
  
  for _, keystr in ipairs(keys) do

    local key = split_keystr(keystr)
    local req_id = key[3]

    local client = cachehd:hgetall(keystr) 

    -- The client's information may not exist.
    if client.client_id ~= nil then

      clients[req_id] = client

    end

  end

  return clients

end

-- get_by_queue
--
-- Returns: table
function acd_client.get_by_queue(cachehd,
                                 tenant_id,
                                 queue_id)
  local keys = cachehd:keys("ACD_CLIENT:" .. tenant_id .. ":" .. queue_id .. ":*")
  
  local clients = {}
  
  for _, keystr in ipairs(keys) do

    local key = split_keystr(keystr)
    local req_id = key[3]

    local client = cachehd:hgetall(keystr) 

    -- The client's information may not exist.
    if client.client_id ~= nil then

      clients[req_id] = client

    end

  end

  return clients

end

-- dequeue
--
-- Returns: true or false
function acd_client.dequeue(cachehd,
                            tenant_id,
                            req_id,
                            dequeued_at,
                            staff_id,
                            access_number)
  local key = "ACD_CLIENT:" .. tenant_id .. ":" .. req_id

  local replies = cachehd:transaction(function(t)

    t:hmset(key, "dequeued_at", dequeued_at, "staff_id", staff_id, 
            "access_number", access_number)

    t:hgetall(key)
  
  end)

  local client = replies[2]

  -- The client was gone.
  if client.client_id == nil then

    cachehd:del(key)

    return false

  end

  return true

end

return acd_client
