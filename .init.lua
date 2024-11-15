-- .init.lua
local session = require "Session"
-- ddos protection
-- ProgramTokenBucket()

HidePath('/usr/')
HidePath('/.lua/')

ProgramBrand('redbean/x.x.x')

-- ProgramAddr('127.0.0.1')

opts = {
  HOSTNAME = 'localhost',
  SESSION_TIME = 60, -- seconds
  SESSION_ID = 'ctx_session',
  SESSION_PATH = {
    ROOT = '/',
    APP = '/app',
    POST = '/catch'
  }
}

errmsg = {}

db = session:new(require "lsqlite3")

function bin2Hex(bin)
  local hexstr = ""
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

function OnServerListen(fd, ip, port)
  print('\e[01;36mOnServerListen(%d, %d, %d)...\e[0m' %
    { fd, ip, port }
  )
  local syn, synerr = unix.setsockopt(fd, unix.SOL_TCP, unix.TCP_SAVE_SYN, true)
  if not syn then
    Log(kLogInfo, "setsockopt crashed with %d" % { synerr })
  end
  -- return false
end

function OnClientConnection(ip, port, serverip, serverport)
  print('\e[01;36mOnClientConnection(ip:%s port:%s serverip:%s serverport:%s\e[0m' %
    { ip, port, serverip, serverport }
  )
  local syn, synerr = unix.getsockopt(GetClientFd(), unix.SOL_TCP, unix.TCP_SAVED_SYN)
  fingeros = finger.GetSynFingerOs(finger.FingerSyn(syn))
  if not syn then
    Log(kLogInfo, "getsockopt crashed with %d" % { synerr })
  end
end

function OnHttpRequest()
  print('\e[01;36mOnHttpRequest()...\e[0m')
  if GetHost() ~= opts.HOSTNAME then
    ServeError(404)
    return
  end

  local session_ctx = nil
  local useragent = re.compile('^Mozilla/5.0[a-zA-Z0-9()/._;, ]{8,255}$'):search(GetHeader('User-Agent'))
  local clientaddr = GetClientAddr()

  if useragent then
    Log(kLogInfo, "client %d trusted:%s is running %s and reports %s looking to %s" % {
      clientaddr,IsTrustedIp(clientaddr),
      fingeros, useragent, GetPath()
      })
  else
    Log(kLogInfo, '\e[01;36mWeb browser doesn\'t qualify for %d\e[0m' % {clientaddr})
    errmsg[tostring(clientaddr)] = '# Your web browser doesn\'t qualify to access our services.'
    ServeError(403)
    return
  end

  if GetCookie(opts.SESSION_ID) then
    session_ctx = re.compile[[^[0-9a-f]{64}$]]:search(GetCookie(opts.SESSION_ID))
  end

  if session_ctx and session_ctx ~= '' then
    print('path:%s %s:%s' % { GetPath() ,opts.SESSION_ID, session_ctx })
    -- trying to trick session db?
    if not db:reset_lastseen(clientaddr, session_ctx, useragent) then
      ServeError(400)
      return
    end
    -- route somewhere wonderful...
  else
    session_ctx = bin2Hex(Sha256(''..clientaddr..Lemur64()..GetTime()))
    local rid = db:add_session(
      clientaddr,
      useragent,
      fingeros,
      session_ctx
    )

    if rid == nil then
      clientaddr = tostring(clientaddr)
      Log(kLogInfo, '\e[01;36msession limit has been reached for %d\e[0m' % {clientaddr})
      errmsg[clientaddr] = '# session limit has been reached for %d;\n' % {clientaddr}
      errmsg[clientaddr] = errmsg[clientaddr]..'# Try back in a moment and if problem persist send us a mail with "SESSION[%d]" as object. Thanks' % {clientaddr}
      ServeError(403)
      return
    end

    SetCookie(
      opts.SESSION_ID,
      session_ctx,
      {
        maxage = opts.SESSION_TIME,
        path = opts.SESSION_PATH.ROOT,
        domain = opts.HOSTNAME,
        secure = true,
        httponly = true
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
  local clientaddr = tostring(GetClientAddr())
  print('\e[01;36mOnError(status:'.. status ..', message:'.. message ..') to:%s...\e[0m' % { clientaddr } )
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
  if errmsg[clientaddr] ~= nil then
    Write("<p><small>%s</small></p>" %{ errmsg[clientaddr] })
    errmsg[clientaddr] = nil
  end
end
