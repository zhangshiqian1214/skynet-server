local skynet = require "skynet"
local gate_mgr = require "gate.gate_mgr"

local gate_msg = {}

function gate_msg.start(conf)
	skynet.call(gate_mgr.get_gate(), "lua", "open", conf)
end

function gate_msg.close(fd)
	
end


return gate_msg