local filter_list = require("acd.alg.filter_list")
local prior_list = require("acd.alg.prior_list")

-- get_range_must_served
--
-- Returns: table
local function get_range_must_served(rule,
                                     range_served,
                                     range_multi,
                                     range_high,
                                     range_easy)
  if rule.multi_prior == true then

    return filter_list(range_multi, range_served)

  elseif rule.high_prior == true then

    return filter_list(range_high, range_served)

  else

    return filter_list(range_easy, range_served)
  
  end
  
end

-- get_range_served_prior
--
-- Returns: table
local function get_range_served_prior(rule,
                                      range_served,
                                      range_multi,
                                      range_high,
                                      range_easy)
  if rule.multi_prior == true then

    return prior_list(range_multi, range_served)

  elseif rule.high_prior == true then

    return prior_list(range_high, range_served)

  else

    return prior_list(range_easy, range_served)
  
  end

end

-- get_range_served_irrelevant
--
-- Returns: table
local function get_range_served_irrelevant(rule,
                                           range_multi,
                                           range_high,
                                           range_easy)
  if rule.multi_prior == true then

    return range_multi

  elseif rule.high_prior == true then

    return range_high

  else

    return range_easy

  end

end

-- get_candidate_range
--
-- Returns: table
local function get_candidate_range(rule,
                                   range_served,
                                   range_multi,
                                   range_high,
                                   range_easy)
 local range = {}
 
 if rule.must_served == true then
    
   range = get_range_must_served(rule, range_served, range_multi, range_high, 
                                 range_easy)

  elseif rule.served_prior == true then

   range = get_range_served_prior(rule, range_served, range_multi, range_high, 
                                  range_easy)

  else

   range = get_range_served_irrelevant(rule, range_multi, range_high, 
                                       range_easy)

  end

  return range

end

return get_candidate_range
