--[[
	@ filename : db_helper.lua
	@ author   : kuzhu1990
	@ modify   : 2017-03-25 10:53
	@ company  : kuzhu1990@hotmail.com
]]

local skynet = require "skynet"
local sharedata_core = require "skynet.sharedata.corelib"
local pathprefix = skynet.getenv("pathprefix") or "config."

local  config_helper = {}

function config_helper.new(path)
	local data = require(pathprefix .. path)
	local cobj = sharedata_core.host.new(data)
	package.loaded[pathprefix .. path] = nil
	return cobj
end


return config_helper
