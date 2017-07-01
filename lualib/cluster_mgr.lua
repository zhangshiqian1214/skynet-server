--
-- Author: Kuzhu1990
-- Date: 2013-12-16 18:52:11
-- 集群节点管理
-- 

local json = require "json"
local skynet = require "skynet"
local cluster = require "skynet.cluster"
local redis_mq = require "redis_mq"
local connector = require "connector"
local share_memory = require "share_memory"

local cluster_mgr = {}
local redis_msg = {}
local _redis_mq = nil
local _redis_conf  = nil
local _current_conf = nil
local _connector_map = {}
local _subscribe_cluster_map = {}

local function on_redis_publish(key, data)
	assert(key, "key is nil")
	local method = string.match(key, "cluster_mgr.([%w_]+)")
	assert(method, "method is nil")
	local func = redis_msg[method]
	if not func then
		return
	end
	local conf = json.decode(data)
	func(conf)
	return
end

local function publish_redis_message(key, data)
	assert(_redis_mq, "_redis_mq is nil")
	_redis_mq:publish(key, data)
end

--主动连接函数
local function _connect_func(conf)
	assert(conf, "conf is nil")
	-- assert(conf.nodename ~= _current_conf.nodename)
	local current_conf = cluster_mgr.get_current_conf()
	return cluster.call(conf.nodename, SERVICE.CLUSTER_MONITOR, "connect", current_conf)
end

--主动掉线检测
local function _check_disconnect_func(conf)
	assert(conf, "conf is nil")
	local current_conf = cluster_mgr.get_current_conf()
	cluster.call(conf.nodename, SERVICE.CLUSTER_MONITOR, "check_alive", current_conf)
end

--连接成功回调
local function _connect_callback(conf)
	print("_connect_callback nodename=", conf.nodename)

	for addr, _ in pairs(_subscribe_cluster_map) do
		skynet.call(addr, "lua", "monitor_node_change", conf)
	end
end

--断开连接回调
local function _disconnect_callback(conf)
	print("_disconnect_callback nodename=", conf.nodename)

	for addr, _ in pairs(_subscribe_cluster_map) do
		skynet.call(addr, "lua", "monitor_node_change", conf)
	end
end

-------------------redis msg-----------------------

function redis_msg.add_cluster_node(conf)
	print("recv redis add_cluster_node message nodename=", conf.nodename)

	cluster_mgr.cache_cluster_conf(conf)
	cluster_mgr.reload_cluster_conf()
	cluster_mgr.reset_connectors()

end

function redis_msg.remove_cluster_node(conf)
	print("recv redis remove_cluster_node message nodename=", conf.nodename)

	cluster_mgr.remove_cluster_conf(conf)
	cluster_mgr.reload_cluster_conf()
	cluster_mgr.reset_connectors()
end


--------------------cluster_mgr---------------------

function cluster_mgr.set_current_conf(conf)
	_current_conf = conf
end

function cluster_mgr.get_current_conf()
	return _current_conf
end

function cluster_mgr.set_redis_conf(conf)
	_redis_conf = conf
end

function cluster_mgr.get_redis_conf()
	return _redis_conf
end

function cluster_mgr.set_connector(name, conn)
	_connector_map[name] = conn
end

function cluster_mgr.get_connector(name)
	return _connector_map[name]
end

-------------------subscribe------------------------
--nodename is nil so subscribe all nodes
function cluster_mgr.subscribe_monitor(addr)
	_subscribe_cluster_map[addr] = true
end

function cluster_mgr.unsubscribe_monitor(addr)
	_subscribe_cluster_map[addr] = nil
end

-----------------------cluster memory----------------------

function cluster_mgr.cache_cluster_conf(conf)
	local cluster_nodes =  share_memory["cluster_nodes"]
	cluster_nodes = cluster_nodes or {}
	if (cluster_nodes[conf.nodename] and conf.ver > cluster_nodes[conf.nodename].ver)
		or not cluster_nodes[conf.nodename] then

		cluster_nodes[conf.nodename] = conf
		share_memory["cluster_nodes"] = cluster_nodes
	end

	local current_conf = cluster_mgr.get_current_conf()
	if current_conf and conf.nodename == current_conf.nodename then
		share_memory["current_nodename"] = conf.nodename
	end
end

function cluster_mgr.remove_cluster_conf(nodename)
	local cluster_nodes =  share_memory["cluster_nodes"]
	if not cluster_nodes[nodename] then
		return
	end

	cluster_nodes[nodename] = nil
	share_memory["cluster_nodes"] = cluster_nodes
