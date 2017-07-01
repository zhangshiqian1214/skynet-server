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
			nodeport = 9001, 
   			intranetip = "127.0.0.1", 
   			extranetip = "127.0.0.1",
  			use_intranet = 1, 
  			serverid = 1, 
  			servertype = 1, 
  			ver = 0 
  	}
	cluster_monitor.start(redis_conf, current_conf)

	-- todo
	

	cluster_monitor.open()
 	skynet.error("server is start")
end)