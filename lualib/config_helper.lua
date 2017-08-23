--[[
	@ filename : config_helper.lua
	@ author   : zhangshiqian1214@163.com
	@ modify   : 2017-08-23 17:53
	@ company  : zhangshiqian1214
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
