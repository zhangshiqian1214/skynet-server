local skynet = require "skynet"
local cluster_monitor = require "cluster_monitor"

skynet.start(function()
	local redis_conf = {
		host = "127.0.0.1" ,
		port = 6379 ,
		db = 0
	}
	local current_conf = { 
			nodename = "node", 
			nodeport = 9002, 
   			intranetip = "127.0.0.1", 
   			extranetip = "127.0.0.1",
  			use_intranet = 1, 
  			serverid = 1, 
  			servertype = 1, 
  			ver = 0 
  	}
	cluster_monitor.start(redis_conf, current_conf)

	-- todo
	local master_db = skynet.newservice("master_db")
	skynet.call(master_db, "lua", "start")

	local svc = skynet.call(master_db, "lua", "get_db_svc", "lobby_db")
	print("svc=", svc)

	cluster_monitor.open()
 	skynet.error("server is start")
end)