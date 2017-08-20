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