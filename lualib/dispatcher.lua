--
-- Author: Kuzhu1990
-- Date: 2013-12-16 18:52:11
-- 服务rpc派发
-- 

local skynet = require "skynet"
local queue = require "skynet.queue"
local cluster = require "skynet.cluster"
local proto_map = require "proto_map"
local sproto_helper = require "sproto_helper"

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


local function _dispatch_client_msg(ctx, header, data)
	local service_base = dispatcher.service_base
	if service_base == nil then
		header.errorcode = SystemError.service_not_impl
		dispatcher.response_client_msg(ctx, header)
		return 
	end

	local proto = proto_map.protos[header.protoid]
	if not proto then
		header.errorcode = SystemError.unknow_proto
		dispatcher.response_client_msg(ctx, header)
		return
	end

	local modname = proto.module
	local funcname = proto.method
	local mod = service_base.modules[modname]
	if mod == nil then
		header.errorcode = SystemError.module_not_impl
		dispatcher.response_client_msg(ctx, header)
		return
	end

	local func = mod[funcname]
	if func == nil then
		header.errorcode = SystemError.func_not_impl
		dispatcher.response_client_msg(ctx, header)
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

	if not ec then
		ec = SystemError.unknow
	elseif ec == SystemError.success and proto.response ~= and reply == nil then
		
	end

	header.errorcode = ec
	dispatcher.response_client_msg(ctx, header, reply)

	return ec, reply
end

local function dispatch_client_msg(ctx, header, data)
	assert(header, "dispatch header is nil")
	local ok, msg = xpcall(function()
		local ec, reply = _dispatch_client_msg(ctx, header, data)
	end, debug.traceback)
	if not ok then
		header.errorcode = SystemError.service_stoped
		dispatcher.response_client_msg(ctx, header, data)
		error("service_stoped:"..msg)
	end
end

function dispatcher.response_client_msg(ctx, header, data)
	local buffer = sproto_helper.pack(header, data)
	if not buffer then
		return
	end
	cluster.call(ctx.gate, ctx.watchdog, "send_client_msg", ctx.fd, buffer)
end

function dispatcher.dispatch_client_msg(ctx, buffer)
	local header, data = sproto_helper.unpack(buffer, #buffer)
	assert(header, "dispatch_client_msg header is nil")
	assert(header.protoid, "dispatch_client_msg protoid is nil")
	dispatch_client_msg(ctx, header, data)
end

function dispatcher.dispatch_service_msg(method, ...)
	local service_base = dispatcher.service_base
	if service_base == nil then
		return SystemError.service_not_impl
	end

	local modname, funcname = string.match(method, "([%w_]+)%.([%w_]+)")
	if not modname or not funcname then
		return SystemError.decode_failure
	end

	local mod = service_base.modules[modname]
	if mod == nil then
		return SystemError.module_not_impl
	end

	local func = mod[funcname]
	if func == nil then
		return SystemError.func_not_impl
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
	dispatch = dispatch_client_msg,
}

return dispatcher

