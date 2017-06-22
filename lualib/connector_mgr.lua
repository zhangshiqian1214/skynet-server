--
-- Author: Kuzhu1990
-- Date: 2013-12-16 18:52:11
-- 连接管理
-- 

local skynet    = require "skynet"
local Connector = require "connector"

local connector_mgr = {}
local connector_map = {}

function connector_mgr.create_connector()
	return Connector()
end

function connector_mgr.get_connector(name)
	return connector_map[name]
end

function connector_mgr.set_connector(name, connector)
	connector_map[name] = connector
end

function connector_mgr.get_connectors()
	return connector_map
end

function connector_mgr._connector_connect()

end

function connector_mgr._connector_check_alive()

end

function connector_mgr._connect_callback()

end

function connector_mgr._disconnect_callback()

end

return connector_mgr