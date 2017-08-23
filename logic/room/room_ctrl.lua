require "skynet.manager"
local skynet = require "skynet"
local context = require "context"
local random = require "random"
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
local player_session_map = {}

local incr_group_id = 0
local using_desks = {} -- group_id : desksvc
local player_group_map = {} -- player_id : group_id
local group_players_map = {} -- group_id : { player_id }

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

local function get_incr_group_id()
	incr_group_id = incr_group_id + 1
	return incr_group_id
end

--获取一个可加入的组id
local function get_joinable_group_id()
	local joinable_group_list = {}
	for group_id, players in pairs(group_players_map) do
		if #players < room_conf.max_group_player then
			table.insert(joinable_group_list, { group_id = group_id, player_count = #players })
		end
	end
	if table.empty(joinable_group_list) then
		local group_id = get_incr_group_id()
		return group_id
	end
	local joinable_group = random.random_one(joinable_group_list)
	return joinable_group.group_id
end

local function get_desk_by_group_id(group_id)
	if using_desks[group_id] then
		return using_desks[group_id]
	end
	local desk = init_desk()
	using_desks[group_id] = desk
	return desk
end

function room_ctrl.init()
	server_id = tonumber(skynet.getenv("cluster_server_id"))
	current_conf = cluster_monitor.get_current_node()
	configs = require("config."..game_conf.module_name.."_config")
	init_desk_pool()
	init_agent_pool()
	init_room()
end

function room_ctrl.get_configs()
	return configs
end

function room_ctrl.update_configs(updates)
	for k, v in pairs(updates) do
		configs[k] = v
	end
end


function room_ctrl.enter_room(ctx, req)
	local reply = {}

	local player_online = db_helper.call(DB_SERVICE.hall, "hall.get_player_online", ctx.player_id)
	if player_online.room_id and player_online.room_id ~= room_id then
		reply.room_id = player_online.room_id
		reply.roomproxy = player_online.agentnode
		local online_game_conf = game_config[player_online.room_id]
		if online_game_conf.game_id ~= current_conf.game_id then
			return GAME_ERROR.in_other_game, reply
		else
			return GAME_ERROR.gameing_in_other_room, reply
		end
	elseif player_online.agentnode ~= current_conf.nodename then
		reply.room_id = player_online.room_id
		reply.roomproxy = player_online.agentnode
		return GAME_ERROR.in_other_room_inst
	end

	reply.room_id = room_id
	reply.roomproxy = current_conf.nodename
	local old_session = player_session_map[ctx.player_id]
	if old_session and old_session ~= ctx.session then
		local old_agent = using_agents[old_session]
		using_agents[old_session] = nil
		using_agents[ctx.session] = old_agent
		player_session_map[ctx.player_id] = ctx.session
		context.call(old_agent, "reconnect", ctx)

		local group_id = player_group_map[ctx.player_id]
		if room_conf.group_type == GROUP_TYPE.auto and group_id ~= nil then
			local old_desk = using_desks[group_id]
			context.call(old_desk, "reconnect", ctx)
		end
		return SYSTEM_ERROR.success, reply
	end

	local player_info = db_helper.call(DB_SERVICE.agent, "player.get_player_info", ctx.player_id)
	if player_info.gold < room_conf.min_enter then
		return GAME_ERROR.gold_not_enough
	end

	local agent = init_agent(ctx)
	using_agents[ctx.player_id] = ctx.session
	player_session_map[ctx.player_id] = ctx.session
	print("enter_room player_info=", table.tostring(player_info), "agent=", agent)
	context.call(agent, "login", ctx, player_info)
	
	return SYSTEM_ERROR.success, reply
end

function room_ctrl.exit_room(ctx, req)
	local agent = using_agents[ctx.session]
	if not agent then
		return SYSTEM_ERROR.success
	end

	local group_id = player_group_map[ctx.player_id]
	if group_id then
		local desk = using_desks[group_id]
		if desk then
			local ec = skynet.call(desk, "lua", "logout_desk", ctx)
			if ec ~= SYSTEM_ERROR.success then
				return ec
			end
		end
	end

	context.call(agent, "logout", ctx)
	using_agents[ctx.session] = nil
	player_session_map[ctx.player_id] = nil
	skynet.kill(agent)

	return SYSTEM_ERROR.success
end

function room_ctrl.group_request(ctx, req)
	local group_id = get_joinable_group_id()
	if room_conf.group_type == GROUP_TYPE.auto then
		group_players_map[group_id] = group_players_map[group_id] or {}
		table.insert(group_players_map[group_id], ctx.player_id)
		player_group_map[ctx.player_id] = group_id

		local desk = get_desk_by_group_id(group_id)
		context.call(desk, "add_player", ctx)
	elseif room_conf.group_type == GROUP_TYPE.ready then

	end
	return SYSTEM_ERROR.success
end


return room_ctrl