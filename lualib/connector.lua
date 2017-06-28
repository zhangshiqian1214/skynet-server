--
-- Author: Kuzhu1990
-- Date: 2013-12-16 18:52:11
-- 连接器, 用于主动连接
-- 

local class = require "class"
local skynet = require "skynet"
local coroutine = require "skynet.coroutine"

CONNECT_NONE = 0 --未连接状态
CONNECT_OK   = 2 --连接成功

local connector = class()
function connector:_init()
	self._connect_status = CONNECT_NONE
	self._useable = true
	self._reconnect_wait = 3
	self._connect_conf = nil
	self._connect_func = nil
	self._check_disconnect_func = nil
	self._connect_cb = nil
	self._disconnect_cb = nil
	self._co = nil
end

function connector:set_connect_conf(conf)
	self._connect_conf = conf
end

function connector:set_connect_func(connect_func)
	self._connect_func = connect_func
end

function connector:set_check_disconnect_fun(check_disconnect_func)
	self._check_disconnect_func = check_disconnect_func
end

function connector:set_connect_callback(connect_cb)
	self._connect_cb = connect_cb
end

function connector:set_disconnect_callback(disconnect_cb)
	self._disconnect_cb = disconnect_cb
end

function connector:set_status_connected()
	self._connect_status = CONNECT_OK
end

function connector:set_status_disconnect()
	self._connect_status = CONNECT_NONE
end

function connector:is_useable()
	return self._useable == true
end

function connector:is_connected()
	return self._connect_status == CONNECT_OK
end

function connector:get_connect_conf()
	return self._connect_conf
end

function connector:stop()
	self._useable = false
	if self._thread then
		self._thread = nil
	end
end

function connector:connect()
	local ret
	local ok, msg = xpcall(function()
		ret = self._connect_func(self._connect_conf)
	end, debug.traceback)
	if not ok or not ret then
		return false
	end

	self:set_status_connected()
	if self._connect_cb then
		pcall(self._connect_cb, self._connect_conf)
	end

	return true
end

function connector:check_disconnect()
	local ok, msg = xpcall(function()
		self._check_disconnect_func(self._connect_conf)
	end, debug.traceback)
	if not ok then
		if self:is_connected() and self._disconnect_cb then
			pcall(self._disconnect_cb, self._connect_conf)
		end

		self:set_status_disconnect()
		return false
	end

	return true
end

function connector:start()
	self._useable = true
	skynet.fork(function()
		self._thread = coroutine.running()
		while self:is_useable() and self._thread == coroutine.running() do
			if not self:connect() then
				skynet.sleep(self._reconnect_wait * 100)
			else
				self:check_disconnect()
			end
		end
	end)
end

function connector:reset()
	self._connect_status = CONNECT_NONE
	self._useable = false
	self._reconnect_wait = 3
	self._connect_conf = nil
	self._connect_func = nil
	self._check_disconnect_func = nil
	self._connect_cb = nil
	self._disconnect_cb = nil
	self._co = nil
end

return connector