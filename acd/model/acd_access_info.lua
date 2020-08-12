local json = require("dkjson")

local acd_access_info = {}

-- get_tenant_id
--
-- Returns: string
function acd_access_info.get_tenant_id(cachehd, 
                                       access_id)
  -- TODO: fix
  access_id = json.encode(access_id)

  local tenantstr = cachehd:hget("ACD_ACCESS_INFO", access_id)
  
  if tenantstr == nil then
    
    return ""

  end

  -- TODO: fix
  tenantstr, _ = json.decode(tenantstr)
  local tenant, _ = json.decode(tenantstr)

  local tenant_id = tenant.tenantId

  if tenant_id == nil then

    return ""

  end
  
  return tenant_id

end

return acd_access_info
