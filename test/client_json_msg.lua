local json = require "json"

--要登录后才能用
local pingReq = {
	header = {
		protoid = 0x0001,
		session = 1,
		response = nil,
	},
	data = 1234,
}
print("pingReq="..json.encode(pingReq))


local registerReq = {
	header = {
		protoid = 0x0101,
		session = 1,
		response = nil,
	},
	data = {
		account = "游客1001",
		password = "123456",
		telephone = "1383838438",
		create_index = 1,
		nickname = "helloworld",
	},
}
print("registerReq="..json.encode(registerReq))

local visitorReq = {
	header = {
		protoid = 0x0104,
		session = 1,
		response = nil,
	},
	data = {
		visit_token = "a3984026-c67b-4889-c827-db693fba8f64",
	},
}
print("visitorReq="..json.encode(visitorReq))

