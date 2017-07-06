

PROTO = {
	C2S = 1,
	S2C = 2,
}

--协议文件名
PROTO_FILES = {
	[1] = "package",
	[2] = "gate",
}

local proto_map = {
	protos = {},
}

local mt = {}
mt.__newindex = function(t, k, v)
	for key, proto in pairs(v) do
		if key ~= "module" then
			assert(proto_map[proto.id] == nil, "has same proto["..proto.id.."]")
			local tmp = {}
			tmp.name = key
			tmp.module = v.module.name
			tmp.server = v.module.server
			tmp.service = v.module.service
			tmp.id = proto.id
			tmp.type = proto.type
			tmp.request = proto.request
			tmp.response= proto.response
			tmp.desc = proto.desc
			tmp.fullname = v.module.name.."."..key
			t.protos[proto.id] = tmp
		end
	end
end
setmetatable(proto_map, mt)


M_WATCHDOG = {
	module = MODULE.GATE,
	ping = {id = 0x0001, type = PROTO.C2S,  request = "integer", response = "integer", desc = "心跳"},
}
proto_map.Watchdog = M_WATCHDOG

M_AUTH = {
	module  = MODULE.AUTH,
	create_account = {id = 0x0101, type = PROTO.C2S, request = "string", response = "string", desc = "注册帐号"},
	login_account  = {id = 0x0102, type = PROTO.C2S, request = "string", response = "string", desc = "登陆帐号"},
	third_login    = {id = 0x0103, type = PROTO.C2S, request = "string", response = "string", desc = "第三方登陆"},
	visitor_login  = {id = 0x0104, type = PROTO.C2S, request = "string", response = "string", desc = "游客登陆"},
}
proto_map.auth = M_AUTH

return proto_map