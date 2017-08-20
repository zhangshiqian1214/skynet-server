require "skynet.manager"
local skynet = require "skynet"
local service = require "service_base"
local requester = require "requester"
local logger = require "logger"
local command = service.command

function command.test(str)

	logger.debug("recv from node="..str)

	requester.rpc_send("node", ".test", "test_send", "i'm node1, now test send.")

	return "node1 recv ok"
end

function service.on_start()
	skynet.register(".test1")
end


service.start()