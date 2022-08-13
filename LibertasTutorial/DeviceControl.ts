// Note this the pseudocode. The device is invalid (hard coded to 0).
// Do not attempt the run this task directly! Otherwise the task will
// be disabled due to invalid access.
export function deviceControl() {
    const device = 0;

    // Turn on a device
    Libertas_DeviceCommand(device,
        LibertasClusterId.GEN_ON_OFF,
        LibertasCommand.ON);
    // Set dimmer level to 128 within 20X100ms = 2 seconds
    Libertas_DeviceCommand(device,
        LibertasClusterId.GEN_LEVEL_CONTROL,
        LibertasCommand.LEVEL_MOVE_TO_LEVEL,
        [128, 20]);
    // Set thermostat to heat at 23.00 °C
    Libertas_DeviceSetAttributes(device,
        LibertasClusterId.HVAC_THERMOSTAT,
        {
            [LibertasAttrId.HVAC_THERMOSTAT_SYSTEM_MODE]: LibertasThermostatMode.HEAT,
            [LibertasAttrId.HVAC_THERMOSTAT_OCCUPIED_HEATING_SETPOINT]: 2300,
        });
}