--
-- Author: Kuzhu1990
-- Date: 2013-12-16 18:52:11
-- 接收器, 用于主动连接
-- 

local skynet  = require "skynet"
local cluster = require "skynet.cluster"

local _conf
local acceptor = {}

function acceptor.connect()
	return true
end

function acceptor.check_alive()

end

function acceptor.set_conf(conf)
	_conf = conf
end

function acceptor.get_conf()
	return _conf
end

function acceptor.start()
	assert(_conf, "conf is nil")
	cluster.open(_conf.nodename)
end

return acceptor