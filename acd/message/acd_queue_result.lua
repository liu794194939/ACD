local json = require("dkjson")

local acd_queue_result = {}

-- send
--
-- Returns: number
function acd_queue_result.send(cachehd, 
                               req)
  -- TODO: fix
  req["@class"] = "com.vcread.unioncloud.common.api.AcdQueueResult"

  local msg = json.encode(req)

  local reply = cachehd:publish("ACD_QUEUE_RESULT", msg)

  return reply

end

return acd_queue_result
