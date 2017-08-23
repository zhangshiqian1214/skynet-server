--模块
MODULE = {
	GATE     = { id = 0x00, name = "gate", server = SERVER.GATE, service = SERVICE.WATCHDOG },
	AUTH     = { id = 0x01, name = "auth", server = SERVER.LOGIN, service = SERVICE.AUTH },
	HALL     = { id = 0x02, name = "hall", server = SERVER.HALL, service = SERVICE.HALL },
	PLAYER   = { id = 0x03, name = "player", server = nil, service = nil, is_agent = true },
	BANK     = { id = 0x04, name = "bank", server = nil, service = nil, is_agent = true},
	CASH     = { id = 0x05, name = "cash", server = nil, service = nil, is_agent = true},
	PUSH     = { id = 0x06, name = "push", server = nil, service = nil, is_agent = true},
	MESSAGE  = { id = 0x07, name = "message", server = nil, service = nil, is_agent = true},

	ROOM     = { id = 0x0d, name = "room", server = SERVER.GAME, service = SERVICE.ROOM },
	XPNN     = { id = 0x10, name = "xpnn", server = SERVER.GAME, service = nil },
	LRNN     = { id = 0x11, name = "lrnn", server = SERVER.GAME },
	DDZ      = { id = 0x12, name = "ddz", server = SERVER.GAME },
	ZJH      = { id = 0x13, name = "zjh", server = SERVER.GAME },
	LRSH     = { id = 0x14, name = "lrsh", server = SERVER.GAME },

}
