local db_mgr = require "common.db_mgr"

local desk_db = {}

local IncrDealIdKey = "incr_deal_id"

function desk_db.incr_deal_id()
	local redisdb = db_mgr.get_redis_db()
	return tonumber(redisdb:incr(IncrDealIdKey))
end

return desk_db