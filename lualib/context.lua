--[[
	@ filename : context.lua
	@ author   : zhangshiqian1214@163.com
	@ modify   : 2017-08-23 17:53
	@ company  : zhangshiqian1214
]]


local skynet = require "skynet"
local requester = require "requester"
local context = {}


function context.call(addr, cmd, ...)
	return requester.call(addr, cmd, ...)
end

function context.send(addr, cmd, ...)
	return requester.send(addr, cmd, ...)
end

function context.rpc_call(node, addr, cmd, ...)
	return requester.rpc_call(node, addr, cmd, ...)
end

function context.rpc_send(node, addr, cmd, ...)
	return requester.rpc_send(node, addr, cmd, ...)
end

function context.send_service(addr, cmd, ...)
	return requester.send(addr, "dispatch_service_msg", cmd, ...)
end

function context.call_service(addr, cmd, ...)
	return requester.call(addr, "dispatch_service_msg", cmd, ...)
end

function context.rpc_send_service(node, addr, cmd, ...)
	return requester.rpc_send(node, addr, "dispatch_service_msg", cmd, ...)
end

function context.rpc_call_service(node, addr, cmd, ...)
	return requester.rpc_call(node, addr, "dispatch_service_msg", cmd, ...)
end

function context.send_client_event(ctx, proto, data)
	return requester.send_client_msg(ctx, proto, nil, data)
end

function context.response_client(ctx, proto, data)
	return requester.send_client_msg(ctx, proto, {session = ctx.request_id, proto_id = proto.id}, data)
end

return context