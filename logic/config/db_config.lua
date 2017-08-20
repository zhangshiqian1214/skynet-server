--[[
	连接名, mysql连接id, redis连接id, 访问svc方式, service服务名, 连接个数, 注释
	svc_name, mysql_id, redis_id, get_svc, service_name, svc_count, desc
]]
local db_config = {
	["unique_db"] = {
			svc_name = [[unique_db]],
			mysql_id = 1,
			redis_id = 1,
			get_svc = 1,
			service_name = ".unique_db",
			svc_count = 1,
			desc = [[该db用于惟一id, 玩家在线状态]],
		},
	["account_db"] = {
			svc_name = [[account_db]],
			mysql_id = 1,
			redis_id = 0,
			get_svc = 2,
			service_name = ".account_db",
			svc_count = 4,
			desc = [[该db用于登陆(查询tb_account, tb_player)]],
		},
	["hall_db"] = {
			svc_name = [[hall_db]],
			mysql_id = 1,
			redis_id = 2,
			get_svc = 1,
			service_name = ".hall_db",
			svc_count = 1,
			desc = [[该db用于缓存玩家在线状态，玩家登录状态]],
		},
	["game_db"] = {
			svc_name = [[game_db]],
			mysql_id = 1,
			redis_id = 3,
			get_svc = 1,
			service_name = ".game_db",
			svc_count = 1,
			desc = [[该db用于游戏房间注册等]],
		},
	["agent_db"] = {
			svc_name = [[agent_db]],
			mysql_id = 1,
			redis_id = 4,
			get_svc = 3,
			service_name = ".agent_db",
			svc_count = 4,
			desc = [[该db用于缓存玩家数据(每个玩家id对应一个db)]],
		},
}
return db_config