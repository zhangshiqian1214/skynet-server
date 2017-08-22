local binary = string.char( 39, 22, 18, 17, 23, 0, 18, 0, 57 )
local str = "aaa"

local result = binary .. str
print(result)

local req = "10101"
print("req=", req, "sz=", #req)

local boolean_bin = string.pack(">B", 3)
print(string.unpack(">B", boolean_bin))