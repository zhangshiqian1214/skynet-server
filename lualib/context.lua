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
	return context.send(addr, "dispatch_service_request", cmd, ...)
end

function context.call_service(addr, cmd, ...)
	return context.call(addr, "dispatch_service_request", cmd, ...)
end

function context.rpc_send_service(node, addr, cmd, ...)
	return context.rpc_send(node, addr, "dispatch_service_request", cmd, ...)
end

function context.rpc_call_service(node, addr, cmd, ...)
	return context.rpc_call(node, addr, "dispatch_service_request", cmd, ...)
end

return context