local buffer = lbuffer
local list_new = list.new
local list_empty = list.empty
local list_pushright = list.pushright
local list_popleft = list.popleft
local list_peekleft = list.peekleft
local math_floor = math.floor
local bit_and = bit.band
local msticks = os.msticks
local Libre_IoNewTcp = Libre_IoNewTcp
local Libre_IoConnectDevice = Libre_IoConnectDevice
local Libre_VirtualDeviceLevelSet = Libre_VirtualDeviceLevelSet
local Libre_VirtualDeviceLevelReport = Libre_VirtualDeviceLevelReport
local Libre_VirtualDeviceLevelConfigExtra = Libre_VirtualDeviceLevelConfigExtra
local Libre_VirtualDeviceOnOffSet = Libre_VirtualDeviceOnOffSet
local Libre_VirtualDeviceOnOffReport = Libre_VirtualDeviceOnOffReport
local Libre_Wait = Libre_Wait

local READ_BUF_SIZE = 128

local ZCL_CLUSTER_ID_GEN_ON_OFF						= 0x0006
local ZCL_CLUSTER_ID_GEN_LEVEL_CONTROL				= 0x0008
local ZCL_CLUSTER_ID_GEN_MULTISTATE_INPUT_BASIC     = 0x0012
local ZCL_CLUSTER_ID_GEN_MULTISTATE_OUTPUT_BASIC    = 0x0013
local ZCL_CLUSTER_ID_GEN_MULTISTATE_VALUE_BASIC     = 0x0014

local COMMAND_MULTI_STATE_ACCESS				= 0x80
local COMMAND_OFF                               = 0x00
local COMMAND_ON                                = 0x01
local COMMAND_LEVEL_MOVE_TO_LEVEL				= 0x00
local COMMAND_LEVEL_MOVE						= 0x01
local COMMAND_LEVEL_STEP						= 0x02
local COMMAND_LEVEL_STOP						= 0x03
local COMMAND_LEVEL_MOVE_TO_LEVEL_WITH_ON_OFF	= 0x04
local COMMAND_LEVEL_MOVE_WITH_ON_OFF			= 0x05
local COMMAND_LEVEL_STEP_WITH_ON_OFF			= 0x06
local COMMAND_LEVEL_STOP_WITH_ON_OFF			= 0x07

local LEVEL_STEP_UP                             = 0x00
local LEVEL_STEP_DOWN                           = 0x01

local EV_TYPE_DEVICE_CMD 		= 0
local EV_TYPE_DEVICE_ATTR 		= 1
local EV_TYPE_DEVICE_QUERY 		= 2
local EV_TYPE_IO                = 10

-- Definition of virtual device internal name
-- Those are our internal normalization of the commands,
-- which may not be the same as the actual commands,
-- especially for Z2 and Z3 commands.
local SV_MAIN_VOLUME 	= 'MV'	-- number, I/O
local SV_MAIN_MUTE 		= 'MU'	-- on/off, I/O
local SV_MAIN_INPUT		= 'SI'	-- enum, I/O
local SV_MAIN_ONOFF		= 'ZM'	-- on/off, I/O
local SV_MAIN_ECO		= 'ECO'	-- enum, I/O
local SV_MAIN_SURR_CTRL	= 'MSC'	-- enum, I
local SV_MAIN_SURR		= 'MS'	-- output, O
local SV_MAIN_SURR_RAW	= 'MSR'	-- string, O
local SV_Z2_ONOFF		= 'Z2ON'-- boolean, I/O
local SV_Z2_MUTE		= 'Z2MU'-- boolean, I/O
local SV_Z2_INPUT		= 'Z2SI'-- enum, I/O
local SV_Z2_VOLUME		= 'Z2V'	-- number, level
local SV_Z3_ONOFF		= 'Z3ON'
local SV_Z3_MUTE		= 'Z3MU'
local SV_Z3_INPUT		= 'Z3SI'
local SV_Z3_VOLUME		= 'Z3V'	-- number, level

-- There are basically two queues
-- Outgoing command queue: Queue for outgoing commands
--	c:	Command
--	n:	Command prefix length, used to match acknowledgment
--		message from AVR, by comparing the prefix.
--		For example, command "MV" has prefix length of 2
--		a command "MVUP" may have an ack of "MV65"
--	a:	Acknowledgement options
--		0 -	No ack
--		1 -	Only ack when there is an update
--		2 -	Force an acknowledgement
--	s:	Source, generate a source for the event, used with emulated device
--	t:	Timestamp, in mono incresing milliseconds
local EV_ACK_NA				= 0
local EV_ACK_UPDATE			= 1
local EV_ACK_FORCE			= 2

local EV_SRC_NA 			= 0
local EV_SRC_MANUAL_LOCAL 	= 1
local EV_SRC_MANUAL_REMOTE 	= 2
local EV_SRC_AUTO_LOCAL 	= 3
local EV_SRC_AUTO_REMOTE 	= 4
local EV_SRC_APP_ENGINE 	= 5
local EV_SRC_QUERY 			= 6
local EV_SRC_REPORT 		= 7

local VALS_SI = {
	'UNKNOWN',
	'PHONO',
	'CD',
	'TUNER',
	'DVD',
	'BD',
	'TV',
	'SAT/CBL',
	'MPLAY',
	'GAME',
	'HDRADIO',
	'NET',
	'PANDORA',
	'SIRIUSXM',
	'IRADIO',
	'SERVER',
	'FAVORITES',
	'AUX1',
	'AUX2',
	'AUX3',
	'AUX4',
	'AUX5',
	'AUX6',
	'AUX7',
	'BT',
	'USB/IPOD',
	'USB',
	'IPD',
	'IRP',
	'FVP'
}

