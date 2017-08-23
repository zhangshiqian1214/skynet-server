--[[
	房间id, 游戏台坐位数, 底注, 最小入场
	room_id, seat_count, init_bet, min_enter
]]
local xpnn_desk_config = {
	[10101] = {
			room_id = 10101,
			seat_count = 5,
			init_bet = 0.10,
			min_enter = 30.00,
		},
	[10102] = {
			room_id = 10102,
			seat_count = 5,
			init_bet = 1.00,
			min_enter = 50.00,
		},
	[10103] = {
			room_id = 10103,
			seat_count = 5,
			init_bet = 5.00,
			min_enter = 300.00,
		},
	[10104] = {
			room_id = 10104,
			seat_count = 5,
			init_bet = 10.00,
			min_enter = 600.00,
		},
}
return xpnn_desk_config