local skynet = require "skynet"
local context = require "context"
local agent_ctrl = {}

local current_conf

function agent_ctrl.is_hall()
	return current_conf.server_type == SERVER.HALL
end

function agent_ctrl.on_login(ctx, player_info)
	print("agent_ctrl.on_login ctx=", table.tostring(ctx), "player_info=", table.tostring(player_info))
	
	if not agent_ctrl.is_hall() then
		local update_online_info = {
			agentnode = current_conf.nodename,
			agentaddr = skynet.self(),
			agentver = current_conf.ver,
		}
		db_helper.call(DB_SERVICE.hall, "hall.set_player_online", player_info.player_id, update_online_info)
	end
	
	context.rpc_call(ctx.gate, ctx.watchdog, "login_ok", ctx.fd, player_info.player_id, current_conf.nodename, skynet.self())
end

function agent_ctrl.on_logout(ctx)

end

function agent_ctrl.init(conf)
	current_conf = conf
end

return agent_ctrl