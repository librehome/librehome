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
    print(
        objweakSet:has(obj1)
    )
    print(
        objweakSet:has(obj2)
    )
    objweakSet:add(obj2)
    print(
        objweakSet:has(obj2)
    )
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
local function testBuffer()
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
    print("b=", b[1], b[2], b[3], b[4])
    b:set(101, "ABC")
    print(
        "b:len()",
        b:len()
    )
    print("b=", b[101], b[102], b[1023], b[104])
end
local function TextRxHttpClient()
    local tag = {step = 1}
    local header = {{"Accept", "*/*"}, {"User-Agent", "librehub/0.1"}}
    local fd = Libre_NetNewHttp()
    Libre_SetOnNetError(
        fd,
        function(tag, fd, errCode, httpStatus, text)
            print(
                string.format("Error %s", text)
            )
            Libre_ExitThread()
        end,
        tag
    )
    Libre_SetOnNetHttpResponse(
        fd,
        function(t, fd, res)
            print(
                string.format("statusCode %d", res.statusCode)
            )
            if res.body then
                local length = #res.body
                if length > 100 then
                    length = 100
                end
                print(
                    string.format(
                        "Respbody %s",
                        __TS__StringSubstr(res.body, 0, length)
                    )
                )
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
local function TsTestThread()
    local function t(a, b, c)
        print("a=", a)
        Libre_Wait(5000)
        print("b=", b)
        Libre_Wait(5000)
        print("c=", c)
        Libre_Wait(5000)
    end
    Libre_NewThread(t, 1, 2, 3)
end
____exports.HolidayLightShow = HolidayLightShow
____exports.TestSimple = TestSimple
____exports.TestWeakSet = TestWeakSet
____exports.TestTimer = TestTimer
____exports.testBuffer = testBuffer
____exports.TextRxHttpClient = TextRxHttpClient
____exports.TsTestThread = TsTestThread
return ____exports