-- Zero based index
local MAP_SI = {}
for i, v in ipairs(VALS_SI) do
	MAP_SI[v] = i - 1
end

local VAL_ON_AUTO_OFF = {
	'ON',
	'AUTO',
	'OFF'
}

local VAL_MS_CTRL = {
	'MOVIE',
	'MUSIC',
	'GAME',
	'DIRECT',
	'PURE DIRECT',
	'STEREO',
	'AUTO',
	'DOLBY DIGITAL',
	'DTS SURROUND',
	'AURO3D',
	'AURO2DSURR',
	'MCH STEREO',
	'WIDE SCREEN',
	'SUPER STADIUM',
	'ROCK ARENA',
	'JAZZ CLUB',
	'CLASSIC CONCERT',
	'MONO MOVIE',
	'MATRIX',
	'VIDEO GAME',
	'VIRTUAL',
	'LEFT',
	'RIGHT'
}

local VAL_MS = {
	'',
	'MOVIE',
	'MUSIC',
	'GAME',
	'DIRECT',
	'PURE DIRECT',
	'STEREO',
	'AUTO',
	'DOLBY PRO LOGIC',
	'DOLBY PL2 C',
	'DOLBY PL2 M',
	'DOLBY PL2 G',
	'DOLBY PL2X C',
	'DOLBY PL2X M',
	'DOLBY PL2X G',
	'DOLBY PL2Z H',
	'DOLBY SURROUND',
	'DOLBY ATMOS',
	'DOLBY DIGITAL',
	'DOLBY D EX',
	'DOLBY D+PL2X C',
	'DOLBY D+PL2X M',
	'DOLBY D+PL2Z H',
	'DOLBY D+DS',
	'DOLBY D+NEO:X C',
	'DOLBY D+NEO:X M',
	'DOLBY D+NEO:X G',
	'DOLBY D+NEURAL:X',
	'DTS SURROUND',
	'DTS ES DSCRT6.1',
	'DTS ES MTRX6.1',
	'DTS+PL2X C',
	'DTS+PL2X M',
	'DTS+PL2Z H',
	'DTS+DS',
	'DTS96/24',
	'DTS96 ES MTRX',
	'DTS+NEO:6',
	'DTS+NEO:X C',
	'DTS+NEO:X M',
	'DTS+NEO:X G',
	'DTS+NEURAL:X',
	'DTS ES MTRX+NEURAL:X',
	'DTS ES DSCRT+NEURAL:X',
	'MULTI CH IN',
	'M CH IN+DOLBY EX',
	'M CH IN+PL2X C',
	'M CH IN+PL2X M',
	'M CH IN+PL2Z H',
	'M CH IN+DS',
	'MULTI CH IN 7.1',
	'M CH IN+NEO:X C',
	'M CH IN+NEO:X M',
	'M CH IN+NEO:X G',
	'M CH IN+NEURAL:X',
	'DOLBY D+',
	'DOLBY D+ +EX',
	'DOLBY D+ +PL2X C',
	'DOLBY D+ +PL2X M',
	'DOLBY D+ +PL2Z H',
	'DOLBY D+ +DS',
	'DOLBY D+ +NEO:X C',
	'DOLBY D+ +NEO:X M',
	'DOLBY D+ +NEO:X G',
	'DOLBY D+ +NEURAL:X',
	'DOLBY HD',
	'DOLBY HD+EX',
	'DOLBY HD+PL2X C',
	'DOLBY HD+PL2X M',
	'DOLBY HD+PL2Z H',
	'DOLBY HD+DS',
	'DOLBY HD+NEO:X C',
	'DOLBY HD+NEO:X M',
	'DOLBY HD+NEO:X G',
	'DOLBY HD+NEURAL:X',
	'DTS HD',
	'DTS HD MSTR',
	'DTS HD+PL2X C',
	'DTS HD+PL2X M',
	'DTS HD+PL2Z H',
	'DTS HD+DS',
	'DTS HD+NEO:6',
	'DTS HD+NEO:X C',
	'DTS HD+NEO:X M',
	'DTS HD+NEO:X G',
	'DTS HD+NEURAL:X',
	'DTS:X',
	'DTS:X MSTR',
	'DTS EXPRESS',
	'DTS ES 8CH DSCRT',
	'MPEG2 AAC',
	'AAC+DOLBY EX',
	'AAC+PL2X C',
	'AAC+PL2X M',
	'AAC+PL2Z H',
	'AAC+DS',
	'AAC+NEO:X C',
	'AAC+NEO:X M',
	'AAC+NEO:X G',
	'AAC+NEURAL:X',
	'PL DSX',
	'PL2 C DSX',
	'PL2 M DSX',
	'PL2 G DSX',
	'PL2X C DSX',
	'PL2X M DSX',
	'PL2X G DSX',
	'AUDYSSEY DSX',
	'DTS NEO:6 C',
	'DTS NEO:6 M',
	'DTS NEO:X C',
	'DTS NEO:X M',
	'DTS NEO:X G',
	'NEURAL:X',
	'NEO:6 C DSX',
	'NEO:6 M DSX',
	'AURO3D',
	'AURO2DSURR',
	'MCH STEREO',
	'WIDE SCREEN',
	'SUPER STADIUM',
	'ROCK ARENA',
	'JAZZ CLUB',
	'CLASSIC CONCERT',
	'MONO MOVIE',
	'MATRIX',
	'VIDEO GAME',
	'VIRTUAL',
	'STEREO',
	'ALL ZONE STEREO',
	'7.1IN'
}

