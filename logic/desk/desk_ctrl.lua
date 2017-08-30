local skynet = require "skynet"
local context = require "context"
local desk_const = require "desk.desk_const"
local db_helper = require "common.db_helper"

local DESK_CALLBACK = desk_const.DESK_CALLBACK

local desk_ctrl = {}

local callbacks = {}

local player_agents = {}
local player_ctxs = {}


function desk_ctrl.register_callback(method, callback)
	if not callbacks[method] then
		callbacks[method] = callback
	end
end

function desk_ctrl.unregister_callback(method)
	if callbacks[method] then
		callbacks[method] = nil
	end
end

function desk_ctrl.incr_deal_id()
	return db_helper.call(DB_SERVICE.unique, "desk.incr_deal_id")
end

function desk_ctrl.get_player_agent(player_id)
	return player_agents[player_id]
end

function desk_ctrl.get_player_ctx(player_id)
	return player_ctxs[player_id]
end

function desk_ctrl.get_player_info(player_id)
	assert(player_id, "player_id is nil")
	local agent = desk_ctrl.get_player_agent(player_id)
	if not agent then
		return nil
	end
	local player_info = context.call_service(agent, "player.get_player_info")
	return player_info
end

function desk_ctrl.login_desk(ctx, agent)

	player_agents[ctx.player_id] = agent
	player_ctxs[ctx.player_id] = ctx

	if callbacks[DESK_CALLBACK.login_desk] then
		local ec = callbacks[DESK_CALLBACK.login_desk](ctx, agent)
		if ec ~= SYSTEM_ERROR.success then
			return ec
		end
	end

	context.rpc_call(ctx.gate, ctx.watchdog, "login_desk", ctx.fd, skynet.self())
	return SYSTEM_ERROR.success
end

function desk_ctrl.logout_desk(ctx)

	if callbacks[DESK_CALLBACK.logout_desk] then
		local ec = callbacks[DESK_CALLBACK.logout_desk](ctx, agent)
		if ec ~= SYSTEM_ERROR.success then
			return ec
		end
	end

	player_agents[ctx.player_id] = nil
	player_ctxs[ctx.player_id] = nil

	context.rpc_call(ctx.gate, ctx.watchdog, "logout_desk", ctx.fd)
	return SYSTEM_ERROR.success
end

function desk_ctrl.player_disconnect()
	if callbacks[DESK_CALLBACK.player_disconnect] then
		local ec = callbacks[DESK_CALLBACK.player_disconnect](ctx, agent)
		if ec ~= SYSTEM_ERROR.success then
			return ec
		end
	end

	return SYSTEM_ERROR.success
end

function desk_ctrl.player_reconnect(ctx)

	if callbacks[DESK_CALLBACK.player_reconnect] then
		local ec = callbacks[DESK_CALLBACK.player_reconnect](ctx, agent)
		if ec ~= SYSTEM_ERROR.success then
			return ec
		end
	end
	
	context.rpc_call(ctx.gate, ctx.watchdog, "login_desk", ctx.fd, skynet.self())

	return SYSTEM_ERROR.success
end

function desk_ctrl.player_payout_end(player_id, player_info)
	if callbacks[DESK_CALLBACK.player_payout_end] then
		callbacks[DESK_CALLBACK.player_payout_end](player_id, player_info)
	end
end

function desk_ctrl.init()

end

return desk_ctrl