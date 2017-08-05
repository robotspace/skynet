local skynet = require "skynet"
local socket = require "socket"
local string = require "string"
local websocket = require "websocket"
local httpd = require "http.httpd"
local urllib = require "http.url"
local sockethelper = require "http.sockethelper"
require "skynet.manager"	-- import skynet.register

local handler = {}


function str_split(s, c)
        if not s then return nil end 

        local m = string.format("([^%s]+)", c)
        local t = {}
        local k = 1 
        for v in string.gmatch(s, m) do
                t[k] = v 
                k = k + 1 
        end 
        return t
end

function handler.on_open(ws)
    print(string.format("%d::open", ws.id))
end

function handler.on_message(ws, message)
   print(string.format("%d receive:%s", ws.id, message))
   local r = -1
   local split_content = str_split(message,",")
   print(split_content[1])
   if(split_content[1] == "notify") then
      print("entrance into set case...")
      r = skynet.call("WATCHDOG","lua","push",split_content[2],split_content[3])
      print("notify result:" ..r)
      ws:send_text(r.."")--not integer but only string can been sent,why?
   else
   local r = skynet.call("SIMPLEDB", "lua", "get", "lzp_item")
   ws:send_text(r .. "from server")
   end
    ws:close()
end

function handler.on_close(ws, code, reason)
    print(string.format("%d close:%s  %s", ws.id, code, reason))
end

local function handle_socket(id)
    -- limit request body size to 8192 (you can pass nil to unlimit)
    local code, url, method, header, body = httpd.read_request(sockethelper.readfunc(id), 8192)
    if code then
        
        if url == "/ws" then
            local ws = websocket.new(id, header, handler)
            ws:start()
        end
    end


end

skynet.start(function()
    local address = "0.0.0.0:8001"
    skynet.error("Listening "..address)
    local id = assert(socket.listen(address))
    socket.start(id , function(id, addr)
       socket.start(id)
       pcall(handle_socket, id)
    end)
    skynet.register "WEBSOCKET"
end)
