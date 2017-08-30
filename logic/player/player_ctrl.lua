local db_helper = require "common.db_helper"
local agent_ctrl = require "agent.agent_ctrl"

local player_ctrl = {}

local player_info


--TODO for service
function player_ctrl.update_player_info(update_info, cache_type)
	for k, v in pairs(update_info) do
		player_info[k] = v
	end
	if cache_type == CACHE_TYPE.redis then
		
	elseif cache_type == CACHE_TYPE.mysql then
		
	end
end

--TODO for service
function player_ctrl.incr_player_info(incr_info, cache_type)
	for k, v in pairs(incr_info) do
		player_info[k] = player_info[k] + v
	end
	if cache_type == CACHE_TYPE.redis then

	elseif cache_type == CACHE_TYPE.mysql then

	end
end

--TODO for service
function player_ctrl.get_player_info()
	if player_info then
		return player_info
	end
	player_info = db_helper.call(DB_SERVICE.agent, "player.get_player_info_cache", ctx.player_id)
	return player_info
end

--TODO for service
function player_ctrl.handle_player_payout(desk_svc, winlost_info)

	context.call(desk_svc, "player_payout_end", ,player_info)
end


--TODO for impl
function player_ctrl.qry_player_info(ctx)
	if not agent_ctrl.is_hall() then
		return SYSTEM_ERROR.success,player_info
	else
		local pl_info = db_helper.call(DB_SERVICE.agent, "player.get_player_info_cache", ctx.player_id)
		return SYSTEM_ERROR.success, pl_info
	end
end

function player_ctrl.modify_head_info(ctx, req)
	
end

function player_ctrl.modify_nickname_info(ctx, req)
	
end

function player_ctrl.get_alipay_info(ctx, req)
	
end

function player_ctrl.get_bank_card_info(ctx, req)
	
end

function player_ctrl.get_weixinpay_info(ctx, req)

end

function player_ctrl.bind_alipay_info(ctx, req)

end

function player_ctrl.bind_bank_card_info(ctx, req)

end

function player_ctrl.bind_weixinpay_info(ctx, req)

end

function player_ctrl.on_login(ctx, pl_info)
	if not agent_ctrl.is_hall() then
		player_info = db_helper.call(DB_SERVICE.agent, "player.get_player_info_cache", pl_info.player_id)
	else
		db_helper.call(DB_SERVICE.agent, "player.cache_player_info", pl_info.player_id)
	end
end

function player_ctrl.on_logout(ctx)
	if not agent_ctrl.is_hall() then
		db_helper.call(DB_SERVICE.agent, "player.set_player_info_cache", ctx.player_id, player_info)
	end
end

return player_ctrl