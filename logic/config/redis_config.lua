--[[
	redis连接id, redis地址, redis端口, redis库名, redis验证, 注释
	redis_id, redis_host, redis_port, redis_db, redis_auth, desc
]]
local redis_config = {
	[1] = {
			redis_id = 1,
			redis_host = "127.0.0.1",
			redis_port = 6379,
			redis_db = 0,
			redis_auth = nil,
			desc = [[全局数据缓存]],
		},
	[2] = {
			redis_id = 2,
			redis_host = "127.0.0.1",
			redis_port = 6379,
			redis_db = 1,
			redis_auth = nil,
			desc = [[lobby数据缓存]],
		},
	[3] = {
			redis_id = 3,
			redis_host = "127.0.0.1",
			redis_port = 6379,
			redis_db = 2,
			redis_auth = nil,
			desc = [[game数据缓存]],
		},
	[4] = {
			redis_id = 4,
			redis_host = "127.0.0.1",
			redis_port = 6379,
			redis_db = 3,
			redis_auth = nil,
			desc = [[玩家数据缓存]],
		},
	[5] = {
			redis_id = 5,
			redis_host = "127.0.0.1",
			redis_port = 6379,
			redis_db = 4,
			redis_auth = nil,
			desc = [[gamelog数据缓存]],
		},
}
return redis_config