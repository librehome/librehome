-- Copyright 2015-2020 Smartonlabs Inc
-- Released under MIT License
-- https://opensource.org/licenses/MIT
-- Latest version: 20201023
local pairs = pairs
local ipairs = ipairs
local floor = math.floor
local error = error
local table = table
local Libre_Sleep = Libre_Sleep
local Libre_Yield = Libre_Yield
local Libre_DeviceOnOffGet = Libre_DeviceOnOffGet
local Libre_DeviceOnOffSet = Libre_DeviceOnOffSet
local Libre_DeviceLevelGet = Libre_DeviceLevelGet
local Libre_DeviceLevelSet = Libre_DeviceLevelSet
local Libre_DeviceLevelMove = Libre_DeviceLevelMove
local Libre_DeviceLevelStep = Libre_DeviceLevelStep
local Libre_DeviceLevelStop = Libre_DeviceLevelStop

local Libre_VirtualDeviceLevelConfigExtra = Libre_VirtualDeviceLevelConfigExtra
local Libre_ActionTrigger = Libre_ActionTrigger

local Libre_SetWaitDevice = Libre_SetWaitDevice
local Libre_SetWaitVirtualDevice = Libre_SetWaitVirtualDevice

local Libre_VirtualDeviceOnOffSet = Libre_VirtualDeviceOnOffSet
local Libre_VirtualDeviceOnOffReport = Libre_VirtualDeviceOnOffReport
local Libre_VirtualDeviceLevelSet = Libre_VirtualDeviceLevelSet
local Libre_VirtualDeviceLevelReport = Libre_VirtualDeviceLevelReport

local Libre_Wait = Libre_Wait
local Libre_GetEvent = Libre_GetEvent

local Libre_Log = Libre_Log

local ZCL_CLUSTER_ID_GEN_ON_OFF					= 0x0006
local ZCL_CLUSTER_ID_GEN_LEVEL_CONTROL  		= 0x0008

local COMMAND_OFF               				= 0x00
local COMMAND_ON                				= 0x01
local COMMAND_TOGGLE							= 0x02

local COMMAND_LEVEL_MOVE_TO_LEVEL				= 0x00
local COMMAND_LEVEL_MOVE                        = 0x01
local COMMAND_LEVEL_STEP                        = 0x02
local COMMAND_LEVEL_STOP                        = 0x03
local COMMAND_LEVEL_MOVE_TO_LEVEL_WITH_ON_OFF   = 0x04
local COMMAND_LEVEL_MOVE_WITH_ON_OFF            = 0x05
local COMMAND_LEVEL_STEP_WITH_ON_OFF            = 0x06
local COMMAND_LEVEL_STOP_WITH_ON_OFF            = 0x07

local ATTRID_ON_OFF             = 0x0000
local ATTRID_LEVEL_CURRENT_LEVEL= 0x0000

local EV_TYPE_DEVICE_CMD 		= 0
local EV_TYPE_DEVICE_ATTR 		= 1
local EV_SOURCE_NA 				= 0
local EV_SOURCE_MANUAL_LOCAL 	= 1
local EV_SOURCE_MANUAL_REMOTE 	= 2
local EV_SOURCE_AUTO_LOCAL 		= 3
local EV_SOURCE_AUTO_REMOTE		= 4
local EV_SOURCE_APP				= 5
local EV_SOURCE_QUERY			= 6
local EV_SOURCE_REPORT			= 7
local EV_SOURCE_GROUP_STATE		= 8

local function debugLog(message)
	if false then
		Libre_Log(0, message)
	end
end

-- Event members
--	t		Event Type
--	id		Device Id
--	ok		Device state
--	c		Cluster
--	d		Command
--	v		Value (May be nil; Array for Command, Map for Attributes)
--	a		Affected attributes (May be nil; otherwise map)
--	s		Source

local function getOnOff(input)
	local ret = false
	for _, d in ipairs(input) do
		local onoff, ok = Libre_DeviceOnOffGet(d)
		if ok then
			ret = (ret or onoff)
		end
	end
	return ret
end

local function setIsEmpty(s)
	for _, v in pairs(s) do
		if v ~= nil then
			return false
		end
	end
	return true
end

