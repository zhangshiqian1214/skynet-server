local json = require "json"

--要登录后才能用
local pingReq = {
	header = {
		protoid = 0x0001,
		session = 1,
		response = 0,
	},
	data = 1234,
}
print("pingReq="..json.encode(pingReq))


local registerReq = {
	header = {
		protoid = 0x0101,
		session = 1,
	},
	data = "helloworld",
}
print("registerReq="..json.encode(registerReq))