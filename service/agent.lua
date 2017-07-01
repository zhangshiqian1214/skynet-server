local skynet = require "skynet"
local service = require "service_base"
local agent_ctrl = require "agent.agent_ctrl"
service.is_agent = true


local command = service.command


function service.on_start()

end

service.start()