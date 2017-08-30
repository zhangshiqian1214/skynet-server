

PROTO_TYPE = {
	C2S = 1,
	S2C = 2,
}

--协议文件名
PROTO_FILES = {
	package = 1,
	gate    = 2,
	auth    = 3,
	hall    = 4,
	player  = 5,
	bank    = 6,
	cash    = 7,
	push    = 8,
	message = 9,
	room    = 10,
	desk    = 11,
	xpnn    = 12,
}

local proto_map = {
	protos = {},
	proto_pool = {},
}

local mt = {}
mt.__newindex = function(t, k, v)
	for key, proto in pairs(v) do
		if key ~= "module" then
			assert(proto_map[proto.id] == nil, "has same proto["..proto.id.."]")
			local tmp = {}
			tmp.name = key
			tmp.module = v.module.name
			tmp.server = v.module.server
			tmp.service = v.module.service
			tmp.is_agent = v.module.is_agent
			tmp.id = proto.id
			tmp.type = proto.type
			tmp.request = proto.request
			tmp.response= proto.response
			tmp.desc = proto.desc
			tmp.fullname = v.module.name.."."..key
			t.protos[proto.id] = tmp
		end
	end
end
setmetatable(proto_map, mt)

--网关
M_Gate = {
	module = MODULE.GATE,
	ping             = {id = 0x0001, type = PROTO_TYPE.C2S,  request = "integer", response = "integer", desc = "心跳"},

	network_event    = {id = 0x00a1, type = PROTO_TYPE.S2C, request = nil, response = "gate.NetworkEvent", desc = "网络事件"},
}
proto_map.Gate = M_Gate

--验证
M_AUTH = {
	module  = MODULE.AUTH,
	register_account = {id = 0x0101, type = PROTO_TYPE.C2S, request = "auth.RegisterReq", response = "auth.RegisterReply", desc = "注册帐号"},
	login_account    = {id = 0x0102, type = PROTO_TYPE.C2S, request = "auth.LoginReq", response = "auth.LoginReply", desc = "登陆帐号"},
	weixin_login     = {id = 0x0103, type = PROTO_TYPE.C2S, request = "auth.WeixinReq", response = "auth.WeiXinReply", desc = "微信登陆"},
	visitor_login    = {id = 0x0104, type = PROTO_TYPE.C2S, request = "auth.VisitorReq", response = "auth.VisitorReply", desc = "游客登陆"},
}
proto_map.auth = M_AUTH

--大厅
M_HALL = {
	module = MODULE.HALL,
	get_room_inst_list = {id = 0x0201, type = PROTO_TYPE.C2S, request = "integer", response = "hall.RoomInstList", desc = "获取房间实例列表"},
	get_player_online_state = {id = 0x0202, type = PROTO_TYPE.C2S, request = nil, response = "hall.PlayerOnlineState", desc = "获取玩家在线状态"},
}
proto_map.hall = M_HALL

--玩家
M_PLAYER = {
	module = MODULE.PLAYER,
	qry_player_info = {id = 0x0301, type = PROTO_TYPE.C2S, request = nil, response = "player.PlayerInfo", desc = "获取自已的玩家信息"},
	modify_head_info = {id = 0x0302, type = PROTO_TYPE.C2S, request = "player.ModifyHeadReq", response = nil, desc = "修改玩家头像"},
	modify_nickname_info = {id = 0x0303, type = PROTO_TYPE.C2S, request = "player.NicknameReq", response = nil, desc = "修改昵称信息"},
	get_alipay_info = {id = 0x0304, type = PROTO_TYPE.C2S, request = nil, response = "player.AliPayInfo", desc = "获取支付宝帐号信息"},
	get_bank_card_info = {id = 0x0305, type = PROTO_TYPE.C2S, request = nil, response = "player.BankCardInfo", desc = "获取银行卡信息"},
	get_weixinpay_info = {id = 0x0306, type = PROTO_TYPE.C2S, request = nil, response = "player.WeixinPayInfo", desc = "获取微信支付信息"},
	bind_alipay_info = {id = 0x0307, type = PROTO_TYPE.C2S, request = "player.AliPayInfo", response = nil, desc = "绑定支付宝信息"},
	bind_bank_card_info = {id = 0x0308, type = PROTO_TYPE.C2S, request = "player.BankCardInfo", response = nil, desc = "绑定银行卡信息"},
	bind_weixinpay_info = {id = 0x0309, type = PROTO_TYPE.C2S, request = "player.WeixinPayInfo", response = nil, desc = "绑定微信支付信息"},
}
proto_map.player = M_PLAYER

--银行
M_BANK = {
	module = MODULE.BANK,
	get_bank_info = {id = 0x0401, type = PROTO_TYPE.C2S, request = nil, response = "bank.PlayerBankInfo", desc = "玩家银行信息"},
	gold_from_bank = {id = 0x0401, type = PROTO_TYPE.C2S, request = "integer", response = "bank.PlayerBankInfo", desc = "玩家从银行取款"},
	gold_to_bank = {id = 0x0402, type = PROTO_TYPE.C2S, request = "integer", response = "bank.PlayerBankInfo", desc = "玩家存款到银行"},
	bank_trade_details = {id = 0x0403, type = PROTO_TYPE.C2S, request = nil, response = "bank.BankTradeDetails", desc = "玩家银行交易明细"},
}
proto_map.bank = M_BANK

