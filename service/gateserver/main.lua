local skynet = require "skynet"
local cluster_monitor = require "cluster_monitor"
local sproto_helper = require "sproto_helper"
local redis_config = require "config.redis_config"
local cluster_config = require "config.cluster_config"

skynet.start(function()

  	local cluster_reids_id = tonumber(skynet.getenv("cluster_redis_id"))
  	local cluster_server_id = tonumber(skynet.getenv("cluster_server_id"))
	cluster_monitor.start(redis_config[cluster_reids_id], cluster_config[cluster_server_id])

	sproto_helper.register_protos()

	local watchdog = skynet.newservice("watchdog")
	skynet.call(watchdog, "lua", "start", {
		port = 5001, 
		maxclient = max_client,
		nodelay = true,
	})

	local wswatchdog = skynet.newservice("wswatchdog")
	skynet.call(wswatchdog, "lua", "start", {
		port = 5002,
		maxclient = max_client,
		nodelay = true,
	})

	cluster_monitor.open()

 	skynet.error("gateserver start ok")

end)