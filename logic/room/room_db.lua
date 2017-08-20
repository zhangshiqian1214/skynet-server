local db_mgr = require "common.db_mgr"

local room_db = {}

local RoomListKey = "room_list"
local RoomInstKey = "room_inst"

local function get_room_list_key(room_id)
	return RoomListKey..":"..room_id
end

local function get_room_inst_key(server_id)
	return RoomInstKey..":"..server_id
end

function room_db.register_room(id, room_inst_info)
	local redisdb = db_mgr.get_redis_db()
	local room_id = room_inst_info.room_id
	local server_id = room_inst_info.server_id
	local room_inst = assert(table.toarray(room_inst_info), "room_inst_info is not table")
	redisdb:hmset(get_room_inst_key(server_id), table.unpack(room_inst))
	redisdb:zadd(get_room_list_key(room_id), 0, server_id)
end

function room_db.get_room_inst(server_id)
	local redisdb = db_mgr.get_redis_db()
	return array_totable(redisdb:hgetall(get_room_inst_key(server_id)))
end

function room_db.get_room_list(room_id)
	local reply = {}
	local redisdb = db_mgr.get_redis_db()
	local room_list = array_totable(redisdb:zrange(get_room_list_key(room_id), 0, -1))
	for k, v in pairs(room_list) do
		table.insert(reply, room_db.get_room_inst(k))
	end
	return reply
end

return room_db