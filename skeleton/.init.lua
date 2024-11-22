-- skeleton .init.lua
-- author: 752963e64 - 22/11/2024

HidePath('/usr/')
HidePath('/.lua/')

-- rebranding for the show.
ProgramBrand('reverse_beam/x.x.x')

-- ProgramSslFetchVerify(false)

-- doesn't transmit SNI when performing fetch request.
EvadeDragnetSurveillance(true)

-- Proxy server listening here
SERVER_ADDR = '127.0.0.1'

ProgramAddr(SERVER_ADDR)

heartbeat = 0

function OnHttpRequest()
  print('\e[01;36mOnHttpRequest()...\e[0m')
  Log(kLogError, "fetch failed %s" % {err})
  ServeError(503)
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

function OnServerListen(sockfd, rip, rport)
  print('\e[01;36mOnServerListen(sockfd:' .. sockfd .. ', rip:' .. rip .. ', rport:' .. rport ..')...\e[0m')
end

function OnServerStart()
  print('\e[01;36mOnServerStart()...\e[0m')
end

function OnServerStop()
  print('\e[01;36mOnServerStop()...\e[0m')
end

function OnClientConnection(ip, port, rip, rport)
  print('\e[01;36mOnClientConnection(ip:'.. ip ..', port:'.. port ..',rip:'.. rip ..',rport:'.. rport ..')...\e[0m')
end

function OnServerHeartbeat()
  print('\e[01;36mOnServerHeartbeat()...\e[0m', heartbeat)
  heartbeat = heartbeat+1
end

function OnLogLatency(reqtimeus, contimeus)
  print('\e[01;36mOnLogLatency(reqtimeus:'.. reqtimeus ..', contimeus:'.. contimeus ..')...\e[0m')
end

function OnError(status, message)
  print('\e[01;36mOnError(status:'.. status ..', message:'.. message ..')...\e[0m')
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
end

