--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local function HolidayLightShow(groups)
    while true do
        for ____, group in ipairs(groups) do
            for ____, lightState in ipairs(group.lightStates) do
                Libre_DeviceLevelSet(lightState.light, lightState.onLevel)
            end
            Libre_Wait(group.wait * 1000)
        end
    end
end
local function TestSimple()
    print("hello world")
end
local function TestWeakSet()
    local objweakSet = __TS__New(WeakSet, {{text = "hi"}})
    local obj1 = {text = "hello"}
    local obj2 = {text = "bye"}
    objweakSet:add(obj1)
    print(objweakSet:has(obj1))
    print(objweakSet:has(obj2))
    objweakSet:add(obj2)
    print(objweakSet:has(obj2))
end
local function getANumber()
    return 100
end
local function TestTimer()
    local t
    t = Libre_TimerNew(
        1000,
        function(tag, timer)
            print("TestTimer called.")
            Libre_TimerUpdate(t, 1000)
        end,
        nil
    )
    Libre_WaitReactive()
end
local function TestBuffer()
    local b = lbuffer(100)
    print(
        "b:len()",
        b:len()
    )
    b[1] = 1
    print("b[0]=", b[1])
    b[1] = 2
    print("b[0]=", b[1])
    b[1] = 255
    print("b[0]=", b[1])
    b:set(2, "ABC")
    print(
        "b=",
        b[1],
        b[2],
        b[3],
        b[4]
    )
    b:set(101, "ABC")
    print(
        "b:len()",
        b:len()
    )
    print(
        "b=",
        b[101],
        b[102],
        b[1023],
        b[104]
    )
    local c = lbuffer("ABCDEFGHIJKLMN")
    print(c:tostring(1, 2))
    print(c:tostring(2, 2))
    print(c:tostring(3, 2))
    c:set(3, "0123456789", 2, 5)
    print(c:tostring())
    c = lbuffer("ABCDEFGHIJKLMN")
    c:clear(2, 5)
    print(c:tostring())
    c = lbuffer("ABCDEFGHIJKLMN")
    c:remove(2, 5)
    print(c:tostring())
end
local function TestRxHttpClient()
    local tag = {step = 1}
    local header = {{"Accept", "*/*"}, {"User-Agent", "librehub/0.1"}}
    local fd = Libre_NetNewHttp()
    Libre_SetOnNetError(
        fd,
        function(tag, fd, errCode, httpStatus, text)
            print(string.format("Error %s", text))
            Libre_ExitThread()
        end,
        tag
    )
    Libre_SetOnNetHttpResponse(
        fd,
        function(t, fd, res)
            print(string.format("statusCode %d", res.statusCode))
            if res.body then
                local length = #res.body
                if length > 100 then
                    length = 100
                end
                print(string.format(
                    "Respbody %s",
                    __TS__StringSubstr(res.body, 0, length)
                ))
            end
            tag.step = tag.step + 1
            if tag.step == 2 then
                Libre_NetHttpAddRequest(fd, "GET", "https://raw.githubusercontent.com/librehome/librehome/master/SmartonLabs/LibreApps.lua", header)
            else
                Libre_ExitThread()
            end
        end,
        tag
    )
    Libre_NetHttpAddRequest(fd, "GET", "https://raw.githubusercontent.com/librehome/librehome/master/SmartonLabs/LibreDenonAVR.lua", header)
    Libre_WaitReactive()
end
local function TestThread()
    local function threadFunc(a, b, c)
        print("a=", a)
        Libre_Wait(1000)
        print("b=", b)
        Libre_Wait(1000)
        print("c=", c)
    end
    local tid = Libre_NewThread(threadFunc, 1, 2, 3)
    Libre_ExitThread(tid)
    Libre_ExitThread()
end
local function Imperative(aDevice, anotherDevice)
    local timeout = 1000
    local fd = 0
    Libre_SetWaitDevice(aDevice)
    Libre_SetWaitIo(fd, LibertasIOEventType.CAN_READ_WRITE)
    while true do
        Libre_Wait(timeout)
        while true do
            local event = Libre_GetEvent()
            if event then
            else
                break
            end
        end
    end
end
local function reactive(aDevice)
    local tag = {}
    local timeout = 1000
    local fd = 0
    Libre_SetOnDevice(
        aDevice,
        function(tag, event)
        end,
        tag
    )
    Libre_TimerNew(
        timeout,
        function(tag)
        end
    )
    Libre_SetOnNetHttpResponse(
        fd,
        function(tag, fd, data)
        end,
        tag
    )
    Libre_WaitReactive()
