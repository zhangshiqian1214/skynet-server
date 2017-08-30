--[[
	游戏id, 游戏大类, 游戏名称, 是否开放, 展示序号, 游戏模块
	game_id, game_type, game_name, is_open, show_index, module_name
]]
local game_config = {
	[101] = {
			game_id = 101,
			game_type = 100,
			game_name = [[血拼牛牛]],
			is_open = 1,
			show_index = 2,
			module_name = "xpnn",
		},
	[102] = {
			game_id = 102,
			game_type = 100,
			game_name = [[龙虎斗]],
			is_open = 1,
			show_index = 3,
			module_name = "lhd",
		},
	[103] = {
			game_id = 103,
			game_type = 100,
			game_name = [[斗地主]],
			is_open = 1,
			show_index = 1,
			module_name = "ddz",
		},
}
return game_config