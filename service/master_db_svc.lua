--[[
	@ filename :  master_db_svc.lua
	@ author   : zhangshiqian1214@163.com
	@ modify   : 2017-08-23 17:53
	@ company  : zhangshiqian1214
]]

local skynet = require "skynet"
local db_mgr = require "common.db_mgr"
local db_module = require "common.db_module"
local svc_name = ...
local command = {}

local function dispatch(session, addr, cmd, ...)
	local modname, funcname = string.match(cmd, "([%w_]+)%.([%w_]+)")
	local mod = db_module[modname]
	if not mod then
		return
	end
	local func = mod[funcname]
	if not func then
		return
	end

	if session > 0 then
		skynet.retpack(func(...))
	else
		func(...)
	end
end


skynet.start(function()
	db_mgr.init(svc_name)
	skynet.dispatch("lua", dispatch)
end)