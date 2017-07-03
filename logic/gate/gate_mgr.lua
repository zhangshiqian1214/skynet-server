local skynet = require "skynet"


local gate_mgr = {}
local gate
local connections = {}
local client_count = 0

function gate_mgr.get_gate()
	return gate
end

function gate_mgr.add_connection(fd, c)
	connections[fd] = c
	client_count = client_count + 1
	skynet.call(gate, "lua", "accept", fd)
end

function gate_mgr.get_connection(fd)
	return connections[fd]
end

function gate_mgr.init(gatename)
	gate = skynet.newservice(gatename)
end

return gate_mgr
