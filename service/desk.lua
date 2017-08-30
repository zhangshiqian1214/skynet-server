--[[
	@ filename : desk.lua
	@ author   : zhangshiqian1214@163.com
	@ modify   : 2017-08-23 17:53
	@ company  : zhangshiqian1214
]]

local skynet = require "skynet"
local service = require "service_base"
local cluster_monitor = require "cluster_monitor"
local context = require "context"
local config_db = require "config_db"
local cluster_config = require "config.cluster_config"
local desk_ctrl = require "desk.desk_ctrl"
local room_id = tonumber(skynet.getenv("room_id"))
local command = service.command
local modulename = ...
service.is_agent = true

local server_id
local current_conf
local module_ctrl

-- local modules

-- local function init_modules()
-- 	modules = require("config."..modulename.."_module")
-- 	setmetatable(service.modules, {
-- 		__index = function(t, k)
-- 			local mod = modules[k]
-- 			if not mod then
-- 				return nil
-- 			end
-- 			local v = require(mod)
-- 			t[k] = v
-- 			return v
-- 		end
-- 	})
-- end

function command.update_configs(configs)
	config_db.update(configs)
end

function command.init(configs)
	config_db.init(configs)
	desk_ctrl.init()
	module_ctrl = require(modulename.."."..modulename.."_ctrl")
	module_ctrl.init()
end

function command.login_desk(ctx, agent)
	return desk_ctrl.login_desk(ctx, agent)
end

function command.logout_desk(ctx)
	return desk_ctrl.logout_desk(ctx)
end

function command.player_reconnect(ctx)
	return desk_ctrl.player_reconnect(ctx)
end

function command.player_disconnect(ctx)
	return desk_ctrl.player_disconnect(ctx)
end

function service.on_start()
	server_id = tonumber(skynet.getenv("cluster_server_id"))
	current_conf = cluster_config[server_id]
end

service.modules.desk = require("desk.desk_impl")
service.modules[modulename] = require(modulename.."."..modulename.."_impl")
service.start()