local MAP_MS = {}
for i, v in ipairs(VAL_MS) do
	MAP_MS[v] = i - 1
end

local function debugLog(message)
	if false then
		Libre_Log(0, message)
	end
end

-- device shall only be used when receives no ack for
-- message. System shall generate an ack to keep client going.
local function enqueuePendingMessages(
		unsupportedCmds, 
		device,
		pendingMessages,
		command,
		prefixLen,
		ack,
		source)
	if unsupportedCmds[command] == nil then
		local message = {
			d = device,
			c = command,
			n = prefixLen,
			a = ack,
			s = source,
			t = msticks()
		}
		list_pushright(pendingMessages, message)
	end
end

local function ackCommand(device, value, pendingAck)
end

local function ackCommand(device, value, pendingAck)
end

local function deviceSendReport(device, value, source)
	if value ~= nil then
		if Libre_DeviceSupportsCluster(device, ZCL_CLUSTER_ID_GEN_LEVEL_CONTROL) then
			debugLog("Libre_VirtualDeviceLevelReport" .. tostring(value))
			Libre_VirtualDeviceLevelReport(device, value, source)
		elseif Libre_DeviceSupportsCluster(device, ZCL_CLUSTER_ID_GEN_ON_OFF) then
			debugLog("Libre_VirtualDeviceOnOffReport" .. tostring(value))
			Libre_VirtualDeviceOnOffReport(device, value, source)
		else
		end
	end
end

-- If pendingAck is not nil, the message is an acknowledgement of 
-- previous command
local function cbUpdate(device, cmd, value, deviceValues, pendingAck)
	debugLog(string.format('cbUpdate %s %s %s', tostring(device), tostring(cmd), tostring(value)) )
	if device ~= nil and value ~= nil then
		local oldval = deviceValues[device]
		deviceValues[device] = value		
		-- local modified = (value ~= oldval)
		if pendingAck ~= nil then
			local shouldNotify = false
			local ackAction = pendingAck.a
			if EV_ACK_UPDATE == ackAction then
				if oldval ~= value then
					shouldNotify = true
				end
			elseif EV_ACK_FORCE == ackAction then
				shouldNotify = true
			end
			if shouldNotify then
				deviceSendReport(device, value, pendingAck.s)
			end
		else	-- Fire an event notification as manual
			if Libre_DeviceSupportsCluster(device, ZCL_CLUSTER_ID_GEN_LEVEL_CONTROL) then
				debugLog("Libre_VirtualDeviceLevelSet" .. tostring(value))
				Libre_VirtualDeviceLevelSet(device, value, EV_SRC_MANUAL_LOCAL)
			elseif Libre_DeviceSupportsCluster(device, ZCL_CLUSTER_ID_GEN_ON_OFF) then
				debugLog("Libre_VirtualDeviceOnOffSet" .. tostring(value))
				Libre_VirtualDeviceOnOffSet(device, value, EV_SRC_MANUAL_LOCAL)
			else
			end	
		end
	end
end

local function onMV(deviceMap, cmd, param, deviceValues, pendingAck)
	local len = param:len()
	local v = tonumber(param)
	if (v ~= nil) then
		if len == 2 then
			v = v * 10
		end
		-- 00.0 - 98.0 TOTAL = 98 * 2
		v = v / 5
	end
	cbUpdate(deviceMap[SV_MAIN_VOLUME], cmd, v, deviceValues, pendingAck)
end

local function onMU(deviceMap, cmd, param, deviceValues, pendingAck)
	local v = nil
	if param == 'ON' then
		v = true
	elseif param == 'OFF' then
		v = false
	end
	cbUpdate(deviceMap[SV_MAIN_MUTE], cmd, v, deviceValues, pendingAck)
end

local function onSI(deviceMap, cmd, param, deviceValues, pendingAck)
	local v= MAP_SI[param]	-- Zero based
	if v == nil then
		v = 0
	end
	cbUpdate(deviceMap[SV_MAIN_INPUT], cmd, v, deviceValues, pendingAck)
end

local function onZM(deviceMap, cmd, param, deviceValues, pendingAck)
	local v = nil
	if param == 'ON' then
		v = true
	elseif param == 'OFF' then
		v = false
	end
	cbUpdate(deviceMap[SV_MAIN_ONOFF], cmd, v, deviceValues, pendingAck)	
end

local function onECO(deviceMap, cmd, param, deviceValues, pendingAck)
	local v = nil
	if param == 'ON' then
		v = 0
	elseif param == 'AUTO' then
		v = 1
	elseif param == 'OFF' then
		v = 2
	end
	cbUpdate(deviceMap[SV_MAIN_ECO], cmd, v, deviceValues, pendingAck)
end

local function onMS(deviceMap, cmd, param, deviceValues, pendingAck)
	local v = MAP_MS[param]
	if v == nil then
		v = 0
	end
	cbUpdate(deviceMap[SV_MAIN_SURR], v, deviceValues, pendingAck)
	cbUpdate(deviceMap[SV_MAIN_SURR_RAW], cmd, param, deviceValues, pendingAck)
end

