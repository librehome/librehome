--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
function ____exports.TestMessage(recipients)
    local now = os.date("%Y-%m-%d %H:%M:%S")
    Libertas_MessageText(
        LibertasMessageLevel.INFO,
        nil,
        recipients,
        "TEST_MESSAGE",
        now
    )
    local temp = {type = "unit", unit = "Cel", value = 23}
    Libertas_MessageText(
        LibertasMessageLevel.INFO,
        nil,
        recipients,
        "TEMP_DISPLAY",
        temp
    )
end
return ____exports
