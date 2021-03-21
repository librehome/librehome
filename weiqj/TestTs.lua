declare class LightAndLevel {
    @LibertasFieldUnique()
    @LibertasFieldTableHeader()
    @LibertasFieldDeviceTypes(
        [
            new LibertasDeviceType(LibertasDeviceLoadType.LOAD, 
                LibertasDeviceId.ANY, [
                    LibertasClusterId.GEN_LEVEL_CONTROL,
                ]
            ),
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
    const objweakSet = new WeakSet([{text:"hi"}]);
    const obj1 = {text:"hello"};
    const obj2 = {text:"bye"};
    objweakSet.add(obj1); 
    console.log(objweakSet.has(obj1)); 
    console.log(objweakSet.has(obj2)); 
    objweakSet.add(obj2); 
    console.log(objweakSet.has(obj2));     
}

function getANumber() : number {
    return 100;
}

function TestTimer() {
    const t = Libre_TimerNew(1000, (tag, timer)=>{
        console.log("TestTimer called.");
        Libre_TimerUpdate(t, 1000);
    }, undefined);
    Libre_WaitReactive();
}

function testBuffer() {
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
}

function TextRxHttpClient() {
	const tag = {
		step: 1,
	}
	
    // HTTP client headers
	const header: LibertasHttpHeader[] = [
        ["Accept", "*/*"],
		["User-Agent", "librehub/0.1"],
    ]

    const fd = Libre_NetNewHttp();
    Libre_SetOnNetError(fd, (tag, fd, errCode, httpStatus, text)=>{
        console.log(string.format(
				'Error %s', text));
		Libre_ExitThread()
    }, tag);
	Libre_SetOnNetHttpResponse(fd, (t, fd, res)=>{
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

function TsTestThread() {
    const t = function(a: number, b: number, c: number) {
        console.log("a=", a);
        Libre_Wait(5000);
        console.log("b=", b);
        Libre_Wait(5000);
        console.log("c=", c);
        Libre_Wait(5000);
    }
    Libre_NewThread(t, 1, 2, 3);
}

export {
    HolidayLightShow, 
    TestSimple, 
    TestWeakSet, 
    TestTimer, 
    testBuffer, 
    TextRxHttpClient,
    TsTestThread,
}