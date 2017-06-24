local skynet = require "skynet"
local share_memory = require "share_memory"

local addr
local cluster_monitor = {}

local function init()
	addr = skynet.uniqueservice("cluster_monitord")
end

function cluster_monitor.get_current_node()
	local nodename = share_memory["current_nodename"]
	if not nodename then
		return nil
	end
	local cluster_nodes =  share_memory["cluster_nodes"]
	if not cluster_nodes then
		return nil
	end
	return cluster_nodes[nodename]
end

function cluster_monitor.get_cluster_nodes()
	local cluster_nodes =  share_memory["cluster_nodes"]
	return cluster_nodes
end

function cluster_monitor.subscribe_cluster()
	
end

function cluster_monitor.unsubscribe_cluster()

end


function cluster_monitor.start(redis_conf, current_conf)
	assert(redis_conf, "redis_conf is nil")
	assert(current_conf, "current_conf is nil")
	current_nodename = current_conf.nodename
	skynet.call(addr, "lua", "start", redis_conf, current_conf)
end

function cluster_monitor.open()
	skynet.call(addr, "lua", "open")
end

skynet.init(init)

return cluster_monitor
