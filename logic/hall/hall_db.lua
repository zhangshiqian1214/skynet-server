local db_mgr = require "common.db_mgr"

local hall_db = {}

local PlayerOnlineKey = "player_online"

local function get_player_online_key(id)
	return PlayerOnlineKey .. ":" .. id
end

function hall_db.get_player_online(id)
	local redisdb = db_mgr.get_redis_db()
	return redisdb:hgetall(get_player_online_key(id))
end

function hall_db.set_player_online(id, online)
	local redisdb = db_mgr.get_redis_db()
	local data = assert(table.toarray(online), "online is not table")
	table.insert(data, 1, get_player_online_key(id))
	redisdb:hmset(table.unpack(data))
	return 
end

function hall_db.update_player_online(id, key, value)
	local redisdb = db_mgr.get_redis_db()
	redisdb:hset(get_player_online_key(id), key, value)
	return
end

return hall_db