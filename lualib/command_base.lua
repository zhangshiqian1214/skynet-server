--
-- Author: Kuzhu1990
-- Date: 2013-12-16 18:52:11
-- 服务调用方法基类
-- 

require("debug")
local skynet = require "skynet"
local profile = require "skynet.profile"
local ti = {}
local command_base = {}


function command_base.run(source, filename, ...)
	local output = {}
	local function print(...)
		local value = {...}
		for k, v in ipairs(value) do
			value[k] = tostring(v)
		end
		table.insert(output, table.concat(value, "\t"))
	end

	local env = setmetatable({print = print, args = {...}}, {__index = _ENV})
	local func, err = load(source, filename, "bt", env)
	if not func then
		return {err}
	end
	local ok, err = xpcall(func, debug.traceback)
	if not ok then
		table.insert(output, err)
	end
end

local function profile_call(func, cmd, ...)
	profile.start()
	local ret1, ret2, ret3, ret4 = func(...)
	local time = profile.stop()
	local p = ti[cmd]
	if p == nil then
		p = { n = 0, ti = 0 }
		ti[cmd] = p
	end
	p.n = p.n + 1
	p.ti = p.ti + time
	return ret1, ret2, ret3, ret4
end

local function dispatch(session, address, cmd, ...)
	local func = assert(command_base[cmd], string.format("command[%s] is nil", cmd))
	if session > 0 then
		skynet.retpack(func(...))
	else
		func(...)
	end
end

skynet.dispatch("lua", dispatch)

skynet.info_func(function()
	return {mem = collectgarbage("count"), ti = ti }
end)

return command_base
