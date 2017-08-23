local xpnn_impl = {}

function xpnn_impl.qiang_banker(ctx, req)
	return xpnn_ctrl.qiang_banker(ctx, req)
end

function xpnn_impl.bet(ctx, req)
	return xpnn_ctrl.bet(ctx, req)
end

function xpnn_impl.open_card(ctx, req)
	return xpnn_ctrl.open_card(ctx, req)
end

return xpnn_impl