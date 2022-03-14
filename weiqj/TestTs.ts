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

function HolidayLightShow(
    @LibertasFieldSizeMin(1)
    groups: LightGroup[]): void {
    while (true) {
        for (let group of groups) {
            for (let lightState of group.lightStates) {
                Libre_DeviceLevelSet(lightState.light, lightState.onLevel);
            }
            Libre_Wait(group.wait * 1000);
        }
    }
}

function TestSimple() {
    console.log("hello world");
}

function TestWeakSet() {
    const objweakSet = new WeakSet([{ text: "hi" }]);
    const obj1 = { text: "hello" };
    const obj2 = { text: "bye" };
    objweakSet.add(obj1);
    console.log(objweakSet.has(obj1));
    console.log(objweakSet.has(obj2));
    objweakSet.add(obj2);
    console.log(objweakSet.has(obj2));
}

function getANumber(): number {
    return 100;
}

// A simple timer that fires every 1 second (1000ms)
function TestTimer() {
    const t = Libre_TimerNew(1000, (tag, timer) => {
        console.log("TestTimer called.");
        Libre_TimerUpdate(t, 1000); // Repeat itself
    }, undefined);
    Libre_WaitReactive();
}

function TestBuffer() {
    const b = new lbuffer(100);
    console.log("b:len()", b.length);
    b[0] = 1;
    console.log("b[0]=", b[0]);
    b[0] = 2;
    console.log("b[0]=", b[0]);
    b[0] = 255;
    console.log("b[0]=", b[0]);
    b.set(1, "ABC");
    console.log("b=", b[0], b[1], b[2], b[3]);
    b.set(100, "ABC");
    console.log("b:len()", b.length);
    console.log("b=", b[100], b[101], b[1022], b[103]);

    let c = new lbuffer('ABCDEFGHIJKLMN');
    console.log(c.tostring(0, 2));
    console.log(c.tostring(1, 2));
    console.log(c.tostring(2, 2));
    c.set(2, "0123456789", 1, 5);
    console.log(c.tostring());

    c = new lbuffer('ABCDEFGHIJKLMN');
    c.clear(1, 5);
    console.log(c.tostring());

    c = new lbuffer('ABCDEFGHIJKLMN');
    c.remove(1, 5);
    console.log(c.tostring());
}

function TestRxHttpClient() {
    const tag = {
        step: 1,
    }

    // HTTP client headers
    const header: LibertasHttpHeader[] = [
        ["Accept", "*/*"],
        ["User-Agent", "librehub/0.1"],
    ]

    const fd = Libre_NetNewHttp();
    Libre_SetOnNetError(fd, (tag, fd, errCode, httpStatus, text) => {
        console.log(string.format(
            'Error %s', text));
        Libre_ExitThread()
    }, tag);
    Libre_SetOnNetHttpResponse(fd, (t, fd, res) => {
        console.log(string.format(
            'statusCode %d', res.statusCode));
        if (res.body) {
            let length = res.body.length;
            if (length > 100) {
                length = 100
            }
            console.log(string.format(
                'Respbody %s', res.body.substr(0, length)));
        }
        tag.step++;
        if (tag.step == 2) {
            Libre_NetHttpAddRequest(fd,
                "GET",
                "https://raw.githubusercontent.com/librehome/librehome/master/SmartonLabs/LibreApps.lua",
                header);
        } else {
            Libre_ExitThread()
        }
    }, tag);

    Libre_NetHttpAddRequest(fd,
        "GET",
        "https://raw.githubusercontent.com/librehome/librehome/master/SmartonLabs/LibreDenonAVR.lua",
        header);
    Libre_WaitReactive();
}

function TestThread() {
    const threadFunc = function (a: number, b: number, c: number) {
        console.log("a=", a);
        Libre_Wait(1000);
        console.log("b=", b);
        Libre_Wait(1000);
        console.log("c=", c);
    }
    const tid = Libre_NewThread(threadFunc, 1, 2, 3);
    // Terminate a thread
    Libre_ExitThread(tid);
    // Terminate self thread
    Libre_ExitThread();
}

function Imperative(aDevice: LibertasDevice, anotherDevice: LibertasDevice) {
    const timeout = 1000;
    const fd = 0;
    // Imperative Programming
    // Subscribe Events
    Libre_SetWaitDevice(aDevice);
    Libre_SetWaitIo(fd, LibertasIOEventType.CAN_READ_WRITE);
    // Event loop
    while (true) {
        Libre_Wait(timeout);
        while (true) {
            const event = Libre_GetEvent();
            if (event) {
                // TODO: Process event
            } else {
                break;
            }
        }
    }
}

function reactive(aDevice: LibertasDevice) {
    const tag = {};
    const timeout = 1000;
    const fd = 0;
    // Reactive Programming
    // Create event callback handlers
    Libre_SetOnDevice(aDevice, (tag, event) => {
        // TODO: Handle device events
    }, tag);
    Libre_TimerNew(timeout, (tag) => {
        // TODO: Handle timer event
    });
    Libre_SetOnNetHttpResponse(fd, (tag, fd, data) => {
        // TODO: Handle HTTP(S) response
    }, tag);

    // Infinite loop to drive the event callbacks.
    // Will exit if Libre_ExitThread() is called.
    Libre_WaitReactive();
}

