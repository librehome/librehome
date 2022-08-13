--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
function ____exports.TestThread()
    local function threadFunc(a, b, c)
        print("a=", a)
        Libertas_Wait(1000)
        print("b=", b)
        if b == 9999 then
            Libertas_ExitThread()
        end
        Libertas_Wait(1000)
        print("c=", c)
    end
    local tid = Libertas_NewThread(threadFunc, 1, 2, 3)
    Libertas_Wait(1500)
    Libertas_ExitThread(tid)
    Libertas_NewThread(threadFunc, 1, 9999, 3)
end
return ____exports
