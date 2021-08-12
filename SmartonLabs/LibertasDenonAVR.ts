// Copyright Qingjun Wei 2021
// Released under GNU General Public License, version 2
// https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html

const ENUM_SI = [
	'UNKNOWN',
	'PHONO',
	'CD',
	'TUNER',
	'DVD',
	'BD',
	'TV',
	'SAT/CBL',
	'MPLAY',
	'GAME',
	'HDRADIO',
	'NET',
	'PANDORA',
	'SIRIUSXM',
	'IRADIO',
	'SERVER',
	'FAVORITES',
	'AUX1',
	'AUX2',
	'AUX3',
	'AUX4',
	'AUX5',
	'AUX6',
	'AUX7',
	'BT',
	'USB/IPOD',
	'USB',
	'IPD',
	'IRP',
	'FVP'
];

const ENUM_ON_AUTO_OFF = [
	'ON',
	'AUTO',
	'OFF'
];

const ENUM_MS = [
	'UNKNOWN',
	'MOVIE',
	'MUSIC',
	'GAME',
	'DIRECT',
	'PURE DIRECT',
	'STEREO',
	'AUTO',
	'DOLBY PRO LOGIC',
	'DOLBY PL2 C',
	'DOLBY PL2 M',
	'DOLBY PL2 G',
	'DOLBY PL2X C',
	'DOLBY PL2X M',
	'DOLBY PL2X G',
	'DOLBY PL2Z H',
	'DOLBY SURROUND',
	'DOLBY ATMOS',
	'DOLBY DIGITAL',
	'DOLBY D EX',
	'DOLBY D+PL2X C',
	'DOLBY D+PL2X M',
	'DOLBY D+PL2Z H',
	'DOLBY D+DS',
	'DOLBY D+NEO:X C',
	'DOLBY D+NEO:X M',
	'DOLBY D+NEO:X G',
	'DOLBY D+NEURAL:X',
	'DTS SURROUND',
	'DTS ES DSCRT6.1',
	'DTS ES MTRX6.1',
	'DTS+PL2X C',
	'DTS+PL2X M',
	'DTS+PL2Z H',
	'DTS+DS',
	'DTS96/24',
	'DTS96 ES MTRX',
	'DTS+NEO:6',
	'DTS+NEO:X C',
	'DTS+NEO:X M',
	'DTS+NEO:X G',
	'DTS+NEURAL:X',
	'DTS ES MTRX+NEURAL:X',
	'DTS ES DSCRT+NEURAL:X',
	'MULTI CH IN',
	'M CH IN+DOLBY EX',
	'M CH IN+PL2X C',
	'M CH IN+PL2X M',
	'M CH IN+PL2Z H',
	'M CH IN+DS',
	'MULTI CH IN 7.1',
	'M CH IN+NEO:X C',
	'M CH IN+NEO:X M',
	'M CH IN+NEO:X G',
	'M CH IN+NEURAL:X',
	'DOLBY D+',
	'DOLBY D+ +EX',
	'DOLBY D+ +PL2X C',
	'DOLBY D+ +PL2X M',
	'DOLBY D+ +PL2Z H',
	'DOLBY D+ +DS',
	'DOLBY D+ +NEO:X C',
	'DOLBY D+ +NEO:X M',
	'DOLBY D+ +NEO:X G',
	'DOLBY D+ +NEURAL:X',
	'DOLBY HD',
	'DOLBY HD+EX',
	'DOLBY HD+PL2X C',
	'DOLBY HD+PL2X M',
	'DOLBY HD+PL2Z H',
	'DOLBY HD+DS',
	'DOLBY HD+NEO:X C',
	'DOLBY HD+NEO:X M',
	'DOLBY HD+NEO:X G',
	'DOLBY HD+NEURAL:X',
	'DTS HD',
	'DTS HD MSTR',
	'DTS HD+PL2X C',
	'DTS HD+PL2X M',
	'DTS HD+PL2Z H',
	'DTS HD+DS',
	'DTS HD+NEO:6',
	'DTS HD+NEO:X C',
	'DTS HD+NEO:X M',
	'DTS HD+NEO:X G',
	'DTS HD+NEURAL:X',
	'DTS:X',
	'DTS:X MSTR',
	'DTS EXPRESS',
	'DTS ES 8CH DSCRT',
	'MPEG2 AAC',
	'AAC+DOLBY EX',
	'AAC+PL2X C',
	'AAC+PL2X M',
	'AAC+PL2Z H',
	'AAC+DS',
	'AAC+NEO:X C',
	'AAC+NEO:X M',
	'AAC+NEO:X G',
	'AAC+NEURAL:X',
	'PL DSX',
	'PL2 C DSX',
	'PL2 M DSX',
	'PL2 G DSX',
	'PL2X C DSX',
	'PL2X M DSX',
	'PL2X G DSX',
	'AUDYSSEY DSX',
	'DTS NEO:6 C',
	'DTS NEO:6 M',
	'DTS NEO:X C',
	'DTS NEO:X M',
	'DTS NEO:X G',
	'NEURAL:X',
	'NEO:6 C DSX',
	'NEO:6 M DSX',
	'AURO3D',
	'AURO2DSURR',
	'MCH STEREO',
	'WIDE SCREEN',
	'SUPER STADIUM',
	'ROCK ARENA',
	'JAZZ CLUB',
	'CLASSIC CONCERT',
	'MONO MOVIE',
	'MATRIX',
	'VIDEO GAME',
	'VIRTUAL',
	'STEREO',
	'ALL ZONE STEREO',
	'7.1IN'
];