local function onZ2(deviceMap, cmd, param, deviceValues, pendingAck)
	local v = tonumber(param)
	if (v ~= nil) then
		if len == 2 then
			v = v * 10
		end
		v = v / 5
		cbUpdate(deviceMap[SV_Z2_VOLUME], SV_Z2_VOLUME, v, deviceValues, pendingAck)
	elseif param == 'ON' then
		cbUpdate(deviceMap[SV_Z2_ONOFF], SV_Z2_ONOFF, true, deviceValues, pendingAck)
	elseif param == 'OFF' then
		cbUpdate(deviceMap[SV_Z2_ONOFF], SV_Z2_ONOFF, false, deviceValues, pendingAck)
	elseif param == 'MUON' then
		cbUpdate(deviceMap[SV_Z2_MUTE], SV_Z2_MUTE, true, deviceValues, pendingAck)
	elseif param == 'MUOFF' then
		cbUpdate(deviceMap[SV_Z2_MUTE], SV_Z2_MUTE, false, deviceValues, pendingAck)
	else
		v = MAP_SI[param]	-- Zero based
		if v == nil then
			v = 0
		end
		cbUpdate(deviceMap[SV_Z2_INPUT], v, deviceValues, pendingAck)
	end
end

local function onZ3(deviceMap, cmd, param, deviceValues, pendingAck)
	local v = tonumber(param)
	if (v ~= nil) then
		if len == 3 then
			v = v / 10
		end
		cbUpdate(deviceMap[SV_Z3_VOLUME], SV_Z3_VOLUME, v, deviceValues, pendingAck)
	elseif param == 'ON' then
		cbUpdate(deviceMap[SV_Z3_ONOFF], SV_Z3_ONOFF, true, deviceValues, pendingAck)
	elseif param == 'OFF' then
		cbUpdate(deviceMap[SV_Z3_ONOFF], SV_Z3_ONOFF, false, deviceValues, pendingAck)
	elseif param == 'MUON' then
		cbUpdate(deviceMap[SV_Z3_MUTE], SV_Z3_MUTE, true, deviceValues, pendingAck)
	elseif param == 'MUOFF' then
		cbUpdate(deviceMap[SV_Z3_MUTE], SV_Z3_MUTE, false, deviceValues, pendingAck)
	else
		v = MAP_SI[param]	-- Zero based
		if v == nil then
			v = 0
		end
		cbUpdate(deviceMap[SV_Z3_INPUT], SV_Z3_MUTE, v, deviceValues, pendingAck)
	end
end

local function genCmdVolume(cmd, v)
	if (type(v) == "number") then
		if (v >= 0 and v <= 98) then
			local whole = math_floor(v)
			local fraction = v - whole
			if (0 ~= fraction) then
				return string.format("%s%02d5\r", cmd, whole)
			else
				return string.format("%s%02d\r", cmd, whole)
			end
		end
	end
	return nil
end

local function genCmdOnoff(cmd, v)
	if (type(v) == "boolean") then
		if (v) then
			return string.format("%sON\r", cmd)
		else
			return string.format("%sOFF\r", cmd)
		end
	end
	return nil
end

local function getCmdParameter(event, index)
	local ret = nil
	local v = event.v
	if v ~= nil then
		ret = v[index]
	end
	return ret
end

-- denonCmd could be MV, Z2, or Z3
local function onControlVolume(
		unsupportedCmds, 
		event, 
		pendingMessages,
		device,
		deviceValues,
		denonCmd)
	if event.c ~= ZCL_CLUSTER_ID_GEN_LEVEL_CONTROL then
		return
	end
	if event.t ~= EV_TYPE_DEVICE_CMD then
		return
	end
	local cmd = event.d
	local outCmd
	if COMMAND_LEVEL_STEP == cmd or 
		COMMAND_LEVEL_STEP_WITH_ON_OFF == cmd then
		local stepMode = getCmdParameter(event, 1)	-- Ignore transition time
		local stepBy = getCmdParameter(event, 2)
		debugLog(string.format('onControlVolume step mode %s by %s', 
				tostring(stepMode),
			tostring(stepBy)))
		local curValue = deviceValues[device]
		if curValue == nil then
			if LEVEL_STEP_UP == stepMode then
				outCmd = string.format("%sUP\r", denonCmd)
			elseif LEVEL_STEP_DOWN == stepMode then
				outCmd = string.format("%sDOWN\r", denonCmd)
			end			
		else
			local newValue = curValue
			if LEVEL_STEP_UP == stepMode then
				newValue = newValue + stepBy
			elseif LEVEL_STEP_DOWN == stepMode then
				newValue = newValue - stepBy
			end
			if (newValue ~= curValue) then
				outCmd = genCmdVolume(denonCmd, newValue / 2)
			end
		end
	elseif COMMAND_LEVEL_MOVE_TO_LEVEL == cmd or
		COMMAND_LEVEL_MOVE_TO_LEVEL_WITH_ON_OFF == cmd then
		local level = getCmdParameter(event, 1)		-- Ignore transition time
		outCmd = genCmdVolume(denonCmd, level / 2)
	end
	if outCmd ~= nil then
		debugLog(string.format('onControlVolume %s', outCmd))
		enqueuePendingMessages(
			unsupportedCmds, 
			device,
			pendingMessages,
			outCmd,
			string.len(denonCmd), 	-- Prefix length
			EV_ACK_FORCE,
			event.s)				-- Source
	else
		debugLog('onControlVolume NA')
	end	
end

