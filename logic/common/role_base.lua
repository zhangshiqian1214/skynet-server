--
-- Author: Kuzhu1990
-- Date: 2017-12-16 18:52:11
-- 有序的玩家类
-- 

local class = require "class"
local skynet = require "skynet"
local session_base = require "session_base"
local role_base = class()

function role_base:_init()
	self._session = session_base()
end

function role_base:dispatch(method, ctx, req)
	local func = self[method]
	if not func then
		return
	end
	return self._session:dispatch(func, self, ctx, req)
end

return role_base