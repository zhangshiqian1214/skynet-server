require "skynet.manager"
local skynet = require "skynet"
local context = require "context"
local configs = require "config.hall_config"
local hall_ctrl = {}

local logic_svc_pool = {}
local logic_svc_index = 1

local agent_pool = {}

local function init_logic_pool()
	local logic_count = skynet.getenv("hall_logic_count")
	for i=1, logic_count do
		local svc = skynet.newservice("hall_logic_svc")
		table.insert(logic_svc_pool, svc)
	end
end

local function init_agent_pool()
	local agent_count = skynet.getenv("agent_count")
	for i=1, agent_count do
		local agent = skynet.launch("snlua","agent")
		skynet.name(".agent"..i, agent)
		context.call(agent, "init", configs)
		table.insert(agent_pool, agent)
	end
end

local  function get_logic_svc()
	local svc = logic_svc_pool[logic_svc_index]
	logic_svc_index = logic_svc_index + 1
	if logic_svc_index > #logic_svc_pool then
		logic_svc_index = 1
	end
	return svc
end

local function get_agent(player_id)
	local agent_count = skynet.getenv("agent_count")
	local index = player_id % agent_count
	if index == 0 then index = agent_count end
	return agent_pool[index]
end

function hall_ctrl.init()
	init_logic_pool()
	init_agent_pool()
end

function hall_ctrl.cast_login(ctx, req)
	assert(ctx.player_id == nil, "player repeat login")
	print("cast_login ctx=", table.tostring(ctx), "req=", table.tostring(req))
	local svc = get_logic_svc()
	context.call(svc, "cast_login", ctx, req)
	
end

function hall_ctrl.cast_logout(ctx, req)

end

function hall_ctrl.get_player_online_state(ctx, req)
	local svc = get_logic_svc()
	local reply = context.call(svc, "get_player_online_state", ctx, req)
	return SYSTEM_ERROR.success, reply
end

function hall_ctrl.get_room_inst_list(ctx, req)
	local svc = get_logic_svc()
	local reply = context.call(svc, "get_room_inst_list", ctx, req)
	return SYSTEM_ERROR.success, reply 
end

return hall_ctrl