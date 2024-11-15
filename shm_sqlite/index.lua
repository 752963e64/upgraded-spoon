-- index.lua

local answer = false

if db then answer = true end

local look = GetCookie(opts.SESSION_ID)
if look then
  look = re.compile('^[0-9a-f]{64}$'):search(look)
end

print('\e[01;31mYay output with goodies...\e[0m', look, answer, opts.SESSION_DOMAIN)
