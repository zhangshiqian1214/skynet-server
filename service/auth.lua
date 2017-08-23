--[[
	@ filename : auth.lua
	@ author   : zhangshiqian1214@163.com
	@ modify   : 2017-08-23 17:53
	@ company  : zhangshiqian1214
]]

require "skynet.manager"
local skynet  = require "skynet"
local service = require "service_base"
local auth_ctrl = require "auth.auth_ctrl"
local auth_impl = require "auth.auth_impl"
local command = service.command

function service.on_start()
	skynet.register(SERVICE.AUTH)
	auth_ctrl.init()
end

service.modules.auth = auth_impl
service.start()