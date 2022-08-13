--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
function ____exports.TestBuffer()
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
return ____exports
