local auth_ctrl = require "auth.auth_ctrl"

local auth_impl = {}

function auth_impl.register_account(ctx, req)
	return auth_ctrl.register_account(ctx, req)
end

function auth_impl.login_account(ctx, req)
	return auth_ctrl.login_account(ctx, req)
end

function auth_impl.weixin_login(ctx, req)
	return auth_ctrl.weixin_login(ctx, req)
end

function auth_impl.visitor_login(ctx, req)
	return auth_ctrl.visitor_login(ctx, req)
end

return auth_impl