local function onControlOnOff(
		unsupportedCmds, 
		event, 
		pendingMessages,
		device,
		deviceValues,
		denonCmd)
	local onoff
	local cmd = event.d
	if COMMAND_OFF == cmd then
		onoff = false
	elseif COMMAND_ON == cmd then
		onoff = true
	end
	if onoff ~= nil then
		enqueuePendingMessages(
			unsupportedCmds, 
			device,
			pendingMessages,
			genCmdOnoff(denonCmd, onoff),
			string.len(denonCmd), 	-- Prefix length
			EV_ACK_FORCE,
			event.s)
	end
end

local function onControlEnum(
		unsupportedCmds, 
		event, 
		pendingMessages, 
		device,
		deviceValues,
		enumList,
		denonCmd)
	local cmd = event.d
	local outCmd
	if COMMAND_MULTI_STATE_ACCESS == cmd then
		local v = getCmdParameter(event, 1)
		if (type(v) == "number") then
			v = v + 1		-- zero based
			local vv = enumList[v]
			if vv ~= nil then
				outCmd = string.format("%s%s\r", denonCmd, vv)
			end
		end
	end
	if outCmd ~= nil then
		enqueuePendingMessages(
			unsupportedCmds, 
			device,
			pendingMessages,
			outCmd,
			string.len(denonCmd), 	-- Prefix length
			EV_ACK_FORCE,
			event.s)
	end	
end

local function onControlMV(unsupportedCmds, event, pendingMessages, device, deviceValues)
	onControlVolume(unsupportedCmds, event, pendingMessages, device, deviceValues, 'MV')
end

local function onControlZ2V(unsupportedCmds, event, pendingMessages, device, deviceValues)
	onControlVolume(unsupportedCmds, event, pendingMessages, device, deviceValues, 'Z2')
end

local function onControlZ3V(unsupportedCmds, event, pendingMessages, device, deviceValues)
	onControlVolume(unsupportedCmds, event, pendingMessages, device, deviceValues, 'Z3')
end

local function onControlMU(unsupportedCmds, event, pendingMessages, device, deviceValues)
	onControlOnOff(unsupportedCmds, event, pendingMessages, device, deviceValues, 'MU')
end

local function onControlSI(unsupportedCmds, event, pendingMessages, device, deviceValues)
	onControlEnum(unsupportedCmds, event, pendingMessages, device, deviceValues, VALS_SI, 'SI', device)
end

local function onControlZM(unsupportedCmds, event, pendingMessages, device, deviceValues)
	onControlOnOff(unsupportedCmds, event, pendingMessages, device, deviceValues, 'ZM')
end

local function onControlMS(unsupportedCmds, event, pendingMessages, device, deviceValues)
	onControlEnum(unsupportedCmds, event, pendingMessages, device, deviceValues, VAL_MS_CTRL, 'MS', device)
end

local function onControlZ2ON(unsupportedCmds, event, pendingMessages, device, deviceValues)
	onControlOnOff(unsupportedCmds, event, pendingMessages, device, deviceValues, 'Z2')
end

local function onControlZ3ON(unsupportedCmds, event, pendingMessages, device, deviceValues)
	onControlOnOff(unsupportedCmds, event, pendingMessages, device, deviceValues, 'Z3')
end

local function onControlZ2MU(unsupportedCmds, event, pendingMessages, device, deviceValues)
	onControlOnOff(unsupportedCmds, event, pendingMessages, device, deviceValues, 'Z2MU')
end

local function onControlZ3MU(unsupportedCmds, event, pendingMessages, device, deviceValues)
	onControlOnOff(unsupportedCmds, event, pendingMessages, device, deviceValues, 'Z3MU')
end

local function onControlZ2SI(unsupportedCmds, event, pendingMessages, deviceValues, device, deviceValues)
	onControlEnum(unsupportedCmds, event, pendingMessages, device, deviceValues, VALS_SI, 'Z2SI')
end

local function onControlZ3SI(unsupportedCmds, event, pendingMessages, device, deviceValues)
	onControlEnum(unsupportedCmds, event, pendingMessages, device, deviceValues, VALS_SI, 'Z3SI')
end

local function onControlEco(unsupportedCmds, event, pendingMessages, device, deviceValues)
	onControlEnum(unsupportedCmds, event, pendingMessages, device, deviceValues, VAL_ON_AUTO_OFF, 'ECO')
end

-- System variables: MV CV MU SI ZM MSC MS Z2MU

local function findCR(b, from, len)
	while from <= len do
		if b[from] == 13 then
			debugLog(string.format('found cr at %d', from))
			return from
		end
		from = from + 1
	end
	return nil
end

local function pendingAckMatches(pendingAck, cmd)
	if string.len(cmd) ~= pendingAck.n then
		return false
	end
	for i = 1, string.len(cmd) do
		if string.byte(cmd, i) ~= string.byte(pendingAck.c, i) then
			return false
		end
	end
	return true
end

local AVR_CMD_ACTIONS_2 = {
	MV = onMV,
	MU = onMU,
	SI = onSI,
	ZM = onZM,
	MS = onMS,
	Z2 = onZ2,
	Z3 = onZ3
}

