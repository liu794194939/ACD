local compare = {}

-- moreThan
--
-- Returns: true or false
function compare.moreThan(p, 
                          c) 
  return p > c

end

-- lessThan
--
-- Returns: true or false
function compare.lessThan(p,
                          c)
  return p < c

end

-- equals
--
-- Returns: true or false
function compare.equals(p,
                        c)
  return p == c
                       
end

return compare
