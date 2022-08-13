--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
function ____exports.TestHttpClient(url)
    local header = {{"Accept", "*/*"}, {"User-Agent", "LibertasHub/1.0"}}
    local fd = Libertas_NetNewHttp()
    Libertas_SetOnNetError(
        fd,
        function(tag, fd, errCode, httpStatus, text)
        end,
        nil
    )
    Libertas_SetOnNetHttpResponse(
        fd,
        function(t, fd, res)
        end,
        nil
    )
    Libertas_NetHttpAddRequest(fd, "GET", url, header)
    Libertas_WaitReactive()
end
return ____exports
