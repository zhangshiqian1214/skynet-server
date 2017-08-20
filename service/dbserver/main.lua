local skynet = require "skynet"
local sproto_helper = require "sproto_helper"
local cluster_monitor = require "cluster_monitor"
local redis_config = require "config.redis_config"
local cluster_config = require "config.cluster_config"

skynet.start(function()
	--nodemonitor
	local cluster_reids_id = tonumber(skynet.getenv("cluster_redis_id"))
  	local cluster_server_id = tonumber(skynet.getenv("cluster_server_id"))
	cluster_monitor.start(redis_config[cluster_reids_id], cluster_config[cluster_server_id])

	--spb
	sproto_helper.register_protos()

	-- todo
	local master_db = skynet.newservice("master_db")
	skynet.call(master_db, "lua", "start")

	local svc = skynet.call(master_db, "lua", "get_db_svc", "lobby_db")
	

	cluster_monitor.open()
 	skynet.error("server is start")
end)