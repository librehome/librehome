-- Copyright 2015-2020 Smartonlabs Inc
-- All Right Reserved
-- Released under MIT License
-- https://opensource.org/licenses/MIT
local pairs = pairs
local ipairs = ipairs
local error = error
local table_sort = table.sort
local date = os.date
local time = os.time
local floor = math.floor
local getn = table.getn
local Libre_WaitUntil = Libre_WaitUntil
local Libre_DeviceOnWithTimedOff = Libre_DeviceOnWithTimedOff

-- Minimum duration is 5 seconds
local MIN_DURATION = 5

local function debugLog(message)
	if false then
		Libre_Log(0, message)
	end
end

local function scheduleActionCompare(a1, a2)
	return (a1.startTime < a2.startTime)
end

-------------------------------------
-- Get next action from current time
-- @param localTimeOfDay 	Local time of day in seconds
-- @param actions 			Array of actions
-- @return					action or nil, index, waitTime and duration
-------------------------------------
local function getNextAction(localTimeOfDay, actions)
	for _, action in ipairs(actions) do
		local startTime = action.startTime
		local endTime = action.startTime
		for index, zoneAction in ipairs(action.zoneActions) do
			endTime = endTime + zoneAction.duration * 60
			if localTimeOfDay <= startTime then
				local waitTime = startTime - localTimeOfDay
				local duration = zoneAction.duration * 60
				return action, index, waitTime, duration
			elseif endTime > localTimeOfDay then
				local duration = endTime - localTimeOfDay
				if duration > MIN_DURATION then
					return action, index, 0, duration
				end
			end
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
-- @return					schedule or nil, index, waitTime, duration
-------------------------------------
local function getNextScheduleAction(scheduleTable, weekDay, localTime)
	for _, schedule in ipairs(scheduleTable) do
		if (weekContains(weekDay, schedule.weekDays)) then
			local action, index, waitTime, duration = getNextAction(localTime, schedule.actions)
			if action ~= nil then
				return action, index, waitTime, duration
			end
		end
	end
	return nil
end

-------------------------------------
-- Calculate next week day
-- @param dayOfWeek 	Array of schedules
-- @return			A number between 0 and 6
-------------------------------------
local function nextDayOfWeek(dayOfWeek)
	dayOfWeek = dayOfWeek + 1
	if dayOfWeek >= 7 then
		dayOfWeek = 0
	end
	return dayOfWeek
end

-------------------------------------
-- Get next action from a certain date and time
-- @param scheduleTable 	Array of schedules
-- @param curDay 			Table representing a local date; time will be ignored
-- @param prevTimeOfDay 	New action must be after the curDay and this time
-- @return					a number representing next UTC epoch time and a schedule
--							or 0, schedule, actionIndex, and duration
-------------------------------------
local function getNextSchedule(scheduleTable, curDay, prevTimeOfDay)
	local dayOfWeek = curDay.wday - 1	-- Adjust to 0 based
	local extraDays = 0
	while true do
		local action, index, waitTime, duration = getNextScheduleAction(scheduleTable, 
			dayOfWeek, prevTimeOfDay)
		if action ~= nil then
			if waitTime > 0 or extraDays > 0 then
				local nextTime = {year = curDay.year, month = curDay.month,
					day = curDay.day + extraDays, hour = 0, min = 0, sec = 0}
				-- os.time will return UTC time from local time
				return time(nextTime) + action.startTime, action
			else
				return 0, action, index, duration
			end
		end
		prevTimeOfDay = -MIN_DURATION	-- Search earilest, could be 0 (00:00:00), -MIN_DURATION will guarantee a match
		dayOfWeek = nextDayOfWeek(dayOfWeek)
		extraDays = extraDays + 1
	end
end

-- scheduleTable structure:
--	scheduleTable
--	  schedule
--		weekDays
--		actions
--		  action
--			startTime
--			zoneActions
--			  zoneAction
--				zone
--				duration (minutes)
function SprinklerSchedule(scheduleTable)
	-- Sort all schedule actions by startTime
	-- This normalizes the schedule action tables
	for _, schedule in ipairs(scheduleTable) do 
		table_sort(schedule.actions, scheduleActionCompare)
	end	
	
	while true do
		local utcNow = time()
		local localDate = date("*t", utcNow)
		local curDay = localDate
		local prevTimeOfDay = localDate.hour * 3600 + 
			localDate.min * 60 + localDate.sec
		local nextTriggerTime, action, index, duration = getNextSchedule(
			scheduleTable, curDay, prevTimeOfDay)

		if nextTriggerTime > 0 then
			debugLog(string.format("Trigger at %f", nextTriggerTime))
			Libre_WaitUntil(nextTriggerTime)
			for i, zoneAction in ipairs(action.zoneActions) do
				debugLog(string.format("Trigger at index %d, total=%d, duration seconds=%f", 
					i, getn(action.zoneActions), zoneAction.duration * 60 * 10))				
				Libre_DeviceOnWithTimedOff(zoneAction.zone, zoneAction.duration * 60 * 10,	0)
				Libre_Wait(zoneAction.duration * 1000)
			end
		else
			debugLog(string.format("Trigger at index %d", index))
			for i=index, getn(action.zoneActions) do
				local zoneAction = action.zoneActions[i]
				local durationSeconds = zoneAction.duration * 60
				if i == index then
					durationSeconds = duration
				end
				debugLog(string.format("Trigger at index %d, total=%d, duration seconds=%f", 
					i, getn(action.zoneActions), durationSeconds))
				-- On/off duration is in 1/10 seconds
				Libre_DeviceOnWithTimedOff(zoneAction.zone, durationSeconds * 10, 0)
				Libre_Wait(durationSeconds * 1000)
			end
		end
	end
end