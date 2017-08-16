--[[
	mysql连接id, mysql地址, mysql端口, mysql库名, mysql用户名, mysql密码, mysql包最大长度, 注释
	mysql_id, mysql_host, mysql_port, mysql_database, mysql_user, mysql_password, mysql_max_packet_size, desc
]]
local mysql_config = {
	[1] = {
			mysql_id = 1,
			mysql_host = "127.0.0.1",
			mysql_port = 3306,
			mysql_database = "game",
			mysql_user = "game",
			mysql_password = "game!Zsq1214",
			mysql_max_packet_size = 1048576,
			desc = [[game库]],
		},
	[2] = {
			mysql_id = 2,
			mysql_host = "127.0.0.1",
			mysql_port = 3306,
			mysql_database = "gamelog",
			mysql_user = "gamelog",
			mysql_password = "gamelog!Zsq1214",
			mysql_max_packet_size = 1048576,
			desc = [[gamelog库]],
		},
}
return mysql_config