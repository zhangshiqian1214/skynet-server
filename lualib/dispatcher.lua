--
-- Author: Kuzhu1990
-- Date: 2013-12-16 18:52:11
-- 服务rpc派发
-- 

local skynet = require "skynet"
local queue = require "skynet.queue"
local cluster = require "skynet.cluster"
local proto_map = require "proto_map"


local cs = queue()
local dispatcher = {}
dispatcher.service_base = nil

local function queue_func(ret, func, ctx, data)
	local ok, msg = xpcall(function()
		local ret1, ret2 = func(ctx, data)
		ret[1] = ret1
		ret[2] = ret2
	end, debug.traceback)
	if not ok then
		error(msg)
	end
end

local function call_func(func, ctx, data)
	local ret1, ret2
	local ok, msg = xpcall(function()
		ret1, ret2 = func(ctx, data)
	end, debug.traceback)
	if not ok then
		error(msg)
	end
	return ret1, ret2
end

local function response(ctx, header, data)
	cluster.call(ctx.gate, ctx.watchdog, "response", ctx, header, data)
end

local function dispatch_client_request(ctx, header, data)
	local service_base = dispatcher.service_base
	if service_base == nil then
		return 
	end

	local header, data = dispatcher.unpack(buffer)
	if not header then
		return
	end

	local proto = proto_map.protos[header.proto_id]
	if not proto then
		
	end

	local modname = proto.module
	local funcname = proto.method
	local mod = service_base.modules[modname]
	if mod == nil then
		return
	end

	local func = mod[funcname]
	if func == nil then
		return
	end

	local ec, reply
	if service_base.is_agent then
		local ret = {}
		cs(lockFunc, ret, func, ctx, data)
		ec = ret[1]
		reply = ret[2]
	else
		ec, reply = call_func(func, ctx, data)
	end

	return ec, ret
end

function dispatcher.pack()

end

function dispatcher.unpack()

end

function dispatcher.dispatch_client_request(ctx, buffer)
	
end

function dispatcher.dispatch_service_request(method, ...)
	local service_base = dispatcher.service_base
	if service_base == nil then
		return 
	end

	local modname, funcname = string.match(method, "([%w_]+)%.([%w_]+)")
	if not modname or not funcname then
		return
	end

	local mod = service_base.modules[modname]
	if mod == nil then
		return
	end

	local func = mod[funcname]
	if func == nil then
		return
	end

	local ec, reply
	if service_base.is_agent then
		local ret = {}
		cs(lockFunc, ret, func, ctx, data)
		ec = ret[1]
		reply = ret[2]
	else
		ec, reply = call_func(func, ctx, data)
	end

	if ec == nil then
		ec = SystemError.unknow
	end
	return ec, reply
end

skynet.register_protocol {
	name     = "client",
	id       = skynet.PTYPE_CLIENT,
	pack     = dispatcher.pack,
	unpack   = dispatcher.unpack,
	dispatch = dispatch_client_request,
}

return dispatcher

