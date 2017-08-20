local skynet = require "skynet"
local redis = require "skynet.db.redis"
local mysql = require "skynet.db.mysql"
local mongo = require "skynet.db.mongo"
local db_config = require "config.db_config"
local mysql_config = require "config.mysql_config"
local redis_config = require "config.redis_config"
local db_mgr = {}

local _redisdb = nil
local _mongodb = nil
local _mysqldb = nil
local _mysqldb_log = nil

function db_mgr.get_mysql_db()
	return _mysqldb
end

function db_mgr.get_redis_db()
	return _redisdb
end

function db_mgr.init_mysql_db(mysql_id)
	local conf = mysql_config[mysql_id]
	if not conf then
		return
	end
	-- local mysql_conf = {
	-- 	host = conf.host,
	-- 	port = conf.port,
	-- 	database = conf.database,
	-- 	user = conf.user,
	-- 	password = conf.password,
	-- 	max_packet_size = conf.max_packet_size
	-- }
	_mysqldb = mysql.connect(conf)
	assert(_mysqldb, string.format("mysql connect %s:%d failed", conf.host, conf.port))
	_mysqldb:query("set charset utf8")
end

function db_mgr.init_redis_db(redis_id)
	local conf = redis_config[redis_id]
	if not conf then
		return
	end
	-- local redis_conf = {
	-- 	host = conf.host,
	-- 	port = conf.port,
	-- 	db = conf.db
	-- }
	_redisdb = redis.connect(conf)
	assert(_redisdb, string.format("redis connect %s:%d failed", conf.host, conf.port))
end

function db_mgr.init(svc_name)
	local conf = assert(db_config[svc_name], "not found svc_name")
	db_mgr.init_mysql_db(conf.mysql_id)
	db_mgr.init_redis_db(conf.redis_id)
end

 return db_mgr