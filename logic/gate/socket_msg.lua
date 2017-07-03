local skynet = require "skynet"
local gate_mgr = require "gate.gate_mgr"
local socket_msg = {}

function socket_msg.open(fd, addr)
	local c = {}
	c.fd = fd
	c.ip = addr
	c.agentnode = nil
	c.agentaddr = nil
	gate_mgr.add_connection(fd, c)
end

function socket_msg.close(fd)
	
end

function socket_msg.error(fd, msg)

end

function socket_msg.warning(fd, size)

end

function socket_msg.data(fd, msg)
	
end


return socket_msg