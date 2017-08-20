require "skynet.manager"
local skynet = require "skynet"
local service = require "service_base"
local requester = require "requester"
local logger = require "logger"
local command = service.command

function command.test_send(str)
	logger.debug(str)
end

function service.on_start()
	skynet.register(".test")
	skynet.fork(function()
		skynet.sleep(2 * 100)
		for i = 1, 10 do
			print(requester.rpc_call("node1", ".test1", "test", "this is test, I'm node"))
			skynet.sleep(2 * 100)
		end
	end)
end


service.start()