local skynet = require "skynet"
local context = require "context"
local db_helper = require "common.db_helper"
local room_id = tonumber(skynet.getenv("room_id"))
local agent_ctrl = {}

local current_conf

local function get_hall_player_agent(player_id)
	local agent_count = skynet.getenv("agent_count")
	local index = toint(player_id % agent_count)
	if index == 0 then index = agent_count end
	return ".agent"..index
end

function agent_ctrl.is_hall()
	return current_conf.servertype == SERVER.HALL
end

function agent_ctrl.init(conf)
	current_conf = conf
end

function agent_ctrl.on_login(ctx, player_info)
	-- print("agent_ctrl.on_login ctx=", table.tostring(ctx), "player_info=", table.tostring(player_info))
	
	local player_id = player_info.player_id
	if agent_ctrl.is_hall() then
		context.rpc_call(ctx.gate, ctx.watchdog, "login_ok", ctx.fd, player_id, current_conf.nodename, get_hall_player_agent(player_id))
	else
		local update_online_info = {
			room_id = room_id,
			agentnode = current_conf.nodename,
			agentaddr = skynet.self(),
			agentver = current_conf.ver,
		}
		db_helper.call(DB_SERVICE.hall, "hall.set_player_online", player_info.player_id, update_online_info)
		context.rpc_call(ctx.gate, ctx.watchdog, "set_agent", ctx.fd, current_conf.nodename, skynet.self(), current_conf.ver)
	end
end

function agent_ctrl.on_logout(ctx)
	print("recv agent_ctrl.on_logout is_hall()=", agent_ctrl.is_hall())
	if not agent_ctrl.is_hall() then
		db_helper.call(DB_SERVICE.hall, "hall.del_player_online_value", ctx.player_id, "room_id")
		db_helper.call(DB_SERVICE.hall, "hall.del_player_online_value", ctx.player_id, "agentnode")
		db_helper.call(DB_SERVICE.hall, "hall.del_player_online_value", ctx.player_id, "agentaddr")
		db_helper.call(DB_SERVICE.hall, "hall.del_player_online_value", ctx.player_id, "agentver")
	end
end

function agent_ctrl.reconnect(ctx)
	
end



return agent_ctrl