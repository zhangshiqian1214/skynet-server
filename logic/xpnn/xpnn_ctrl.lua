local skynet = require "skynet"
local timer = require "timer"
local context = require "context"
local random = require "random"
local config_db = require "config_db"
local desk_const = require "desk.desk_const"
local desk_ctrl = require "desk.desk_ctrl"
local xpnn_const = require "xpnn.xpnn_const"
local xpnn_logic = require "xpnn.xpnn_logic"
local cd_ctrl = require "game.cd_ctrl"
local room_id = tonumber(skynet.getenv("room_id"))
local xpnn_desk_config = config_db.xpnn_desk_config
local xpnn_ctrl = {}


local DESK_CALLBACK = desk_const.DESK_CALLBACK
local CD_TYPE = xpnn_const.CD_TYPE
local GAME_STATE = xpnn_const.GAME_STATE
local MAX_QIANG_BANKER_TIMES = xpnn_const.MAX_QIANG_BANKER_TIMES
local MAX_BET_TIMES =xpnn_const.MAX_BET_TIMES

local ready_begin_cd_id = nil
local qiang_banker_cd_id = nil
local bet_cd_id = nil
local open_card_cd_id = nil
local game_end_cd_id = nil

--游戏变量
local desk_id
local deal_id
local game_state
local table_base = {}
local player_map = {}
local seat_state_map = {}
local player_cards_map = {}
local banker = nil
local qiang_times_map = {}
local bet_times_map= {}
local winlost_map = {}
local open_card_map = {}

--内部使用变量
local unshow_cards = {}
local group_cards_map = {}
local max_card_map = {}
local payout_end_map = {}

local function get_null_seat()
	local null_seats = {}
	for i=1, xpnn_desk_config[room_id].seat_count do
		if not player_map[i] then
			table.insert(null_seats, i)
		end
	end
	if table.empty(null_seats) then
		return ERR_SEAT
	end
	return null_seats[1]
end

local function can_game_start()
	if game_state ~= GAME_STATE.ready_begin then
		return false
	end

	if table.nums(player_map) >= xpnn_desk_config[room_id].min_player then
		return true
	end
	return false
end

local function shuffle_cards()
	unshow_cards = random.random_shuffle(CARD_POOL)
	for seat, v in pairs(seat_state_map) do
		if v.state & SEAT_STATE.gaming > 0 then
			player_cards_map[seat] = player_cards_map[seat] or {}
			player_cards_map[seat].seat = seat
			player_cards_map[seat].cards = {}
			player_cards_map[seat].card_type = CARD_TYPE.no_niu
			for i=1, 5 do
				local card = table.remove(unshow_cards, 1)
				table.insert(player_cards_map[seat].cards, card)
			end
			local card_type, max_card, group_cards = xpnn_logic.get_card_type(player_cards_map[seat].cards)
			player_cards_map[seat].card_type = card_type
			max_card_map[seat] = max_card
			group_cards_map[seat] = group_cards
		end
	end
end

local function get_player_cards_map(seat)
	if game_state == GAME_STATE.ready_begin then
		return nil
	end
	local tmp_cards_map = {}
	for k, v in pairs(player_cards_map) do
		tmp_cards_map[k] = clone(v)
		if game_state < GAME_STATE.open_card then
			if k == seat then
				tmp_cards_map[k].cards[5] = 0x00
				tmp_cards_map[k].card_type = nil
			else
				tmp_cards_map[k].cards[1] = 0x00
				tmp_cards_map[k].cards[2] = 0x00
				tmp_cards_map[k].cards[3] = 0x00
				tmp_cards_map[k].cards[4] = 0x00
				tmp_cards_map[k].cards[5] = 0x00
				tmp_cards_map[k].card_type = nil
			end
		elseif game_state == GAME_STATE.open_card then
			if k ~= seat then
				tmp_cards_map[k].cards[1] = 0x00
				tmp_cards_map[k].cards[2] = 0x00
				tmp_cards_map[k].cards[3] = 0x00
				tmp_cards_map[k].cards[4] = 0x00
				tmp_cards_map[k].cards[5] = 0x00
				tmp_cards_map[k].card_type = nil
			end
		end
	end
	return tmp_cards_map
