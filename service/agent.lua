local skynet = require "skynet"
local service = require "service_base"
local agent_ctrl = require "agent.agent_ctrl"
local cluster_monitor = require "cluster_monitor"
local context = require "context"
local config_db = require "config_db"
local cluster_config = require "config.cluster_config"
local command = service.command
service.is_agent = true

local current_conf
local login_callbacks
local logout_callbacks

local modules = {
	agent = "agent.agent_ctrl",
	player = "player.player_ctrl",
}

local function register_login_and_logout()
	login_callbacks = {
		require("agent.agent_ctrl").on_login,
		require("player.player_ctrl").on_login,
	}
	logout_callbacks = {
		require("player.player_ctrl").on_logout,
		require("agent.agent_ctrl").on_logout,
	}
end

local function init_modules()
	setmetatable(service.modules, {
		__index = function(t, k)
			local mod = modules[k]
			if not mod then
				return nil
			end
			local v = require(mod)
			t[k] = v
			return v
		end
	})
end


function command.login(ctx, player_info)
	if current_conf.server_type == SERVER.HALL then
		service.player_id = player_info.player_id
		service.fd = ctx.fd
	end
	for _, callback in ipairs(login_callbacks) do
		callback(ctx, player_info)
	end
end

function command.update_configs(configs)
	config_db.update(configs)
end

function command.init(configs)
	config_db.init(configs)
	init_modules()
	register_login_and_logout()
end

function service.on_start()
	local server_id = tonumber(skynet.getenv("cluster_server_id"))
	current_conf = cluster_config[server_id]
	agent_ctrl.init(current_conf)
end

service.start()