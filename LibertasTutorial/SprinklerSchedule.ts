// Data structure (and UI) used in sprinkler scheduler.
enum DayOfWeek {Sun, Mon, Tue, Wed, Thu, Fri, Sat }

declare class ZoneAction {
    @LibertasFieldDeviceTypes([
        [
            LibertasDeviceLoadType.LOAD, 
            LibertasDeviceId.SPRINKLER_CONTROLLER, 
            [LibertasClusterId.GEN_ON_OFF]
        ]
    ])
    @LibertasFieldAccess(LibertasAccess.Write)
    zone: LibertasDevice;
    duration: number;
}

declare class ScheduleAction {
    startTime: LibertasTimeOnly;
    @LibertasFieldSizeMin(1)
    zoneActions: ZoneAction[];
}

declare class Schedule {
    @LibertasFieldUnique()
    @LibertasFieldUnordered()
    daysOfWeek: DayOfWeek[];
    @LibertasFieldSizeMin(1)
    actions: ScheduleAction[];
}

export function SprinklerSchedule(
    @LibertasFieldSizeMin(1)
    scheduleTable: Schedule[]) {
    // Main process starts here
    const n = LibertasAccess.Read | LibertasAccess.Write | LibertasAccess.Config
}