end

local function on_ready_begin()
	assert(game_state == GAME_STATE.ready_begin)
	for k, v in pairs(player_map) do
		seat_state_map[k].state = SEAT_STATE.gaming
	end
	
	shuffle_cards()
	for seat, v in pairs(player_map) do
		local event = {}
		event.cards = clone(player_cards_map[seat].cards)
		event.cards[5] = 0x00
		xpnn_ctrl.send_game_start_event(seat, event)
	end
	
	game_state = GAME_STATE.qiang_banker
	ready_begin_cd_id = nil
	qiang_banker_cd_id = cd_ctrl.add_cd(GAME_STATE.qiang_banker, xpnn_desk_config[room_id].qiang_banker_time)
end

local function on_qiang_banker()
	assert(game_state == GAME_STATE.qiang_banker)

	for seat, v in pairs(player_map) do
		if not qiang_times_map[seat] then
			xpnn_ctrl.handle_qiang_banker(seat, 0)
		end
	end
	game_state = GAME_STATE.bet
	qiang_banker_cd_id = nil
	bet_cd_id = cd_ctrl.add_cd(GAME_STATE.bet, xpnn_desk_config[room_id].bet_time)
end

local function on_bet()
	assert(game_state == GAME_STATE.bet)
	for seat, v in pairs(player_map) do
		if not qiang_times_map[seat] then
			xpnn_ctrl.handle_bet(seat, 1)
		end
	end
	game_state = GAME_STATE.open_card
	bet_cd_id = nil
	open_card_cd_id = cd_ctrl.add_cd(GAME_STATE.open_card, xpnn_desk_config[room_id].open_card_time)
end

local function on_open_card()
	assert(game_state == GAME_STATE.open_card)
	for seat, v in pairs(player_map) do
		if not qiang_times_map[seat] then
			xpnn_ctrl.handle_open_card(seat, 1)
		end
	end
	game_state = GAME_STATE.game_end
	open_card_cd_id = nil
	game_end_cd_id = cd_ctrl.add_cd(GAME_STATE.game_end, xpnn_desk_config[room_id].game_end_time)
end

local function on_game_end()
	assert(game_state == GAME_STATE.game_end)

	xpnn_ctrl.handle_game_end()

end

--------------------------内部函数---------------------------------

function xpnn_ctrl.get_seat_by_player(player_id)
	for k, v in pairs(player_map) do
		if v.player_id == player_id then
			return k
		end
	end
	return ERR_SEAT
end

function xpnn_ctrl.get_player_by_seat(seat)
	return player_map[seat]
end

function xpnn_ctrl.get_gaming_player_num()
	local gameing_num = 0
	for k, v in pairs(seat_state_map) do
		if v.state & SEAT_STATE.gaming > 0 then
			gameing_num = gameing_num + 1
		end
	end
	return gameing_num
end

function xpnn_ctrl.get_player_ctx_by_seat(seat)
	local player_info = xpnn_ctrl.get_player_by_seat(seat)
	if not player_info then
		return
	end
	return desk_ctrl.get_player_ctx(player_info.player_id)
end

function xpnn_ctrl.is_player_online(seat)
	if not seat_state_map[seat] then
		return false
	end
	if seat_state_map[seat].state == 0 then
		return false
	end
	if seat_state_map[seat].state & SEAT_STATE.offline > 0 or seat_state_map[seat].state & SEAT_STATE.exit > 0 then
		return false
	end
	return true
end

function xpnn_ctrl.is_player_gaming(seat)
	if not seat_state_map[seat] then
		return false
	end
	if game_state == GAME_STATE.ready_begin then
		return false
	end
	if seat_state_map[seat].state == 0 then
		return false
	end
	if seat_state_map[seat].state & SEAT_STATE.gaming > 0 then
		return true
	end
	return false
end

function xpnn_ctrl.update_player_info(player_info)

end

-----------------------------事件广播-------------------------