function ComboOnOff(input, output)
	-- Register device events
	for _, d in ipairs(input) do
		Libre_SetWaitDevice(d)
	end	
	-- Receive virtual device events
	Libre_SetWaitVirtualDevice(output)
	-- Read states and initialize virtual device
	local curOnOff = getOnOff(input)
	Libre_VirtualDeviceOnOffReport(output, curOnOff, EV_SOURCE_APP)
	-- Pending devie is a set of device Ids
	local pendingDevices = {}
	local lastEventType = nil
	local lastEventSource = nil
	while true do
		Libre_Wait()
		local ev_type = nil	-- CMD or ATTR
		local ev_source = nil
		while true do
			local e = Libre_GetEvent()
			if (e == nil) then
				break
			end
			local cluster = e.c
			if cluster == ZCL_CLUSTER_ID_GEN_ON_OFF or cluster == 
				ZCL_CLUSTER_ID_GEN_LEVEL_CONTROL then
				if e.id == output then
					-- Cluster must be OnOff, Check control signal
					local newOnOff = nil
					if e.t == EV_TYPE_DEVICE_CMD then
						local cmd = e.d
						if cmd == COMMAND_OFF or cmd == COMMAND_ON then
							newOnOff = (cmd == COMMAND_ON)
						elseif cmd == COMMAND_TOGGLE then
							newOnOff = not curOnOff
						end
					else
						local onoff = e.v[ATTRID_ON_OFF]
						if onoff == true or onoff == false then
							newOnOff = onoff
						end
					end
					if newOnOff ~= nil then
						pendingDevices = {}
						lastEventType = e.t
						lastEventSource = e.s
						for _, d in ipairs(input) do
							pendingDevices[d] = true
							Libre_DeviceOnOffSet(d, newOnOff)
						end
					end
				else
					if setIsEmpty(pendingDevices) then
						if lastEventType == nil then
							lastEventType = e.t
							lastEventSource = e.s
						else
							local type = e.t
							if type < lastEventType then	-- CMD has higher priority
								lastEventType = type
								lastEventSource = e.s
							else
								if e.s ~= 0 and e.s < lastEventSource then
									lastEventSource = e.s
								end
							end
						end
					else
						pendingDevices[e.id] = nil
					end
				end
			end
		end
		if lastEventType ~= nil and setIsEmpty(pendingDevices) then
			curOnOff = getOnOff(input)
			debugLog("NewState=" .. tostring(curOnOff))
			if EV_TYPE_DEVICE_CMD == lastEventType then
				Libre_VirtualDeviceOnOffSet(output, curOnOff, lastEventSource)
			else
				Libre_VirtualDeviceOnOffReport(output, curOnOff, lastEventSource)
			end
		end
	end
end

local OUT_LEVEL_MIN 	= 0
local OUT_LEVEL_MAX 	= 1
local OUT_LEVEL_AVERAGE = 2

local function getLevel(input, method)
	local ret = nil
	if method == OUT_LEVEL_MIN then
		for _, d in ipairs(input) do
			local level, ok = Libre_DeviceLevelGet(d)
			if ok then
				if ret == nil then
					ret = level
				elseif level < ret then 
					ret = level
				end
			end
		end
	elseif method == OUT_LEVEL_MAX then
		for _, d in ipairs(input) do
			local level, ok = Libre_DeviceLevelGet(d)
			if ok then
				if ret == nil then
					ret = level
				elseif level > ret then 
					ret = level
				end
			end
		end
	else
		ret = 0
		local n = 0
		for _, d in ipairs(input) do
			local level, ok = Libre_DeviceLevelGet(d)
			if ok then
				ret = ret + level
				n = n + 1
			end
		end
		if n > 0 then
			ret = floor(ret / n + 0.5)
		end
	end
	return ret
end

-- Pending device event map {}
--	Key: id
--	Value: {}
--		ticks: ticks in ms
--		l: level
--		t: transition time

