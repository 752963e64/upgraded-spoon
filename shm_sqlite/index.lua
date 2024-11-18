-- shm_sqlite index.lua
-- author: 752963e64 - 14/11/2024

answer = false

if db then answer = true end

local look = GetCookie(opts.SESSION_ID)
if look then
  look = re.compile('^[0-9a-f]{64}$'):search(look)
end

print('\e[01;31mYay output with goodies...\e[0m', look, answer, opts.SESSION_DOMAIN)

Write('<h1>Hello, World<h2>cookie: ')
if look ~= nil then
  Write(look)
else
  Write('no cookie :/')
end
