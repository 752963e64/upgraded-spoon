-- signed_cake_slice session.lua
-- author: 752963e64 - 22/11/2024

if type(opts) == 'table' then
  -- loads config
  opts['SESSION_DOMAIN'] = 'localhost'
  opts['SESSION_TIME'] = 60 -- seconds
  opts['SESSION_ID'] = 'ctx_session'
  opts['SESSION_SKEY'] = 'skey_session'
  opts['SESSION_PATH'] = {
    ROOT = '/',
    APP = '/app',
    POST = '/catch'
  }
  opts['SESSION_SECURE'] = true
  opts['SESSION_HTTP'] = true
  opts['SESSION_SS'] = 'Strict'
  opts['SESSION_SECRET'] = GetRandomBytes(64)
  opts['SESSION_PASSPHRASE'] = 'curvy dead alive'
  opts['SESSION_PUBLIC_KEY'] = Curve25519(opts.SESSION_SECRET, opts.SESSION_PASSPHRASE)
else
  Log(kLogError, 'missing opts config table...')
end

function SendSession(id, value)
  SetCookie(
    id,
    value,
    {
      maxage = opts.SESSION_TIME,
      path = opts.SESSION_PATH.ROOT,
      domain = opts.SESSION_DOMAIN,
      secure = opts.SESSION_SECURE,
      httponly = opts.SESSION_HTTP,
      samesite = opts.SESSION_SS
    }
  )
end

function GetSession(id)
  return GetCookie(id)
end
