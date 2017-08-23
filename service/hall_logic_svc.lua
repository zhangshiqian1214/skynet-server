--[[
	@ filename :  hall_logic_svc.lua
	@ author   : zhangshiqian1214@163.com
	@ modify   : 2017-08-23 17:53
	@ company  : zhangshiqian1214
]]

local skynet = require "skynet"
local json = require "json"
local command = require "command_base"
local hall_logic = require "hall.hall_logic"

function command.cast_login(ctx, req)
	return hall_logic.cast_login(ctx, req)
end

function command.get_player_online_state(ctx, req)
	return hall_logic.get_player_online_state(ctx, req)
end

function command.get_room_inst_list(ctx, req)
	return hall_logic.get_room_inst_list(ctx, req)
end

skynet.start(function()
	hall_logic.init()
end)