-- If message is successfully processed, it will be removed from input buffer
local function onIncoming(b, deviceMap, deviceValues, pendingAckQueue)
	local cur = 1
	local len = b:len()
	while (cur <= len) do
		local cr = findCR(b, cur, len)
		if cr == nil then
			break
		end
		local cmdLen = cr - cur
		if cmdLen >= 3 then
			local cmd, params, f
			if b:tostring(cur, 3) == 'ECO' then
				cmd = 'ECO'
				params = b:tostring(cur + 3, cmdLen - 3)
				f = onECO
			else
				cmd = b:tostring(cur, 2)
				f = AVR_CMD_ACTIONS_2[cmd]
				if (f ~= nil) then
					params = b:tostring(cur + 2, cmdLen - 2)
				end
			end
			if (f ~= nil) then
				local virtualDevice = deviceMap[cmd]
				debugLog(string.format('CMD=%s Device=%s', cmd, tostring(virtualDevice)))
				local pendingAck = list_peekleft(pendingAckQueue)
				if pendingAck ~= nil then
					if pendingAckMatches(pendingAck, cmd) then
						list_popleft(pendingAckQueue)	-- Remove from queue
					end
				end
				f(deviceMap, cmd, params, deviceValues, pendingAck)
			end
		end
		cur = cr + 1
	end
	if (cur > 1) then
		b:remove(1, cur - 1)
	end
end

local TCP_CONNECT_TIMEOUT_SECONDS = 20	-- 20 seconds
local TICKS_HB = 60000					-- 60 seconds
local TICKS_WRITE_TIMEOUT = 30000		-- 30 seconds
local ACK_TIMEOUT = 2000				-- 2 seconds

local function setWaitZoneCommon(zone)
	if zone.onoff ~= nil then
		Libre_SetWaitVirtualDevice(zone.onoff)
	end
	if zone.mute ~= nil then
		Libre_SetWaitVirtualDevice(zone.mute)
	end
	if zone.input ~= nil then
		Libre_SetWaitVirtualDevice(zone.input)
	end
	if zone.volume ~= nil then
		Libre_SetWaitVirtualDevice(zone.volume)
	end
end

-- Returns -9999 if socket is closed.
local function setWaitIO(
		unsupportedCmds, 
		tcp, 
		connected, 
		curOut, 
		pendingMessages, 
		pendingAckQueue, 
		lastWriteTicks,
		heartBeatDevice)	-- mainZone.onoff
	local events
	local curTicks = msticks()
	local waitTimeout = -1
	if connected then
		events = 1			-- We shall always read
		if not list_empty(pendingAckQueue) then
			local curPendingAck = list_peekleft(pendingAckQueue)
			local ackElapsed = curTicks - curPendingAck.t
			waitTimeout = ACK_TIMEOUT - ackElapsed
			if waitTimeout < 0 then
				waitTimeout = 0
			end
		else		
			local writeElapsed = curTicks - lastWriteTicks
			if (curOut ~= nil or not list_empty(pendingMessages)) then
				debugLog('Pending outgoing')
				events = events + 2		-- Wait for read and write
				if writeElapsed >= TICKS_WRITE_TIMEOUT then
					-- Wait forever until writable
				else
					waitTimeout = TICKS_WRITE_TIMEOUT - writeElapsed
				end
			else
				if writeElapsed >= TICKS_HB then
					enqueuePendingMessages(
						unsupportedCmds, 
						heartBeatDevice,	-- device is nil
						pendingMessages, 
						"ZM?\r", 			-- Heartbeat message
						2, 
						EV_ACK_NA, 
						EV_SRC_NA)
					waitTimeout = TICKS_HB
					events = events + 2		-- Wait for read and write
					debugLog('Send heartbeat')
				else
					waitTimeout = TICKS_HB - writeElapsed
				end
			end
		end
	else
		events = 2						-- Wait for connected (write)
	end
	debugLog(string.format('Libre_SetWaitIo %d mask=%d', tcp, events))
	if not Libre_SetWaitIo(tcp, events)	then -- TCP level trigger
		return -9999
	end
	return waitTimeout
end

local function addVirtualDevicehandler(handlerMap, device, handler, onOffDevice)
	if device ~= nil then
		local value = {}
		value.h = handler		-- Handler function
		value.p = onOffDevice	-- Power device
		handlerMap[device] = value
	end
end