function xpnn_ctrl.broad_seat_state_event(seat)
	local event = {}
	event.seat_state_map = seat_state_map
	event.player_map = player_map
	for k, v in pairs(player_map) do
		if xpnn_ctrl.is_player_online(k) == true then
			local ctx = desk_ctrl.get_player_ctx(v.player_id)
			context.send_client_event(ctx, M_XPNN.seat_state_event, event)
		end
	end
end

function xpnn_ctrl.send_game_start_event(seat, event)
	if not xpnn_ctrl.is_player_online(seat) then
		return
	end
	local ctx = xpnn_ctrl.get_player_ctx_by_seat(seat)
	if ctx then
		context.send_client_event(ctx, M_XPNN.game_start_event, event)
	end
end

function xpnn_ctrl.send_qiang_banker_event(seat, event)
	if not xpnn_ctrl.is_player_online(seat) then
		return
	end
	local ctx = xpnn_ctrl.get_player_ctx_by_seat(seat)
	if ctx then
		context.send_client_event(ctx, M_XPNN.qiang_banker_event, event)
	end
end

function xpnn_ctrl.send_bet_event(seat, event)
	if not xpnn_ctrl.is_player_online(seat) then
		return
	end
	local ctx = xpnn_ctrl.get_player_ctx_by_seat(seat)
	if ctx then
		context.send_client_event(ctx, M_XPNN.bet_event, event)
	end
end

function xpnn_ctrl.send_deal_card_event(seat, event)
	if not xpnn_ctrl.is_player_online(seat) then
		return
	end
	local ctx = xpnn_ctrl.get_player_ctx_by_seat(seat)
	if ctx then
		context.send_client_event(ctx, M_XPNN.deal_card_event, event)
	end
end

function xpnn_ctrl.send_open_card_event(seat, event)
	if not xpnn_ctrl.is_player_online(seat) then
		return
	end
	local ctx = xpnn_ctrl.get_player_ctx_by_seat(seat)
	if ctx then
		context.send_client_event(ctx, M_XPNN.open_card_event, event)
	end
end

function xpnn_ctrl.game_end_event(seat, event)
	if not xpnn_ctrl.is_player_online(seat) then
		return
	end
	local ctx = xpnn_ctrl.get_player_ctx_by_seat(seat)
	if ctx then
		context.send_client_event(ctx, M_XPNN.game_end_event, event)
	end
end


function xpnn_ctrl.handle_qiang_banker(seat, times)
	qiang_times_map[seat] = times
	local event = {}
	event.seat = seat
	event.times = times

	if table.nums(qiang_times_map) < xpnn_ctrl.get_gaming_player_num() then
		for k, v in pairs(player_map) do
			xpnn_ctrl.send_qiang_banker_event(k, event)
		end
		return
	end

	local max_times = 0
	local qiang_banker_list = {}
	for k, v in pairs(qiang_times_map) do
		if v > max_times then
			max_times = v
		end
	end
	
	local random_banker_seats = {}
	for k, v in pairs(qiang_times_map) do
		if v == max_times then
			table.insert(random_banker_seats, k)
		end
	end

	if #random_banker_seats > 1 then
		banker = random.random_one(random_banker_seats)
	else
		banker = random_banker_seats[1]
	end

	event.banker = banker
	event.random_banker_seats = random_banker_seats
	for k, v in pairs(player_map) do
		xpnn_ctrl.send_qiang_banker_event(k, event)
	end
end

function xpnn_ctrl.handle_bet(seat, times)
	local event = {}
	event.seat = seat
	event.times = times

	if table.nums(bet_times_map) < xpnn_ctrl.get_gaming_player_num() then
		for k, v in pairs(player_map) do
			xpnn_ctrl.send_bet_event(k, event)
		end
		return
	end

	--TODO 发最后一张牌
	for k, v in pairs(player_map) do
		local last_card_event = {}
		last_card_event.card = player_cards_map[k].cards[5]
		last_card_event.card_type = player_cards_map[k].card_type
		last_card_event.group_cards = group_cards_map[k]
		xpnn_ctrl.send_deal_card_event(k, last_card_event)
	end
end

