{"Functions":[{"NativeName":"TestCircularRef", "Reserved":false, "Parameters":[{"ID":0, "NativeName":"sa", "Type":"NestA", "BuiltinType":false}]}], "Types":[{"ID":0, "NativeName":"NestA", "Type":"Table", "BuiltinType":true, "Children":[{"ID":1, "NativeName":"a", "Type":"Number", "BuiltinType":true},{"ID":2, "NativeName":"b", "Type":"NestB", "BuiltinType":false}]},{"ID":0, "NativeName":"NestB", "Type":"Table", "BuiltinType":true, "Children":[{"ID":1, "NativeName":"b", "Type":"Number", "BuiltinType":true},{"ID":2, "NativeName":"a", "Type":"NestA", "BuiltinType":false, "Attributes":[{"Name":"Nullable", "Value":""}]}]}]}