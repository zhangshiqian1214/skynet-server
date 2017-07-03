--
-- Author: Kuzhu1990
-- Date: 2013-12-16 18:52:11
-- 集群节点管理
-- 

require "skynet.manager"
local skynet = require "skynet"
local cluster = require "skynet.cluster"
local cluster_mgr = require "common.cluster_mgr"

local command = {}


function command.connect(session, conf)
	local ret1, ret2 
	if session > 0 then
		skynet.retpack(true)
	end
	print("recv connect nodename=", conf.nodename)
end

function command.check_alive(session, conf)
	print("recv check_alive nodename=", conf.nodename)
end

function command.subscribe_monitor(session, addr)
	local ret1, ret2 = cluster_mgr.subscribe_monitor(addr)
	if session > 0 then
		skynet.retpack(ret1, ret2)
	end
end

function command.unsubscribe_monitor(session, addr)
	local ret1, ret2 = cluster_mgr.unsubscribe_monitor(addr)
	if session > 0 then
		skynet.retpack(ret1, ret2)
	end
end

function command.start(session, redis_conf, current_conf)
	local ret1, ret2 = cluster_mgr.start(redis_conf, current_conf)
	if session > 0 then
		skynet.retpack(ret1, ret2)

	end
end

function command.open(session)
	local ret1, ret2 = cluster_mgr.open()
	if session > 0 then
		skynet.retpack(ret1, ret2)
	end
end

skynet.start(function()
	skynet.dispatch("lua", function(session, address, cmd, ...)
		local f = command[cmd]
		assert(f, "function["..cmd.."] is nil")
		f(session, ...)
	end)
	skynet.register(SERVICE.CLUSTER_MONITOR)
end)