--充值
M_CASH = {
	module = MODULE.CASH,
	get_deposit_agent_list = {id = 0x0501, type = PROTO_TYPE.C2S, request = nil, response = "cash.DepositAgentList", desc = "充值代理列表"},
	alipay_deposit = {id = 0x0502, type = PROTO_TYPE.C2S, request = "cash.AliPayReq", response = "cash.AliPayReply", desc = "支付宝充值"},
	weixinpay_deposit = {id = 0x0503, type = PROTO_TYPE.C2S, request = "cash.WeixinPayReq", response = "cash.WeixinPayReply", desc = "微信充值"},
	bank_card_deposit = {id = 0x0504, type = PROTO_TYPE.C2S, request = "cash.BankCardReq", response = "cash.BankCardReply", desc = "银行卡充值"},
}
proto_map.cash = M_CASH

--推广
M_PUSH = {
	module = MODULE.PUSH,
	get_push_info = {id = 0x0601, type = PROTO_TYPE.C2S, request = nil, response = "push.PushInfo", desc = "推广信息"},
	get_push_details = {id = 0x0602, type = PROTO_TYPE.C2S, request = nil, response = "push.PushDetails", desc = "推广明细"},
}
proto_map.push = M_PUSH

--消息
M_MESSAGE = {
	module = MODULE.MESSAGE,

}
proto_map.message = M_MESSAGE



--房间
M_ROOM = {
	module = MODULE.ROOM,
	enter_room = {id = 0x0d01, type = PROTO_TYPE.C2S, request = nil, response = "room.EnterRoomReply", desc = "进入游戏房间"},
	exit_room = {id = 0x0d02, type = PROTO_TYPE.C2S, request = nil, response = "room.ExitRoomReply", desc = "退出游戏房间"},
	group_request = {id = 0x0d03, type = PROTO_TYPE.C2S, request = nil, response = nil, desc = "请求分组"},
}
proto_map.room = M_ROOM

M_DESK = {
	module = MODULE.DESK,
	
	add_cd_event = {id = 0x0e01, type = PROTO_TYPE.S2C, request = nil, response = "desk.AddCdEvent", desc = "增加cd事件"},
	del_cd_event = {id = 0x0e02, type = PROTO_TYPE.S2C, request = nil, request = "desk.DelCdEvent", desc = "删除cd事件"},
}
proto_map.desk = M_DESK

--血拼牛牛
M_XPNN = {
	module = MODULE.XPNN,
	qry_desk = {id = 0x1001, type = PROTO_TYPE.C2S, request = "xpnn.QryDeskReq", response = "xpnn.QryDeskReply", desc = "查询游戏台"},
	qiang_banker = {id = 0x1002, type = PROTO_TYPE.C2S, request = "xpnn.QiangBankerReq", response = "xpnn.QiangBankerReply", desc = "抢庄"},
	bet = {id = 0x1003, type = PROTO_TYPE.C2S, request = "xpnn.BetReq", response = "xpnn.BetReply", desc = "倍投"},
	open_card = {id = 0x1004, type = PROTO_TYPE.C2S, request = nil, response = nil, desc = "开牌"},

	deal_info_event = {id = 0x10a1, type = PROTO_TYPE.S2C, request = nil, response = "xpnn.DealInfo", desc = "牌局信息事件"},
	game_start_event = {id = 0x10a2, type = PROTO_TYPE.S2C, request = nil, response = "xpnn.GameStartEvent", desc = "开始游戏事件"},
	qiang_banker_event = {id = 0x10a3, type = PROTO_TYPE.S2C, request = nil, response = "xpnn.QiangBankerEvent", desc = "抢庄事件"},
	bet_event = {id = 0x10a4, type = PROTO_TYPE.S2C, request = nil, response = "xpnn.BetEvent", desc = "投注事件"},
	deal_card_event = {id = 0x10a5, type = PROTO_TYPE.S2C, request = nil, response = "xpnn.DealCardEvent", desc = "发牌事件"},
	open_card_event = {id = 0x10a6, type = PROTO_TYPE.S2C, request = nil, response = "xpnn.OpenCardEvent", desc = "开牌事件"},
	game_end_event = {id = 0x10a7, type = PROTO_TYPE.S2C, request = nil, response = "xpnn.GameEndEvent", desc = "游戏结束事件"},
	seat_state_event = {id = 0x10a8, type = PROTO_TYPE.S2C, request = nil, response = "xpnn.SeatStateEvent", desc = "坐位事件"},
}
proto_map.xpnn = M_XPNN

--龙虎斗
M_LHD = {
	module = MODULE.LHD
	
}
proto_map.lhd = M_LHD

--斗地主
M_DDZ = {
	module = MODULE.DDZ

}
proto_map.ddz = M_DDZ


return proto_map