function ComboLevel(input, output, method)
	-- Register device events
	for _, d in ipairs(input) do
		Libre_SetWaitDevice(d)
	end	
	-- Receive virtual device events
	Libre_SetWaitVirtualDevice(output)
	-- Read states and initialize virtual device
	local curLevel = getLevel(input, method)
	if curLevel ~= nil then
		Libre_VirtualDeviceLevelReport(output, curLevel, EV_SOURCE_REPORT)
	else
		Libre_VirtualDeviceStatusDeviceDown(output)
	end
	-- Pending devie is a set of device Ids
	local pendingDevices = {}
	local lastEventType = nil
	local lastEventSource = nil
	while true do
		Libre_Wait()
		local updateLevel = false
		while true do
			local e = Libre_GetEvent()
			if (e == nil) then
				break
			end
			local cluster = e.c
			if cluster == ZCL_CLUSTER_ID_GEN_LEVEL_CONTROL then
				if e.id == output then		-- Virtual device
					-- -- Cluster must be Level, Check control signal
					local shallWait = false
					if e.t == EV_TYPE_DEVICE_CMD then
						local cmd = e.d
						if cmd == COMMAND_LEVEL_MOVE_TO_LEVEL or
							cmd == COMMAND_LEVEL_MOVE_TO_LEVEL_WITH_ON_OFF then
							for _, d in ipairs(input) do
								Libre_DeviceLevelSet(d, e.v[1], e.v[2])
							end
							shallWait = true
						elseif cmd == COMMAND_LEVEL_MOVE or
							cmd == COMMAND_LEVEL_MOVE_WITH_ON_OFF then
							for _, d in ipairs(input) do
								Libre_DeviceLevelMove(d, e.v[1], e.v[2])
							end
							shallWait = true
						elseif cmd == COMMAND_LEVEL_STEP or
							cmd == COMMAND_LEVEL_STEP_WITH_ON_OFF then
							for _, d in ipairs(input) do
								Libre_DeviceLevelStep(d, e.v[1], e.v[2], e.v[3])
							end
							shallWait = true
						elseif cmd == COMMAND_LEVEL_STOP or
							cmd == COMMAND_LEVEL_STOP_WITH_ON_OFF then
							for _, d in ipairs(input) do
								Libre_DeviceLevelStop(d)
							end
						end
					else	-- Attributes
						local level = e.v[ATTRID_LEVEL_CURRENT_LEVEL]
						if level ~= nil then
							for _, d in ipairs(input) do
								Libre_DeviceLevelSet(d, level, 0)
							end
						end
					end
					if shallWait then
						lastEventType = e.t
						lastEventSource = e.s								
						pendingDevices = {}
						for _, d in ipairs(input) do
							pendingDevices[d] = true
						end
					end
				else			-- device
					local eventType = e.t
					local affectedAttributes = e.a
					if affectedAttributes ~= nil and 
						affectedAttributes[ATTRID_LEVEL_CURRENT_LEVEL] ~= nil then
						updateLevel = true
						debugLog("NewState=" .. tostring(curLevel))
					end
					if setIsEmpty(pendingDevices) then
						if lastEventType == nil then
							lastEventType = eventType
							lastEventSource = e.s
						else
							if eventType < lastEventType then	-- CMD has higher priority
								lastEventType = eventType
								lastEventSource = e.s
							else
								if e.s ~= 0 and e.s < lastEventSource then
									lastEventSource = e.s
								end
							end
						end
					else
						pendingDevices[e.id] = nil
					end
				end
			end
		end
		if lastEventType ~= nil and setIsEmpty(pendingDevices) then
			if updateLevel then
				curLevel = getLevel(input, method)
				if curLevel ~= nil then
					debugLog(string.format("NewState=%d evType=%d", curLevel, lastEventType))
					if EV_TYPE_DEVICE_CMD == lastEventType then
						Libre_VirtualDeviceLevelSet(output, curLevel, lastEventSource, 0)
					else
						Libre_VirtualDeviceLevelReport(output, curLevel, lastEventSource)
					end
				end
			end
			lastEventType = nil
		end	
	end
end

function FlexLevel(virtualDevice, onActions, offActions, stateDevice)
	-- Receive virtual device events
	Libre_VirtualDeviceLevelConfigExtra(virtualDevice, 0, 255, false, 1, 1, 50)
	Libre_SetWaitDevice(stateDevice)
	Libre_SetWaitVirtualDevice(virtualDevice)
	local curLevel, _ = Libre_DeviceLevelGet(stateDevice)
	if curLevel ~= nil then
		Libre_VirtualDeviceLevelReport(virtualDevice, curLevel, EV_SOURCE_APP)
	end	
	for _, a in ipairs(onActions) do
		debugLog("onAction " .. a)
	end	
	for _, a in ipairs(offActions) do
		debugLog("offAction " .. a)
	end	
	while true do
		Libre_Wait()
		while true do
			local e = Libre_GetEvent()
			if (e == nil) then
				break
			end
			local cluster = e.c
			if cluster == ZCL_CLUSTER_ID_GEN_LEVEL_CONTROL then
				if e.id == stateDevice then
					if e.ok then
						local affectedAttributes = e.a
						if affectedAttributes ~= nil then 
							local level = affectedAttributes[ATTRID_LEVEL_CURRENT_LEVEL]
							if level ~= nil then
								curLevel = level
								Libre_VirtualDeviceLevelReport(virtualDevice, curLevel, e.s)
							end
						end	
					end
				elseif e.id == virtualDevice then
					if e.t == EV_TYPE_DEVICE_CMD then
						local cmd = e.d
						if cmd == COMMAND_LEVEL_MOVE_TO_LEVEL or
							cmd == COMMAND_LEVEL_MOVE_TO_LEVEL_WITH_ON_OFF then
							local actions = offActions
							curLevel = e.v[1]
							if curLevel > 0 then	-- Level > 0
								actions = onActions
							end
							for _, a in ipairs(actions) do
								Libre_ActionTrigger(a, e.s)
							end	
							Libre_VirtualDeviceLevelReport(virtualDevice, curLevel, e.s)
						elseif cmd == COMMAND_LEVEL_STEP or
							cmd == COMMAND_LEVEL_STEP_WITH_ON_OFF or
							cmd == COMMAND_LEVEL_STOP or
							cmd == COMMAND_LEVEL_STOP_WITH_ON_OFF then
							if curLevel ~= nil then
								Libre_VirtualDeviceLevelReport(virtualDevice, curLevel, e.s)
							end
						end
					end
				end
			elseif cluster == ZCL_CLUSTER_ID_GEN_ON_OFF then
				if e.id == stateDevice then
					local on_off = e.v[ATTRID_ON_OFF]
					if on_off ~= nil then
						curLevel = 0
						if onoff then
							curLevel = 254
						end
						Libre_VirtualDeviceLevelReport(virtualDevice, curLevel, e.s)
					end	
				end
			end
		end
	end
end
