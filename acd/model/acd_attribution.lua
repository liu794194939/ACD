local json = require("dkjson")

local acd_attribution = {}

-- get
--
-- Returns: string
function acd_attribution.get(cachehd, 
                             phone)
  local key = "ACD_ATTRIBUTION"

  local phone_prefix = string.sub(phone, 1, 7)

  -- TODO: fix
  phone_prefix = json.encode(phone_prefix)

  local districtstr = cachehd:hget(key, phone_prefix)

  if districtstr == nil then

    return ""
    
  end

  -- TODO: fix
  districtstr, _ = json.decode(districtstr)
  local district, _ = json.decode(districtstr)

  return district.city

end

return acd_attribution
