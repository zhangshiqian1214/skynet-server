local errors = {}

local function add(err)
	assert(errors[err.code] == nil, string.format("have the same error code[%x], msg[%s]", err.code, err.desc))
	errors[err.code] = { desc = err.desc }
	return err.code
end

function rpc_errmsg(ec)
	if not ec then
		return "nil"
	end
	return errors[ec].desc
end

RPC_ERROR = {
	success        = add{ code = 0x01, desc = "请求成功"},
	node_nil       = add{ code = 0x02, desc = "请求节点为nil"},
	service_nil    = add{ code = 0x03, desc = "请求服务为nil"},
	node_offline   = add{ code = 0x04, desc = "节点不在线"},
	service_stoped = add{ code = 0x05, desc = "服务故障"},
}

return errors