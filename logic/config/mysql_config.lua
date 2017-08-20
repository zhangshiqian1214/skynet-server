--[[
	mysql连接id, mysql地址, mysql端口, mysql库名, mysql用户名, mysql密码, mysql包最大长度, 注释
	id, host, port, database, user, password, max_packet_size, desc
]]
local mysql_config = {
	[1] = {
			id = 1,
			host = "127.0.0.1",
			port = 3306,
			database = "game",
			user = "game",
			password = "game!Zsq1214",
			max_packet_size = 1048576,
			desc = [[game库]],
		},
	[2] = {
			id = 2,
			host = "127.0.0.1",
			port = 3306,
			database = "gamelog",
			user = "gamelog",
			password = "gamelog!Zsq1214",
			max_packet_size = 1048576,
			desc = [[gamelog库]],
		},
}
return mysql_config