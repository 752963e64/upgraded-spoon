-- memory_test .init.lua
-- author: 752963e64 - 23/11/2024

require 'opts'

if type(opts) == 'table' then
  -- loads config
  opts['SERVER_ADDR'] = '127.0.0.1'
  opts['SERVER_BRAND'] = 'redbean/x.x.x'
else
  Log(kLogError, 'missing opts config table...')
end

HidePath('/usr/')
HidePath('/.lua/')

-- rebranding for the show.
ProgramBrand(opts.SERVER_BRAND)

ProgramAddr(opts.SERVER_ADDR)

heartbeat = 0

memory1 = {}
table.insert(memory1, "test1")
table.insert(memory1, "test2")

function OnHttpRequest()
  print('\e[01;36mOnHttpRequest()...\e[0m')

  memory1[1] = "lol"
  memory1[3] = "lol"
  -- only heartbeat persist the table rewind to default value
  -- when connection close
  -- however data persist and growth with pipelined connection.
  print(heartbeat, #memory1, memory1[1])
  
  -- this will never show up outside a pipelined connection.
  table.insert(memory1, ''..GetRemoteAddr())

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
  -- print('\e[01;36mOnServerHeartbeat()...\e[0m', heartbeat)
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

