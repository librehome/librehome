--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local DayOfWeek = DayOfWeek or ({})
DayOfWeek.Sun = 0
DayOfWeek[DayOfWeek.Sun] = "Sun"
DayOfWeek.Mon = 1
DayOfWeek[DayOfWeek.Mon] = "Mon"
DayOfWeek.Tue = 2
DayOfWeek[DayOfWeek.Tue] = "Tue"
DayOfWeek.Wed = 3
DayOfWeek[DayOfWeek.Wed] = "Wed"
DayOfWeek.Thu = 4
DayOfWeek[DayOfWeek.Thu] = "Thu"
DayOfWeek.Fri = 5
DayOfWeek[DayOfWeek.Fri] = "Fri"
DayOfWeek.Sat = 6
DayOfWeek[DayOfWeek.Sat] = "Sat"
function ____exports.SprinklerSchedule(scheduleTable)
    local n = bit.bor(
        bit.bor(LibertasAccess.Read, LibertasAccess.Write),
        LibertasAccess.Config
    )
end
return ____exports
