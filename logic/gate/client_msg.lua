local skynet = require "skynet"
local json = require "json"
local proto_map = require "proto_map"
local cluster_monitor = require "cluster_monitor"
local context = require "context"
local gate_mgr = require "gate.gate_mgr"
local sproto_helper = require "sproto_helper"
local client_msg = {}

function client_msg.get_context(c)
	local ctx = {}
	ctx.gate = cluster_monitor.get_current_nodename()
	ctx.watchdog = skynet.self()
	ctx.is_websocket = gate_mgr.is_websocket()
	ctx.fd = c.fd
	ctx.ip = c.ip
	ctx.session = c.session
	ctx.player_id = c.player_id
	return ctx
end

function client_msg.dispatch(c, header, msg)
	if not header or not header.protoid then
		return
	end

	local proto = proto_map.protos[header.protoid]
	if not proto then
		header.errorcode = SYSTEM_ERROR.unknow_proto
		client_msg.send(c.fd, header)
		return
	end
	--print("dispatch proto=", table.tostring(proto))

	if proto.type ~= PROTO_TYPE.C2S then
		header.errorcode = SYSTEM_ERROR.invalid_proto
		client_msg.send(c.fd, header)
		return
	end

	if proto.service and proto.service ~= SERVICE.AUTH and not c.auth_ok then
		header.errorcode = SYSTEM_ERROR.no_auth_account
		client_msg.send(c.fd, header)
		-- print("dispatch proto.service=", proto.service, "c.auth_ok=", c.auth_ok)
		return
	end

	if proto.server == SERVER.GAME and not header.roomproxy then
		header.errorcode = SYSTEM_ERROR.unknow_roomproxy
		client_msg.send(c.fd, header)
		return
	end

	if not proto.service and not c.agentnode and not c.agentaddr then
		header.errorcode = SYSTEM_ERROR.no_login_game
		-- print("dispatch proto.service=", proto.service, "c.agentnode=", c.agentnode, "c.agentaddr=", c.agentaddr)
		client_msg.send(c.fd, header)
		return
	end

	local rpc_err
	local ctx = client_msg.get_context(c)

	--非游戏服务
	if proto.service then
		if proto.service == SERVICE.ROOM then
			rpc_err = context.rpc_call(header.roomproxy, SERVICE.ROOM, "dispatch_client_msg", ctx, msg)
		else
			local target_node = cluster_monitor.get_cluster_node_by_server(proto.server)
			if not target_node then
				header.errorcode = SYSTEM_ERROR.service_maintance
				client_msg.send(c.fd, header)
				return
			end
			rpc_err = context.rpc_call(target_node.nodename, proto.service, "dispatch_client_msg", ctx, msg)
		end
		
	else
		rpc_err = context.rpc_call(c.agentnode, c.agentaddr, "dispatch_client_msg", ctx, msg)
	end

	if rpc_err ~= RPC_ERROR.success then
		header.errorcode = SYSTEM_ERROR.service_stoped
		client_msg.send(c.fd, header)
		return
	end
end

function client_msg.send(fd, header, data)
	if skynet.getenv("websocket_test") and gate_mgr.is_websocket() then
		local j_packet = json.encode({header = header, data = data})
		skynet.send(gate_mgr.get_gate(), "lua", "send_buffer", fd, j_packet, true)
		return
	end

	local buffer = sproto_helper.pack(header, data)
	if buffer then
		skynet.send(gate_mgr.get_gate(), "lua", "send_buffer", fd, buffer)
	end
end

return client_msg