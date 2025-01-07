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

function NewKeyPairSession()
  session_ctx = bin2Hex(Sha256(''..GetClientAddr()..Lemur64()..GetTime()))
  session_pubkey = Curve25519(session_ctx, opts.SESSION_PASSPHRASE)
  session_shared_key = bin2Hex(Curve25519(opts.SESSION_SECRET, session_pubkey))
  SendKeyPairSession({ { opts.SESSION_ID, session_ctx } , { opts.SESSION_SKEY, session_shared_key } })
  return session_ctx, session_shared_key
end

function SendKeyPairSession(keycombo)
  local v
  for v=1,#keycombo do
    SetCookie(
      keycombo[v][1],
      keycombo[v][2],
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
end

function GetKeyPairSession(id,skey)
  if GetCookie(id) and GetCookie(skey) then
    return re.compile[[^[0-9a-f]{64}$]]:search(GetCookie(id)),
      re.compile[[^[0-9a-f]{64}$]]:search(GetCookie(skey))
  end  
  return nil
end

function ValidateKeyPairSession(id, skey)
  sskey = bin2Hex(Curve25519(id, opts.SESSION_PUBLIC_KEY))
  return sskey == skey
end
