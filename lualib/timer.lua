--[[
	@ filename : timer.lua
	@ author   : zhangshiqian1214@163.com
	@ modify   : 2017-08-23 17:53
	@ company  : zhangshiqian1214
]]

local skynet = require "skynet"
local class = require "class"

local timer = class()

function timer:_init(func, class_obj)
	self._taskid = 0
	self._expire_time = 0
	self._repeat_count = 0
	self._func = func
	self._class_obj = obj
	self._args = {}
	self._on_expire = function(taskid)
		if taskid ~= self._taskid then
			return
		end
		if not self._func then
			return
		end
		if self._repeat_count == 0 then
			self._expire_time = 0
			self._args = {}
			return
		end

		if self._repeat_count > 0 then
			self._repeat_count = self._repeat_count - 1
		end
		if self._class_obj then
			self._func(self._class_obj, table.unpack(self._args))
		else
			self._func(table.unpack(self._args))
		end

		if self._repeat_count == 0 then
			self._args = {}
			self._expire_time = 0
		else
			skynet.timeout(self._expire_time * 100, function() self._on_expire(taskid) end)
		end

	end
end

function timer:run_every(second, count, ...)
	if not self:is_canceled() then
		return nil
	end
	if not count or count < 0 then
		self._repeat_count = -1
	else
		self._repeat_count = count
	end
	self._taskid = self._taskid + 1
	self._expire_time = second
	self._args = table.pack(...)
	skynet.timeout(second * 100, function() self._on_expire(self._taskid) end)
	return self._taskid
end

function timer:run_after(second, ...)
	if not self:is_canceled() then
		return nil
	end
	self._taskid = self._taskid + 1
	self._expire_time = second
	self._repeat_count = 1
	self._args = table.pack(...)
	skynet.timeout(second * 100, function() self._on_expire(self._taskid) end)
	return self._taskid
end

function timer:cancel()
	if self._repeat_count == 0 then
		return
	end
	self._repeat_count = 0
	self._args = {}
	self._expire_time = 0
end

function timer:is_canceled()
	return self._repeat_count == 0
end

return timer