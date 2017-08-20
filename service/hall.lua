require "skynet.manager"
local skynet  = require "skynet"
local service = require "service_base"
local hall_ctrl = require "hall.hall_ctrl"
local hall_impl = require "hall.hall_impl"
local command = service.command

function command.cast_login(ctx, player_info)
	return hall_ctrl.cast_login(ctx, player_info)
end

function command.cast_logout(ctx)
	return hall_ctrl.cast_logout(ctx)
end

function service.on_start()
	skynet.register(SERVICE.HALL)
	hall_ctrl.init()
end

service.modules.hall = hall_impl
service.start()