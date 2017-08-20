local skynet = require "skynet"
local json = require "json"
local command = require "command_base"
local auth_logic = require "auth.auth_logic"

function command.register_account(ctx, req)
	return auth_logic.register_account(ctx, req)
end

function command.login_account(ctx, req)
	return auth_logic.login_account(ctx, req)
end

function command.weixin_login(ctx, req)
	return auth_logic.weixin_login(ctx, req)
end

function command.visitor_login(ctx, req)
	return auth_logic.visitor_login(ctx, req)
end

skynet.start(function()
	auth_logic.init()
end)
