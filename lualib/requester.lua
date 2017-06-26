local skynet = require "skynet"
local cluster = require "skynet.cluster"

local requester = {}

function requester.call(service, cmd, ...)
	return skynet.call(service, "lua", cmd, ...)
end

function requester.send(service, cmd, ...)
	skynet.send(service, "lua", cmd, ...)
end

function requester.rpc_call(node, service, cmd, ...)
	if not node then
		return
	end

	if not service then
		return
	end

	local rets
	local args = {...}
	local ok, msg = xpcall(function()
		rets = table.pack(cluster.call(node, service, cmd, table.unpack(args)))
	end)
	if not ok then
		error(msg)
	end
	if not rets then
		return
	end
	return table.unpack(rets)
end

function requester.rpc_send(node, service, cmd, ...)
if not node then
		return
	end

	if not service then
		return
	end

	cluster.send(node, service, cmd, ...)
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