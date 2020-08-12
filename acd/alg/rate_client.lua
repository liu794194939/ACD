local compare_client = require("acd.alg.compare_client")

-- rate_client
-- 
-- Args:
--   clients: A table representing all waiting clients by score from low to high.
--   
-- Returns: The first value is nil or string, the second value is NaN or number.
local function rate_client(rule,
                           clients,
                           new_client)
  if #clients == 0 then

    return nil, NaN

  end

  for _, client in ipairs(clients) do

    -- If new_client has lower priority than client, stop the loop.
    if compare_client(rule, client, new_client) == false then

      return client.req_id, -1

    end

  end
 
  -- new_client has the highest priority.
  return clients[#clients].req_id, 1

end

return rate_client
