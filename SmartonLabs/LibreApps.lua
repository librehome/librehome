-- Copyright 2015-2020 Smartonlabs Inc
-- Released under MIT License
-- https://opensource.org/licenses/MIT
local ipairs = ipairs
local Libre_DeviceLevelSet = Libre_DeviceLevelSet
local Libre_Wait = Libre_Wait

function HolidayLightShow(groups)
	while true do
		-- groups is a list of control group
		for i, group in ipairs(groups) do
      		for j, lightState in ipairs(group.lightStates) do
				Libre_DeviceLevelSet(lightState.light, lightState.onLevel)
			end
			Libre_Wait(group.wait * 1000)
    	end		
	end
end