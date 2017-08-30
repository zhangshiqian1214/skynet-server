--[[
	@ filename : requester.lua
	@ author   : zhangshiqian1214@163.com
	@ modify   : 2017-08-23 17:53
	@ company  : zhangshiqian1214
]]

local skynet = require "skynet"
local cluster = require "skynet.cluster"
local cluster_monitor = require "cluster_monitor"
local logger = require "logger"
local sproto_helper = require "sproto_helper"
local requester = {}

function requester.call(service, cmd, ...)
	return skynet.call(service, "lua", cmd, ...)
end

function requester.send(service, cmd, ...)
	skynet.send(service, "lua", cmd, ...)
end

function requester.rpc_call(node, service, cmd, ...)
	if not node then
		return RPC_ERROR.node_nil
	end

	if not service then
		return RPC_ERROR.service_nil
	end

	local nodeconf = cluster_monitor.get_cluster_node(node)
	if not nodeconf then
		return RPC_ERROR.node_offline
	end

	local rets
	local args = {...}
	local ok, msg = xpcall(function()
		rets = table.pack(cluster.call(node, service, cmd, table.unpack(args)))
	end, debug.traceback)
	if not ok then
		logger.fatalf("rpc_call fatal, node[%s] err:%s", tostring(node), msg)
		--assert(false, string.format("rpc_call fatal, node[%s] err:%s", tostring(node), msg))
		return RPC_ERROR.service_stoped
	end
	
	if rets then
		rets = table.unpack(rets)
	end
	return RPC_ERROR.success, rets
end

function requester.rpc_send(node, service, cmd, ...)
	if not node then
		return RPC_ERROR.node_nil
	end

	if not service then
		return RPC_ERROR.service_nil
	end

	local nodeconf = cluster_monitor.get_cluster_node(node)
	if not nodeconf then
		return RPC_ERROR.node_offline
	end

	local args = {...}
	local ok, msg = xpcall(function()
		cluster.send(node, service, cmd, table.unpack(args))
	end, debug.traceback)
	if not ok then
		return RPC_ERROR.service_stoped
	end
	return RPC_ERROR.success
end

function requester.send_client_msg(ctx, proto, header, data)
	if not ctx or not proto then
		return
	end
	header = header or {}
	header.protoid = proto.id
	local buffer = sproto_helper.pack(header, data)
	if not buffer then
		print("send_client_msg proto=", table.tostring(proto), "data=", table.tostring(data))
		return
	end
	requester.rpc_call(ctx.gate, ctx.watchdog, "send_client_msg", ctx.fd, buffer)
end


return requester