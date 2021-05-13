{"Functions":[{"NativeName":"DenonAVR", "Reserved":false, "Parameters":[{"ID":0, "NativeName":"avr", "Type":"LanDevice", "BuiltinType":true},{"ID":1, "NativeName":"mainZone", "Type":"AVRMainZone", "BuiltinType":false},{"ID":2, "NativeName":"extraZones", "Type":"List", "BuiltinType":true, "Children":[{"ID":3, "NativeName":"", "Type":"AVRExtraZone", "BuiltinType":false}], "Attributes":[{"Name":"SizeMax", "Value":"2"}]}]}], "Types":[{"ID":0, "NativeName":"AVRMainZone", "Type":"Table", "BuiltinType":true, "Children":[{"ID":1, "NativeName":"onOff", "Type":"VirtualDevice", "BuiltinType":true, "Attributes":[{"Name":"VirtualDevice", "Value":"1,0,6"}]},{"ID":2, "NativeName":"input", "Type":"VirtualDevice", "BuiltinType":true, "Attributes":[{"Name":"Nullable", "Value":""},{"Name":"VirtualDevice", "Value":"1,f002,12"},{"Name":"Enum", "Value":"ENUM_SI"}]},{"ID":3, "NativeName":"eco", "Type":"VirtualDevice", "BuiltinType":true, "Attributes":[{"Name":"Nullable", "Value":""},{"Name":"VirtualDevice", "Value":"1,f002,12"},{"Name":"Enum", "Value":"ENUM_ON_AUTO_OFF"}]},{"ID":4, "NativeName":"volume", "Type":"VirtualDevice", "BuiltinType":true, "Attributes":[{"Name":"Nullable", "Value":""},{"Name":"VirtualDevice", "Value":"1,3,8|fc02"}]},{"ID":5, "NativeName":"mute", "Type":"VirtualDevice", "BuiltinType":true, "Attributes":[{"Name":"Nullable", "Value":""},{"Name":"VirtualDevice", "Value":"1,0,6"}]}]},{"ID":0, "NativeName":"AVRExtraZone", "Type":"Table", "BuiltinType":true, "Children":[{"ID":1, "NativeName":"onOff", "Type":"VirtualDevice", "BuiltinType":true, "Attributes":[{"Name":"VirtualDevice", "Value":"1,0,6"}]},{"ID":2, "NativeName":"input", "Type":"VirtualDevice", "BuiltinType":true, "Attributes":[{"Name":"Nullable", "Value":""},{"Name":"VirtualDevice", "Value":"1,f002,12"},{"Name":"Enum", "Value":"ENUM_SI"}]},{"ID":3, "NativeName":"volume", "Type":"VirtualDevice", "BuiltinType":true, "Attributes":[{"Name":"Nullable", "Value":""},{"Name":"VirtualDevice", "Value":"1,3,8|fc02"}]},{"ID":4, "NativeName":"mute", "Type":"VirtualDevice", "BuiltinType":true, "Attributes":[{"Name":"Nullable", "Value":""},{"Name":"VirtualDevice", "Value":"1,0,6"}]}]},{"ID":0, "NativeName":"ENUM_SI", "Type":"Enumeration", "BuiltinType":true, "Children":[{"ID":-1, "NativeName":"UNKNOWN", "Type":"Number", "BuiltinType":true},{"ID":-1, "NativeName":"PHONO", "Type":"Number", "BuiltinType":true},{"ID":-1, "NativeName":"CD", "Type":"Number", "BuiltinType":true},{"ID":-1, "NativeName":"TUNER", "Type":"Number", "BuiltinType":true},{"ID":-1, "NativeName":"DVD", "Type":"Number", "BuiltinType":true},{"ID":-1, "NativeName":"BD", "Type":"Number", "BuiltinType":true},{"ID":-1, "NativeName":"TV", "Type":"Number", "BuiltinType":true},{"ID":-1, "NativeName":"SAT/CBL", "Type":"Number", "BuiltinType":true},{"ID":-1, "NativeName":"MPLAY", "Type":"Number", "BuiltinType":true},{"ID":-1, "NativeName":"GAME", "Type":"Number", "BuiltinType":true},{"ID":-1, "NativeName":"HDRADIO", "Type":"Number", "BuiltinType":true},{"ID":-1, "NativeName":"NET", "Type":"Number", "BuiltinType":true},{"ID":-1, "NativeName":"PANDORA", "Type":"Number", "BuiltinType":true},{"ID":-1, "NativeName":"SIRIUSXM", "Type":"Number", "BuiltinType":true},{"ID":-1, "NativeName":"IRADIO", "Type":"Number", "BuiltinType":true},{"ID":-1, "NativeName":"SERVER", "Type":"Number", "BuiltinType":true},{"ID":-1, "NativeName":"FAVORITES", "Type":"Number", "BuiltinType":true},{"ID":-1, "NativeName":"AUX1", "Type":"Number", "BuiltinType":true},{"ID":-1, "NativeName":"AUX2", "Type":"Number", "BuiltinType":true},{"ID":-1, "NativeName":"AUX3", "Type":"Number", "BuiltinType":true},{"ID":-1, "NativeName":"AUX4", "Type":"Number", "BuiltinType":true},{"ID":-1, "NativeName":"AUX5", "Type":"Number", "BuiltinType":true},{"ID":-1, "NativeName":"AUX6", "Type":"Number", "BuiltinType":true},{"ID":-1, "NativeName":"AUX7", "Type":"Number", "BuiltinType":true},{"ID":-1, "NativeName":"BT", "Type":"Number", "BuiltinType":true},{"ID":-1, "NativeName":"USB/IPOD", "Type":"Number", "BuiltinType":true},{"ID":-1, "NativeName":"USB", "Type":"Number", "BuiltinType":true},{"ID":-1, "NativeName":"IPD", "Type":"Number", "BuiltinType":true},{"ID":-1, "NativeName":"IRP", "Type":"Number", "BuiltinType":true},{"ID":-1, "NativeName":"FVP", "Type":"Number", "BuiltinType":true}]},{"ID":0, "NativeName":"ENUM_ON_AUTO_OFF", "Type":"Enumeration", "BuiltinType":true, "Children":[{"ID":-1, "NativeName":"ON", "Type":"Number", "BuiltinType":true},{"ID":-1, "NativeName":"AUTO", "Type":"Number", "BuiltinType":true},{"ID":-1, "NativeName":"OFF", "Type":"Number", "BuiltinType":true}]}]}