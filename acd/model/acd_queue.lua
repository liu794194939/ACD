local json = require("dkjson")

local acd_queue = {}

-- get_skills
--
-- Returns: table
local function get_skills(businessType)

  local skills = {}

  for _, it in pairs(businessType) do

    table.insert(skills, it.name)

  end

  return skills

end

-- all_queues
--
-- Returns: table
function acd_queue.all_queues(cachehd,
                              tenant_id)
  local reply = cachehd:hgetall("ACD_QUEUE:" .. tenant_id)
  
  local queues = {}

  for queue_id, v in pairs(reply) do

    -- TODO: fix
    v, _ = json.decode(v)
    local queue, _ = json.decode(v)
    
    -- Add the "skills" field.
    queue["skills"] = get_skills(queue.businessType)
    queue.businessType = nil
    
    -- Add the "occupied" field.
    queue["occupied"] = cachehd:zcard("ACD_CLIENT_QUEUE:" .. tenant_id .. ":" .. queue_id)
    
    table.insert(queues, queue)

  end

  return queues

end

-- get
--
-- Returns: table
function acd_queue.get(cachehd,
                       tenant_id,
                       queue_id)
  local queuestr = cachehd:hget("ACD_QUEUE:" .. tenant_id, queue_id)
  
  -- TODO: fix
  queuestr, _ = json.decode(queuestr)
  local queue, _ = json.decode(queuestr)
  
  -- Add the "skills" field.
  queue["skills"] = get_skills(queue.businessType)
  queue.businessType = nil
  
  -- Add the "occupied" field.
  queue["occupied"] = cachehd:zcard("ACD_CLIENT_QUEUE:" .. tenant_id .. ":" .. queue_id)
  
  return queue

end

return acd_queue
