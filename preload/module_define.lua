--模块
MODULE = {
	GATE     = { id = 0x00, name = "gate", server = SERVER.GATE, service = SERVICE.WATCHDOG },
	AUTH     = { id = 0x01, name = "auth", server = SERVER.LOGIN, service = SERVICE.AUTH },
	HALL     = { id = 0x02, name = "hall", server = SERVER.HALL, service = SERVICE.HALL },
	PLAYER   = { id = 0x03, name = "player", server = nil, service = nil, is_agent = true },
	ROOM     = { id = 0x04, name = "room", server = SERVER.GAME, service = SERVICE.ROOM },
	XPNN     = { id = 0x05, name = "xpnn", server = SERVER.GAME, service = nil },
}
