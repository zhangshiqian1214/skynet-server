--[[
	@ filename : auth_logic_svc.lua
	@ author   : zhangshiqian1214@163.com
	@ modify   : 2017-08-23 17:53
	@ company  : zhangshiqian1214
]]

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
