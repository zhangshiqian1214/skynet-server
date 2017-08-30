local xpnn_logic = {}

--牌的花色掩码
MASK_VALUE = 0x0F
MASK_COLOR = 0xF0

CARD_TYPE = {
	no_niu      = 0x0000, --无牛
	niu1        = 0x0001, --牛一
	niu2        = 0x0002, --牛二
	niu3        = 0x0003, --牛三
	niu4        = 0x0004, --牛四
	niu5        = 0x0005, --牛五
	niu6        = 0x0006, --牛六
	niu7        = 0x0007, --牛七
	niu8        = 0x0008, --牛八
	niu9        = 0x0009, --牛九
	niu_niu     = 0x000a, --牛牛
	king4_niu   = 0x000b, --四花牛
	king5_niu   = 0x000c, --五花牛
}

CARD_POOL = {
	0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, --方块A-10JQK
	0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, --梅花A-10JQK
	0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x2d, --红桃A-10JQK
	0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3a, 0x3b, 0x3c, 0x3d, --黑桃A-10JQK
}

--分组类型
local GROUP_TYPE = {
	{1,2,3,4,5},{1,2,4,3,5},{1,2,5,3,4},
	{1,3,4,2,5},{1,3,5,2,4},{1,4,5,2,3},
	{2,3,4,1,5},{2,3,5,1,4},{2,4,5,1,3},
	{3,4,5,1,2},
}

--洗牌
function xpnn_logic.shuffle_card_pool()

end

function xpnn_logic.get_card_color(card)
	return MASK_COLOR & card	
end

function xpnn_logic.get_card_value(card)
	return MASK_VALUE & card
end

function xpnn_logic.get_card_logic_value(card)
	local card_value = xpnn_logic.get_card_value(card)
	return (card_value > 10) and 10 or card_value
end

function xpnn_logic.get_card_type(cards)
	assert(#cards == 5)
	local tmp_cards = { cards[1], cards[2], cards[3], cards[4], cards[5] }
	local sum_logic_value = 0 --总计数
	local pai_king_count = 0 --JQK的张数
	local pai_10_count = 0 --牌10的张数
	local max_card = 0x00 --最大的那张牌

	table.sort(tmp_cards, function(a, b)
		local valuea = xpnn_logic.get_card_value(a)
		local valueb = xpnn_logic.get_card_value(b)
		if valuea < valueb then
			return true
		end
		if valuea == valueb then
			if xpnn_logic.get_card_color(a) < xpnn_logic.get_card_color(b) then
				return true
			end
			return false
		end
	end)
	max_card = tmp_cards[5]

	for _, v in ipairs(tmp_cards) do
		local card_value = xpnn_logic.get_card_value(v)
		local logic_value = xpnn_logic.get_card_logic_value(v)
		if card_value > 10 then
			pai_king_count = pai_king_count + 1
		elseif card_value == 10 then
			pai_10_count = pai_10_count + 1
		end
		sum_logic_value = sum_logic_value + logic_value
	end

	if pai_king_count == 5 then
		return CARD_TYPE.king5_niu, max_card, {tmp_cards[3], tmp_cards[4], tmp_cards[5], tmp_cards[1], tmp_cards[ 2]}
	end

	if pai_king_count == 4 and pai_10_count == 1 then
		return CARD_TYPE.king4_niu, max_card, {tmp_cards[3], tmp_cards[4], tmp_cards[5], tmp_cards[1], tmp_cards[ 2]}
	end

	
	local result_group = nil
	local result_cards = {}
	local result_type = CARD_TYPE.no_niu
	for _, group in ipairs(GROUP_TYPE) do
		local tmp_sum_value = 0
		for i, v in ipairs(group) do
			if i < 4 then
				tmp_sum_value = tmp_sum_value + xpnn_logic.get_card_logic_value(tmp_cards[v])
			end
		end
		if tmp_sum_value % 10 == 0 then
			local left_value = sum_logic_value - tmp_sum_value
			left_value = (left_value > 10) and (left_value - 10) or left_value
			if left_value > result_type then
				result_type = left_value
				result_group = group
			end 
		end
	end

	if result_type ~= CARD_TYPE.no_niu then
		for k, v in ipairs(result_group) do
			result_cards[k] = tmp_cards[v]
		end
	end
	return result_type, max_card, result_cards
end

--如果a>b return true, 否则return false
function xpnn_logic.compare(card_type1, card_type2, card1, card2)
	if card_type1 ~= card_type2 then return card_type1 > card_type2 end
	local value1 = xpnn_logic.get_card_value(card1)
	local value2 = xpnn_logic.get_card_value(card2)
	if value1 > value2 then return true end
	if value1 == value2 then
		if xpnn_logic.get_card_color(card1) > xpnn_logic.get_card_color(card2) then
			return true
		end
	end
	return false
end

function xpnn_logic.get_times(card_type)
	if card_type == CARD_TYPE.king5_niu then return 5 end
	if card_type == CARD_TYPE.king4_niu then return 4 end
	if card_type == CARD_TYPE.niu_niu then return 3 end
	if card_type > CARD_TYPE.niu6 then return 2 end
	return 1
end

return xpnn_logic