local skynet = require "skynet"
local redis = require "skynet.db.redis"
local mysql = require "skynet.db.mysql"
local mongo = require "skynet.db.mongo"


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

function dbmgr.get_mongo_db()
	return _mongodb
end

function dbmgr.init_mysql_db(conf)
	_mysqldb = mysql.connect(conf)
	assert(_mysqldb, string.format("mysql connect %s:%d failed", conf.host, conf.port))
	db:query("set charset utf8")
end

function dbmgr.init_redis_db(conf)
	_redisdb = redis.connect(conf)
	assert(_redisdb, string.format("redis connect %s:%d failed", conf.host, conf.port))
end

function dbmgr.init_mongo_db(conf)
	_mongodb = mongo.connect(conf)
	assert(_mongodb, string.format("mongo connect %s:%d failed", conf.host, conf.port))
end

 return dbmgr