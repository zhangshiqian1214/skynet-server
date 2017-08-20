require "skynet.manager"
local skynet = require "skynet"
local db_config = require "config.db_config"

local command = {}
local db_pool = {}
local db_pool_index = {}


local function init_db_pool()
	for _, conf in pairs(db_config) do
		local svc_count = conf.svc_count
		for i=1, svc_count do
			local svc = skynet.newservice("master_db_svc", conf.svc_name)
			if conf.get_svc == GET_SVC_TYPE.unique then
				skynet.name(conf.service_name, svc)
			else
				skynet.name(conf.service_name..i, svc)
			end
			db_pool[conf.svc_name] = db_pool[conf.svc_name] or {}
			table.insert(db_pool[conf.svc_name], svc)
		end
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

function command.get_db_svc(svc_name)
	if not svc_name or not db_pool[svc_name] then
		return nil
	end
	db_pool_index[svc_name] = db_pool_index[svc_name] or 1
	local index = db_pool_index[svc_name]
	local svc = db_pool[svc_name][index]
	if not svc then
		return nil
	end
	db_pool_index[svc_name] = db_pool_index[svc_name] + 1
	if db_pool_index[svc_name] > #db_pool[svc_name] then
		db_pool_index[svc_name] = 1
	end
	
	return svc
end

function command.start()
	init_db_pool()
end

skynet.start(function()
	skynet.dispatch("lua", dispatch)
	skynet.register(SERVICE.MASTER_DB)
end)
