-- reverse proxy .init.lua
-- author: 752963e64 - 18/11/2024

HidePath('/usr/')
HidePath('/.lua/')

-- rebranding for the show.
ProgramBrand('reverse_beam/x.x.x')

-- Proxy server listening here
FRONTEND = '6.6.6.6'
ProgramAddr(FRONTEND)
-- we'll be reverse proxying to a server running here
BACKEND = '127.0.0.1:8080'

RELAY_HEADERS_TO_CLIENT = {
  'Access-Control-Allow-Origin',
  'Cache-Control',
  'Connection',
  'Content-Type',
  'Last-Modified',
  'Referrer-Policy',
}

function OnHttpRequest()
  print('\e[01;36mOnHttpRequest()...\e[0m')

  print('\e[01;33mGetParams\e[0m')
  local url = 'https://' .. BACKEND .. EscapePath(GetPath())
  local rparams = GetParams()
  if #rparams > 0 then
    url = url .. '?'
    for i, v in ipairs(rparams) do
      -- print('"'..EscapeParam(v[1])..'" "'..EscapeParam(v[2])..'"')
      url = url .. EscapeParam(v[1])..'='..EscapeParam(v[2])..((i < #rparams) and '&' or '')
    end
  end
    
  print('\e[01;33mGetHeaders\e[0m')
  local tabl = GetHeaders()
  for i, v in pairs(tabl) do
    print('"'..i..'" - "'..v..'"')
  end

  -- forward header
  local status, headers, body =
      Fetch(url,
          {method = GetMethod(),
            headers = {
              ['Accept'] = GetHeader('Accept'),
              ['Host'] = GetHost(),
              ['Referer'] = GetHeader('Referer'),
              ['If-Modified-Since'] = GetHeader('If-Modified-Since'),
              ['Sec-CH-UA-Platform'] = GetHeader('Sec-CH-UA-Platform'),
              ['User-Agent'] = GetHeader('User-Agent'),
              ['X-Forwarded-For'] = FormatIp(ip)}})
  if status then
    -- reply
    print('status:'..status)
    SetStatus(status)
    for k,v in pairs(RELAY_HEADERS_TO_CLIENT) do
      SetHeader(v, headers[v])
    end
    Write(body)
    return
  end
  
  local err = headers
  Log(kLogError, "proxy failed %s" % {err})
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

