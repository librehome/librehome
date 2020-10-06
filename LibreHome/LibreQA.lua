-- Copyright 2015-2020 Smartonlabs Inc
-- Released under MIT License
-- https://opensource.org/licenses/MIT
local ZCL_CLUSTER_ID_GEN_ON_OFF		= 0x0006
local ATTRID_ON_OFF             	= 0x0000
local ATTRID_LEVEL_CURRENT_LEVEL	= 0x0000

local COMMAND_OFF               	= 0x00
local COMMAND_ON                	= 0x01
local COMMAND_TOGGLE				= 0x02

local EV_TYPE_DEVICE_CMD 			= 0

local function debugLog(message)
	if true then
		Libre_Log(0, message)
	end
end

function TestActions(actions)
end

function TestLogLimit()
	local i = 0
	while true do
		i = i + 1
		Libre_Log(0, "Log message " .. tostring(i))
		Libre_Yield()
	end
end

function TestFreeze()
	while true do
	end
end

local function aThread()
	local i = 0
	while true do
		Libre_Log(0, "aThread"..tostring(i))
		if i == 10 then
			Libre_ExitThread()
		end
		i = i + 1
	end
end

function TestThreadExit()
	Libre_NewThread(aThread)
end
	
function TestRxDevice(light)
	debugLog(string.format(
			'%s %s', tostring(table.insert), tostring(table.clear)))
	local timerCB = function(tag, timer)
		local seconds = math.random() * 10 + 1
		debugLog(string.format(
				'timer %d callback, next %d seconds', tag, seconds))
		Libre_TimerUpdate(timer, math.floor(seconds * 1000 + 0.5))
	end
	Libre_TimerNew(10000, timerCB, 1)
	Libre_TimerNew(10000, timerCB, 2)
	local deviceCB = function(tag, event)
		-- Event members
		--	t		Event Type
		--	id		Device Id
		--	ok		Device state
		--	c		Cluster
		--	d		Command
		--	v		Value (May be nil; Array for Command, Map for Attributes)
		--	a		Affected attributes (May be nil; otherwise map)
		--	s		Source		
		if event.ok then
			debugLog(string.format('RxDev: dev=%d type=%d', 
				event.id, event.t))
		else
			debugLog(string.format('RxDev: dev=%d failure', event.id))
		end
	end
	Libre_SetOnDevice(light, deviceCB, nil)
	
	local data = '\n\r1234567890\n\r'
	
	local ctx = {}
	ctx.recvTotal = 0
	ctx.sendTotal = 0
	ctx.fd = Libre_NetNewTcp()
	
	local function writerTimerCB(tag, timer)
		Libre_NetWrite(tag.fd, data)
		tag.sendTotal = tag.sendTotal + string.len(data)
		debugLog(string.format(
				'%d sent %d', tag.fd, tag.sendTotal))		
	end
	
	local function updateWriterTimer(tag)
		local seconds = math.random() * 10 + 1
		if tag.timer then
			Libre_TimerUpdate(tag.timer, math. floor(seconds * 1000 + 0.5))		
		else
			tag.timer = Libre_TimerNew(
				math.floor(seconds * 1000 + 0.5), writerTimerCB, tag)		
		end
	end
	
	Libre_SetOnNetClosed(ctx.fd, function(tag, fd)
			debugLog(string.format(
				'%d closed', tag.fd))
		end, ctx)
	Libre_SetOnNetData(ctx.fd, function(tag, fd, data)
			tag.recvTotal = tag.recvTotal + string.len(data)
			debugLog(string.format(
				'%d received %d', tag.fd, tag.recvTotal))
			if tag.recvTotal >= tag.sendTotal then
				updateWriterTimer(tag)
			end
		end, ctx)
	Libre_SetOnNetReady(ctx.fd, function(tag, fd)
			debugLog(string.format(
				'%d ready', tag.fd))
			updateWriterTimer(tag)
		end, ctx)	
	
	Libre_NetConnect(ctx.fd, '192.168.11.73', 2000)
	
	Libre_WaitReactive()
end

function TextRxHttpClient()
	local tag = {
		step = 1
	}
	
	local header = {
		{"Accept", "*/*"},
		{"User-Agent", "librehub/0.1"},
	}
	
	local function onError(tag, fd, errCode, httpStatus, text)
		debugLog(string.format(
				'Error %s', txt))
		Libre_ExitThread()
	end
	
	local function onResponse(tag, fd, res)
		debugLog(string.format(
				'statusCode %d', res.statusCode))
		if res.body then
			local length = string.len(res.body)
			if length > 100 then
				length = 100
			end
			debugLog(string.format(
				'Respbody %s', string.sub(res.body, 1, length + 1)))
		end
		tag.step = tag.step + 1
		if tag.step == 2 then
			Libre_NetHttpAddRequest(fd, 
				"GET", 
				"https://raw.githubusercontent.com/librehome/librehome/master/SmartonLabs/LibreApps.lua", 
				header)
		else
			Libre_ExitThread()
		end
	end
	
	local fd = Libre_NetNewHttp()
	Libre_SetOnNetError(fd, onError, tag)
	Libre_SetOnNetHttpResponse(fd, onResponse, tag)
	
	Libre_NetHttpAddRequest(fd, 
		"GET", 
		"https://raw.githubusercontent.com/librehome/librehome/master/SmartonLabs/LibreDenonAVR.lua", 
		header)
	
	Libre_WaitReactive()
