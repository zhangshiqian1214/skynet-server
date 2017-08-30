local root = "../"
local skynet_root = root .. "skynet/"
package.path = skynet_root .. "lualib/?.lua;"..root.."preload/?.lua;"..root.."logic/?.lua;"

require "luaext"

local xpnn_logic = require "xpnn.xpnn_logic"

print(xpnn_logic.get_card_type({ 0x01, 0x02, 0x03, 0x04, 0x05 }))
print(xpnn_logic.get_card_type({ 0x08, 0x18, 0x28, 0x03, 0x02 }))
print(xpnn_logic.get_card_type({ 0x0a, 0x02, 0x08, 0x12, 0x0b }))
print(xpnn_logic.get_card_type({ 0x0d, 0x03, 0x07, 0x0a, 0x0b }))
print(xpnn_logic.get_card_type({ 0x0d, 0x0c, 0x1c, 0x2b, 0x0a }))
print(xpnn_logic.get_card_type({ 0x0d, 0x0c, 0x1c, 0x2b, 0x0b }))
