local skynet = require "skynet"

local service_base = {}

service_base.name = nil
service_base.modules = {}
service_base.command = require "command_base"
service_base.is_agent = false

local command = service_base.command



return service_base