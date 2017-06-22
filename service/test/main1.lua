local skynet = require "skynet"
local RedisMQ = require "redis_mq"
local share_memory = require "share_memory"
local cluster_monitor = require "cluster_monitor"

local function testMQ(...)
	print("testMQ message=", ...)
end

skynet.start(function()
	local redis_conf = {
		host = "127.0.0.1" ,
		port = 6379 ,
		db = 0
	}

	local current_conf = { 
			nodename = "node2", 
			nodeport = 9002, 
   			intranetip = "127.0.0.1", 
   			extranetip = "127.0.0.1",
  			use_intranet = 1, 
  			serverid = 2, 
  			servertype = 2, 
  			ver = 0,
  	}

  	cluster_monitor.start(redis_conf, current_conf)
	cluster_monitor.open()

 	skynet.error("server is start")

end)