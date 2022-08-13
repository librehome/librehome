--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
function ____exports.deviceControl()
    local device = 0
    Libertas_DeviceCommand(device, LibertasClusterId.GEN_ON_OFF, LibertasCommand.ON)
    Libertas_DeviceCommand(device, LibertasClusterId.GEN_LEVEL_CONTROL, LibertasCommand.LEVEL_MOVE_TO_LEVEL, {128, 20})
    Libertas_DeviceSetAttributes(device, LibertasClusterId.HVAC_THERMOSTAT, {[LibertasAttrId.HVAC_THERMOSTAT_SYSTEM_MODE] = LibertasThermostatMode.HEAT, [LibertasAttrId.HVAC_THERMOSTAT_OCCUPIED_HEATING_SETPOINT] = 2300})
end
return ____exports
