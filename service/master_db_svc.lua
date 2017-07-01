

local skynet = require "skynet"
local dbmgr = require "dbmgr"
local db_module = require "db_module"

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
skynet.dispatch("lua", dispatch)

skynet.start(function()
	
end)