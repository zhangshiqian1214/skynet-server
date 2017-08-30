local skynet = require "skynet"
local context = require "context"
local cluster_monitor = require "cluster_monitor"
local db_helper = require "common.db_helper"
local hall_logic = {}

local current_conf

local function get_player_agent(player_id)
	local agent_count = skynet.getenv("agent_count")
	local index = toint(player_id % agent_count)
	if index == 0 then index = agent_count end
	return ".agent"..index
end

function hall_logic.init()
	current_conf = cluster_monitor.get_current_node()
end

function hall_logic.cast_login(ctx, req)
	-- print("cast_login ctx=", table.tostring(ctx), "req=", table.tostring(req))
	local player_id = req.player_id
	local online = db_helper.call(DB_SERVICE.hall, "hall.get_player_online", player_id)
	if online and online.state == ONLINE_STATE.online then
		if online.session == ctx.session then
			return
		end

		context.rpc_call(online.gate, online.watchdog, "kick_player", online.fd)
	end
	local is_logined_game = false
	if online and online.agentnode and online.agentaddr then
		local agent_node_info = cluster_monitor.get_cluster_node(online.agentnode)
		if agent_node_info and agent_node_info.ver == online.agentver then
			is_logined_game = true
		else
			db_helper.call(DB_SERVICE.hall, "hall.del_player_online", player_id)
		end
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
	--大厅agent登录
	context.call(get_player_agent(player_id), "login", ctx, req)
	
	if is_logined_game then
		context.rpc_call(online.agentnode, online.agentaddr, "login", ctx, req)
	end
end

function hall_logic.get_player_online_state(ctx, req)
	local player_id = ctx.player_id
	local player_online = db_helper.call(DB_SERVICE.hall, "hall.get_player_online", player_id)
	-- print("get_player_online_state =", table.tostring(player_online))
	return player_online
end

function hall_logic.get_room_inst_list(ctx, req)

	local room_id = req
	local room_inst_list = db_helper.call(DB_SERVICE.game, "room.get_room_list", room_id)

	local reply = { room_insts = {} }
	for _, v in pairs(room_inst_list) do
		local room_nodeinfo = cluster_monitor.get_cluster_node(v.roomproxy)
		print("get_room_inst_list v.roomproxy=", v.roomproxy, "room_nodeinfo=", table.tostring(room_nodeinfo))
		if room_nodeinfo and room_nodeinfo.is_online == 1 and room_nodeinfo.ver == tonumber(v.ver) then
			table.insert(reply.room_insts, { roomproxy = v.roomproxy, player_num = v.player_num, player_limit = v.player_limit})
		end
	end

	return reply
end

return hall_logic