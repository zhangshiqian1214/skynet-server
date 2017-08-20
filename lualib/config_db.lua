--[[
	@ filename : db_helper.lua
	@ author   : zhangshiqian1214@163.com (kuzhu)
	@ modify   : 2017-03-25 10:53
	@ company  : zhangshiqian
]]

local conf = require "sharedata.corelib"

local config_db = {}
local config_keys = {}

setmetatable(config_db, {
	__index = function(t, k)
		local value = config_keys[k]
		if value == nil then
			return require("config."..k)
		end
		if value[2] then
			return value[2]
		end
		local obj = conf.box(value[1])
		value[2] = obj
		return obj
	end
})


function config_db.init(configs)
	for k, p in pairs(configs) do
		config_keys[k] = {p}
	end
end

function config_db.update(configs)
	for k, p in pairs(configs) do
		local value = config_keys[k]
		if value then
			if value[2] then
				conf.update(value[2], p)
			end
			value[1] = p
		else
			config_keys[k] = {p}
		end
	end
end

return config_db
