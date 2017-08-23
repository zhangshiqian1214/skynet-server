local db_mgr = require "common.db_mgr"

local player_db = {}

function player_db.get_player_info(id)
	local mysqldb = db_mgr.get_mysql_db()
	local sql = string.format("select * from tb_player where player_id = %d;", id)
	local result = mysqldb:query(sql)
	if result.err then
		error(result.err)
	end
	return result[1]
end

return player_db