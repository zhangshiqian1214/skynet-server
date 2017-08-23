--[[
	@ filename : watchdog.lua
	@ author   : zhangshiqian1214@163.com
	@ modify   : 2017-08-23 17:53
	@ company  : zhangshiqian1214
]]

local skynet = require "skynet"
local proto_map = require "proto_map"
local socket_msg = require "gate.socket_msg"
local gate_msg = require "gate.gate_msg"
local gate_mgr = require "gate.gate_mgr"


skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, subcmd, ...)
		if cmd == "socket" then
			local f = socket_msg[subcmd]
			f(...)
			-- socket api don't need return
		else
			local f = assert(gate_msg[cmd])
			if session > 0 then
				skynet.retpack(f(subcmd, ...))
			else
				f(subcmd, ...)
			end
		end
	end)
	gate_mgr.init("gate", false)
end)
