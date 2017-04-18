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
local function dump(obj)
    local getIndent, quoteStr, wrapKey, wrapVal, dumpObj
    getIndent = function(level)
        return string.rep("\t", level)
    end
    quoteStr = function(str)
        return '"' .. string.gsub(str, '"', '\\"') .. '"'
    end
    wrapKey = function(val)
        if type(val) == "number" then
            return "[" .. val .. "]"
        elseif type(val) == "string" then
            return "[" .. quoteStr(val) .. "]"
        else
            return "[" .. tostring(val) .. "]"
        end
    end
    wrapVal = function(val, level)
        if type(val) == "table" then
            return dumpObj(val, level)
        elseif type(val) == "number" then
            return val
        elseif type(val) == "string" then
            return quoteStr(val)
        else
            return tostring(val)
        end
    end
    dumpObj = function(obj, level)
        if type(obj) ~= "table" then
            return wrapVal(obj)
        end
        level = level + 1
        local tokens = {}
        tokens[#tokens + 1] = "{"
        for k, v in pairs(obj) do
            tokens[#tokens + 1] = getIndent(level) .. wrapKey(k) .. " = " .. wrapVal(v, level) .. ","
        end
        tokens[#tokens + 1] = getIndent(level - 1) .. "}"
        return table.concat(tokens, "\n")
    end
    return dumpObj(obj, 0)
end

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
	   send_package("Returned from server:"..args)
	   if db then
	   res = db:query("insert into device_log values (null,0,'device_name111111',  'protocol_version',  'device_imei' ,  'device_name',  'gprs_flag',  'date',  'time' ,  123131 , null , null,  'gps_flag', null , null,  'n', null , null,  'long',  'beidou_num',  'gps_num',  'glonass_num',  '0.00000',  '0.00000', '0.00000',  'altitude',  'mileage',  '0',  '0',  null, null,  'mcc',  'mnc',  'lac' ,  'cell_id','0',  '0',  '0',  '0',  '0',  '0',  '0.00000',  '0.00000',  '0',  '0' ,  'battery',  'alarm_events',  'CRC' ,  0)")
	   print( dump( res ) )
	   end
	end
}

function CMD.start(conf)
	local fd = conf.client
	local gate = conf.gate
	WATCHDOG = conf.watchdog
	skynet.fork(function()
		while true do
			send_package("heartbeat")
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

skynet.start(function()
      	db=mysql.connect({
		host="127.0.0.1",
		port=3306,
		database="gps",
		user="root",
		password="",
		max_packet_size = 1024 * 1024,
		on_connect = on_connect
	})
	if not db then
		print("failed to connect db")
	end
--	res = db:query("select * from device_log")
--	print ( dump( res ) )
--	res = db:query("insert into device_log values (null,0,'device_name111111',  'protocol_version',  'device_imei' ,  'device_name',  'gprs_flag',  'date',  'time' ,  123131 , null , null,  'gps_flag', null , null,  'n', null , null,  'long',  'beidou_num',  'gps_num',  'glonass_num',  '0.00000',  '0.00000', '0.00000',  'altitude',  'mileage',  '0',  '0',  null, null,  'mcc',  'mnc',  'lac' ,  'cell_id','0',  '0',  '0',  '0',  '0',  '0',  '0.00000',  '0.00000',  '0',  '0' ,  'battery',  'alarm_events',  'CRC' ,  0)")



	skynet.dispatch("lua", function(_,_, command, ...)
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
end)
