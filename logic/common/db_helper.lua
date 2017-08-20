local skynet = require "skynet"
local context = require "context"
local cluster_monitor = require "cluster_monitor"
local db_config = require "config.db_config"

local db_helper = {}

local db_node = nil
local svc_map = {}

local function get_db_node()
	if not db_node then
		local node = cluster_monitor.get_cluster_node_by_server(SERVER.DB)
		db_node = node.nodename
	end
	return db_node
end

local function get_db_svc(dbname, id)
	if db_node and svc_map[dbname] then
		return db_node, svc_map[dbname]
	end

	local nodename = get_db_node()
	if not nodename then
		return nil
	end
	
	local conf = db_config[dbname]
	if not conf then
		return nil
	end

	if conf.get_svc == GET_SVC_TYPE.unique then
		svc_map[dbname] = conf.service_name
		return nodename, svc_map[dbname]
	elseif conf.get_svc == GET_SVC_TYPE.robin then
		local rpc_err, svc = context.rpc_call(nodename, SERVICE.MASTER_DB, "get_db_svc", dbname)
		if rpc_err ~= RPC_ERROR.success then
			return nil
		end
		svc_map[dbname] = svc
		return nodename, svc_map[dbname]
	elseif conf.get_svc == GET_SVC_TYPE.player_id then
		if not id then return nil end
		local index = id % conf.svc_count
		if index == 0 then index = conf.svc_count end
		svc_map[dbname] = conf.service_name..index
		return nodename, svc_map[dbname]
	end
	return nil
end

function db_helper.call(dbname, method, id, ...)
	local nodename, svc = get_db_svc(dbname, id)
	if not nodename or not svc then
		return nil
	end
	local rpc_err, ret = context.rpc_call(nodename, svc, method, id, ...)
	if rpc_err ~= RPC_ERROR.success then
		error(string.format("db_helper.call err dbname[%s] method[%s] id[%s]", dbname, method, tostring(id)))
	end
	return ret
end

function db_helper.send(dbname, method, id, ...)
	local nodename, svc = get_db_svc(dbname, id)
	if not nodename or not svc then
		return nil
	end
	local rpc_err = context.rpc_send(nodename, svc, method, id, ...)
	if rpc_err ~= RPC_ERROR.success then
		error(string.format("db_helper.send err dbname[%s] method[%s] id[%s]", dbname, method, tostring(id)))
	end
end

return db_helper