-- Zone: Main, Zone2, Zone3
--	Common Members:
--		onoff
--		mute
--		input
--		volume
--	Main Zone:
--		eco
--		surrCtrl
--		surr
function DenonAVR(device, mainZone, extraZones)
	local lastExpiredCmd = nil
	-- Hashtable of CMD - FailureCount
	local suspectedUnsupportedCmd = {}
	local unsupportedCmds = {}
	-- Build Virtual Device Handler Map
	local handlerMap = {}
	addVirtualDevicehandler(handlerMap, mainZone.onoff, onControlZM, mainZone.onoff)
	addVirtualDevicehandler(handlerMap, mainZone.volume, onControlMV, mainZone.onoff)
	addVirtualDevicehandler(handlerMap, mainZone.mute, onControlMU, mainZone.onoff)
	addVirtualDevicehandler(handlerMap, mainZone.input, onControlSI, mainZone.onoff)
	addVirtualDevicehandler(handlerMap, mainZone.eco, onControlEco, mainZone.onoff)
	addVirtualDevicehandler(handlerMap, mainZone.surrCtrl, onControlMS, mainZone.onoff)
	if extraZones[1] ~= nil then
		local z2 = extraZones[1]
		addVirtualDevicehandler(handlerMap, z2.onoff, onControlZ2ON, z2.onoff)
		addVirtualDevicehandler(handlerMap, z2.mute, onControlZ2MU, z2.onoff)
		addVirtualDevicehandler(handlerMap, z2.input, onControlZ2SI, z2.onoff)
		addVirtualDevicehandler(handlerMap, z2.volume, onControlZ2V, z2.onoff)
	end
	if extraZones[2] ~= nil then
		local z3 = extraZones[2]
		addVirtualDevicehandler(handlerMap, z3.onoff, onControlZ3ON, z3.onoff)
		addVirtualDevicehandler(handlerMap, z3.mute, onControlZ3MU, z3.onoff)
		addVirtualDevicehandler(handlerMap, z3.input, onControlZ3SI, z3.onoff)
		addVirtualDevicehandler(handlerMap, z3.volume, onControlZ3V, z3.onoff)
	end	
	-- Build Command-VirtualDevice Map
	local commandDeviceMap = {}
	commandDeviceMap[SV_MAIN_VOLUME]= mainZone.volume
	commandDeviceMap[SV_MAIN_MUTE] 	= mainZone.mute
	commandDeviceMap[SV_MAIN_INPUT]	= mainZone.input
	commandDeviceMap[SV_MAIN_ONOFF]	= mainZone.onoff
	commandDeviceMap[SV_MAIN_ECO]	= mainZone.eco
	if extraZones[1] ~= nil then
		local z2 = extraZones[1]
		commandDeviceMap[SV_Z2_ONOFF] = z2.onoff
		commandDeviceMap[SV_Z2_MUTE] = z2.mute
		commandDeviceMap[SV_Z2_INPUT] = z2.input
		commandDeviceMap[SV_Z2_VOLUME] = z2.volume
	end
	if extraZones[2] ~= nil then
		local z3 = extraZones[1]
		commandDeviceMap[SV_Z3_ONOFF] = z3.onoff
		commandDeviceMap[SV_Z3_MUTE] = z3.mute
		commandDeviceMap[SV_Z3_INPUT] = z3.input
		commandDeviceMap[SV_Z3_VOLUME] = z3.volume
	end
	-- Subscribe events
	setWaitZoneCommon(mainZone)
	if mainZone.eco ~= nil then
		Libre_SetWaitVirtualDevice(mainZone.eco)
	end
	if mainZone.surrCtrl ~= nil then
		Libre_SetWaitVirtualDevice(mainZone.surrCtrl)
	end
	for _, zone in ipairs(extraZones) do
		setWaitZoneCommon(zone)
	end	
	-- Set extra attributes for volumes
	-- Volumes has to be step only so that system won't allow simple on/off
	-- which will set volume to extreme levels
	if mainZone.volume ~= nil then
		Libre_VirtualDeviceLevelConfigExtra(mainZone.volume, 0, 98 * 2, true, 1, 3, 5)
	end
	local z2 = extraZones[1]	
	if z2 ~= nil and z2.volume ~= nil then
		Libre_VirtualDeviceLevelConfigExtra(z2.volume, 0, 98 * 2, true, 1, 3, 5)
	end
	local z3 = extraZones[2]	
	if z3 ~= nil and z3.volume ~= nil then
		Libre_VirtualDeviceLevelConfigExtra(z3.volume, 0, 98 * 2, true, 1, 3, 5)
	end
	-- b is a buffer for incoming command string
	local b = buffer(READ_BUF_SIZE)
	
	local tcp = Libre_IoNewTcp()
	while true do					-- Infinite loop
		local deviceValues = {}
		local pendingMessages = list_new()
		local pendingAckQueue = list_new()
		local curOut = nil
		local curOutPos
		
		b:setlen(0)		-- Reset buffer
		
		Libre_IoConnectDevice(tcp, device, 23)
		
		local connectTime = msticks()
		local lastWriteTicks = msticks()
		local connected = false
		
		local connectionActive = true
		-- Process virtual device events
		while connectionActive do
			local waitTimeout = setWaitIO(
				unsupportedCmds, 
				tcp, 
				connected, 
				curOut, 
				pendingMessages, 
				pendingAckQueue, 
				lastWriteTicks,
				mainZone.onoff)
			if waitTimeout == -9999 then
				connectionActive = false
				break
			end
			Libre_Wait(waitTimeout)
			debugLog('Wait end')
			-- Discard expired pending acknowledge commands
			local curTicks = msticks()
			-- Purge expired Pending Acks
			while true do
				local curPendingAck = list_peekleft(pendingAckQueue)
				if curPendingAck == nil then
					break
				end
				local PendingAckElapsed = curTicks - curPendingAck.t
				if PendingAckElapsed >= ACK_TIMEOUT then
					debugLog('Pending ack expired ' .. curPendingAck.c)
					lastExpiredCmd = curPendingAck.c
					if curPendingAck.d ~= nil and curPendingAck.a ~= EV_ACK_NA then
						local v = deviceValues[curPendingAck.d]
						if v ~= nil then
							deviceSendReport(curPendingAck.d, v, EV_SRC_REPORT)
						end
					end
					list_popleft(pendingAckQueue)		-- Discard it
				else
					break
				end
			end
			-- Process events
			debugLog('Libre_GetEvent')
			local e = Libre_GetEvent()
			if (e ~= nil) then
				local ev_type = e.t
				if ev_type == EV_TYPE_DEVICE_CMD or -- Virtual device events
					ev_type == EV_TYPE_DEVICE_ATTR then
					local handlerData = handlerMap[e.id]
					if handlerData ~= nil then
						if EV_TYPE_DEVICE_CMD == e.t then
							local powerDevice = handlerData.p
							-- Only take effect when zone power is on
							if (e.id == powerDevice or 
									deviceValues[powerDevice]) then	
								handlerData.h(unsupportedCmds, e, pendingMessages, e.id, deviceValues)
							else	-- Otherwise report old value
								deviceSendReport(e.id, deviceValues[e.id], EV_SRC_REPORT)
							end
						end
					end
				elseif ev_type == EV_TYPE_IO then	-- I/O events
					local tcpEv = e.v
					if tcpEv < 0 then				-- IO closed
						connectionActive = false
						break
					end
					debugLog(string.format('TCP event=%d', tcpEv))
					if connected then
						if 0 ~= bit_and(tcpEv, 1) then	-- Read
							local len = b:len()
							b:setlen(READ_BUF_SIZE)		-- Set to maximum
							debugLog(string.format('Read from %d len=%d', len, READ_BUF_SIZE - len))
							local n, errMsg = Libre_IoRead(tcp, b, len + 1, READ_BUF_SIZE - len, 0)
							if (n > 0) then
								-- If connection is not closed on expired cmd, 
								-- then CMD is supported
								if lastExpiredCmd ~= nil then
									suspectedUnsupportedCmd[lastExpiredCmd] = nil
									lastExpiredCmd = nil
								end
								b:setlen(len + n)
								debugLog(string.format('Read %d %s', n, b:tostring(1, len + n)))
								onIncoming(b, commandDeviceMap, deviceValues, pendingAckQueue)
								if b:len() == READ_BUF_SIZE then
									b:len(0)
								end
							elseif (n < 0) then
								connectionActive = false
								break
							else
								b:setlen(len)
							end
						end
						if 0 ~= bit_and(tcpEv, 2) then	-- Write
							while list_empty(pendingAckQueue) do
								if curOut ~= nil then
									local len = curOut.c:len()
									local n, errMsg = Libre_IoWrite(tcp, curOut.c, curOutPos, 
										len + 1 - curOutPos, 0)
									debugLog(string.format('Libre_IoWrite len=%d', n))
									if (n < 0) then
										connectionActive = false
										break
									elseif n > 0 then
										lastWriteTicks = msticks()
										curOutPos = curOutPos + n
										debugLog(string.format('Write %d len=%d', n, curOutPos))
										if curOutPos > len then
											curOut.t = lastWriteTicks
											list_pushright(pendingAckQueue, curOut)
											curOut = nil
										end
									else		-- Write blocking
										break
									end
								else
									curOut = list_popleft(pendingMessages)
									if curOut == nil then
										break
									end
									curOutPos = 1
								end
							end
							if not connectionActive then
								debugLog(string.format('TCP error %s', tostring(errMsg)))
								break
							end
						end
					else
						if 0 ~= bit_and(tcpEv, 2) then
							debugLog("TCP connected")
							connected = true
							lastWriteTicks = msticks()
							if mainZone.onoff ~= nil then
								enqueuePendingMessages(
									unsupportedCmds, 
									mainZone.onoff,
									pendingMessages, 
									"ZM?\r", 
									2, 
									EV_ACK_FORCE, 
									EV_SRC_REPORT)
							end
							if mainZone.volume ~= nil then
								enqueuePendingMessages(
									unsupportedCmds, 
									mainZone.volume,
									pendingMessages, 
									"MV?\r", 
									2, 
									EV_ACK_FORCE, 
									EV_SRC_REPORT)
							end
							if mainZone.mute ~= nil then
								enqueuePendingMessages(
									unsupportedCmds, 
									mainZone.mute,
									pendingMessages, 
									"MU?\r", 
									2, 
									EV_ACK_FORCE, 
									EV_SRC_REPORT)
							end
							if mainZone.input ~= nil then
								enqueuePendingMessages(
									unsupportedCmds, 
									mainZone.input,
									pendingMessages, 
									"SI?\r", 
									2, 
									EV_ACK_FORCE, 
									EV_SRC_REPORT)
							end
							if mainZone.eco ~= nil then
								enqueuePendingMessages(
									unsupportedCmds, 
									mainZone.eco,
									pendingMessages, 
									"ECO?\r", 
									3, 
									EV_ACK_FORCE, 
									EV_SRC_REPORT)
							end
							if extraZones[1] ~= nil then
								enqueuePendingMessages(
									unsupportedCmds, 
									nil,
									pendingMessages, 
									"Z2?\r", 
									2, 
									EV_ACK_FORCE, 
									EV_SRC_REPORT)
							end
							if extraZones[1] ~= nil then
								enqueuePendingMessages(
									unsupportedCmds, 
									nil,
									pendingMessages, 
									"Z3?\r", 
									2, 
									EV_ACK_FORCE, 
									EV_SRC_REPORT)
							end
						end
					end
				end	-- Event type handling
			end
		end
		if lastExpiredCmd ~= nil then
			local failureCount = suspectedUnsupportedCmd[lastExpiredCmd]
			if failureCount == nil then
				failureCount = 0
			end
			failureCount = failureCount + 1
			if failureCount >= 3 then
				debugLog("Unsupported command " .. lastExpiredCmd)
				failureCount = nil
				unsupportedCmds[lastExpiredCmd] = true
			end
			suspectedUnsupportedCmd[lastExpiredCmd] = failureCount
			lastExpiredCmd = nil
		end
		debugLog("TCP closed")
		Libre_IoClose(tcp)
		Libre_Wait(2000)	-- Wait for 2 seconds		
	end
end
