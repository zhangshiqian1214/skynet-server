--[[
	@ filename : service_base.lua
	@ author   : zhangshiqian1214@163.com
	@ modify   : 2017-08-23 17:53
	@ company  : zhangshiqian1214
]]

local skynet = require "skynet"
local dispatcher = require "dispatcher"
local cluster_monitor = require "cluster_monitor"

local service_base = {}
service_base.name = nil
service_base.modules = {}
service_base.command = require "command_base"
service_base.is_agent = false
dispatcher.service_base = service_base
local command = service_base.command

function command.dispatch_client_msg(ctx, ...)
	return dispatcher.dispatch_client_msg(ctx, ...)
end

function command.dispatch_service_msg(ctx, ...)
	return dispatcher.dispatch_service_msg(ctx, ...)
end

function command.monitor_node_change(conf)
	if not conf then return end
	if not conf.nodename then return end
	local callback = cluster_monitor.get_subcribe_callback(conf.nodename)
	if not callback then
		return
	end
	return callback(conf)
end


function command.gc()

end

function service_base.on_start()

end

function service_base.start()
	skynet.start(function()
		service_base.on_start()
	end)
end

return service_base