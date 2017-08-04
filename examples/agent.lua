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

function build_value1(t)
   local res = "null"
   for i=2, #(t) do --skip the first column 'type'
      if not t[i] then
	 t[i]=''
      end
      res =  res .. ',' .. t[i]
      print( t[i])
   end
   return res
end

function build_value(t)
   local res = "null"
   local pre = '\''
   local protocol_version = pre .. t[2] .. pre
   local device_id = t[3]
   local device_imei = device_id
   local device_name = pre .. t[4] .. pre
   local device_name111111 = device_name
   local gprs_data_flag = pre .. t[5] .. pre
   local date = pre ..  t[6] .. pre
   local time = pre .. t[7] .. pre
   local receiveTime = 0
   local receiveTime1 = 'null'
   local gps_time = 'null'
   local gps_flag = pre .. t[8] .. pre
   
   local latitude = (t[9] or 0)/100
   local original_lat = latitude
   local latitude_ns = pre .. t[10] .. pre
   print("latitude_ns:".. latitude_ns)
   local longitude = (t[11] or 0)/100
   local original_lng = longitude
   local longitude_we = pre .. t[12] .. pre
   local beidou_num = t[13]
   local gps_num = t[14]
   local glonass_num = t[15]
   local horizontal_location_accuracy = t[16]

   local speed = t[17]
   local course = t[18]
   local altitude = t[19]
   local mileage = t[20]
   local is_lbs = 0
   local is_phone_position = 0
   local lbs_lat = 0
   local lbs_lng = 0

   local mcc = t[21]
   print("mcc:" .. mcc)
   local mnc = t[22]
   print("mnc:" .. mnc)
   local lac = t[23]
   local cell_id =pre .. t[24] .. pre
   local gsm_signal = t[25]
   local digital_in = t[26]
   local digital_out = digital_in
   local simulate1 = t[27]
   local simulate2 = simulate1
   local simulate3 = simulate1
   local temperature_sensor1 = t[28]
   local temperature_sensor2 = temperature_sensor1
   print("temperature:"..temperature_sensor1)
   local rfid = t[29]
   local external_device_status = t[30]
   local battery = t[31]
   print("battery.."..battery)
   local alarm_event = t[32]
   local the_efficacy_and = '0'
   local department_id = '0'
   res = res .. ',' .. '0' .. ',' .. device_name111111 ..',' .. protocol_version ..',' .. device_imei ..',' .. device_name ..',' .. gprs_data_flag ..',' .. date ..',' .. time ..',' .. receiveTime ..',' .. receiveTime1 .. ',' .. gps_time .. ','.. gps_flag ..',' .. latitude .. ',' .. original_lat .. ',' .. latitude_ns .. ',' .. longitude .. ',' .. original_lng .. ',' .. longitude_we .. ',' .. beidou_num .. ',' .. gps_num .. ',' .. glonass_num .. ',' .. horizontal_location_accuracy  .. ',' .. speed .. ',' .. course .. ',' .. altitude .. ',' .. mileage .. ',' .. is_lbs .. ',' .. is_phone_position .. ',' .. lbs_lat .. ',' .. lbs_lng .. ','  .. mcc .. ',' .. mnc .. ',' .. lac .. ',' .. cell_id .. ',' .. gsm_signal .. ',' .. digital_in .. ',' .. digital_out .. ',' .. simulate1 .. ',' .. simulate2 .. ',' .. simulate3 .. ',' .. temperature_sensor1 .. ',' .. temperature_sensor2 .. ',' .. rfid .. ',' .. external_device_status .. ',' .. battery .. ',' .. alarm_event .. ',' .. the_efficacy_and .. ',' .. department_id
   return res
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
	   local r = skynet.call("SIMPLEDB", "lua", "set", "lzp_item", args)
	   local split_content = str_split(args,",")
	   if(split_content[1] =="putPhonePosition")
	   then
	      print("putPhonePosition:"..split_content[2]..split_content[3])
	   elseif(split_content[1] == "setUID")
		then
		   print("set uid...")
		   skynet.call(WATCHDOG, "lua", "set_uid", client_fd, split_content[2])
	   else
	   local t0 = str_split(args,";")--split at ';'
	   local t = str_split(t0[1],',')--split valuable content
	   value = build_value(t)
	   print("built_value:" .. value)

	   if db then
--	   res = db:query("insert into device_log values (null,0,'lzp',  'protocol_version',  'device_imei' ,  'device_name',  'gprs_flag',  'date',  'time' ,  123131 , null , null,  'gps_flag', null , null,  'n', null , null,  'long',  'beidou_num',  'gps_num',  'glonass_num',  '0.00000',  '0.00000', '0.00000',  'altitude',  'mileage',  '0',  '0',  null, null,  'mcc',  'mnc',  'lac' ,  'cell_id','0',  '0',  '0',  '0',  '0',  '0',  '0.00000',  '0.00000',  '0',  '0' ,  'battery',  'alarm_events',  'CRC' ,  0)")

	      res = db:query("insert into device_log values ("..value..")")
	      
	      print( dump( res ) )
	   end
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

function CMD.push(msg)
   print("agent, get push command")
	   send_package("Push from server:"..msg)
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

	skynet.dispatch("lua", function(_,_, command, ...)
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
end)
