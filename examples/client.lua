package.cpath = "luaclib/?.so"
package.path = "lualib/?.lua;examples/?.lua"

if _VERSION ~= "Lua 5.3" then
	error "Use lua 5.3"
end

local socket = require "clientsocket"
local proto = require "proto"
local sproto = require "sproto"

local host = sproto.new(proto.s2c):host "package"
local request = host:attach(sproto.new(proto.c2s))

local fd = assert(socket.connect("127.0.0.1", 8888))

local function send_package(fd, pack)
	local package = string.pack(">s2", pack)
	socket.send(fd, package)
end

local function unpack_package(text)
	local size = #text
	if size < 2 then
		return nil, text
	end
	local s = text:byte(1) * 256 + text:byte(2)
	if size < s+2 then
		return nil, text
	end

	return text:sub(3,2+s), text:sub(3+s)
end

local function recv_package(last)
	local result
	result, last = unpack_package(last)
	if result then
		return result, last
	end
	local r = socket.recv(fd)
	if not r then
		return nil, last
	end
	if r == "" then
		error "Server closed"
	end
	return unpack_package(last .. r)
end

local session = 0

local function send_request(name, args)
	session = session + 1
	str = name..","..args..","..session
	send_package(fd, str)
	print("Request:", str)
end

local last = ""

local function print_request(name, args)
	print("REQUEST", name)
	if args then
		for k,v in pairs(args) do
			print(k,v)
		end
	end
end

local function print_response(session, args)
	print("RESPONSE", session)
	if args then
		for k,v in pairs(args) do
			print(k,v)
		end
	end
end

local function print_package(t, ...)
	if t == "REQUEST" then
		print_request(...)
	else
		assert(t == "RESPONSE")
		print_response(...)
	end
end

local function dispatch_package()
	while true do
		local v
		v, last = recv_package(last)
		if not v then
			break
		end
		print(v)
	end
end

while true do
	dispatch_package()
	local cmd = socket.readstdin()
	if cmd then
		if cmd == "quit" then
			send_request("quit")
		else
		   --		   send_request("REQUEST", "MGV002,861694034616795,GongAn0001,R,190417,100703.00,V,4001.6080,N,11616.3807,E,0,00,0,99.9,0.00,149.38,-8.9,54.4,460,00,1019,7ec5, 1,,0,0,0,153,0,0,0,0,87,Timer;28!")
		   --http://url/index.php?m=Api&c=preview&a=getPhonePosition&phone_number=1396969658&police_name=minjingname&lng=116.325066&lat=39.93702&police_id=33
		   --send_request("putPhonePosition", "1396969658,minjingname,116.325066,39.93702,33")
		   send_request("setUID", "0123456")
		   
		end
	else
		socket.usleep(100)
	end
end
