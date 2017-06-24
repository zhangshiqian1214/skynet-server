--
-- Author: Kuzhu1990
-- Date: 2013-12-16 18:52:11
-- 多节点监控
-- 
-- redis_conf = { host="127.0.0.1", port=6379, db=0 }
-- node_conf = { nodename="node1", nodeprot=9001, 
--   intranetip="127.0.0.1", extranetip="127.1.1.1",
--   use_intranet=1, serverid=1, servertype=1, ver=0 }
--
require "skynet.manager"
local skynet = require "skynet"
local cluster = require "skynet.cluster"
local cluster_mgr = require "cluster_mgr"

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

function command.subscribe_cluster(session, addr)
	local ret1, ret2 = cluster_mgr.subscribe_cluster(addr)
	if session > 0 then
		skynet.retpack(ret1, ret2)
	end
end

function command.unsubscribe_cluster(session, addr)
	local ret1, ret2 = cluster_mgr.unsubscribe_cluster(addr)
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
