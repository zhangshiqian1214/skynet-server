local class = require "class"
local skynet = require "skynet"
local queue = require "skynet.queue"
local requester = require "requester"
local cluster_monitor = require "cluster_monitor"
local session_base = class()


function session_base:_init()
	self._ctx = nil
	self._is_agent = false
	self._cs = queue()
	self._dbnode = nil
	self._dbserv = nil
end

function session_base:update_ctx(ctx)
	self._ctx = ctx
end

function session_base:get_robin_db_addr()
	if self._dbnode and self._dbserv then
		return self._dbnode, self._dbserv
	end
	self._dbnode = nil
	self._dbserv = nil
	local nodes = cluster_monitor.get_cluster_nodes()
	for nodename, v in pairs(nodes) do
		local rpc_err, serv = requester.rpc_call(nodename, SERVICE.MASTER_DB, "get_db_svc")
		if rpc_err == RPC_ERROR.OK and serv then
			self._dbnode = nodename
			self._dbserv = serv
			break
		end
	end
	return self._dbnode, self._dbserv
end

function session_base:call_db(method, ...)
	if not self._dbnode or not self._dbserv then
		return 
	end
	local rpc_err, ... = requester.rpc_call(self._dbnode, self._dbserv, method, ...)
	if rpc_err ~= RPC_ERROR.OK then
		return
	end
	return ...
end

function session_base:send_db(method, ...)
	if not self._dbnode or not self._dbserv then
		return 
	end
	requester.rpc_send(self._dbnode, self._dbserv, method, ...)
end

function session_base:_queue_func(rets, func, obj, ctx, req)
	local ok, msg = xpcall(function()
		rets[1], rets[2] = func(obj, ctx, req)
	end, debug.traceback)
	if not ok then
		error(msg)
	end
end

function session_base:dispatch(func, obj, ctx, req)
	local rets = {}
	self._cs(self._queue_func, self, rets, func, obj, ctx, req)
	return rets[1], rets[2]
end


return session_base