end
local function deviceControl()
    local device = 0
    Libre_DeviceCommand(device, LibertasClusterId.GEN_ON_OFF, LibertasCommand.ON)
    Libre_DeviceCommand(device, LibertasClusterId.GEN_LEVEL_CONTROL, LibertasCommand.LEVEL_MOVE_TO_LEVEL, {128, 20})
    Libre_DeviceSetAttributes(device, LibertasClusterId.HVAC_THERMOSTAT, {[LibertasAttrId.HVAC_THERMOSTAT_SYSTEM_MODE] = LibertasThermostatMode.HEAT, [LibertasAttrId.HVAC_THERMOSTAT_OCCUPIED_HEATING_SETPOINT] = 2300})
end
local function TestMessage(recipients)
    local now = os.date("%Y-%m-%d %H:%M:%S")
    Libre_MessageText(
        LibertasMessageLevel.INFO,
        nil,
        recipients,
        "TEST_MESSAGE",
        now
    )
    local temp = {type = "unit", unit = "Cel", value = 23}
    Libre_MessageText(
        LibertasMessageLevel.INFO,
        nil,
        recipients,
        "TEMP_DISPLAY",
        temp
    )
end
local function VirtualSwitch(device)
    Libre_SetOnVirtualDevice(
        device,
        function(tag, event)
            if event.c == LibertasClusterId.GEN_ON_OFF then
                if event.t == LibertasEventType.COMMAND then
                    if event.d == LibertasCommand.ON or event.d == LibertasCommand.OFF then
                        Libre_VirtualDeviceOnOffSet(device, event.d == LibertasCommand.ON, event.s)
                    end
                end
            end
        end
    )
    Libre_VirtualDeviceOnOffReport(device, false)
end
local function TestData()
    local schema = {{type = "enum", name = "DayOfWeek", symbols = {
        "Sun",
        "Mon",
        "Tue",
        "Wed",
        "Thu",
        "Fri",
        "Sat"
    }}, {type = "record", name = "TreeNode", fields = {{name = "value", type = "string"}, {name = "children", type = {"null", {type = "array", items = "TreeNode"}}}}}}
    Libre_DataInitSchema(schema)
    local tree = {value = "Root", children = {{value = "1-1", children = nil}, {value = "1-2", children = {{value = "2-1", children = nil}, {value = "2-2", children = nil}, {value = "2-3", children = nil}}}, {value = "1-3", children = nil}}}
end
local function TestData2()
    local schema = {{type = "record", name = "TreeNode", fields = {{name = "value", type = "string"}, {name = "children", type = {"null", {type = "array", items = "TreeNode"}}}}}}
    Libre_DataInitSchema(schema)
    local dbTable = Libre_DataOpenTimeSeries("Data Table Name", true)
    local treeRecord = {value = "Root", children = {{value = "1-1"}, {value = "1-2", children = {{value = "1-2-1"}, {value = "1-2-2"}, {value = "1-2-3"}}}, {value = "1-3"}}}
    local index, timestamp = Libre_DataWriteTimeSeries(dbTable, treeRecord, "TreeNode")
    local j = json.encode(schema)
    local o = json.decode(j)
    if o == json.null then
    end
    local xml = lom.encode(o)
    local xmlO = lom.parse(xml)
end
local function TestHttpClient(url)
    local header = {{"Accept", "*/*"}, {"User-Agent", "LibertasHub/1.0"}}
    local fd = Libre_NetNewHttp()
    Libre_SetOnNetError(
        fd,
        function(tag, fd, errCode, httpStatus, text)
        end,
        nil
    )
    Libre_SetOnNetHttpResponse(
        fd,
        function(t, fd, res)
        end,
        nil
    )
    Libre_NetHttpAddRequest(fd, "GET", url, header)
    Libre_WaitReactive()
end
function ____exports.TestCircularRef(sa)
    print(sa)
end
____exports.HolidayLightShow = HolidayLightShow
____exports.TestSimple = TestSimple
____exports.TestWeakSet = TestWeakSet
____exports.TestTimer = TestTimer
____exports.TestBuffer = TestBuffer
____exports.TestRxHttpClient = TestRxHttpClient
____exports.TestThread = TestThread
____exports.TestMessage = TestMessage
return ____exports