declare class AVRMainZone {
    @LibertasFieldVirtualDeviceType(
        LibertasDeviceLoadType.LOAD,
        LibertasDeviceId.ON_OFF_SWITCH,
        [LibertasClusterId.GEN_ON_OFF])
    onOff: LibertasVirtualDevice;
    @LibertasFieldVirtualDeviceType(
        LibertasDeviceLoadType.LOAD,
        LibertasDeviceId.GEN_MULTISTATE,
        [LibertasClusterId.GEN_MULTISTATE_INPUT_BASIC])
    @LibertasFieldEnum("ENUM_SI")
    input?: LibertasVirtualDevice;
    @LibertasFieldVirtualDeviceType(
        LibertasDeviceLoadType.LOAD,
        LibertasDeviceId.GEN_MULTISTATE,
        [LibertasClusterId.GEN_MULTISTATE_INPUT_BASIC])
    @LibertasFieldEnum("ENUM_ON_AUTO_OFF")
    eco?: LibertasVirtualDevice;
    @LibertasFieldVirtualDeviceType(
        LibertasDeviceLoadType.LOAD,
        LibertasDeviceId.LEVEL_CONTROLLABLE_OUTPUT,
        [LibertasClusterId.GEN_LEVEL_CONTROL, LibertasClusterId.LIBERTAS_LEVEL_CONFIG])
    volume?: LibertasVirtualDevice;
    @LibertasFieldVirtualDeviceType(
        LibertasDeviceLoadType.LOAD,
        LibertasDeviceId.ON_OFF_SWITCH,
        [LibertasClusterId.GEN_ON_OFF])
    mute?: LibertasVirtualDevice;
    @LibertasFieldVirtualDeviceType(
        LibertasDeviceLoadType.LOAD,
        LibertasDeviceId.GEN_MULTISTATE,
        [LibertasClusterId.GEN_MULTISTATE_INPUT_BASIC])
    @LibertasFieldEnum("ENUM_MS")
    mode?: LibertasVirtualDevice;
}