function xpnn_ctrl.handle_open_card(seat)
	local event = {}
	event.seat = seat
	event.card_type = player_cards_map[k].card_type

	if table.nums(qiang_times_map) < xpnn_ctrl.get_gaming_player_num() then
		for k, v in pairs(player_map) do
			xpnn_ctrl.send_open_card_event(k, event)
		end
		return
	end
	--TODO
end

function xpnn_ctrl.handle_game_end()
	xpnn_desk_config[room_id].init_bet

	local banker_times = (qiang_times_map[banker] > 0) and qiang_times_map[banker] or 1
	local banker_card_type_times = xpnn_logic.get_times(player_cards_map[banker].card_type)
	for k, v in pairs(seat_state_map) do
		if k ~= banker and v.state & GAME_STATE.gaming > 0 then
			--TODO 比牌
			local isWin = xpnn_logic.compare(player_cards_map[k].card_type, player_cards_map[banker].card_type, max_card_map[k], max_card_map[banker])
			if isWin then
				local card_type_times = xpnn_logic.get_times(player_cards_map[k].card_type)
				winlost_map[k] = { seat = k, winlost = 0, fee = 0 }
				local win = banker_times * bet_times_map[k] * card_type_times
				winlost_map[k].winlost =  win

				winlost_map[banker] = winlost_map[banker] or { seat = banker, winlost = 0, fee = 0}
				winlost_map[banker].winlost = winlost_map[banker].winlost - win

				--TODO 系统抽水
				winlost_map[k].fee = -win * xpnn_desk_config[room_id].fee
			else
				winlost_map[k] = { seat = k, winlost = 0, fee = 0 }
				local win = banker_times * bet_times_map[k] * banker_card_type_times
				winlost_map[k].winlost = -win

				winlost_map[banker].winlost = winlost_map[banker].winlost or { seat = banker, winlost = 0, fee = 0}
				winlost_map[banker].winlost = winlost_map[banker].winlost + win

				--TODO 系统抽水
				winlost_map[banker].fee = winlost_map[banker].fee + (-win * xpnn_desk_config[room_id].fee)
			end
		end
	end

	for k, v in pairs(winlost_map) do
		local player_id = xpnn_ctrl.get_player_by_seat(k)
		local agent = desk_ctrl.get_player_agent(player_id)
		if agent then
			payout_end_map[player_id] = false
			context.send_service(agent, "player.handle_player_payout", skynet.self(), v)
		end
	end
end

function xpnn_ctrl.handle_game_totally_end()
	--清理游戏状态
	assert(game_state == GAME_STATE.game_end)

	--发送事件给客户端
	local event = {}
	for k, v in pairs(player_map) do
		xpnn_ctrl.game_end_event(k, )
	end

	game_state = GAME_STATE.ready_begin
	for k, v in pairs(player_map) do
		seat_state_map[k] = seat_state_map[k] or { seat = seat, state = SEAT_STATE.ready }
		local old_state = seat_state_map[k].state
		if old_state & SEAT_STATE.offline > 0 or old_state & SEAT_STATE.exit > 0 then
			--TODO 踢出游戏台
			
		end
	end

end

function xpnn_ctrl.player_payout_end(player_id, player_info)
	if payout_end_map[player_id] then
		return
	end
	xpnn_ctrl.update_player_info(player_id, player_info)
	local payout_end_num = 0
	for k, v in pairs(payout_end_map) do
		if v == true then
			payout_end_num = payout_end_num + 1
		end
	end
	if table.nums(payout_end_map) == payout_end_num then
		xpnn_ctrl.handle_game_totally_end()
	end
end

----------------------------------------------------



