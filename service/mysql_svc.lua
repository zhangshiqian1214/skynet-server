local skynet  = require "skynet"
local mysql = require "skynet.db.mysql"

local db = nil
local command = {}

function command.ping()
	db:query("select 1")
end

function command.execute(sql)
	return db:query(sql)
end

function command.init(conf)
	db = mysql.connect(conf)
end

local function dispatch(session, addr, cmd, ...)
	local func = assert(command[cmd, string.format("mysql svc func is nil")])
	if session > 0 then
		skynet.retpack(func(...))
	else
		func(...)
	end
end

skynet.start(function()
	skynet.dispatch("lua", dispatch)
end)