local skynet = require "skynet"
local redis = require "skynet.db.redis"
local mysql = require "skynet.db.mysql"
local mongo = require "skynet.db.mongo"
local db_config = require "config.db_config"
local mysql_config = require "config.mysql_config"
local redis_config = require "config.redis_config"
local dbmgr = {}

local _redisdb = nil
local _mongodb = nil
local _mysqldb = nil
local _mysqldb_log = nil

function dbmgr.get_mysql_db()
	return _mysqldb
end

function dbmgr.get_redis_db()
	return _redisdb
end

function dbmgr.init_mysql_db(mysql_id)
	local conf = mysql_config[mysql_id]
	if not conf then
		return
	end
	local mysql_conf = {
		host = conf.mysql_host,
		port = conf.mysql_port,
		database = conf.mysql_database,
		user = conf.mysql_user,
		password = conf.mysql_password,
		max_packet_size = conf.mysql_max_packet_size
	}
	_mysqldb = mysql.connect(mysql_conf)
	assert(_mysqldb, string.format("mysql connect %s:%d failed", mysql_conf.host, mysql_conf.port))
	_mysqldb:query("set charset utf8")
end

function dbmgr.init_redis_db(redis_id)
	local conf = redis_config[redis_id]
	if not conf then
		return
	end
	local redis_conf = {
		host = conf.redis_host,
		port = conf.redis_port,
		db = conf.redis_db
	}
	_redisdb = redis.connect(redis_conf)
	assert(_redisdb, string.format("redis connect %s:%d failed", redis_conf.host, redis_conf.port))
end

function dbmgr.init(svc_name)
	local conf = assert(db_config[svc_name], "not found svc_name")
	dbmgr.init_mysql_db(conf.mysql_id)
	dbmgr.init_redis_db(conf.redis_id)
end

 return dbmgr