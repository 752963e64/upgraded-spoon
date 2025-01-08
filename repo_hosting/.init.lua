-- reverse proxy .init.lua
-- author: 752963e64 - 18/11/2024

require 'opts'

HidePath('/usr/')
HidePath('/.lua/')

function OnHttpRequest()
  print('\e[01;36mOnHttpRequest()...\e[0m')
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

function OnServerListen(sockfd,rip,rport)
  print('\e[01;36mOnServerListen(sockfd:' .. sockfd .. ', rip:' .. rip .. ', rport:' .. rport ..')...\e[0m')
end

function OnServerStart()
  print('\e[01;36mOnServerStart()...\e[0m')
end

function OnServerStop()
  print('\e[01;36mOnServerStop()...\e[0m')
end

function OnClientConnection(ip,port,rip,rport)
  print('\e[01;36mOnClientConnection(ip:'.. ip ..', port:'.. port ..',rip:'.. rip ..',rport:'.. rport ..')...\e[0m')
end

function OnServerHeartBeat(status,message)
  print('\e[01;36mOnServerHeartBeat(status:'.. status ..', message:'.. message ..')...\e[0m')
end

function OnLogLatency(reqtimeus,contimeus)
  print('\e[01;36mOnLogLatency(reqtimeus:'.. reqtimeus ..', contimeus:'.. contimeus ..')...\e[0m')
end

function OnError(status,message)
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

