-- signed_cake_slice index.lua
-- author: 752963e64 - 22/11/2024

local sha2 = GetCookie(opts.SESSION_ID)
local signed = GetCookie(opts.SESSION_SKEY)

if sha2 and signed then
  sha2 = re.compile('^[0-9a-f]{64}$'):search(sha2)
  signed = re.compile('^[0-9a-f]{64}$'):search(signed)
end

print('\e[01;31mYay output with goodies...\e[0m', sha2, signed, opts.SESSION_DOMAIN)

Write('<h1>Hello, World<h2>cookie: ')
if sha2 ~= nil then
  Write(sha2)
else
  Write('no cookie :/')
end
