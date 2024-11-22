-- signed_cake_slice strtools.lua
-- author: 752963e64 - 22/11/2024

function bin2Hex(bin)
  hexstr = ""
  if bin ~= '' and type(bin) == 'string' then
    for l=#bin,1,-1 do
      hexstr = "%.2x" % {string.byte( string.sub(bin, l) )} .. hexstr
    end
  end
  if hexstr ~= "" then
    return hexstr
  else
    return nil
  end
end

