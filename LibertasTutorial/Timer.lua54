--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
function ____exports.TestTimer()
    local t
    t = Libertas_TimerNew(
        1000,
        function(tag, timer)
            print("TestTimer called.")
            Libertas_TimerUpdate(t, 1000)
        end,
        nil
    )
    Libertas_WaitReactive()
end
return ____exports