declare class AVRExtraZone {
    @LibertasFieldVirtualDeviceType(
        LibertasDeviceLoadType.LOAD,
        LibertasDeviceId.ON_OFF_SWITCH,
        [LibertasClusterId.GEN_ON_OFF])
    onOff: LibertasVirtualDevice;
    @LibertasFieldVirtualDeviceType(
        LibertasDeviceLoadType.LOAD,
        LibertasDeviceId.GEN_MULTISTATE,
        [LibertasClusterId.GEN_MULTISTATE_INPUT_BASIC])
    @LibertasFieldEnum("ENUM_SI")
    input?: LibertasVirtualDevice;
    @LibertasFieldVirtualDeviceType(
        LibertasDeviceLoadType.LOAD,
        LibertasDeviceId.LEVEL_CONTROLLABLE_OUTPUT,
        [LibertasClusterId.GEN_LEVEL_CONTROL, LibertasClusterId.LIBERTAS_LEVEL_CONFIG])
    volume?: LibertasVirtualDevice;
    @LibertasFieldVirtualDeviceType(
        LibertasDeviceLoadType.LOAD,
        LibertasDeviceId.ON_OFF_SWITCH,
        [LibertasClusterId.GEN_ON_OFF])
    mute?: LibertasVirtualDevice;
    @LibertasFieldVirtualDeviceType(
        LibertasDeviceLoadType.LOAD,
        LibertasDeviceId.GEN_MULTISTATE,
        [LibertasClusterId.GEN_MULTISTATE_INPUT_BASIC])
    @LibertasFieldEnum("ENUM_MS")
    mode?: LibertasVirtualDevice;
}

enum AckAction {
    NA,     // No ack
    UPDATE, // Send ack on a new state
    FORCE,
}

interface PendingMessage {
    d: LibertasVirtualDevice | undefined;
    c: string;      // Command
    n: number;      // Prefix length
    a: AckAction;
    s: LibertasEventSource;
    t: number;      // millisecond ticks
}

const TIMEOUT_ACK = 2000;           // 2s
const TIMEOUT_HB = 60000;           // 60s
const TIMEOUT_RECONN_WAIT = 10000;  // 10s

function getEnumIndex(value: string, e: string[], start?: number, def?: number): number|undefined {
    start = start || 0;
    for (let i=start; i<e.length; i++) {
        if (e[i] === value) {
            return i;
        }
    }
    return def;
}

function getBoolean(value: string): boolean | undefined {
    if (value === "ON") {
        return true;
    } else if (value === "OFF") {
        return false;
    }
}

function virtualDeviceSendReport(device: LibertasVirtualDevice, value: number|boolean) {
    if (Libre_DeviceSupportsCluster(device, LibertasClusterId.GEN_LEVEL_CONTROL)) {
        Libre_VirtualDeviceLevelReport(device, value as number);
    } else if (Libre_DeviceSupportsCluster(device, LibertasClusterId.GEN_ON_OFF)) {
        Libre_VirtualDeviceOnOffReport(device, value as boolean);
    } else if (Libre_DeviceSupportsCluster(device, LibertasClusterId.GEN_MULTISTATE_INPUT_BASIC)) {
        const attrs: LibertasDeviceClusterAttributes = {
            [LibertasAttrId.IOV_BASIC_PRESENT_VALUE]: value
        }
        Libre_VirtualDeviceSetAttributes(device, 
            LibertasClusterId.GEN_MULTISTATE_INPUT_BASIC,
            attrs,
            LibertasEventSource.REPORT);
    }
}

