--
-- Author: Kuzhu1990
-- Date: 2013-12-16 18:52:11
-- 多节点监控
-- 

local skynet    = require "skynet"
local cluster   = require "cluster"
local acceptor  = require "acceptor"
local redis_mq  = require "redis_mq"
local connector_mgr = require "connector_mgr"

local clustermq  = nil


--mq的消息回调
local function on_mq_message(method, data)

end

local function reload_cluster_conf()

end


--启动多节点监控
-- redis_conf = {
--		host="127.0.0.1", 
--		port=6379, 
--		db=0
--	}
-- node_conf = {
--		nodename="node1", 
--		nodeprot=9001, 
--		intranetip="127.0.0.1",
--		extranetip="122.10.10.10",
--		serverid=1,
--      servertype=1,
--	}
function command.start(redis_conf, node_conf)
	
	clustermq = redis_mq(redis_conf, on_mq_message)

	acceptor.set_conf(node_conf)

	local db = clustermq.get_redis_db()

end

skynet.start(function()

	skynet.dispatch("lua", function(session, address, cmd, ...)

		local f = command[cmd]
		assert(f, "function["..cmd.."] is nil")
		local ret1, ret2, ret3, ret4 = f(...)

	end)

end)