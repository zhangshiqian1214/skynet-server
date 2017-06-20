--
-- Author: Kuzhu1990
-- Date: 2013-12-16 18:52:11
-- 连接器, 用于主动连接
-- 

local class = require "class"
local skynet = require "skynet"


CONNECT_NONE = 0 --未连接状态
CONNECT_OK   = 2 --连接成功

local Connector = class()
function Connector:_init()
	self._connect_status = CONNECT_NONE
	self._useable = true
	self._reconnect_wait = 3
	self._connect_conf = nil
	self._connect_func = nil
	self._check_alive_func = nil
	self._connect_cb = nil
	self._disconnect_cb = nil
end


function Connector:set_connect_conf(conf)
	self._connect_conf = conf
end

function Connector:set_connect_func(connect_func)
	self._connect_func = connect_func
end

function Connector:set_check_alive_fun(check_alive_func)
	self._check_alive_func = check_alive_func
end

function Connector:set_connect_callback(connect_cb)
	self._connect_cb = connect_cb
end

function Connector:set_disconnect_callback(disconnect_cb)
	self._disconnect_cb = disconnect_cb
end

function Connector:set_status_connected()
	self._connect_status = CONNECT_OK
end

function Connector:set_status_disconnect()
	self._connect_status = CONNECT_NONE
end

function Connector:is_useable()
	return self._useable == true
end

function Connector:is_connected()
	return self._connect_status == CONNECT_OK
end

function Connector:get_connect_conf()
	return self._connect_conf
end

function Connector:stop()
	self._useable = false
end

function Connector:connect()
	local ret
	local ok, msg = xpcall(function()
		ret = self._connect_func(self._connect_conf)
	end, debug.traceback)
	if not ok or not ret then
		self:set_status_disconnect()

		if self:is_connected() and self._disconnect_cb then
			pcall(self._disconnect_cb, self._connect_conf)
		end
		
		return false
	end

	self:set_status_connected()

	if self._connect_cb then
		pcall(self._connect_cb, self._connect_conf)
	end

	return true
end

function Connector:check_alive()

	local ok, msg = xpcall(function()
		self._check_alive_func(self._connect_conf)
	end, debug.traceback)
	if not ok then
		self:set_status_disconnect()

		if self:is_connected() and self._disconnect_cb then
			pcall(self._disconnect_cb, self._connect_conf)
		end

		return false
	end

	--永不返回,若返回则是状态变了
	self:set_status_disconnect()
	if self._disconnect_cb then
		pcall(self._disconnect_cb, self._connect_conf)
	end

	return true
end

function Connector:start()

	self._useable = true

	skynet.fork(function()
		while self:is_useable() do
			if not self:connect() then
				skynet.sleep(self._reconnect_wait * 100)
			else
				self:check_alive()
			end
		end

	end)
end

return Connector