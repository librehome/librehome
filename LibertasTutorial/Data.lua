--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local DataQA_Schema = {{type = "enum", name = "DayOfWeek", symbols = {
    "Sun",
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat"
}}, {type = "record", name = "TreeNode", fields = {{name = "value", type = "string"}, {name = "children", type = {"null", {type = "array", items = "TreeNode"}}}}}, {type = "record", name = "Tree", fields = {
    {name = "timestamp", type = "double"},
    {name = "index", type = "long"},
    {name = "dow", type = "DayOfWeek"},
    {name = "value", type = "string"},
    {name = "children", type = {"null", {type = "array", items = "TreeNode"}}}
}}}
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
function ____exports.DataQA(verify)
    Libertas_DataInitSchema(DataQA_Schema)
    local db = Libertas_DataOpenTimeSeries("main", true)
    local size, start = Libertas_DataStatTimeSeries(db)
    if verify then
        local verified = true
        do
            local i = start
            while i < size do
                local record = Libertas_DataReadTimeSeries(db, i, i)[1]
                local value = record.v
                if record.i ~= value.index then
                    verified = false
                    break
                end
                i = i + 1
            end
        end
        print(
            "Verification result",
            tostring(verified)
        )
    else
        do
            local i = 0
            while i < 100 do
                local index = i + size
                local treeVal = {
                    timestamp = os.utcnow(),
                    index = index,
                    dow = DayOfWeek[index % 7],
                    value = "Root",
                    children = {{value = "1-1", children = nil}, {value = "1-2", children = {{value = "2-1", children = nil}, {value = "2-2", children = nil}, {value = "2-3", children = nil}}}, {value = "1-3", children = nil}}
                }
                Libertas_DataWriteTimeSeries(db, treeVal, 2)
                i = i + 1
            end
        end
    end
end
return ____exports
