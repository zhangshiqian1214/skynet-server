local skynet = require "skynet"


local gate_mgr = {}
local gate
local iswebsocket
local connections = {}
local client_count = 0


function gate_mgr.get_gate()
	return gate
end

function gate_mgr.is_websocket()
	return iswebsocket
end

function gate_mgr.add_connection(fd, c)
	connections[fd] = c
	client_count = client_count + 1
	skynet.call(gate, "lua", "accept", fd)
end

function gate_mgr.get_connection(fd)
	return connections[fd]
end

function gate_mgr.close_connection(fd)
	local c = connections[fd]
	if c then
		connections[fd] = nil
	end
end

function gate_mgr.init(gatename, isws)
	iswebsocket = isws
	gate = skynet.newservice(gatename)
end

return gate_mgr
