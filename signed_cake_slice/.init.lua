-- signed_cake_slice .init.lua
-- author: 752963e64 - 22/11/2024

require 'opts'

if type(opts) == 'table' then
  -- loads config
  opts['SERVER_ADDR'] = '127.0.0.1'
  opts['SERVER_BRAND'] = 'redbean/x.x.x'
else
  Log(kLogError, 'missing opts config table...')
end

require 'strtools'
require 'session'

HidePath('/usr/')
HidePath('/.lua/')

ProgramBrand(opts.SERVER_BRAND)
ProgramAddr(opts.SERVER_ADDR)

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
  errmsg = nil

  if GetHost() ~= opts.SESSION_DOMAIN then
    ServeError(404)
    errmsg = 'Your webbrowser misbehaving with domain...'
    return
  end

  session_id, session_skey = GetKeyPairSession(opts.SESSION_ID, opts.SESSION_SKEY)
  if session_id and session_skey then
    if ValidateKeyPairSession(session_id, session_skey) then
      print("EVERYTHING OKAY :)")
    else
      errmsg = 'Your webbrowser misbehaving with cookies...'
      ServeError(403)
      return
    end
  else
    -- craft session and send it. see .lua/session.lua
    session_ctx, session_shared_key = NewKeyPairSession()
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
