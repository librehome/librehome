--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
function ____exports.VirtualSwitch(device)
    Libertas_SetOnVirtualDevice(
        device,
        function(tag, event)
            if event.c == LibertasClusterId.GEN_ON_OFF then
                if event.t == LibertasEventType.COMMAND then
                    if event.d == LibertasCommand.ON or event.d == LibertasCommand.OFF then
                        Libertas_VirtualDeviceCommand(
                            device,
                            LibertasClusterId.GEN_ON_OFF,
                            event.d,
                            event.s,
                            {}
                        )
                    end
                end
            end
        end
    )
    Libertas_VirtualDeviceUpdate(device, LibertasClusterId.GEN_ON_OFF, {[LibertasAttrId.ON_OFF] = false}, LibertasEventSource.REPORT)
end
return ____exports
