local is_prior = require("acd.alg.is_prior")

-- compare_client
-- Is new_client has higher priority?
--
-- Returns: boolean
local function compare_client(rule,
                              client,
                              new_client)
  local cond = is_prior(rule.client_class, client.client_class, new_client.client_class)
  
  if cond == 1 then

    return true

  elseif cond == 2 then

    cond = is_prior(rule.district, client.district, new_client.district)

    if cond == 1 then

      return true

    elseif cond == 2 then

      if client.entry_time > new_client.entry_time then

        return true

      else

        return false

      end

    else

      return false

    end

  else

    return false

  end



end

return compare_client
