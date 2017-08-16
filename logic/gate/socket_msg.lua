local skynet = require "skynet"
local gate_mgr = require "gate.gate_mgr"
local client_msg = require "gate.client_msg"
local sproto_helper = require "sproto_helper"
local json = require "json"
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
	--print("recv socket_msg close fd=", fd)

	--skynet.send(gate_mgr.get_gate(), "lua", "kick", fd)
	gate_mgr.close_connection(fd)
end

function socket_msg.error(fd, msg)

end

function socket_msg.warning(fd, size)

end

local function dispatch_data(c, msg)
	local header, content
	local ok, err = xpcall(function()
		header, content = sproto_helper.unpack_header(msg, #msg)
		if not header then
			gate_mgr.close_connection(c.fd)
			return
		end
		client_msg.dispatch(c, header, msg)
	end, debug.traceback)
	if not ok then
		gate_mgr.close_connection(c.fd)
		error("unpack_header:"..err)
		return
	end
end

function socket_msg.data(fd, msg)
	local c = gate_mgr.get_connection(fd)
	if not c then
		return
	end

	if gate_mgr.is_websocket() then
		if msg == "@heart" then
			return
		end
	end

	--todo with websocket
	if skynet.getenv("websocket_test") then
		print("socket_msg msg=", msg)
		local packet = json.decode(msg)
		local j_header = packet.header
		local j_data = packet.data

		local buffer = sproto_helper.pack(j_header, j_data)

		dispatch_data(c, buffer)
		return
	end

	--todo with socket
	dispatch_data(c, msg)
	--skynet.send(gate_mgr.get_gate(), "lua", "send_buffer", fd, msg)
end


return socket_msg