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

local visitorReq = {
	header = {
		protoid = 0x0104,
		session = 1,
		response = nil,
	},
	data = {
		visit_token = "b4a7d645-f3c9-472e-c76c-14c09b8596c8",
	},
}
print("visitorReq="..json.encode(visitorReq))


local roomListReq = {
	header = {
		protoid = 0x0201,
		session = 2,
		response = nil,
	},
	data = 10101,
}
print("roomListReq="..json.encode(roomListReq))

local enterRoomReq = {
	header = {
		protoid = 0x0d01,
		session = 2,
		response = nil,
		roomproxy = "xpnn",
	},
}
print("enterRoomReq="..json.encode(enterRoomReq))

exitRoomReq = {
	header = {
		protoid = 0x0d02,
		session = 2,
		response = nil,
		roomproxy = "xpnn",
	},
}
print("exitRoomReq="..json.encode(exitRoomReq))

groupRequest = {
	header = {
		protoid = 0x0d03,
		session = 2,
		response = nil,
		roomproxy = "xpnn",
	},
}
print("groupRequest="..json.encode(groupRequest))