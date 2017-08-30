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
	print("gate_msg.send_client_msg 111 fd=", fd, "#buffer=", #buffer)
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

	local header, content = sproto_helper.unpack_header(buffer)
	if not header then
		return
	end
	header.response = 1
	local header, result = sproto_helper.unpack_data(header, content)
	print("gate_msg.send_client_msg 222 header=", table.tostring(header), "#result=", table.tostring(result))
end

--暂时不用
function gate_msg.reponse_client_msg(fd, buffer)
	skynet.send(gate_mgr.get_gate(), "lua", "send_buffer", fd, buffer)
end

function gate_msg.login_ok(fd, player_id, agentnode, agentaddr)
	-- print("gate_msg.login_ok fd=", fd, "player_id=", player_id, "agentnode=", agentnode, "agentaddr=", agentaddr)
	local c = gate_mgr.get_connection(fd)
	if c then
		c.player_id = player_id
		c.hall_agentnode = agentnode
		c.hall_agentaddr = agentaddr
		c.auth_ok = true
	end
end

function gate_msg.login_failure(fd)
	local c = gate_mgr.get_connection(fd)
	if c then
		c.auth_ok = false
	end
end

function gate_msg.set_agent(fd, agentnode, agentaddr, agentver)
	local c = gate_mgr.get_connection(fd)
	if c then
		c.agentnode = agentnode
		c.agentaddr = agentaddr
		c.agentver = agentver
	end
end

function gate_msg.login_desk(fd, deskaddr)
	local c = gate_mgr.get_connection(fd)
	if c then
		c.deskaddr = deskaddr
	end
end

function gate_msg.logout_desk(fd)
	local c = gate_mgr.get_connection(fd)
	if c then
		c.deskaddr = nil
	end
end

function gate_msg.kick_player(fd)
	local c = gate_mgr.get_connection(fd)
	skynet.send(gate_mgr.get_gate(), "lua", "kick", fd)
end

return gate_msg