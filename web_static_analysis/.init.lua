-- web static analysis .init.lua
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

RELAY_HEADERS_TO_CLIENT = {
  'Access-Control-Allow-Origin',
  'Cache-Control',
  'Connection',
  'Content-Type',
  'Last-Modified',
  'Referrer-Policy',
}

heartbeat = 0

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

form = [=[<div id="container"><form action="/" method="get">
<label for="url">URL:</label><br>
<input type="text" id="url" name="url" value="https://..."><br>
<input type="submit" value="Submit">
</form></div>]=]


function OnHttpRequest()
  print('\e[01;36mOnHttpRequest()...\e[0m')

  if HasParam('url') then
    url = GetParam('url')
    Log(kLogInfo, 'client:%s looking at %s' % {FormatIp(GetClientAddr()), VisualizeControlCodes(url)})
  end
  
  SetStatus(200)
  SetHeader('Connection', 'close')
  Write(page..form)

  if url and url ~= '' then
    local status, headers, body =
      Fetch(url,
        {method = 'GET',
          headers = {
            ['DNT'] = '1',
            ['Accept'] = GetHeader('Accept'),
            ['Host'] = GetHost(),
            ['Referer'] = GetHeader('Referer'),
            ['If-Modified-Since'] = GetHeader('If-Modified-Since'),
            ['Sec-CH-UA-Platform'] = GetHeader('Sec-CH-UA-Platform'),
            ['User-Agent'] = 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/113.0',
            ['X-Forwarded-For'] = FormatIp(GetClientAddr())}})
    if status then
      -- reply
      Write('<br><label for="header">HEADER:</label><br><pre id="header">')
      Write('Status: '..status..' '..GetHttpReason(status))
      for i, v in pairs(headers) do
        Write('"'..VisualizeControlCodes(i)..'": "'..VisualizeControlCodes(v)..'"\n')
      end
      Write('</pre>')
      Write('<br><label for="body">BODY:</label><br><pre id="body">'..EscapeHtml(body)..'</pre>')
      return
    end
  
    local err = headers
    Log(kLogError, "fetch failed %s" % {err})
    ServeError(503)
  end

  if body then Write('<pre>'..body..'</pre>') end
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

