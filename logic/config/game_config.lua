--[[
	游戏id, 游戏大类, 游戏名称, 是否开放, 展示序号
	game_id, game_type, game_name, is_open, show_index
]]
local game_config = {
	[101] = {
			game_id = 101,
			game_type = 100,
			game_name = [[血拼牛牛]],
			is_open = 1,
			show_index = 2,
		},
	[102] = {
			game_id = 102,
			game_type = 100,
			game_name = [[二人牛牛]],
			is_open = 1,
			show_index = 4,
		},
	[103] = {
			game_id = 103,
			game_type = 100,
			game_name = [[斗地主]],
			is_open = 1,
			show_index = 1,
		},
	[104] = {
			game_id = 104,
			game_type = 100,
			game_name = [[炸金花]],
			is_open = 1,
			show_index = 3,
		},
	[105] = {
			game_id = 105,
			game_type = 100,
			game_name = [[二人梭哈]],
			is_open = 1,
			show_index = 5,
		},
}
return game_config