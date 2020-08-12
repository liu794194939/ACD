local acd_client_queue = {}

-- all_members
--
-- Returns: table
function acd_client_queue.all_members(cachehd, 
                                      tenant_id, 
                                      queue_id)
  local key = "ACD_CLIENT_QUEUE:" .. tenant_id .. ":" .. queue_id

  local req_id_list = cachehd:zrevrange(key, 0, -1)

  return req_id_list

end

-- get_members
--
-- Returns: table
function acd_client_queue.get_members(cachehd, 
                                      tenant_id, 
                                      queue_id)
  local key = "ACD_CLIENT_QUEUE:" .. tenant_id .. ":" .. queue_id

  local req_id_list = cachehd:zrange(key, 0, -1)

  local replies = cachehd:transaction(function(t)

    for _, req_id in ipairs(req_id_list) do

      t:hgetall("ACD_CLIENT:" .. tenant_id .. ":" .. req_id)

    end

  end)
 
  local clients = {}

  for i, req_id in ipairs(req_id_list) do

    local client = replies[i]

    -- The client's information may not exist.
    if client.client_id ~= nil then

      client.entry_time = tonumber(client.entry_time)

      table.insert(clients, client)

    end

  end

  return clients

end

-- insert
--
-- Returns: number
function acd_client_queue.insert(cachehd, 
                                 tenant_id, 
                                 queue_id, 
                                 req_id,
                                 score)
  local key = "ACD_CLIENT_QUEUE:" .. tenant_id .. ":" .. queue_id

  local reply = cachehd:zadd(key, score, req_id)

  return reply

end

-- decrease
--
-- Returns: number
function acd_client_queue.decrease(cachehd, 
                                   tenant_id, 
                                   queue_id, 
                                   req_id)
  local key = "ACD_CLIENT_QUEUE:" .. tenant_id .. ":" .. queue_id

  local reply = cachehd:zincrby(key, -1, req_id)

  return reply

end

-- remove
--
-- Returns: number
function acd_client_queue.remove(cachehd, 
                                 tenant_id, 
                                 queue_id, 
                                 req_id)
  local key = "ACD_CLIENT_QUEUE:" .. tenant_id .. ":" .. queue_id

  local reply = cachehd:zrem(key, req_id)

  return reply

end

-- all_keys
--
-- Returns: table
function acd_client_queue.all_keys(cachehd)

  local keys = cachehd:keys("ACD_CLIENT_QUEUE:*")

  return keys

end

-- get_by_tenant
--
-- Returns: table
function acd_client_queue.get_by_tenant(cachehd,
                                        tenant_id)
  local keys = cachehd:keys("ACD_CLIENT_QUEUE:" .. tenant_id .. ":*")

  return keys

end

-- get_score
--
-- Returns: number or nil
function acd_client_queue.get_score(cachehd,
                                    tenant_id,
                                    queue_id,
                                    req_id)
  local key = "ACD_CLIENT_QUEUE:" .. tenant_id .. ":" .. queue_id

  local score = cachehd:zscore(key, req_id)

  return score

end

-- pick_front
--
-- Returns: string
function acd_client_queue.pick_front(cachehd, 
                                     tenant_id, 
                                     queue_id)
  local key = "ACD_CLIENT_QUEUE:" .. tenant_id .. ":" .. queue_id
 
  local req_id_list = cachehd:zrange(key, -1, -1)

  -- There is no client waiting in the queue.
  if #req_id_list == 0 then 

    return ""

  end
  
  return req_id_list[1]
  
end

-- info
--
-- Returns: number, number
function acd_client_queue.info(cachehd,
                               tenant_id,
                               queue_id)
  local key = "ACD_CLIENT_QUEUE:" .. tenant_id .. ":" .. queue_id
 
  local req_id_list = cachehd:zrange(key, 0, -1)
  
  if #req_id_list == 0 then

    return 0, 0

  end

  local replies = cachehd:transaction(function(t)

    for _, req_id in ipairs(req_id_list) do

      t:hget("ACD_CLIENT:" .. tenant_id .. ":" .. req_id, "entry_time")

    end

  end)

  local waiting_time = 0

  for i, req_id in ipairs(req_id_list) do

    if replies[i] ~= nil then
    
      waiting_time = waiting_time + os.time() - tonumber(replies[i])   

    end

  end

  return #req_id_list, waiting_time / #req_id_list

end

-- empty
--
-- Returns: nil
function acd_client_queue.empty(cachehd,
                                tenant_id,
                                queue_id)
  local key = "ACD_CLIENT_QUEUE:" .. tenant_id .. ":" .. queue_id
 
  local req_id_list = cachehd:zrange(key, 0, -1)

  cachehd:transaction(function(t)

    for _, req_id in ipairs(req_id_list) do

      t:zrem(key, req_id)

      t:del("ACD_CLIENT:" .. tenant_id .. ":" .. req_id)

    end

  end)

  return nil

end

-- move
--
-- Returns: nil
function acd_client_queue.move(cachehd,
                               tenant_id,
                               queue_id,
                               count,
                               target_queue_id)
  if count <= 0 or target_queue_id == nil then
    
    return nil

  end

  local key = "ACD_CLIENT_QUEUE:" .. tenant_id .. ":" .. queue_id

  local replies = cachehd:transaction(function(t)
  
    t:zrange(key, 0, count - 1, "WITHSCORES")
    
    t:zremrangebyrank(key, 0, count -1)

  end)

  local req_id_list = replies[1]

  local key = "ACD_CLIENT_QUEUE:" .. tenant_id .. ":" .. target_queue_id

  cachehd:transaction(function(t)

    for i, req_id in ipairs(req_id_list) do

      t:hset("ACD_CLIENT:" .. tenant_id .. ":" .. req_id[1], "queue_id", target_queue_id)

      t:zadd(key, req_id[2], req_id[1])

    end

  end)

  return nil

end

return acd_client_queue
