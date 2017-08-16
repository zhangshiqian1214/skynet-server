local skynet = require "skynet"
local json = require "json"
local gate_mgr = require "gate.gate_mgr"
local sproto_helper = require "sproto_helper"


local gate_msg = {}

function gate_msg.start(conf)
	skynet.call(gate_mgr.get_gate(), "lua", "open", conf)
end

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
	if skynet.getenv("websocket_test") then
		local header, data = sproto_helper.unpack(buffer)
		if not header then
			return
		end
		local j_packet = json.encode({header = header, data = data})
		skynet.send(gate_mgr.get_gate(), "lua", "send_buffer", fd, j_packet, true)
		return
	end

	skynet.send(gate_mgr.get_gate(), "lua", "send_buffer", fd, buffer)
end

--暂时不用
function gate_msg.reponse_client_msg(fd, buffer)
	skynet.send(gate_mgr.get_gate(), "lua", "send_buffer", fd, buffer)
end

function gate_msg.auth_ok(fd, roleid)

end

function gate_msg.auth_failure(fd)

end

function gate_msg.bind_agent(fd, agentnode, agentaddr)

end

return gate_msg