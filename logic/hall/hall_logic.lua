local skynet = require "skynet"
local context = require "context"
local cluster_monitor = require "cluster_monitor"
local db_helper = require "common.db_helper"
local hall_logic = {}

local function get_player_agent(player_id)
	local agent_count = skynet.getenv("agent_count")
	local index = toint(player_id % agent_count)
	if index == 0 then index = agent_count end
	return ".agent"..index
end

function hall_logic.init()
	
end

function hall_logic.cast_login(ctx, req)
	print("cast_login ctx=", table.tostring(ctx), "req=", table.tostring(req))
	local player_id = req.player_id
	local online = db_helper.call(DB_SERVICE.hall, "hall.get_player_online", player_id)
	if online and online.state == ONLINE_STATE.online then
		if online.session == ctx.session then
			return
		end

		context.rpc_call(online.gate, online.watchdog, "kick_player", online.fd)
	end
	local is_logined = false
	if online and online.agentnode and online.agentaddr then
		is_logined = true
	else
		is_logined = false
	end
	online = online or {}
	online.session = ctx.session
	online.state = ONLINE_STATE.online
	online.player_id = player_id
	online.gate = ctx.gate
	online.watchdog = ctx.watchdog
	online.fd = ctx.fd
	online.ip = ctx.ip
	db_helper.call(DB_SERVICE.hall, "hall.set_player_online", player_id, online)

	if not is_logined then
		context.call(get_player_agent(player_id), "login", ctx, req)
	else
		context.rpc_call(online.agentnode, online.agentaddr, "login", ctx, req)
	end
end

function hall_logic.get_player_online_state(ctx, req)
	local player_id = ctx.player_id
	local player_online = db_helper.call(DB_SERVICE.hall, "hall.get_player_online", player_id)
	return player_online
end

function hall_logic.get_room_inst_list(ctx, req)
	local room_id = req
	
end

return hall_logic