function DenonAVR(
    avr: LibertasLanDevice, 
    mainZone: AVRMainZone, 
    @LibertasFieldSizeMax(2)
    extraZones: AVRExtraZone[]): void {

    const curIncoming = new lbuffer();
    const unsupportedCmds = new Set<string>();
    const suspectedUnsupportedCmd = new Map<string, number>();
    const socket = Libre_NetNewTcp();
    const deviceValues = new Map<LibertasVirtualDevice, number|boolean>();
    const validDevices = new Set<LibertasVirtualDevice>();
    // A zone cannot be controlled if it is powered off.
    let pendingMessages = new LibertasList<PendingMessage>();
    let pendingAck: PendingMessage | undefined;
    let ready = false;
    let validSession = false;   // Session is valid when the first ACK(ZM?) is received

    // Three timers
    const reconnectTimer = Libre_TimerNew(0, 
        ()=>{
            Libre_NetConnectDevice(socket, avr, 23);            
        });
    const commandAckTimer = Libre_TimerNew(0, ()=>{
            onError();
        });
    const heartBeatTimer = Libre_TimerNew(0, 
            ()=>{   // Use power on/off query as heartbeat
                enqueuePendingMessagesForce(undefined, "ZM?\r", 2, AckAction.NA, LibertasEventSource.NA);
            }
        );

    function onError() {
        let reconnectTimeout = TIMEOUT_RECONN_WAIT;
        if (validSession && pendingAck) {
            let failureCount = suspectedUnsupportedCmd.get(pendingAck.c);
            if (failureCount === undefined) {
                failureCount = 0;
            }
            if (failureCount >= 3) {
                suspectedUnsupportedCmd.delete(pendingAck.c);
                unsupportedCmds.add(pendingAck.c);
            } else {
                suspectedUnsupportedCmd.set(pendingAck.c, failureCount + 1);
            }
            reconnectTimeout = 100;     // reduce to 100ms
        }
        for (let device of validDevices) {
            Libre_VirtualDeviceStatusDeviceDown(device);
        }
        deviceValues.clear();
        Libre_NetClose(socket);     // Will reconnect later
        Libre_TimerCancel(commandAckTimer);
        Libre_TimerCancel(heartBeatTimer);
        ready = false;
        Libre_TimerUpdate(reconnectTimer, reconnectTimeout);
    }

    function enqueuePendingMessagesForce(
		device: LibertasVirtualDevice|undefined,
		command: string,
		prefixLen: number,
		ack: AckAction,
		source: LibertasEventSource) {
        if (ready) {
            if (!unsupportedCmds.has(command)) {
                const msg: PendingMessage = {
                    d: device,
                    c: command,
                    n: prefixLen,
                    a: ack,
                    s: source,
                    t: os.msticks()
                }
                pendingMessages.pushright(msg);
                trySendMessage();
            }
        }
    }

    function enqueuePendingMessages(
		device: LibertasVirtualDevice|undefined,
		command: string,
		prefixLen: number,
		ack: AckAction,
		source: LibertasEventSource) {
        if (device !== undefined) {
            enqueuePendingMessagesForce(device, command, prefixLen, ack, source);
        }
    }

    function rescheduleHeartbeat() {
        if (ready) {
            if (!pendingAck) {
                Libre_TimerUpdate(heartBeatTimer, TIMEOUT_HB);
            } else {
                Libre_TimerCancel(heartBeatTimer);
            }
        }
    }

    function trySendMessage() {
        if (ready && pendingAck === undefined) {
            pendingAck = pendingMessages.popleft();
            if (pendingAck) {
                Libre_NetWrite(socket, pendingAck.c);
                Libre_TimerUpdate(commandAckTimer, TIMEOUT_ACK);
            }
            rescheduleHeartbeat();
        }
    }

    function cbUpdate(device: LibertasVirtualDevice|undefined, cmd: string, value: number|boolean) {
        const oldValue = (device !== undefined) ? deviceValues.get(device) : undefined;
        const modified = (oldValue === undefined || oldValue !== value);
        let shouldNotify = false;
        let source = LibertasEventSource.MANUAL_LOCAL;

        let isAck = (pendingAck !== undefined && pendingAck.n === cmd.length &&
                pendingAck.c.startsWith(cmd));
        if (isAck) {
            suspectedUnsupportedCmd.delete(pendingAck!.c);  // It is a valid command
            const ackAction = pendingAck!.a
            if (ackAction === AckAction.UPDATE) {
                shouldNotify = modified;
            } else if (ackAction === AckAction.FORCE) {
                shouldNotify = true
            }
            source = pendingAck!.s;
            pendingAck = undefined;
            Libre_TimerCancel(commandAckTimer);
            validSession = true;
            trySendMessage();
        } else {    // For unsolicited commands, only notify on change
            shouldNotify = modified;
        }
        if (device !== undefined) {
            deviceValues.set(device, value);
            if (shouldNotify) {
                if (oldValue === undefined) {   // Initial report
                    virtualDeviceSendReport(device, value);
                } else {
                    if (Libre_DeviceSupportsCluster(device, LibertasClusterId.GEN_LEVEL_CONTROL)) {
                        Libre_VirtualDeviceLevelSet(device, value as number, source);
                    } else if (Libre_DeviceSupportsCluster(device, LibertasClusterId.GEN_ON_OFF)) {
                        Libre_VirtualDeviceOnOffSet(device, value as boolean, source);
                    } else if (Libre_DeviceSupportsCluster(device, LibertasClusterId.GEN_MULTISTATE_INPUT_BASIC)) {
                        const attrs: LibertasDeviceClusterAttributes = {
                            [LibertasAttrId.IOV_BASIC_PRESENT_VALUE]: value
                        }
                        Libre_VirtualDeviceSetAttributes(device, 
                            LibertasClusterId.GEN_MULTISTATE_INPUT_BASIC,
                            attrs,
                            source);
                    }
                }
            }
        }
    }

    function onMV(cmd: string, params: string) {
        let v = tonumber(params);
        if (v !== undefined) {
            if (params.length == 2) {
                v = v * 10;
            }
            v = v / 5;      // 00.0 - 98.0 TOTAL = 98 * 2
            cbUpdate(mainZone.volume!, cmd, v);
        }
    }

    function onMU(cmd: string, params: string) {
        const v = getBoolean(params);
        if (v !== undefined) {
            cbUpdate(mainZone.mute!, cmd, v);
        }
    }

    function onSI(cmd: string, params: string) {
        const v = getEnumIndex(params, ENUM_SI, 1, 0);
        if (v !== undefined) {
            cbUpdate(mainZone.input!, cmd, v);
        }
    }

    function onMS(cmd: string, params: string) {
        const v = getEnumIndex(params, ENUM_MS, 1, 0);
        if (v !== undefined) {
            cbUpdate(mainZone.mode!, cmd, v);
        }
    }

    function onZM(cmd: string, params: string) {
        const v = getBoolean(params);
        if (v !== undefined) {
            cbUpdate(mainZone.onOff!, cmd, v);
        }
    }

    function onECO(cmd: string, params: string) {
        const v = getEnumIndex(params, ENUM_ON_AUTO_OFF);
        if (v !== undefined) {
            cbUpdate(mainZone.eco!, cmd, v);
        }
    }

    /**
     * @zone: 0 = Z2, 1 - Z3
     */
    function onExtraZone(zone: 0|1, cmd: string, params: string) {
        if (extraZones.length < zone + 1) {
            return;
        }
        let d: LibertasVirtualDevice | undefined;
        let v: number|boolean|undefined = tonumber(params);
        if (v !== undefined) {
            if (params.length == 2) {
                v = v * 10;
            }
            v = v / 5;      // 00.0 - 98.0 TOTAL = 98 * 2
            d = extraZones[zone].volume;
        } else if (params == "ON") {
            d = extraZones[zone].onOff;
            v = true;
        } else if (params == "OFF") {
            d = extraZones[zone].onOff;
            v = false;
        } else if (params == "MUON") {
            d = extraZones[zone].mute;
            cmd += "MU";
            v = true;
        } else if (params == "MUOFF") {
            d = extraZones[zone].mute;
            cmd += "MU";
            v = false;
        } else {
            v = getEnumIndex(params, ENUM_SI, 1);
            if (v !== undefined) {
                d = extraZones[zone].input;
            } else {
                v = getEnumIndex(params, ENUM_MS, 1);
                if (v !== undefined) {
                    d = extraZones[zone].mode;
                }                
            }
        }
        if (d !== undefined && v != undefined) {
            cbUpdate(d, cmd, v);
        }
    }    

    type CommandHandler = (cmd: string, params: string)=>void;
    const HANDLERS = new LuaTable<string, CommandHandler|undefined>();
    HANDLERS.set("ZM", onZM);   // Onoff is mandatory
    if (mainZone.eco !== undefined) {
        HANDLERS.set("ECO", onECO);
    }
    if (mainZone.input !== undefined) {
        HANDLERS.set("SI", onSI);
    }
    if (mainZone.mute !== undefined) {
        HANDLERS.set("MU", onMU);
    }
    if (mainZone.volume !== undefined) {
        HANDLERS.set("MV", onMV);
    }
    if (mainZone.mode !== undefined) {
        HANDLERS.set("MS", onMS);
    }    

    function onIncoming(c: number) {
        if (c == 0x0d) {    // '\r'
            let cmd, params: string;
            if (curIncoming.length > 3) {
                if (curIncoming.tostring(0, 3) === "ECO") {
                    cmd = "ECO";
                    params = curIncoming.tostring(3);
                } else {
                    cmd = curIncoming.tostring(0, 2);
                    params = curIncoming.tostring(2);
                }
                if (cmd == "Z2") {
                    onExtraZone(0, cmd, params);
                } else if (cmd == "Z3") {
                    onExtraZone(1, cmd, params);
                } else {
                    const f = HANDLERS.get(cmd);
                    if (f) {
                        f(cmd, params);
                    }
                }
            }
            curIncoming.setlen(0);
            rescheduleHeartbeat();
        } else {
            const p = curIncoming.length;
            curIncoming.setlen(p + 1);
            curIncoming[p] = c;
        }
    }

    function getCmdParameter(event: LibertasEvent, index: number): LibertasDeviceAttributeValue|undefined {
        if (event.v !== undefined) {
            const l = event.v as LibertasDeviceAttributeValue[];
            return l[index];
        }
    }

    function genCmdVolume(cmd: string, v: number): string|undefined {
        if (v >= 0 && v <= 98) {
            const whole = math.floor(v);
			const fraction = v - whole;
			if (fraction != 0) {
                return string.format("%s%02d5\r", cmd, whole)
            } else {
                return string.format("%s%02d\r", cmd, whole)
            }
        }
    }

    function onControlVolume(event: LibertasEvent, cmd: string): string|undefined {
        if (event.c != LibertasClusterId.GEN_LEVEL_CONTROL) {
            return;
        }
        if (event.t != LibertasEventType.COMMAND) {
            return;
        }
        let outCmd: string|undefined;
        if (cmd !== undefined && event.d !== undefined) {
            if (event.d === LibertasCommand.LEVEL_STEP ||
                event.d === LibertasCommand.LEVEL_STEP_WITH_ON_OFF) {
                const stepMode = getCmdParameter(event, 0) as number;
                const stepBy = getCmdParameter(event, 1) as number;
                const curValue = deviceValues.get(event.id);
                if (curValue === undefined) {
                    if (stepMode == LibertasLevelStep.UP) {
                        outCmd = string.format("%sUP\r", cmd)
                    } else if (stepMode == LibertasLevelStep.DOWN) {
                        outCmd = string.format("%sDOWN\r", cmd)
                    }
                } else {
                    let newValue = curValue as number;
                    if (stepMode == LibertasLevelStep.UP) {
                        newValue += stepBy;
                    } else if (stepMode == LibertasLevelStep.DOWN) {
                        newValue -= stepBy;
                    }
                    if (newValue >= 0 && newValue < 98 * 2 && newValue !== curValue) {
                        outCmd = genCmdVolume(cmd, newValue / 2)
                    }
                }
            } else if (event.d === LibertasCommand.LEVEL_MOVE_TO_LEVEL ||
                event.d === LibertasCommand.LEVEL_MOVE_TO_LEVEL_WITH_ON_OFF) {
                const level = getCmdParameter(event, 0) as number;	// Ignore transition time
                outCmd = genCmdVolume(cmd, level / 2);
            }
            return outCmd;
        }
    }

    function onControlOnOff(event: LibertasEvent, cmd: string): string|undefined {
        if (event.c != LibertasClusterId.GEN_ON_OFF) {
            return;
        }
        if (event.t != LibertasEventType.COMMAND) {
            return;
        }        
        let outCmd: string|undefined;
        if (event.d === LibertasCommand.ON) {
            outCmd = string.format("%sON\r", cmd);
        } else if (event.d === LibertasCommand.OFF) {
            outCmd = string.format("%sOFF\r", cmd);
        } else if (event.d === LibertasCommand.TOGGLE) {
            let curValue = deviceValues.get(event.id);
            if (curValue === undefined) {
                curValue = false;
            }
            const newValue = !(curValue as boolean);
            outCmd = string.format("%s%s\r", cmd, (newValue) ? "ON" : "OFF");
        }
        return outCmd;
    }

    function onControlEnum(event: LibertasEvent, cmd: string, values?: string[]): string|undefined {
        if (event.c != LibertasClusterId.GEN_MULTISTATE_INPUT_BASIC) {
            return;
        }
        if (event.t != LibertasEventType.ATTR) {
            return;
        }
        if (event.s === LibertasEventSource.QUERY || event.s === LibertasEventSource.REPORT) {
            return;
        }
        const attrs = event.v as LibertasDeviceClusterAttributes;
        const v = attrs[LibertasClusterId.GEN_MULTISTATE_INPUT_BASIC << 16 | LibertasAttrId.IOV_BASIC_PRESENT_VALUE];
        if (v !== undefined) {
            const val = values![v as number];
            if (val !== undefined) {
                return string.format("%s%s\r", cmd, val);
            }
        }
    }

    type DeviceControlCmdGen = (event: LibertasEvent, cmd: string, values?: string[])=>string|undefined;
    function initCtrlMap(d: LibertasVirtualDevice|undefined, 
            cmd: string, 
            f: DeviceControlCmdGen, 
            depends: LibertasVirtualDevice,
            values?: string[]) {
        if (d !== undefined) {
            validDevices.add(d);
            Libre_SetOnVirtualDevice(d, (_, event)=>{
                // Received user control events
                if (d !== depends) {    // Not controlling zone power
                    const dependentPower = deviceValues.get(depends);
                    if (dependentPower === undefined || !(dependentPower as boolean)) {
                        // Zone is powered off, do not control it! Send report instead.
                        const value = deviceValues.get(d);
                        if (value !== undefined) {
                            virtualDeviceSendReport(d, value);
                        }
                        return;
                    }
                }
                const ctrlCmd = f(event, cmd, values);
                if (ctrlCmd) {
                    enqueuePendingMessages(
                        d,
                        ctrlCmd,
                        cmd.length,
                        AckAction.FORCE,
                        event.s!);       
                }
            });
        }
    }

    function initSubZone(zone: AVRExtraZone, cmd: string) {
        initCtrlMap(zone.input, cmd, onControlEnum, zone.onOff, ENUM_SI);
        initCtrlMap(zone.mode, cmd, onControlEnum, zone.onOff, ENUM_MS);
        initCtrlMap(zone.mute, cmd + "MU", onControlOnOff, zone.onOff);
        initCtrlMap(zone.onOff, cmd, onControlOnOff, zone.onOff);
        initCtrlMap(zone.volume, cmd, onControlVolume, zone.onOff);
    }
    initCtrlMap(mainZone.eco, "ECO", onControlEnum, mainZone.onOff, ENUM_ON_AUTO_OFF);
    initCtrlMap(mainZone.input, "SI", onControlEnum, mainZone.onOff, ENUM_SI);
    initCtrlMap(mainZone.mute, "MU", onControlOnOff, mainZone.onOff);
    initCtrlMap(mainZone.onOff, "ZM", onControlOnOff, mainZone.onOff);
    initCtrlMap(mainZone.volume, "MV", onControlVolume, mainZone.onOff);
    initCtrlMap(mainZone.input, "MS", onControlEnum, mainZone.onOff, ENUM_MS);
    if (extraZones.length > 0) {
        initSubZone(extraZones[0], "Z2");
        if (extraZones.length > 1) {
            initSubZone(extraZones[1], "Z3");
        }
    }

    function initVolumeAttributes(device: LibertasVirtualDevice | undefined) {
        if (device !== undefined) {
            Libre_VirtualDeviceSetAttributes(
                device, 
                LibertasClusterId.LIBERTAS_LEVEL_CONFIG,
                {                                                       // LibertasDeviceClusterAttributes
                    [LibertasAttrId.LIBERTAS_LEVEL_MIN]: 0,
                    [LibertasAttrId.LIBERTAS_LEVEL_MAX]: 196,           // Max volume 98*2
                    [LibertasAttrId.LIBERTAS_LEVEL_STEP_ONLY]: true,    // Only repeated step commands are allowed (prevent volume out-of-control)
                    [LibertasAttrId.LIBERTAS_LEVEL_STEP_SINGLE]: 1,     // Single press step 1
                    [LibertasAttrId.LIBERTAS_LEVEL_STEP_REPEAT]: 3,     // Long press step 3 (speed up)
                    [LibertasAttrId.LIBERTAS_LEVEL_STEP_INTERVAL]: 5    // 500ms
                },
                LibertasEventSource.REPORT);
        }
    }

    function initMultiStateAttributes(device: LibertasVirtualDevice | undefined, 
            nStates: number,
            minState?: number) {
        if (device !== undefined) {
            Libre_VirtualDeviceSetAttributes(
                device, 
                LibertasClusterId.GEN_MULTISTATE_INPUT_BASIC,
                {
                    [LibertasAttrId.IOV_BASIC_NUM_OF_STATES]: nStates
                },
                LibertasEventSource.REPORT);
            if (minState !== undefined && minState !== 0) {
                Libre_VirtualDeviceSetAttributes(
                    device, 
                    LibertasClusterId.LIBERTAS_HUB,
                    {
                        [LibertasAttrId.LIBERTAS_MULTISTATE_MIN]: minState
                    },
                    LibertasEventSource.REPORT);
            }                
        }
    }

    initVolumeAttributes(mainZone.volume);
    initMultiStateAttributes(mainZone.input, ENUM_SI.length, 1);
    initMultiStateAttributes(mainZone.eco, ENUM_ON_AUTO_OFF.length);
    initMultiStateAttributes(mainZone.mode, ENUM_MS.length, 1);
    if (extraZones.length > 0) {
        initVolumeAttributes(extraZones[0].volume);
        initMultiStateAttributes(extraZones[0].input, ENUM_SI.length, 1);
        initMultiStateAttributes(extraZones[0].mode, ENUM_MS.length, 1);
        if (extraZones.length > 1) {
            initVolumeAttributes(extraZones[1].volume);
            initMultiStateAttributes(extraZones[1].input, ENUM_SI.length, 1);
            initMultiStateAttributes(extraZones[1].mode, ENUM_MS.length, 1);
        }
    }    

    Libre_SetOnNetReady(socket, (tag)=>{
        // First reset
        curIncoming.setlen(0);
        pendingMessages = new LibertasList<PendingMessage>();
        pendingAck = undefined;

        ready = true;
        validSession = false;

        enqueuePendingMessagesForce(
            mainZone.onOff,
            "ZM?\r", 
            2, 
            AckAction.FORCE, 
            LibertasEventSource.REPORT);
        enqueuePendingMessages(
            mainZone.volume,
            "MV?\r", 
            2, 
            AckAction.FORCE, 
            LibertasEventSource.REPORT);
        enqueuePendingMessages(
            mainZone.mute,
            "MU?\r",
            2, 
            AckAction.FORCE, 
            LibertasEventSource.REPORT);
        enqueuePendingMessages(
            mainZone.input,
            "SI?\r",             
            2, 
            AckAction.FORCE, 
            LibertasEventSource.REPORT);
        enqueuePendingMessages(
            mainZone.eco,
            "ECO?\r",             
            3, 
            AckAction.FORCE, 
            LibertasEventSource.REPORT);
        enqueuePendingMessages(
            mainZone.mode,
            "MS?\r",             
            2, 
            AckAction.FORCE, 
            LibertasEventSource.REPORT);
        if (extraZones.length > 0) {
            enqueuePendingMessagesForce(
                undefined,
                "Z2?\r",
                2, 
                AckAction.FORCE, 
                LibertasEventSource.REPORT);
            if (extraZones.length > 1) {
                enqueuePendingMessagesForce(
                    undefined,
                    "Z3?\r",
                    2, 
                    AckAction.FORCE, 
                    LibertasEventSource.REPORT);
            }
        }
    });
    Libre_SetOnNetDrain(socket, ()=>{
        trySendMessage();
    });
    Libre_SetOnNetError(socket, (tag, fd, errorType, errorCode, errorText)=>{
        onError();
    });
    Libre_SetOnNetData(socket, (tag, fd, data)=>{
        for (let i=0; i<data.length; i++) {
            onIncoming(data.charCodeAt(i));
        }
    });
    Libre_NetSetConnectTimeout(socket, 10);
    // Kick start the TCP connection
    Libre_NetConnectDevice(socket, avr, 23);
    Libre_WaitReactive();
}

export {DenonAVR}
