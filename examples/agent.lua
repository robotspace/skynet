local skynet = require "skynet"
local netpack = require "netpack"
local socket = require "socket"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"
local WATCHDOG
local host
local send_request
local CMD = {}
local REQUEST = {}
local client_fd
local mysql = require "mysql"
local db
local iconv = require("iconv")
function REQUEST:get()
	print("get", self.what)
	local r = skynet.call("SIMPLEDB", "lua", "get", self.what)
	return { result = r }
end

function REQUEST:set()
	print("set", self.what, self.value)
	local r = skynet.call("SIMPLEDB", "lua", "set", self.what, self.value)
end

function REQUEST:handshake()
	return { msg = "Welcome to skynet, I will send heartbeat every 5 sec." }
end

function REQUEST:quit()
	skynet.call(WATCHDOG, "lua", "close", client_fd)
end

local function request(name, args, response)
	local f = assert(REQUEST[name])
	local r = f(args)
	if response then
		return response(r)
	end
end

local function send_package(pack)
	local package = string.pack(">s2", pack)
	socket.write(client_fd, package)
end

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,

        unpack = skynet.tostring,
	dispatch = function (_, _, args, ...)
	   print("args:"..args)


source="春眠不觉晓，处处闻啼鸟。夜来风雨声，花落知多少。"

print(createIconv("utf-8","gbk",source))

	   send_package("Returned from server:"..args)
	end
}



function createIconv(from,to,text)  

  local cd = iconv.new(to .. "//TRANSLIT", from)

  local ostr, err = cd:iconv(text)

  if err == iconv.ERROR_INCOMPLETE then
    return "ERROR: Incomplete input."
  elseif err == iconv.ERROR_INVALID then
    return "ERROR: Invalid input."
  elseif err == iconv.ERROR_NO_MEMORY then
    return "ERROR: Failed to allocate memory."
  elseif err == iconv.ERROR_UNKNOWN then
    return "ERROR: There was an unknown error."
  end
  return ostr
end

function CMD.start(conf)
	local fd = conf.client
	local gate = conf.gate
	WATCHDOG = conf.watchdog
	skynet.fork(function()
		while true do
--source="1234567890abcdefghijklmnopqrstuvwxyz春眠不觉晓，处处闻啼鸟。夜来风雨声，花落知多少。".."\n\r"
--send_package(createIconv("utf-8","gbk",source))
			--send_package("春眠不觉晓，处处闻啼鸟。夜来风雨声，花落知多少。".."\n\r")
			skynet.sleep(500)
		end
	end)

	client_fd = fd
	skynet.call(gate, "lua", "forward", fd)
end

function CMD.disconnect()
	-- todo: do something before exit
	skynet.exit()
end

function CMD.push(msg)
   print("agent, get push command")
source="1234567890abcdefghijklmnopqrstuvwxyz春眠不觉晓，处处闻啼鸟。夜来风雨声，花落知多少。".."\n\r"
send_package(createIconv("utf-8","gbk",source))

--	   send_package("Push from server:"..msg)
end


skynet.start(function()

	skynet.dispatch("lua", function(_,_, command, ...)
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
end)
