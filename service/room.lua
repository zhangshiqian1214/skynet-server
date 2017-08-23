--[[
	@ filename : room.lua
	@ author   : zhangshiqian1214@163.com
	@ modify   : 2017-08-23 17:53
	@ company  : zhangshiqian1214
]]

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