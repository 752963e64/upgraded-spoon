-- web_static_analysis .init.lua
-- author: 752963e64 - 22/11/2024

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


ProgramBrand(opts.SERVER_BRAND)

ProgramAddr(opts.SERVER_ADDR)

local page = "<!DOCTYPE html>\r\n"

page = page .. [[<head>
<meta charset="utf-8">
<meta name="viewport" content="width=1024">
<title>Web scraping</title>
<link rel="canonical" href="https://">
<style>
body { text-align:center; background-color:#fdfdfd; color:#2d2d2d; font-size:1.8em;
  font-family:monospace; font-weight:700; line-height:125%; }
#container { width:800px; margin:auto; }
pre { text-align:left; font-size:0.5em; line-height:125%; margin:auto; }
p { color:#5d5d5d; font-size:0.6em; }
#intro { margin:auto; }
a { text-decoration:none; color:#ac0fb0; }
li { font-size:0.7em; font-weight:700; }
hr { width:30%; }
</style>
<script></script>
<body>]]

function OnHttpRequest()
  print('\e[01;36mOnHttpRequest()...\e[0m')

  --[[
  if HasParam('url') then
    url = GetParam('url')
    Log(kLogInfo, 'client:%s looking at %s' % {FormatIp(GetClientAddr()), VisualizeControlCodes(url)})
  end
  ]]

  SetStatus(200)
  SetHeader('Connection', 'close')
  Write(page..form)
  Write('<br><label for="header">HEADER:</label><br><pre id="header">')
  Write(Slurp('../.git/logs/HEAD')..'\n')
  --[[file .git/objects/02/3658702097935ff4cbb74dd63da29a679e6286 
  .git/objects/02/3658702097935ff4cbb74dd63da29a679e6286: zlib compressed data]]  
  Write('</pre>')
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

--[[ function OnServerHeartbeat()
  print('\e[01;36mOnServerHeartbeat()...\e[0m')
end ]]

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

