

local skynet = require "skynet"
local dbmgr = require "common.dbmgr"
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
	dbmgr.init(svc_name)
	skynet.dispatch("lua", dispatch)
end)