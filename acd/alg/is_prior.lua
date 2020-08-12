local find_index = require("acd.alg.find_index")

-- is_prior
-- Compare p and k's priority.
--
-- Returns: number, 1 stands that k has higher priority, 2 stands for same 
--   priority, 3 stands that k has lower prioriy.
local function is_prior(list, 
                        p, 
                        k)
  local p_group, p_index = NaN, NaN
  local k_group, k_index = NaN, NaN

  -- Find p and k.
  for i, u in ipairs(list) do

    for j, v in ipairs(u) do

      -- Find p.
      if p_group == NaN and p == v then

        p_group, p_index =  i, j 

      end

      -- Find k.
      if k_group == NaN and k == v then

        k_group, k_index = i, j 
      
      end

      -- Stop the loop if both are found.
      if p_group ~= NaN and k_group ~= NaN then

        break

      end

    end

  end

  -- Compare p and k.
  if p_group == NaN and k_group == NaN then
    
    return 2

  elseif p_group ~= NaN and k_group == NaN then

    if p_group == 3 or p_group == 4 then

      return 1

    else

      return 3

    end

  elseif p_group == NaN and k_group ~= NaN then

    if k_group == 1 or k_group == 2 then

      return 1

    else

      return 3

    end

  else

    if p_group == k_group then

      if p_index > k_index then

        return 1

      elseif p_index < k_index then

        return 3

      else

        return 2

      end

    elseif p_group > k_group then

      return 1

    else

      return 3

    end

  end

end

return is_prior
