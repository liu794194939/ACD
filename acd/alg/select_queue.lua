local is_subset = require("acd.alg.is_subset")
local split_skillstr = require("acd.alg.split_skillstr")

-- select_queue
--
-- Returns: string
local function select_queue(queues,
                            skillstr)
  local skills = split_skillstr(skillstr)
 
  local names = {}
  
  for _, queue in pairs(queues) do

    if queue.occupied < queue.capacity then
         
      if is_subset(queue.skills, skills) then

        return queue.id

      end

    end

  end

  return ""

end

return select_queue
