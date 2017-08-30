local player_ctrl = require "player.player_ctrl"

local player_impl = {}

--TODO 获取玩家信息 for service
function player_impl.get_player_info(ctx)
	return player_ctrl.get_player_info(ctx)
end

--TODO for service
function player_impl.handle_player_payout(desk_svc, winlost_info)
	return player_ctrl.handle_player_payout(desk_svc, winlost_info)
end

--TODO 获取玩家数据for client
function player_impl.qry_player_info(ctx, req)
	return player_ctrl.qry_player_info(ctx, req)
end

--TODO 修改玩家头像数据
function player_impl.modify_head_info(ctx, req)
	return player_ctrl.modify_head_info(ctx, req)
end

function player_impl.modify_nickname_info(ctx, req)
	return player_ctrl.modify_nickname_info(ctx, req)
end

function player_impl.get_alipay_info(ctx, req)
	return player_ctrl.get_alipay_info(ctx, req)
end

function player_impl.get_bank_card_info(ctx, req)
	return player_ctrl.get_bank_card_info(ctx, req)
end

function player_impl.get_weixinpay_info(ctx, req)
	return player_ctrl.get_weixinpay_info(ctx, req)
end

function player_impl.bind_alipay_info(ctx, req)
	return player_ctrl.bind_alipay_info(ctx, req)
end

function player_impl.bind_bank_card_info(ctx, req)
	return player_ctrl.bind_bank_card_info(ctx, req)
end

function player_impl.bind_weixinpay_info(ctx, req)
	return player_ctrl.bind_weixinpay_info(ctx, req)
end


return player_impl