function xpnn_ctrl.login_desk(ctx, agent)
	local seat = get_null_seat()
	if seat == ERR_SEAT then
		return GAME_ERROR.desk_full
	end
	local player_info = desk_ctrl.get_player_info(ctx.player_id)
	if not player_info then
		return GAME_ERROR.desk_no_player
	end
	local player = {
		seat = seat, 
		player_id = player_info.player_id,
		nickname = player_info.nickname,
		head_id = player_info.head_id,
		head_url = player_info.head_url,
		sex = player_info.sex,
		gold = player_info.gold,
	}

	player_map[seat] = player
	seat_state_map[seat] = seat_state_map[seat] or {}
	seat_state_map[seat].seat = seat
	seat_state_map[seat].state = SEAT_STATE.ready


	--TODO 玩家注册cd监听
	for _, v in pairs(GAME_STATE) do
		cd_ctrl.register_listener(v, ctx)
	end

	cd_ctrl.on_login(ctx)

	xpnn_ctrl.broad_seat_state_event(seat)

	if can_game_start() then
		ready_begin_cd_id = cd_ctrl.add_cd(GAME_STATE.ready_begin, xpnn_desk_config[room_id].ready_begin_time)
	end

	return SYSTEM_ERROR.success
end

function xpnn_ctrl.logout_desk(ctx)
	local seat = xpnn_ctrl.get_seat_by_player(ctx.player_id)
	if seat == ERR_SEAT then
		return SYSTEM_ERROR.success
	end

	--TODO 解除监听
	for _, v in pairs(GAME_STATE) do
		cd_ctrl.unregister_listener(v, ctx)
	end
	cd_ctrl.on_logout(ctx)

	if not xpnn_ctrl.is_player_gaming(seat) then
		player_map[seat] = nil
		seat_state_map[seat] = nil
		xpnn_ctrl.broad_seat_state_event(seat)
		return SYSTEM_ERROR.success
	end

	seat_state_map[seat].state = seat_state_map[seat].state | SEAT_STATE.exit
	xpnn_ctrl.broad_seat_state_event(seat)
	return GAME_ERROR.player_gaming
end

function xpnn_ctrl.player_disconnect(ctx)
	local seat = xpnn_ctrl.get_seat_by_player(ctx.player_id)
	if seat == ERR_SEAT then
		return SYSTEM_ERROR.success
	end

	--TODO 解除监听
	for _, v in pairs(GAME_STATE) do
		cd_ctrl.unregister_listener(v, ctx)
	end
	cd_ctrl.on_logout(ctx)

	seat_state_map[seat].state = seat_state_map[seat].state | SEAT_STATE.offline
	xpnn_ctrl.broad_seat_state_event(seat)

	return SYSTEM_ERROR.success
end

function xpnn_ctrl.player_reconnect(ctx)
	local seat = xpnn_ctrl.get_seat_by_player(ctx.player_id)
	if seat == ERR_SEAT then
		return SYSTEM_ERROR.success
	end

	--TODO 玩家注册cd监听
	for _, v in pairs(GAME_STATE) do
		cd_ctrl.register_listener(v, ctx)
	end
	cd_ctrl.on_login(ctx)

	seat_state_map[seat].state = seat_state_map[seat].state & ~ SEAT_STATE.offline

	xpnn_ctrl.broad_seat_state_event(seat)

	return SYSTEM_ERROR.success
end

function xpnn_ctrl.qry_desk(ctx, req)
	local seat = xpnn_ctrl.get_seat_by_player(ctx.player_id)
	if seat == ERR_SEAT then
		return DESK_ERROR.player_no_seat
	end
	local reply = { table_info = {} }
	reply.table_info.table_base = { deal_id = desk_id, game_state = game_state }
	reply.table_info.player_map = player_map
	reply.table_info.seat_state_map = seat_state_map
	reply.table_info.banker = banker
	for k, v in pairs(player_map) do
		reply.table_info.qiang_times_map = {}
		reply.table_info.bet_times_map = {}
		reply.table_info.open_card_map = {}
		reply.table_info.qiang_times_map[k] = qiang_times_map[k] or -1
		reply.table_info.bet_times_map[k] = bet_times_map[k] or -1
		reply.table_info.open_card_map[k] = open_card_map[k] or false
	end
	reply.table_info.player_cards_map = get_player_cards_map(seat)
	reply.table_info.winlost_map = winlost_map

	return SYSTEM_ERROR.success, reply
end

