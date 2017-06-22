--
-- Author: Kuzhu1990
-- Date: 2013-12-16 18:52:11
-- 多节点监控
-- 
-- redis_conf = { host="127.0.0.1", port=6379, db=0 }
-- node_conf = { nodename="node1", nodeprot=9001, 
--   intranetip="127.0.0.1", extranetip="127.1.1.1",
--   use_intranet=1, serverid=1, servertype=1, ver=0 }
--
local json = require "json"
local skynet = require "skynet"
local cluster = require "skynet.cluster"
local acceptor = require "acceptor"
local redis_mq = require "redis_mq"
local share_memory = require "share_memory"
local connector_mgr = require "connector_mgr"

local clustermq  = nil
local command = {}
local mq_command = {}


--mq的消息回调
local function on_mq_message(key, data)
	local method = string.match(key, "cluster_nodes.([%w_]+)")
	assert(method)
	local func = mq_command[method]
	if func then
		func(data)
	end
end

local function send_mq_message(method, data)
	assert(clustermq, "clustermq is nil")
	clustermq:publish(method, data)
end

local function cache_cluster_conf(conf)
	local cluster_nodes =  share_memory["cluster_nodes"]
	cluster_nodes = cluster_nodes or {}
	if not cluster_nodes[conf.nodename] or cluster_nodes[conf.nodename] and conf.ver > cluster_nodes[conf.nodename].ver then
		cluster_nodes[conf.nodename] = conf
		share_memory["cluster_nodes"] = cluster_nodes
	end
end


local function load_conf_from_redis()
	assert(clustermq, "clustermq is nil")
	local db = assert(clustermq:get_redis_db(), "redis db is nil")

	local current_ver = 0
	local current_conf = acceptor.get_cluster_conf()
	local cluster_nodes = db:hvals("cluster_nodes")
	for _, v in pairs(cluster_nodes) do
		local conf = json.decode(v)
		local nodename = assert(conf.nodename)
		if nodename == current_conf.nodename then
			current_ver = conf.ver
		else
			cache_cluster_conf(conf)
		end
	end

	current_ver = current_ver + 1
	current_conf.ver =  current_ver
	cache_cluster_conf(current_conf)
	acceptor.set_cluster_conf(current_conf)
end

local function cache_conf_to_redis()
	assert(clustermq, "clustermq is nil")
	local db = assert(clustermq:get_redis_db(), "redis db is nil")
	
	local current_conf = acceptor.get_cluster_conf()
	local str_conf = json.encode(current_conf)
	db:hset("cluster_nodes", current_conf.nodename, str_conf)
end

local function reload_cluster_conf()
	local cluster_nodes =  share_memory["cluster_nodes"]
	if not cluster_nodes then
		return 
	end

	local config = {}
	local current_conf = acceptor.get_cluster_conf()
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

local function reset_connector_mgr()
	local cluster_nodes =  share_memory["cluster_nodes"]
	if not cluster_nodes then
		return 
	end
	local current_conf = acceptor.get_cluster_conf()
	for _, v in pairs(cluster_nodes) do
		if v.nodename ~= current_conf.nodename then
			local connector = connector_mgr.get_connector(v.nodename)
			if not connector then
				connector = connector_mgr.create_connector()
				connector:set_connect_conf(v)
				connector:set_connect_func(connector_mgr._connector_connect)
				connector:set_check_alive_fun(connector_mgr._connector_check_alive)
				connector:set_connect_callback(connector_mgr._connect_callback)
				connector:set_disconnect_callback(connector_mgr._disconnect_callback)
				connector_mgr.set_connector(v.nodename, connector)
				connector:start()
			else
				local conf = connector:get_connect_conf()
				if conf.ver < v.ver then
					connector:stop()
					connector:set_connect_conf(v)
					connector:start()
				end
			end
		end
	end
end


function mq_command.node_open(data)
	print("recv mq_command.node_open data=", data)
	local conf = json.decode(data)
	cache_cluster_conf(conf)
	reload_cluster_conf()
	reset_connector_mgr()

end

function mq_command.node_close(data)

end

--启动多节点监控
function command.start(session, redis_conf, current_conf)
	
	clustermq = redis_mq(redis_conf, on_mq_message)
	clustermq:psubscribe("cluster_nodes.*")
	clustermq:start_watching()

	acceptor.set_cluster_conf(current_conf)

	load_conf_from_redis()

	reload_cluster_conf()

	reset_connector_mgr()

	if session > 0 then
		skynet.retpack(true)
	end
end

function command.open(session)
	acceptor.start()
	cache_conf_to_redis()
	local current_conf = acceptor.get_cluster_conf()
	local str_conf = json.encode(current_conf)
	send_mq_message("cluster_nodes.node_open", str_conf)

	if session > 0 then
		skynet.retpack(true)
	end
end

skynet.start(function()

	skynet.dispatch("lua", function(session, address, cmd, ...)

		local f = command[cmd]
		assert(f, "function["..cmd.."] is nil")
		f(session, ...)

	end)

end)