local skynet = require "skynet"
local context = require "context"
local cluster_monitor = require "cluster_monitor"
local create_player_config = require "config.create_player_config"
local auth_ctrl = {}

local logic_svc_pool = {}
local logic_svc_index = 1

local request_sessions = {}

local function init_logic_pool()
	local logic_count = skynet.getenv("auth_logic_count")
	for i=1, logic_count do
		local svc = skynet.newservice("auth_logic_svc")
		logic_svc_pool[#logic_svc_pool + 1] = svc
	end
end

local function get_logic_svc()
	local svc = logic_svc_pool[logic_svc_index]
	logic_svc_index = logic_svc_index + 1
	if logic_svc_index > #logic_svc_pool then
		logic_svc_index = 1
	end
	return svc
end

function auth_ctrl.init()
	init_logic_pool()
end

function auth_ctrl.cast_login(ctx, player_info)
	local hall_node = cluster_monitor.get_cluster_node_by_server(SERVER.HALL)
	if not hall_node then
		error("cast_login hallserver not online")
	end
	context.rpc_call(hall_node.nodename, SERVICE.HALL, "cast_login", ctx, player_info)
end

function auth_ctrl.cast_logout(ctx)

end

function auth_ctrl.register_account(ctx, req)
	if not req.account then
		return AUTH_ERROR.account_nil
	end

	if not req.password then
		return AUTH_ERROR.password_nil
	end

	if not req.telephone then
		return AUTH_ERROR.telephone_nil
	end

	req.create_index = req.create_index or 1
	local conf = create_player_config[req.create_index]
	if not conf then
		return SYSTEM_ERROR.argument
	end

	local session_info = request_sessions[ctx.session]
	if session_info then
		return SYSTEM_ERROR.busy
	end
	request_sessions[ctx.session] = true

	local svc = get_logic_svc()
	local ec, reply = context.call(svc, "register_account", ctx, req)
	if ec ~= SYSTEM_ERROR.success then
		request_sessions[ctx.session] = nil
		return ec
	end

	local ec, reply = context.call(svc, "login_account", ctx, req)
	if ec ~= SYSTEM_ERROR.success then
		request_sessions[ctx.session] = nil
		return ec
	end

	ctx.account_type = ACCOUNT_TYPE.normal
	auth_ctrl.cast_login(ctx, reply.player)
	request_sessions[ctx.session] = nil

	return SYSTEM_ERROR.success, reply
end

function auth_ctrl.login_account(ctx, req)
	if not req.account then
		return AUTH_ERROR.account_nil
	end
	if not req.password then
		return AUTH_ERROR.password_nil
	end

	if ctx.player_id then
		return AUTH_ERROR.repeat_login
	end

	local session_info = request_sessions[ctx.session]
	if session_info then
		return SYSTEM_ERROR.busy
	end
	request_sessions[ctx.session] = true

	local svc = get_logic_svc()
	local ec, reply = context.call(svc, "login_account", ctx, req)
	if ec ~= SYSTEM_ERROR.success then
		request_sessions[ctx.session] = nil
		return ec
	end

	ctx.account_type = ACCOUNT_TYPE.normal
	auth_ctrl.cast_login(ctx, reply.player)
	request_sessions[ctx.session] = nil
	return SYSTEM_ERROR.success, reply
end

function auth_ctrl.weixin_login(ctx, req)
	if not req.union_id then
		return AUTH_ERROR.union_id_nil
	end
	if not req.head_url then
		return AUTH_ERROR.head_url_nil
	end
	if not req.nickname then
		return AUTH_ERROR.nickname_nil
	end
	if not req.sex then
		return AUTH_ERROR.sex_nil
	end
	if ctx.player_id then
		return AUTH_ERROR.repeat_login
	end
	local session_info = request_sessions[ctx.session]
	if session_info then
		return SYSTEM_ERROR.busy
	end
	request_sessions[ctx.session] = true

	local svc = get_logic_svc()
	local ec, reply = context.call(svc, "weixin_login", ctx, req)
	if ec ~= SYSTEM_ERROR.success then
		request_sessions[ctx.session] = nil
		return ec
	end

	ctx.account_type = ACCOUNT_TYPE.weixin
	reply.player.head_url = req.head_url
	reply.player.nickname = req.nickname
	reply.player.sex = req.sex
	auth_ctrl.cast_login(ctx, reply.player)
	request_sessions[ctx.session] = nil
	return SYSTEM_ERROR.success, reply
end

function auth_ctrl.visitor_login(ctx, req)
	print("recv visitor_login ctx=", table.tostring(ctx), "req=", table.tostring(req))
	if ctx.player_id then
		return AUTH_ERROR.repeat_login
	end

	local session_info = request_sessions[ctx.session]
	if session_info then
		return SYSTEM_ERROR.busy
	end
	request_sessions[ctx.session] = true

	local svc = get_logic_svc()
	local ec, reply = context.call(svc, "visitor_login", ctx, req)
	if ec ~= SYSTEM_ERROR.success then
		request_sessions[ctx.session] = nil
		return ec
	end

	auth_ctrl.cast_login(ctx, reply.player)
	request_sessions[ctx.session] = nil
	print("visitor_login reply=", table.tostring(reply))
	return SYSTEM_ERROR.success, reply
end

return auth_ctrl