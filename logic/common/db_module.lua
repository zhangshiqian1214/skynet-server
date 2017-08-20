local skynet = require "skynet"

local db_modules = {}
local modules = {}

setmetatable(db_modules, {
	__index = function(t, k)
		local mod = modules[k]
		if mod ~= nil then
			return mod
		end
		mod = require(k.."."..k.."_db")
		if mod then
			modules[k] = mod
		end
		return mod
	end
})

return db_modules

