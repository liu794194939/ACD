local json = require("dkjson")

local acd_customer_type = {}

-- get
--
-- Returns: string
function acd_customer_type.get(cachehd, 
                               tenant_id,
                               phone)
  local key = "ACD_CUSTOMER_TYPE:" .. tenant_id

  -- TODO: fix
  phone = json.encode(phone)

  local classstr = cachehd:hget(key, phone)

  if classstr == nil then

    return ""

  end

  -- TODO: fix
  local class, _ = json.decode(classstr)

  return class

end

return acd_customer_type
