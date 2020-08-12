local json = require("dkjson")

local in_list = require("acd.alg.in_list")

local acd_client_server_status = {}

-- get_staff_skills
--
-- Returns: table, number
local function get_staff_skills(groups)
  
  local skills = {}
  local score = 0

  for _, v in ipairs(groups) do
    
    table.insert(skills, v.skillGroup)

    score = score + v.score

  end
  
  score = math.floor(score/#skills)

  return skills, score

end

-- get_served_clients
--
-- Returns: table
local function get_served_clients(reply)

  if reply == nil then

    return {}

  end

  -- TODO: fix
  reply, _ = json.decode(reply)
  local obj = json.decode(reply)

  local client_id_list = {}

  for _, it in pairs(obj.customers) do
  
    if in_list(client_id_list, it.customerId) == false then

      table.insert(client_id_list, it.customerId)

    end

  end

  return client_id_list

end

-- all
--
-- Returns: table
function acd_client_server_status.all(cachehd, 
                                      tenant_id)
  local replies = cachehd:hgetall("ACD_CLIENT_SERVER_STATUS:" .. tenant_id)
  
  local staffs = {}

  for _, staffstr in pairs(replies) do

    -- TODO: fix
    staffstr, _ = json.decode(staffstr)
    local staff, _ = json.decode(staffstr)

    -- Add the "skills" and "score" fields.
    staff["skills"], staff["score"] = get_staff_skills(staff.skillGroupDetails)
  
    -- Remove the "skillGroupDetails" field.
    staff.skillGroupDetails = nil
    
    -- Add the "served_clients" field.
    local records = cachehd:hget("ACD_SERVICE_RECORD:" .. tenant_id, 
                                 json.encode(staff.jobNumber))
    
    staff["served_clients"] = get_served_clients(records)

    if staff.accessNumber == nil then

      staff.accessNumber = ""

    end
  
    staffs[staff.jobNumber] = staff
  
  end
  
  return staffs

end

-- all_keys
--
-- Returns: table
function acd_client_server_status.all_keys(cachehd)

  local keys = cachehd:keys("ACD_CLIENT_SERVER_STATUS:*")

  return keys

end

-- occupy
--
-- Returns: true or false
function acd_client_server_status.occupy(cachehd, 
                                         tenant_id, 
                                         staff_id,
                                         protocol)
  local key = "ACD_CLIENT_SERVER_STATUS:" .. tenant_id
 
  -- TODO: fix 
  staff_id = json.encode(staff_id)

  local staffstr = cachehd:hget(key, staff_id)
  
  -- TODO: fix
  staffstr, _ = json.decode(staffstr)
  local staff, _ = json.decode(staffstr)
    
  if staff[protocol .. "Status"] == "busy" then

    return false

  end
 
  -- Update the staff's status.
  if protocol == "online" then
    
    staff.imCurrServiceCount = staff.imCurrServiceCount + 1
   
    if staff.imCurrServiceCount >= staff.imServiceUpperLimit then

      staff.onlineStatus = "busy"

    end

  else

    staff[protocol .. "Status"] = "busy"
    
  end
  
  -- TODO: fix
  staffstr = json.encode(staff)
  staffstr = json.encode(staffstr)

  cachehd:hset(key, staff_id, staffstr)

  return true

end

-- free
--
-- Returns: nil
function acd_client_server_status.free(cachehd, 
                                       tenant_id, 
                                       staff_id, 
                                       protocol)
  local key = "ACD_CLIENT_SERVER_STATUS:" .. tenant_id

  -- TODO: fix 
  staff_id = json.encode(staff_id)

  local staffstr = cachehd:hget(key, staff_id)

  -- Check if the staff exists.
  if staffstr == nil then

    return nil

  end
  
  -- TODO: fix
  staffstr, _ = json.decode(staffstr)
  local staff, _ = json.decode(staffstr)
 
  -- Update the staff's status.
  if protocol == "online" then
    
    staff.imCurrServiceCount = staff.imCurrServiceCount - 1

  end

  staff[protocol .. "Status"] = "idle"

  -- TODO: fix
  staffstr = json.encode(staff)
  staffstr = json.encode(staffstr)

  cachehd:hset(key, staff_id, staffstr)
  
end

-- info
--
-- Returns: number, number, number
function acd_client_server_status.info(cachehd, 
                                       tenant_id)
  local replies = cachehd:hgetall("ACD_CLIENT_SERVER_STATUS:" .. tenant_id)
 
  local count_all = 0
  local count_vacant = 0

  for _, staffstr in pairs(replies) do

    -- TODO: fix
    staffstr, _ = json.decode(staffstr)
    local staff, _ = json.decode(staffstr)
    
    count_all = count_all + 1

    if staff["onlineStatus"] == "idle" 
      or staff["hotlineStatus"] == "idle" 
      or staff["videoStatus"] == "idle" then

      count_vacant = count_vacant + 1
    
    end
  
  end

  return count_all, count_vacant, count_all - count_vacant

end

return acd_client_server_status
