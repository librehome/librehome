--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
function ____exports.reactive()
    local aDevice = 0
    local tag = {}
    local timeout = 1000
    local fd = 0
    Libertas_SetOnDevice(
        aDevice,
        function(tag, event)
        end,
        tag
    )
    Libertas_TimerNew(
        timeout,
        function(tag)
        end
    )
    Libertas_SetOnNetHttpResponse(
        fd,
        function(tag, fd, data)
        end,
        tag
    )
    Libertas_WaitReactive()
end
return ____exports
