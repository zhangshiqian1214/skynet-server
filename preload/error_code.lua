local errors = {}

function errmsg(ec)
	if not ec then
		return "nil"
	end
	return errors[ec].desc
end

local function add(err)
	assert(errors[err.code] == nil, string.format("have the same error code[%x], msg[%s]", err.code, err.message))
	errors[err.code] = {desc = err.message , type = err.type}
	return err.code
end

SystemError = {
	success            = add{code = 0x0000, message = "请求成功"},
	unknow             = add{code = 0x0001, message = "未知错误"},
	decode_failure     = add{code = 0x0002, message = "解析协议失败"},
	decode_header      = add{code = 0x0003, message = "解析包头出错"},
	decode_data        = add{code = 0x0004, message = "解析包体出错"},
	unknow_protoid     = add{code = 0x0005, message = "未知协议id"},
	unknow_proto       = add{code = 0x0006, message = "未知协议"},
	unknow_roomproxy   = add{code = 0x0007, message = "未知房间地址"},
	invalid_proto      = add{code = 0x0008, message = "非法协议"},
	no_auth_account    = add{code = 0x0009, message = "未登录帐号"},
	service_stoped     = add{code = 0x000a, message = "服务故障"},
	no_login_game      = add{code = 0x000b, message = "未登陆游戏"},
	service_not_impl   = add{code = 0x000c, message = "服务未实现"},
	module_not_impl    = add{code = 0x000d, message = "模块未实现"},
	func_not_impl      = add{code = 0x000e, message = "函数未实现"},
	service_maintance  = add{code = 0x000f, message = "服务维护"},
}

return errors