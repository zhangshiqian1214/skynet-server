local dbmgr = require "common.dbmgr"
local role_db = {}

function role_db.get_role_info(role_id)
	local mysqldb = dbmgr.get_mysql_db()
	if not mysqldb then return end
	local result = mysqldb:query("select * from tb_player where id=%d;", role_id)
	return result
end


return role_db