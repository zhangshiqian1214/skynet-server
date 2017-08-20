

PROTO_TYPE = {
	C2S = 1,
	S2C = 2,
}

--协议文件名
PROTO_FILES = {
	package = 1,
	gate    = 2,
	auth    = 3,
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


M_Gate = {
	module = MODULE.GATE,
	ping             = {id = 0x0001, type = PROTO_TYPE.C2S,  request = "integer", response = "integer", desc = "心跳"},

	network_event    = {id = 0x00a1, type = PROTO_TYPE.S2C, request = nil, response = "gate.NetworkEvent", desc = "网络事件"},
}
proto_map.Gate = M_Gate

M_AUTH = {
	module  = MODULE.AUTH,
	register_account = {id = 0x0101, type = PROTO_TYPE.C2S, request = "auth.RegisterReq", response = "auth.RegisterReply", desc = "注册帐号"},
	login_account    = {id = 0x0102, type = PROTO_TYPE.C2S, request = "auth.LoginReq", response = "auth.LoginReply", desc = "登陆帐号"},
	weixin_login     = {id = 0x0103, type = PROTO_TYPE.C2S, request = "auth.WeixinReq", response = "auth.WeiXinReply", desc = "微信登陆"},
	visitor_login    = {id = 0x0104, type = PROTO_TYPE.C2S, request = "auth.VisitorReq", response = "auth.VisitorReply", desc = "游客登陆"},
}
proto_map.auth = M_AUTH

return proto_map