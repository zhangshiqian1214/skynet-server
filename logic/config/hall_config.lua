local config_helper = require "config_helper"

local config = {}

config.game_type_config = config_helper.new("game_type_config")
config.game_config = config_helper.new("game_config")
config.game_room_config = config_helper.new("game_room_config")

return config