--[[
	@ filename : share_memory.lua
	@ author   : zhangshiqian1214@163.com
	@ modify   : 2017-08-23 17:53
	@ company  : zhangshiqian1214
]]

local skynet = require "skynet"
local stm = require "skynet.stm"

local addr

local share_memory = {}
local share_data_map = {}

local function init()
	addr = skynet.uniqueservice("share_memoryd")
end

local function get_stmcopy(name)
	if share_data_map[name] then
		return share_data_map[name].stmcopy
	end
	
	local stmobj = skynet.call(addr, "lua", "get_stmobj", name)
	if not stmobj then
		return nil
	end
	share_data_map[name] = {}
	share_data_map[name].stmcopy = stm.newcopy(stmobj)
	share_data_map[name].data = nil
	return share_data_map[name].stmcopy
end

local function get_share_memory(name)
	local stmcopy = get_stmcopy(name)
	if not stmcopy then
		return
	end

	local ok, data = stmcopy(skynet.unpack)
	if not ok then --旧数据
		return share_data_map[name].data
	end
	share_data_map[name].data = data
	return share_data_map[name].data
end

local function set_share_memory(name, data)
	local stmcopy = get_stmcopy(name)
	if not stmcopy then
		skynet.call(addr, "lua", "set_stmobj", name, data)

		stmcopy = get_stmcopy(name)
		share_data_map[name].data = data
		return
	end
	
	skynet.call(addr, "lua", "set_stmobj", name, data)
	share_data_map[name].data = data
	return
end

setmetatable(share_memory, {
	__index = function(t, k)
		return get_share_memory(k)
	end,
	__newindex = function(t, k, v)
		return set_share_memory(k, v)
	end,
})


skynet.init(init)


return share_memory


