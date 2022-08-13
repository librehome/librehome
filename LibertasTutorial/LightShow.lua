--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
function ____exports.HolidayLightShow(groups)
    while true do
        for ____, group in ipairs(groups) do
            for ____, lightState in ipairs(group.lightStates) do
                Libertas_DeviceCommand(lightState.light, LibertasClusterId.GEN_LEVEL_CONTROL, LibertasCommand.LEVEL_MOVE_TO_LEVEL, {lightState.onLevel, 0})
            end
            Libertas_Wait(group.wait * 1000)
        end
    end
end
return ____exports
