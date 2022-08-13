// Usage of virtual device API.
// For more information, read LibertasDenonAVR.

export function VirtualSwitch(
    @LibertasFieldVirtualDeviceType(
        LibertasDeviceLoadType.LOAD,
        LibertasDeviceId.ON_OFF_SWITCH, 
        [LibertasClusterId.GEN_ON_OFF])
    device: LibertasVirtualDevice) {
    Libertas_SetOnVirtualDevice(device, (tag, event) => {
        if (event.c === LibertasClusterId.GEN_ON_OFF) {
            if (event.t === LibertasEventType.COMMAND) {
                if (event.d === LibertasCommand.ON ||
                    event.d === LibertasCommand.OFF) {
                    Libertas_VirtualDeviceCommand(
                        device, 
                        LibertasClusterId.GEN_ON_OFF,
                        event.d,
                        event.s!,
                        []);                        
                }
            }
        }
    });
    Libertas_VirtualDeviceUpdate(
        device, 
        LibertasClusterId.GEN_ON_OFF,
        {                                  
            [LibertasAttrId.ON_OFF]: false, // Initially set to off
        },
        LibertasEventSource.REPORT);    
}
