local room_ctrl = require "room.room_ctrl"

local room_impl = {}

function room_impl.enter_room(ctx, req)
	return room_ctrl.enter_room(ctx, req)
end

function room_impl.exit_room(ctx, req)
	return room_ctrl.exit_room(ctx, req)
end

function room_impl.group_request(ctx, req)
	return room_ctrl.group_request(ctx, req)
end

return room_impl