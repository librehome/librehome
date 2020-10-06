-- Copyright 2015-2020 Smartonlabs Inc
-- Released under MIT License
-- https://opensource.org/licenses/MIT
local pairs = pairs
local ipairs = ipairs
local error = error
local table_sort = table.sort
local date = os.date
local time = os.time
local floor = math.floor
local Libre_WaitUntil = Libre_WaitUntil
local Libre_DeviceThermostatSet = Libre_DeviceThermostatSet

local ZCL_CLUSTER_ID_HVAC_THERMOSTAT                	= 0x0201
local ATTRID_HVAC_THERMOSTAT_SYSTEM_MODE				= 0x001C
local ATTRID_HVAC_THERMOSTAT_OCCUPIED_COOLING_SETPOINT	= 0x0011
local ATTRID_HVAC_THERMOSTAT_OCCUPIED_HEATING_SETPOINT  = 0x0012
local HVAC_THERMOSTAT_SYSTEM_MODE_AUTO					= 0x01

local function debugLog(message)
	if false then
		Libre_Log(0, message)
	end
end

-------------------------------------
-- Get next action from current time
-- @param localTimeOfDay 	Local time of day in seconds
-- @param actions 			Array of actions
-- @return					action or nil
-------------------------------------
local function getNextActionAfter(localTimeOfDay, actions)
	for _, action in ipairs(actions) do
		if (action.startTime > localTimeOfDay) then
			return action
		end
	end
	return nil
end

-------------------------------------
-- Check if array contains the element
-- @param weekDay 	A number represents weekDay 0 is Sunday
-- @param weekDays 	An array of week days
-- @return			True if value is in list; otherwise false
-------------------------------------
local function weekContains(weekDay, weekDays)
	for _, cur in ipairs(weekDays) do
		if cur == weekDay then
			return true
		end
	end
	return false
end

-------------------------------------
-- Get next action from current time
-- @param scheduleTable 	Array of schedules
-- @param weekDay 			Sunday is 0
-- @param localTime 		Local time of day
-- @return					action or nil; corresponding schedule or nil
-------------------------------------
local function getNextScheduleActionAfter(scheduleTable, weekDay, localTime)
	for _, schedule in ipairs(scheduleTable) do
		if (weekContains(weekDay, schedule.weekDays)) then
			local action = getNextActionAfter(localTime, schedule.actions)
			if action ~= nil then
				return action, schedule
			end
		end
	end
	return nil
end

-------------------------------------
-- Calculate next week day
-- @param weekDay 	Array of schedules
-- @return			A number between 0 and 6
-------------------------------------
local function nextWeekDay(weekDay)
	weekDay = weekDay + 1
	if weekDay >= 7 then
		weekDay = 0
	end
	return weekDay
end

-------------------------------------
-- Get next action from a certain date and time
-- @param scheduleTable 	Array of schedules
-- @param prevDay 			Table representing a local date; time will be ignored
-- @param prevTimeOfDay 	New action must be after the prevDay and this time
-- @return					a number representing next local epoch time and an action
-------------------------------------
local function getNextAction(scheduleTable, prevDay, prevTimeOfDay)
	local weekDay = prevDay.wday - 1	-- Adjust to 0 based
	local extraDays = 0
	local action = nil
	local schedule = nil
	while true do
		action, schedule = getNextScheduleActionAfter(scheduleTable, 
			weekDay, prevTimeOfDay)
		if action ~= nil then
			break
		end
		prevTimeOfDay = -1	-- Search earilest, could be 0 (00:00:00), -1 will guarantee a match
		weekDay = nextWeekDay(weekDay)
		extraDays = extraDays + 1
	end
	local nextTime = {year = prevDay.year, month = prevDay.month,
		day = prevDay.day + extraDays, hour = 0, min = 0, sec = 0}
	-- os.time will return UTC time from local time
	return (time(nextTime) + action.startTime), action, schedule
end

local function scheduleActionCompare(a1, a2)
	return (a1.startTime < a2.startTime)
end

function ThermostatSchedule(scheduleTable, thermostats)
	-- Sort all schedule actions by time
	-- This normalizes the schedule action tables
	for _, schedule in ipairs(scheduleTable) do 
		table_sort(schedule.actions, scheduleActionCompare)
	end	
	
	local utcNow = time()
	local localDate = date("*t", utcNow)
	local prevDay = localDate
	local prevTimeOfDay = localDate.hour * 3600 + 
		localDate.min * 60 + localDate.sec
	while true do
		local nextTriggerTime, nextAction, schedule = getNextAction(
			scheduleTable, prevDay, prevTimeOfDay)
		Libre_WaitUntil(nextTriggerTime)
		debugLog(string.format("Trigger action %s:%s",
				schedule.name, nextAction.name))
		-- Set heat and cool setpoints to list of thermostats
		local heat = floor(nextAction.heat * 100)
		local cool = floor(nextAction.cool * 100)
		local attributes = {
			[ATTRID_HVAC_THERMOSTAT_SYSTEM_MODE] = HVAC_THERMOSTAT_SYSTEM_MODE_AUTO,
			[ATTRID_HVAC_THERMOSTAT_OCCUPIED_COOLING_SETPOINT] = cool,
			[ATTRID_HVAC_THERMOSTAT_OCCUPIED_HEATING_SETPOINT] = heat,
		}
		for _, t in ipairs(thermostats) do
			Libre_DeviceThermostatSet(t, attributes)
		end
		
		prevDay = date("*t", nextTriggerTime)
		prevTimeOfDay = nextAction.startTime
	end
end