function deviceControl() {
    const device = 0;

    // Turn on a device
    Libre_DeviceCommand(device,
        LibertasClusterId.GEN_ON_OFF,
        LibertasCommand.ON);
    // Set dimmer level to 128 within 20X100ms = 2 seconds
    Libre_DeviceCommand(device,
        LibertasClusterId.GEN_LEVEL_CONTROL,
        LibertasCommand.LEVEL_MOVE_TO_LEVEL,
        [128, 20]);
    // Set thermostat to heat at 23.00 °C
    Libre_DeviceSetAttributes(device,
        LibertasClusterId.HVAC_THERMOSTAT,
        {
            [LibertasAttrId.HVAC_THERMOSTAT_SYSTEM_MODE]: LibertasThermostatMode.HEAT,
            [LibertasAttrId.HVAC_THERMOSTAT_OCCUPIED_HEATING_SETPOINT]: 2300,
        });
}

function TestMessage(
    @LibertasFieldSizeMin(1)
    @LibertasFieldUnordered
    @LibertasFieldUnique
    recipients: LibertasUser[]) {
    const now = os.date("%Y-%m-%d %H:%M:%S") as string;
    Libre_MessageText(
        LibertasMessageLevel.INFO,
        undefined,
        recipients,
        "TEST_MESSAGE",
        now);

    const temp: LibertasMessageVariableUnit = {
        type: "unit",
        unit: 'Cel',  // Temperature in Celsius
        value: 23
    }
    Libre_MessageText(
        LibertasMessageLevel.INFO,
        undefined,
        recipients,
        "TEMP_DISPLAY",
        temp);
}

function VirtualSwitch(
    @LibertasFieldVirtualDeviceType(
        new LibertasDeviceType(
            LibertasDeviceLoadType.LOAD,
            LibertasDeviceId.ON_OFF_SWITCH, [
            LibertasClusterId.GEN_ON_OFF,
        ]))
    device: LibertasVirtualDevice) {
    Libre_SetOnVirtualDevice(device, (tag, event) => {
        if (event.c === LibertasClusterId.GEN_ON_OFF) {
            if (event.t === LibertasEventType.COMMAND) {
                if (event.d === LibertasCommand.ON ||
                    event.d === LibertasCommand.OFF) {
                    Libre_VirtualDeviceOnOffSet(device,
                        (event.d === LibertasCommand.ON),
                        event.s!);  // Confirm the on/off command
                }
            }
        }
    });
    Libre_VirtualDeviceOnOffReport(device, false); // Set to "off" initially
}

function TestData() {
    interface TreeNode {
        value: string;
        children?: TreeNode[];
    }

    const schema: LibertasAvroSchema[] = [
        <LibertasAvroSchemaEnum>
        {
            "type": "enum",
            "name": "DayOfWeek",
            "symbols": ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        },
        <LibertasAvroSchemaRecord>
        {
            "type": "record",
            "name": "TreeNode",
            "fields": [
                { "name": "value", "type": "string" },
                { "name": "children", "type": ["null", { "type": "array", "items": "TreeNode" }] }
            ]
        },

    ];
    Libre_DataInitSchema(schema);

    const tree: TreeNode = {
        value: "Root",
        children: [
            { value: "1-1", children: undefined },
            {
                value: "1-2", children: [
                    { value: "2-1", children: undefined },
                    { value: "2-2", children: undefined },
                    { value: "2-3", children: undefined },
                ]
            },
            { value: "1-3", children: undefined },
        ]
    }
}

function TestData2() {
    interface TreeNode {
        value: string;
        children?: TreeNode[];
    }

    const schema: LibertasAvroSchema[] = [
        <LibertasAvroSchemaRecord>
        {
            "type": "record",
            "name": "TreeNode",
            "fields": [
                { "name": "value", "type": "string" },
                { "name": "children", "type": ["null", { "type": "array", "items": "TreeNode" }] }
            ]
        },
    ];
    Libre_DataInitSchema(schema);
    const dbTable = Libre_DataOpenTimeSeries("Data Table Name", true);
    const treeRecord: TreeNode = {
        value: "Root",
        children: [
            { value: "1-1" },
            {
                value: "1-2", children: [
                    { value: "1-2-1" },
                    { value: "1-2-2" },
                    { value: "1-2-3" },
                ]
            },
            { value: "1-3" },
        ]
    };
    const [index, timestamp] =
        Libre_DataWriteTimeSeries(dbTable, treeRecord, "TreeNode");
    const j = JSON.stringify(schema);
    const o = JSON.parse(j) as LibertasAvroSchema[];
    if (o == json.NULL) {

    }

    const xml = lom.encode(o);
    const xmlO = lom.parse(xml);
}

function TestHttpClient(url: string) {
    const header: LibertasHttpHeader[] = [
        ["Accept", "*/*"],
        ["User-Agent", "LibertasHub/1.0"],
    ]
    const fd = Libre_NetNewHttp();
    Libre_SetOnNetError(fd, (tag, fd, errCode, httpStatus, text) => {
        // TODO:
    }, undefined);
    Libre_SetOnNetHttpResponse(fd, (t, fd, res) => {
        // TODO: res.statusCode, res.body etc 
    }, undefined);
    Libre_NetHttpAddRequest(fd,
        "GET",
        url, // HTTP or HTTPS
        header);
    Libre_WaitReactive();
}

declare class NestA {
    a: number;
    b: NestB;
}

declare class NestB {
    b: number;
    a?: NestA;
}

export function TestCircularRef(sa: NestA) {
    console.log(sa);
}

export {
    HolidayLightShow,
    TestSimple,
    TestWeakSet,
    TestTimer,
    TestBuffer,
    TestRxHttpClient,
    TestThread,
    TestMessage,
}
