-- signed_cake_slice .init.lua
-- author: 752963e64 - 22/11/2024

HidePath('/usr/')
HidePath('/.lua/')

ProgramBrand('redbean/x.x.x')

ProgramAddr('127.0.0.1')

opts = {}
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

function SendCookie(id, value)
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

function OnServerListen(fd, ip, port)
  print('\e[01;36mOnServerListen(%d, %d, %d)...\e[0m' %
    { fd, ip, port }
  )
end

function OnClientConnection(ip, port, serverip, serverport)
  print('\e[01;36mOnClientConnection(ip:%s port:%s serverip:%s serverport:%s\e[0m' %
    { ip, port, serverip, serverport })
end

function OnHttpRequest()
  print('\e[01;36mOnHttpRequest()...\e[0m')
  if GetHost() ~= opts.SESSION_DOMAIN then
    ServeError(404)
    return
  end

  errmsg = nil

  if GetCookie(opts.SESSION_ID) and GetCookie(opts.SESSION_SKEY) then
    session_ctx = re.compile[[^[0-9a-f]{64}$]]:search(GetCookie(opts.SESSION_ID))
    sskey = bin2Hex(Curve25519(session_ctx, opts.SESSION_PUBLIC_KEY))
    uskey = GetCookie(opts.SESSION_SKEY)
    if sskey == uskey then
      print("EVERYTHING OKAY :)", uskey, sskey)
    else
      errmsg = 'Your webbrowser misbehaving with cookies...'
      ServeError(403)
    end
  else
    -- craft session
    session_ctx = bin2Hex(Sha256(''..GetClientAddr()..Lemur64()..GetTime()))
    session_pubkey = Curve25519(session_ctx, opts.SESSION_PASSPHRASE)
    session_shared_key = Curve25519(opts.SESSION_SECRET, session_pubkey)
    SendCookie(opts.SESSION_ID, session_ctx)
    SendCookie(opts.SESSION_SKEY, bin2Hex(session_shared_key))
  end

  Route()
end

function OnWorkerStart()
  print('\e[01;36mOnWorkerStart()...\e[0m')
end

function OnWorkerStop()
  print('\e[01;36mOnWorkerStop()...\e[0m')
end

function OnProcessCreate()
  print('\e[01;36mOnProcessCreate()...\e[0m')
end

function OnProcessDestroy(pid)
  print('\e[01;36mOnProcessDestroy(pid:'.. pid ..')...\e[0m')
end

function OnServerStart()
  print('\e[01;36mOnServerStart()...\e[0m')
end

function OnServerStop()
  print('\e[01;36mOnServerStop()...\e[0m')
end

function OnServerHeartBeat(status,message)
  print('\e[01;36mOnServerHeartBeat(status:'.. status ..', message:'.. message ..')...\e[0m')
end

function OnLogLatency(reqtimeus,contimeus)
  print('\e[01;36mOnLogLatency(reqtimeus:'.. reqtimeus ..', contimeus:'.. contimeus ..')...\e[0m')
end

function OnError(status,message)
  print('\e[01;36mOnError(status:'.. status ..', message:'.. message ..') to:%s...\e[0m' % { raddr } )
  SetStatus(status)
  SetHeader('Connection', 'close')
  Write([[<!doctype html>]])
  Write("<title>%d %s</title>\n" %{ status, message })
  Write([[<style>]])
  Write([[html { color: #111; font-family: sans-serif; }]])
  Write([[svg { vertical-align: middle; }]])
  Write([[h1 { text-align:center; margin:25%; }]])
  Write([[</style>]])
  Write([[<h1>]])
  Write("%d %s" %{ status, message })
  Write([[</h1>]])
  if errmsg ~= nil then
    Write("<p><small>%s</small></p>" %{ errmsg })
    errmsg = nil
  end
end
