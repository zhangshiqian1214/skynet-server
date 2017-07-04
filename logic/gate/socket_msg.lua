local skynet = require "skynet"
local gate_mgr = require "gate.gate_mgr"
local client_msg = require "gate.client_msg"
local socket_msg = {}

function socket_msg.open(fd, addr)
	local c = {}
	c.fd = fd
	c.ip = addr
	c.agentnode = nil
	c.agentaddr = nil
	gate_mgr.add_connection(fd, c)
	print("recv socket_msg open fd=", fd, "addr=", addr)


end

function socket_msg.close(fd)
	print("recv socket_msg close fd=", fd)

	skynet.send(gate_mgr.get_gate(), "lua", "kick", fd)
end

function socket_msg.error(fd, msg)

end

function socket_msg.warning(fd, size)

end

function socket_msg.data(fd, msg)
	print("recv socket_msg data, fd=", fd, "msg=", msg)


	skynet.send(gate_mgr.get_gate(), "lua", "send_buffer", fd, msg)
end


return socket_msg