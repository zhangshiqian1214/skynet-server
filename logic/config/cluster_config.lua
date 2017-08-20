--[[
	服务器id, 节点名, 节点端口, 内网地址, 外网地址, 是否使用内网, 服务器类型, 服务器版本号
	serverid, nodename, nodeport, intranetip, extranetip, use_intranet, servertype, ver
]]
local cluster_config = {
	[1] = {
			serverid = 1,
			nodename = "gate1",
			nodeport = 9001,
			intranetip = "127.0.0.1",
			extranetip = "127.0.0.1",
			use_intranet = 1,
			servertype = 1,
			ver = 0,
		},
	[2] = {
			serverid = 2,
			nodename = "gate2",
			nodeport = 9002,
			intranetip = "127.0.0.1",
			extranetip = "127.0.0.1",
			use_intranet = 1,
			servertype = 1,
			ver = 0,
		},
	[3] = {
			serverid = 3,
			nodename = "db1",
			nodeport = 9003,
			intranetip = "127.0.0.1",
			extranetip = "127.0.0.1",
			use_intranet = 1,
			servertype = 2,
			ver = 0,
		},
	[4] = {
			serverid = 4,
			nodename = "login",
			nodeport = 9004,
			intranetip = "127.0.0.1",
			extranetip = "127.0.0.1",
			use_intranet = 1,
			servertype = 3,
			ver = 0,
		},
	[5] = {
			serverid = 5,
			nodename = "hall",
			nodeport = 9005,
			intranetip = "127.0.0.1",
			extranetip = "127.0.0.1",
			use_intranet = 1,
			servertype = 4,
			ver = 0,
		},
	[6] = {
			serverid = 6,
			nodename = "xpnn",
			nodeport = 9006,
			intranetip = "127.0.0.1",
			extranetip = "127.0.0.1",
			use_intranet = 1,
			servertype = 5,
			ver = 0,
		},
}
return cluster_config