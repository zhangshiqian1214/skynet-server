--[[
	房间id, 游戏台坐位数, 底注, 最小入场, 玩游戏最小人数, 准备开始cd, 抢庄cd, 倍投cd, 开牌cd, 结束cd, 系统抽水
	room_id, seat_count, init_bet, min_enter, min_player, ready_begin_time, qiang_banker_time, bet_time, open_card_time, game_end_time, fee
]]
local xpnn_desk_config = {
	[10101] = {
			room_id = 10101,
			seat_count = 5,
			init_bet = 0.10,
			min_enter = 30.00,
			min_player = 2,
			ready_begin_time = 3,
			qiang_banker_time = 4,
			bet_time = 5,
			open_card_time = 5,
			game_end_time = 2,
			fee = 0.05,
		},
	[10102] = {
			room_id = 10102,
			seat_count = 5,
			init_bet = 1.00,
			min_enter = 50.00,
			min_player = 2,
			ready_begin_time = 3,
			qiang_banker_time = 4,
			bet_time = 5,
			open_card_time = 5,
			game_end_time = 2,
			fee = 0.05,
		},
	[10103] = {
			room_id = 10103,
			seat_count = 5,
			init_bet = 5.00,
			min_enter = 300.00,
			min_player = 2,
			ready_begin_time = 3,
			qiang_banker_time = 4,
			bet_time = 5,
			open_card_time = 5,
			game_end_time = 2,
			fee = 0.05,
		},
	[10104] = {
			room_id = 10104,
			seat_count = 5,
			init_bet = 10.00,
			min_enter = 600.00,
			min_player = 2,
			ready_begin_time = 3,
			qiang_banker_time = 4,
			bet_time = 5,
			open_card_time = 5,
			game_end_time = 2,
			fee = 0.05,
		},
}
return xpnn_desk_config