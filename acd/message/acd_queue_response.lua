local json = require("dkjson")

local acd_queue_response = {}

-- send
--
-- Returns: number
function acd_queue_response.send(cachehd,
                                 res)
  -- TODO: fix
  res["@class"] = "com.vcread.unioncloud.common.api.QueueResponse"

  local msg = json.encode(res)

  local reply = cachehd:publish("ACD_QUEUE_RESPONSE", msg)

  return reply

end

return acd_queue_response
