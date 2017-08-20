require "skynet.manager"
local skynet = require "skynet"
local context = require "context"
local db_helper = require "common.db_helper"
local game_config = require "config.game_config"
local room_config = require "config.game_room_config"
local cluster_config = require "config.cluster_config"
local room_id = tonumber(skynet.getenv("room_id"))
local room_ctrl = {}

local room_conf = room_config[room_id]
local game_conf = game_config[room_conf.game_id]

local server_id
local current_conf
local configs

local desk_pool = {}
local agent_pool = {}

local using_agents = {}
local player_agent_map = {}

local function init_desk_pool()
	local desk_count = skynet.getenv("init_desk_count")
	for i=1, desk_count do
		local desk_svc = skynet.launch("snlua", "desk", game_conf.module_name)
		context.call(desk_svc, "init", configs)
		table.insert(desk_pool, desk_svc)
	end
	collectgarbage("collect")
end

local function init_agent_pool()
	local agent_count = skynet.getenv("init_agent_count")
	for i=1, agent_count do
		local agent = skynet.launch("snlua", "agent")
		context.call(agent, "init", configs)
		table.insert(agent_pool, agent)
	end
end

local function init_desk()
	local desk
	if #desk_pool > 0 then
		desk = table.remove(desk_pool, #desk_pool)
	else
		desk = skynet.launch("snlua", "agent")
		context.call(desk, "init", configs)
	end
	return desk
end

local function init_agent(ctx)
	local agent
	if #agent_pool > 0 then
		agent = table.remove(agent_pool, #agent_pool)
	else
		agent = skynet.launch("snlua", "agent")
		context.call(agent, "init", configs)
	end
	return agent
end

local function init_room()
	local room_inst_info = {
		server_id = server_id,
		room_id = room_id,
		roomproxy = current_conf.nodename,
		player_num = 0,
		player_limit = tonumber(skynet.getenv("player_limit")) or 600,
	}
	db_helper.call(DB_SERVICE.game, "room.register_room", nil, room_inst_info)
end

function room_ctrl.get_configs()
	return configs
end

function room_ctrl.update_configs(updates)
	for k, v in pairs(updates) do
		configs[k] = v
	end
end

function room_ctrl.cast_login(ctx, player_info)

end

function room_ctrl.init()
	server_id = tonumber(skynet.getenv("cluster_server_id"))
	current_conf = cluster_config[server_id]
	configs = require("config."..game_conf.module_name.."_config")
	init_desk_pool()
	init_agent_pool()
	init_room()
end

return room_ctrl