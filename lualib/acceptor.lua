--
-- Author: Kuzhu1990
-- Date: 2013-12-16 18:52:11
-- 接收器, 用于主动连接
-- 

local skynet  = require "skynet"
local cluster = require "skynet.cluster"
local current_conf
local acceptor = {}

function acceptor.connect()
	return true
end

function acceptor.check_alive()

end

function acceptor.set_cluster_conf(conf)
	current_conf = conf
end

function acceptor.get_cluster_conf()
	return current_conf
end

function acceptor.start()
	assert(current_conf, "conf is nil")
	cluster.open(current_conf.nodename)
end

return acceptor