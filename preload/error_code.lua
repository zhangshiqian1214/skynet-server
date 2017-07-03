local errors = {}

function errmsg(ec)
	if not ec then
		return "nil"
	end
	return errors[ec].desc
end

local function add(err)
	assert(errors[err.code] == nil, string.format("have the same error code[%x], msg[%s]", err.code, err.message))
	errors[err.code] = {desc = err.message , type = err.type or TYPE_TIPS , back = err.backUi}
	return err.code
end

SystemError = {
	success            = add{code = 0x0000, message = "请求成功"},
	unknow             = add{code = 0x0001, message = "未知错误"},
}

return errors