// A light show using dimmers.
declare class LightAndLevel {
    @LibertasFieldUnique()
    @LibertasFieldTableHeader()
    @LibertasFieldDeviceTypes(
        [
            [
                LibertasDeviceLoadType.LOAD,
                LibertasDeviceId.ANY,
                [LibertasClusterId.GEN_LEVEL_CONTROL]
            ]
        ]
    )
    light: LibertasDevice;
    @LibertasFieldMin(0)
    @LibertasFieldMax(255)
    @LibertasFieldStep(1)
    @LibertasFieldShowPercentage()
    onLevel: number;
}

declare class LightGroup {
    @LibertasFieldSizeMin(1)
    @LibertasFieldUnordered()
    lightStates: LightAndLevel[];
    @LibertasFieldMin(0.001)
    @LibertasFieldStep(0.001)
    wait: number;
}

export function HolidayLightShow(
    @LibertasFieldSizeMin(1)
    groups: LightGroup[]): void {
    while (true) {
        for (let group of groups) {
            for (let lightState of group.lightStates) {
                Libertas_DeviceCommand(lightState.light,
                    LibertasClusterId.GEN_LEVEL_CONTROL,
                    LibertasCommand.LEVEL_MOVE_TO_LEVEL,
                    [lightState.onLevel, 0]);
            }
            Libertas_Wait(group.wait * 1000);
        }
    }
}