local skynet = require "skynet"

local gate_msg = {}

function CMD.start(conf)
	skynet.call(gate, "lua", "open", conf)
end

function CMD.close(fd)
	
end


return gate_msg