end

-----------------------cluster redis-----------------------

function cluster_mgr.load_conf_from_redis()
	assert(_redis_mq, "_redis_mq is nil")
	local db = assert(_redis_mq:get_redis_db(), "redis db is nil")

	local current_ver = 0
	local current_conf = cluster_mgr.get_current_conf()
	local cluster_nodes = db:hvals("cluster_nodes")
	for _, v in pairs(cluster_nodes) do
		local conf = json.decode(v)
		local nodename = assert(conf.nodename)
		if nodename == current_conf.nodename then
			current_ver = conf.ver
		else
			cluster_mgr.cache_cluster_conf(conf)
		end
	end

	current_ver = current_ver + 1
	current_conf.ver =  current_ver
	cluster_mgr.cache_cluster_conf(current_conf)
end

function cluster_mgr.cache_conf_to_redis(conf)
	assert(_redis_mq, "_redis_mq is nil")
	local db = assert(_redis_mq:get_redis_db(), "redis db is nil")
	
	local str_conf = json.encode(conf)
	db:hset("cluster_nodes", conf.nodename, str_conf)
end

function cluster_mgr.remove_conf_from_redis(conf)
	assert(_redis_mq, "_redis_mq is nil")
	local db = assert(_redis_mq:get_redis_db(), "redis db is nil")

	db:hdel("cluster_nodes", conf.nodename)
end

----------------------skynet.cluster conf----------------------

function cluster_mgr.reload_cluster_conf()
	local cluster_nodes =  share_memory["cluster_nodes"]
	if not cluster_nodes then
		return 
	end

	local config = {}
	local current_conf = cluster_mgr.get_current_conf()
	for _, v in pairs(cluster_nodes) do
		if v.nodename == current_conf.nodename then
			config[v.nodename] = "0.0.0.0:"..v.nodeport
		else
			if v.use_intranet == 1 then
				config[v.nodename] = v.intranetip..":"..v.nodeport
			else
				config[v.nodename] = v.extranetip..":"..v.nodeport
			end
		end
	end
	cluster.reload(config)
end

----------------------connector mgr----------------------------

function cluster_mgr.reset_connectors()
	local cluster_nodes =  share_memory["cluster_nodes"]
	if not cluster_nodes then
		return 
	end

	local current_conf = cluster_mgr.get_current_conf()
	for _, v in pairs(cluster_nodes) do
		if v.nodename ~= current_conf.nodename then
			local conn = _connector_map[v.nodename]
			if not conn then
				conn = connector()
				conn:set_connect_conf(v)
				conn:set_connect_func(_connect_func)
				conn:set_check_disconnect_fun(_check_disconnect_func)
				conn:set_connect_callback(_connect_callback)
				conn:set_disconnect_callback(_disconnect_callback)
				conn:start()
				cluster_mgr.set_connector(v.nodename, conn)
			else
				local conf = conn:get_connect_conf()
				if conf.ver < v.ver then
					conn:stop()
					conn:set_connect_conf(v)
					conn:start()
				end
			end
		end
	end

	local removeList = {}
	for name, v in pairs(_connector_map) do
		if not cluster_nodes[name] then
			v:stop()
			v:reset()
			table.insert(removeList, name)
		end
	end

	for _, name in pairs(removeList) do
		_connector_map[name] = nil
	end
	removeList = nil
end

-------------------------------init---------------------------

function cluster_mgr.init_mq()
	assert(_redis_conf, "redis_conf is nil")
	if not _redis_mq then
		_redis_mq = redis_mq(_redis_conf, on_redis_publish)
		_redis_mq:psubscribe("cluster_mgr.*")
		_redis_mq:start_watching()
	end
end

function cluster_mgr.start(redis_conf, current_conf)
	cluster_mgr.set_current_conf(current_conf)
	cluster_mgr.set_redis_conf(redis_conf)
	cluster_mgr.init_mq()

	cluster_mgr.load_conf_from_redis()
	cluster_mgr.reload_cluster_conf()
	cluster_mgr.reset_connectors()
	return true
end

--开放本节点
function cluster_mgr.open()
	local current_conf = cluster_mgr.get_current_conf()
	cluster.open(current_conf.nodename)
	cluster_mgr.cache_conf_to_redis(current_conf)

	local str_conf = json.encode(current_conf)
	publish_redis_message("cluster_mgr.add_cluster_node", str_conf)
	return true
end

--关闭本节点
function cluster_mgr.close()

end

return cluster_mgr
