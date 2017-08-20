require "skynet.manager"
local skynet  = require "skynet"
local service = require "service_base"
local room_ctrl = require "room.room_ctrl"
local room_impl = require "room.room_impl"
local command = service.command

function service.on_start()
	skynet.register(SERVICE.ROOM)
	room_ctrl.init()
end

service.modules.room = room_impl
service.start()