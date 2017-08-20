local hall_ctrl = require "hall.hall_ctrl"
local hall_impl = {}

function hall_impl.cast_login(ctx, req)
	return hall_ctrl.cast_login(ctx, req)
end

function hall_impl.cast_logout(ctx, req)
	return hall_ctrl.cast_logout(ctx, req)
end


return hall_impl