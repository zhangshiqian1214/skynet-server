--[[
	@ filename : mysql_mgr.lua
	@ author   : zhangshiqian1214@163.com
	@ modify   : 2017-08-23 17:53
	@ company  : zhangshiqian1214
]]

require "skynet.manager"
local skynet  = require "skynet"
local mysql = require "skynet.db.mysql"

local command = {}
local db_pool = {}
local index = 1

local function init_db_pool()
	local dbcount = skynet.getenv("dbcount")
	for i=1, dbcount do
		db_pool[#db_pool+1] = skynet.newservice("mysql_svc")
	end
end

local function dispatch(session, addr, cmd, ...)
	local func = command[cmd]
	if not func then
		return
	end
	if session > 0 then
		skynet.retpack(func(...))
	else
		func(...)
	end
end

function command.get_db_svc()
	local db = db_pool[index]
	index = index + 1
	if index > #db_pool then
		index = 1
	end
	return db
end

skynet.start(function()
	skynet.dispatch("lua", dispatch)
	skynet.register(SERVICE.MYSQL_MGR)
end)