function xpnn_ctrl.qiang_banker(ctx, req)
	local seat = xpnn_ctrl.get_seat_by_player(ctx.player_id)
	if seat == ERR_SEAT then
		return DESK_ERROR.player_no_seat
	end
	if not req.times or req.times > MAX_QIANG_BANKER_TIMES or req.times < 0 then
		return SYSTEM_ERROR.argument
	end
	if game_state ~= GAME_STATE.qiang_banker then
		return DESK_ERROR.game_state_limit
	end
	local state = seat_state_map[seat].state
	if state & GAME_STATE.gaming == 0 then
		return DESK_ERROR.game_has_begin
	end
	if qiang_times_map[seat] then
		return SYSTEM_ERROR.success
	end

	xpnn_ctrl.handle_qiang_banker(seat, req.times)
	if table.nums(qiang_times_map) == xpnn_ctrl.get_gaming_player_num() then
		assert(qiang_banker_cd_id, "倒计时未启动")
		cd_ctrl.del_cd(qiang_banker_cd_id)
		on_qiang_banker()
	end

	return SYSTEM_ERROR.success
end

function xpnn_ctrl.bet(ctx, req)
	local seat = xpnn_ctrl.get_seat_by_player(ctx.player_id)
	if seat == ERR_SEAT then
		return DESK_ERROR.player_no_seat
	end
	if not req.times or req.times > MAX_BET_TIMES or req.times <= 0 then
		return SYSTEM_ERROR.argument
	end
	if game_state ~= GAME_STATE.bet then
		return DESK_ERROR.game_state_limit
	end
	local state = seat_state_map[seat].state
	if state & GAME_STATE.gaming == 0 then
		return DESK_ERROR.game_has_begin
	end
	if bet_times_map[seat] then
		return SYSTEM_ERROR.success
	end

	xpnn_ctrl.handle_bet(seat, req.times)
	if table.nums(bet_times_map) == xpnn_ctrl.get_gaming_player_num() then
		assert(bet_cd_id, "倒计时未启动")
		cd_ctrl.del_cd(bet_cd_id)
		on_bet()
	end
	return SYSTEM_ERROR.success
end

function xpnn_ctrl.open_card(ctx, req)
	local seat = xpnn_ctrl.get_seat_by_player(ctx.player_id)
	if seat == ERR_SEAT then
		return DESK_ERROR.player_no_seat
	end
	if game_state ~= GAME_STATE.bet then
		return DESK_ERROR.game_state_limit
	end
	local state = seat_state_map[seat].state
	if state & GAME_STATE.gaming == 0 then
		return DESK_ERROR.game_has_begin
	end
	if open_card_map[seat] then
		return SYSTEM_ERROR.success
	end
	xpnn_ctrl.handle_open_card(seat)
	if table.nums(bet_times_map) == xpnn_ctrl.get_gaming_player_num() then
		assert(open_card_cd_id, "倒计时未启动")
		cd_ctrl.del_cd(open_card_cd_id)
		on_open_card()
	end
	return SYSTEM_ERROR.success
end

function xpnn_ctrl.init()
	desk_id = skynet.self()
	deal_id = 0
	game_state = GAME_STATE.ready_begin

	--TODO 注册游戏台回调
	desk_ctrl.register_callback(DESK_CALLBACK.login_desk, xpnn_ctrl.login_desk)
	desk_ctrl.register_callback(DESK_CALLBACK.logout_desk, xpnn_ctrl.logout_desk)
	desk_ctrl.register_callback(DESK_CALLBACK.player_disconnect, xpnn_ctrl.player_disconnect)
	desk_ctrl.register_callback(DESK_CALLBACK.player_reconnect, xpnn_ctrl.player_reconnect)

	--TODO 注册cd回调
	cd_ctrl.register_callback(GAME_STATE.ready_begin, on_ready_begin)
	cd_ctrl.register_callback(GAME_STATE.qiang_banker, on_qiang_banker)
	cd_ctrl.register_callback(GAME_STATE.bet, on_bet)
	cd_ctrl.register_callback(GAME_STATE.open_card, on_open_card)
	cd_ctrl.register_callback(GAME_STATE.game_end, on_game_end)
end

return xpnn_ctrl