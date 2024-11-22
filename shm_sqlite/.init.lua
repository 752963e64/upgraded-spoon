-- shm_sqlite .init.lua
-- author: 752963e64 - 14/11/2024

require 'opts'

if type(opts) == 'table' then
  -- loads config
  opts['SERVER_ADDR'] = '127.0.0.1'
  opts['SERVER_BRAND'] = 'redbean/x.x.x'
else
  Log(kLogError, 'missing opts config table...')
end

require 'strtools'

session = require "Session"

HidePath('/usr/')
HidePath('/.lua/')

ProgramBrand(opts.SERVER_BRAND)

ProgramAddr(opts.SERVER_ADDR)

opts = {
  SESSION_DOMAIN = 'localhost',
  SESSION_TIME = 60, -- seconds
  SESSION_ID = 'ctx_session',
  SESSION_PATH = {
    ROOT = '/',
    APP = '/app',
    POST = '/catch'
  },
  SESSION_SECURE = true,
  SESSION_HTTP = true
}

db = session:new(require "lsqlite3")

function OnServerListen(fd, ip, port)
  print('\e[01;36mOnServerListen(%d, %d, %d)...\e[0m' %
    { fd, ip, port }
  )
  syn, synerr = unix.setsockopt(fd, unix.SOL_TCP, unix.TCP_SAVE_SYN, true)
  if not syn then
    Log(kLogInfo, "setsockopt crashed with %d" % { synerr })
  end
  -- return false
end

function OnClientConnection(ip, port, serverip, serverport)
  print('\e[01;36mOnClientConnection(ip:%s port:%s serverip:%s serverport:%s\e[0m' %
    { ip, port, serverip, serverport }
  )
  syn, synerr = unix.getsockopt(GetClientFd(), unix.SOL_TCP, unix.TCP_SAVED_SYN)
  fingeros = finger.GetSynFingerOs(finger.FingerSyn(syn))
  if not syn then
    Log(kLogInfo, "getsockopt crashed with %d" % { synerr })
  end
end

function OnHttpRequest()
  print('\e[01;36mOnHttpRequest()...\e[0m')
  if GetHost() ~= opts.SESSION_DOMAIN then
    ServeError(404)
    return
  end
  
  errmsg = nil
  session_ctx = nil
  useragent = re.compile('^Mozilla/5.0[a-zA-Z0-9()/._;:, ]{8,255}$'):search(GetHeader('User-Agent'))
  raddr = GetClientAddr()

  if useragent then
    Log(kLogInfo, "client %d trusted:%s is running %s and reports %s looking to %s" % {
      raddr,IsTrustedIp(raddr),
      fingeros, useragent, GetPath()
      })
  else
    Log(kLogInfo, '\e[01;36mWeb browser doesn\'t qualify for %d\e[0m' % {raddr})
    errmsg = '# Your web browser doesn\'t qualify to access our services.'
    ServeError(403)
    return
  end

  if GetCookie(opts.SESSION_ID) then
    session_ctx = re.compile[[^[0-9a-f]{64}$]]:search(GetCookie(opts.SESSION_ID))
  end

  if session_ctx and session_ctx ~= '' then
    print('path:%s %s:%s' % { GetPath() ,opts.SESSION_ID, session_ctx })
    -- route design asset before session and return.
    -- authenticate only the information and values.
    if not db:reset_lastseen(raddr, session_ctx, useragent) then
      ServeError(400)
      return
    end
    -- route somewhere wonderful...
  else
    session_ctx = bin2Hex(Sha256(''..raddr..Lemur64()..GetTime()))
    local rid = db:add_session(
      raddr,
      useragent,
      fingeros,
      session_ctx
    )

    if rid == nil then
      Log(kLogInfo, '\e[01;36msession limit has been reached for %d\e[0m' % {raddr})
      errmsg = '# session limit has been reached for %d;\n' % {raddr}
      errmsg = errmsg..'# Try back in a moment and if problem persist send us a mail with "SESSION[%d]" as object. Thanks' % {raddr}
      ServeError(403)
      return
    end

    SetCookie(
      opts.SESSION_ID,
      session_ctx,
      {
        maxage = opts.SESSION_TIME,
        path = opts.SESSION_PATH.ROOT,
        domain = opts.SESSION_DOMAIN,
        secure = opts.SESSION_SECURE,
        httponly = opts.SESSION_HTTP
      }
    )
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
