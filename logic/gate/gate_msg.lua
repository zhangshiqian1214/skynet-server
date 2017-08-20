local skynet = require "skynet"
local json = require "json"
local gate_mgr = require "gate.gate_mgr"
local sproto_helper = require "sproto_helper"


local gate_msg = {}

--开放网关
function gate_msg.start(conf)
	skynet.call(gate_mgr.get_gate(), "lua", "open", conf)
end

--关闭网关
function gate_msg.close(fd)
	
end

function gate_msg.login_open_switch(isopen)

end

function gate_msg.monitor_node_change(conf)
	if not conf then return end
	if not conf.nodename then return end
	local callback = cluster_monitor.get_subcribe_callback(conf.nodename)
	if not callback then
		return
	end
	return callback(conf)
end

function gate_msg.send_client_msg(fd, buffer)
	if skynet.getenv("websocket_test") and gate_mgr.is_websocket() then
		local header, content = sproto_helper.unpack_header(buffer)
		if not header then
			return
		end
		header.response = 1
		local header, result = sproto_helper.unpack_data(header, content)
		local j_packet = json.encode({header = header, data = result})
		skynet.send(gate_mgr.get_gate(), "lua", "send_buffer", fd, j_packet, true)
		return
	end
	skynet.send(gate_mgr.get_gate(), "lua", "send_buffer", fd, buffer)
end

--暂时不用
function gate_msg.reponse_client_msg(fd, buffer)
	skynet.send(gate_mgr.get_gate(), "lua", "send_buffer", fd, buffer)
end

function gate_msg.login_ok(fd, player_id, agentnode, agentaddr)
	print("gate_msg.login_ok fd=", fd, "player_id=", player_id, "agentnode=", agentnode, "agentaddr=", agentaddr)
	local c = gate_mgr.get_connection(fd)
	if c then
		c.player_id = player_id
		c.agentnode = agentnode
		c.agentaddr = agentaddr
		c.auth_ok = true
	end
end

function gate_msg.login_failure(fd)

end

function gate_msg.kick_player(fd)
	local c = gate_mgr.get_connection(fd)
	skynet.send(gate_mgr.get_gate(), "lua", "kick", fd)
	print("recv gate_msg.kick_player fd=", fd, "c=", table.tostring(c))
end

return gate_msg