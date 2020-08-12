-- split_keystr
--
-- Returns: table
local function split_keystr(keystr)

  local segs = {}

  for v in string.gmatch(keystr, "[^:]+") do

    table.insert(segs, v)

  end

  return segs

end

return split_keystr
