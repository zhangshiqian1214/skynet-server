local skynet = require "skynet"
local share_memory = require "share_memory"

local addr
local cluster_monitor = {}
local subscribe_nodes = {}
local all_subscribe = false
local all_subscribe_cb = nil

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

function cluster_monitor.subscribe_node(callback, nodename)
	if nodename == nil then
		all_subscribe = true
		all_subscribe_cb = callback
	else
		subscribe_nodes[nodename] = callback
	end
	
	skynet.call(addr, "lua", "subscribe_monitor", skynet.self())

end

function cluster_monitor.unsubscribe_node(nodename)
	if nodename == nil then
		all_subscribe = false
		all_subscribe_cb = nil
		return
	end

	if subscribe_nodes[nodename] then
		subscribe_nodes[nodename] = nil
	end

	if not all_subscribe and table.empty(subscribe_nodes) then
		skynet.call(addr, "lua", "unsubscribe_monitor", skynet.self())
	end
end

function cluster_monitor.get_subcribe_callback(nodename)
	if nodename == nil and all_subscribe == true then
		return all_subscribe_cb
	elseif nodename and subscribe_nodes[nodename] then
		return subscribe_nodes[nodename]
	end
	return nil
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
