--
-- Author: Kuzhu1990
-- Date: 2013-12-16 18:52:11
-- 服务rpc调用
-- 

local skynet = require "skynet"
local cluster = require "skynet.cluster"
local cluster_monitor = require "cluster_monitor"
local logger = require "logger"
local requester = {}

function requester.call(service, cmd, ...)
	return skynet.call(service, "lua", cmd, ...)
end

function requester.send(service, cmd, ...)
	skynet.send(service, "lua", cmd, ...)
end

function requester.rpc_call(node, service, cmd, ...)
	if not node or not service then
		return RPC_ERROR.ARGUMENT_NIL
	end

	local nodeconf = cluster_monitor.get_cluster_node(node)
	if not nodeconf then
		return RPC_ERROR.NODE_OFFLINE
	end

	local rets
	local args = {...}
	local ok, msg = xpcall(function()
		rets = table.pack(cluster.call(node, service, cmd, table.unpack(args)))
	end, debug.traceback)
	if not ok then
		logger.fatalf("rpc_call fatal, node[%s] err:%s", tostring(node), msg))
		--assert(false, string.format("rpc_call fatal, node[%s] err:%s", tostring(node), msg))
		return RPC_ERROR.CALL_FAILED
	end
	
	if not rets then
		return RPC_ERROR.OK
	end
	return RPC_ERROR.OK, table.unpack(rets)
end

function requester.rpc_send(node, service, cmd, ...)
	if not node or not service then
		return RPC_ERROR.ARGUMENT_NIL
	end

	local nodeconf = cluster_monitor.get_cluster_node(node)
	if not nodeconf then
		return RPC_ERROR.NODE_OFFLINE
	end

	local ok, msg = xpcall(function()
		cluster.send(node, service, cmd, ...)
	end, debug.traceback)
	if not ok then
		return RPC_ERROR.CALL_FAILED
	end
	return RPC_ERROR.OK
end

function requester.send_to_client(ctx, proto, header, data)
	if not ctx or not proto then
		return
	end
	if not header then
		header = {}
		header.proto_id = proto.id
	end
	requester.rpc_call(ctx.gate, ctx.watchdog, "send_to_client", ctx, header, data)
end


return requester