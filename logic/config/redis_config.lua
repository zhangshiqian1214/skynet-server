--[[
	redis连接id, redis地址, redis端口, redis库名, redis验证, 注释
	id, host, port, db, auth, desc
]]
local redis_config = {
	[1] = {
			id = 1,
			host = "127.0.0.1",
			port = 6379,
			db = 0,
			auth = nil,
			desc = [[全局数据缓存]],
		},
	[2] = {
			id = 2,
			host = "127.0.0.1",
			port = 6379,
			db = 1,
			auth = nil,
			desc = [[lobby数据缓存]],
		},
	[3] = {
			id = 3,
			host = "127.0.0.1",
			port = 6379,
			db = 2,
			auth = nil,
			desc = [[game数据缓存]],
		},
	[4] = {
			id = 4,
			host = "127.0.0.1",
			port = 6379,
			db = 3,
			auth = nil,
			desc = [[玩家数据缓存]],
		},
	[5] = {
			id = 5,
			host = "127.0.0.1",
			port = 6379,
			db = 4,
			auth = nil,
			desc = [[gamelog数据缓存]],
		},
}
return redis_config