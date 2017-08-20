local skynet = require "skynet"
local json = require "json"
local command = require "command_base"
local hall_logic = require "hall.hall_logic"

function command.cast_login(ctx, req)
	return hall_logic.cast_login(ctx, req)
end

skynet.start(function()
	hall_logic.init()
end)
