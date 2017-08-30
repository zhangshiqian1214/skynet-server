local db_mgr = require "common.db_mgr"

local player_db = {}

local PlayerInfoKey = "player_info"
local function get_player_info_key(id)
	return PlayerInfoKey..":"..id
end

function player_db.get_player_info(id)
	local mysqldb = db_mgr.get_mysql_db()
	local sql = string.format("select * from tb_player where player_id = %d;", id)
	local result = mysqldb:query(sql)
	if result.err then
		error(result.err)
	end
	return result[1]
end

function player_db.cache_player_info(id)
	local player_info = player_db.get_player_info(id)
	if not player_info then
		return nil
	end
	player_db.set_player_info_cache(id, player_info)
	return player_info
end

--载入到redis
function player_db.get_player_info_cache(id)
	local redisdb = db_mgr.get_redis_db()
	local player_info = array_totable(redisdb:hgetall(get_player_info_key(id)))
	player_info.player_id = tonumber(player_info.player_id)
	player_info.head_id = tonumber(player_info.head_id)
	player_info.sex = tonumber(player_info.sex)
	player_info.gold = tonumber(player_info.gold)
	player_info.safe_gold = tonumber(player_info.safe_gold)
	player_info.last_mod_time = tonumber(player_info.last_mod_time)
	return player_info
end

--写入到redis
function player_db.set_player_info_cache(id, player_info)
	local redisdb = db_mgr.get_redis_db()
	local data = assert(table.toarray(player_info), "online is not table")
	redisdb:hmset(get_player_info_key(id), table.unpack(data))
	return
end

--写入到mysql
function player_db.uncache_player_info(id)
	local player_info = player_db.get_player_info_cache(id)
	local mysqldb = db_mgr.get_mysql_db()
	local sql = string.format("update tb_player set head_id=%s, head_url='%s', nickname='%s', sex=%s, gold=%s, safe_gold=%s, last_mod_time=%s where player_id = %s;",
		player_info.head_id, player_info.head_url, player_info.nickname, player_info.sex, player_info.gold, player_info.safe_gold, player_info.last_mod_time)
	local result = mysqldb:query(sql)
	if result.err then
		error(result.err)
	end
	local redisdb = db_mgr.get_redis_db()
	redisdb:del(get_player_info_key(id))
	return
end

--更新玩家数据
function player_db.update_player_info_cache(id, key, value)
	local redisdb = db_mgr.get_redis_db()
	redisdb:hset(get_player_info_key(id), key, value)
	return
end

return player_db