end

-- This App Searches Libertas Hub in the local network
-- by sending broadcast UDP packets to port 1901.
function TextRxUdpClient()
	local query =
		"M-SEARCH * HTTP/1.1\r\n" ..
		"HOST: 239.255.255.250:1901\r\n" ..	-- Host IP ignored by Libertas Hub
		"MAN: \"ssdp:discover\"\r\n" ..
		"MX: 1\r\n" ..
		"ST: urn:smartonlabs-com:service:libre-hub:1\r\n" ..
		"\r\n"
	
	local ctx = {}
	ctx.recvTotal = 0
	ctx.sendTotal = 0
	ctx.fd = Libre_NetNewUdp(0, true)		-- Any port, broadcast
	
	local function writerTimerCB(tag, timer)
		Libre_NetWriteUdp(tag.fd, query, '255.255.255.255:1901')
		tag.sendTotal = tag.sendTotal + 1
		debugLog(string.format(
				'%d sent %d', tag.fd, tag.sendTotal))
		if tag.sendTotal > 5 then
			Libre_ExitThread()
		end
	end
	
	local function updateWriterTimer(tag)
		local seconds = math.random() * 10 + 1
		if tag.timer then
			Libre_TimerUpdate(tag.timer, math.floor(seconds * 1000 + 0.5))		
		else
			tag.timer = Libre_TimerNew(
				math.floor(seconds * 1000 + 0.5), writerTimerCB, tag)		
		end
	end	
	
	local function onError(tag, fd, errCode, httpStatus, text)
		debugLog(string.format(
				'Error %s', txt))
		Libre_ExitThread()
	end
	Libre_SetOnNetReady(ctx.fd, function(tag, fd)
			debugLog(string.format(
				'%d ready', tag.fd))
			updateWriterTimer(tag)
		end, ctx)	
	Libre_SetOnNetError(fd, onError, tag)
	Libre_SetOnNetData(ctx.fd, function(tag, fd, data, fromAddr)
			tag.recvTotal = tag.recvTotal + 1
			debugLog(string.format(
					'%d received from %s', tag.fd, fromAddr))
			updateWriterTimer(tag)
		end, ctx)
	
	Libre_WaitReactive()
end

function TextRxVirtualOnOff(onoff)
	local curOnOff = false
	local deviceCB = function(tag, event)
		-- Event members
		--	t		Event Type
		--	id		Device Id
		--	ok		Device state
		--	c		Cluster
		--	d		Command
		--	v		Value (May be nil; Array for Command, Map for Attributes)
		--	a		Affected attributes (May be nil; otherwise map)
		--	s		Source	
		local cluster = event.c
		if cluster == ZCL_CLUSTER_ID_GEN_ON_OFF then
			-- Cluster must be OnOff, Check control signal
			local newOnOff = nil
			if event.t == EV_TYPE_DEVICE_CMD then
				local cmd = event.d
				if cmd == COMMAND_OFF or cmd == COMMAND_ON then
					newOnOff = (cmd == COMMAND_ON)
				elseif cmd == COMMAND_TOGGLE then
					newOnOff = not curOnOff
				end
			else
				local onoff = event.v[ATTRID_ON_OFF]
				if onoff == true or onoff == false then
					newOnOff = onoff
				end
			end
			if newOnOff ~= nil then
				curOnOff = newOnOff
				if event.t == EV_TYPE_DEVICE_CMD then
					Libre_VirtualDeviceOnOffSet(event.id, curOnOff, event.s)
				else
					Libre_VirtualDeviceOnOffReport(event.id, curOnOff, event.s)
				end
			end	
		end
	end
	Libre_SetOnVirtualDevice(onoff, deviceCB, nil)
	Libre_VirtualDeviceOnOffReport(onoff, curOnOff, 7)	-- Init report
	Libre_WaitReactive()
end

function TestBlockingHttp()
	local function printRes(res)
		local length = string.len(res.body)
		if length > 100 then
			length = 100
		end
		debugLog(string.format(
			'Respbody %s', string.sub(res.body, 1, length + 1)))		
	end
	
	local fd = Libre_IoNewHttp()
	Libre_SetWaitIo(fd, 1)
	Libre_IoHttpAddRequest(fd, 
		"GET", 
		"https://raw.githubusercontent.com/librehome/librehome/master/SmartonLabs/LibreDenonAVR.lua", 
		header)
	Libre_Wait()	-- Wait fd forever
	local ok, res = Libre_IoHttpGetResponse(fd)
	if not ok then
		debugLog(string.format(
			'Error %s', tostring(res)))
		return
	end
	printRes(res)

	Libre_NetHttpAddRequest(fd, 
		"GET", 
		"https://raw.githubusercontent.com/librehome/librehome/master/SmartonLabs/LibreApps.lua", 
		header)
	Libre_Wait()	-- Wait fd forever
	local ok, res = Libre_IoHttpGetResponse(fd)
	if not ok then
		debugLog(string.format(
			'Error %s', tostring(res)))
		return
	end
	printRes(res)
end