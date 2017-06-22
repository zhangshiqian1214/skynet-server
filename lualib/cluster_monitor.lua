local skynet = require "skynet"

local addr
local cluster_monitor = {}

local function init()
	addr = skynet.uniqueservice("cluster_monitord")
end

function cluster_monitor.start(redis_conf, current_conf)
	skynet.call(addr, "lua", "start", redis_conf, current_conf)
end

function cluster_monitor.open()
	skynet.call(addr, "lua", "open")
end

skynet.init(init)

return cluster_monitor
