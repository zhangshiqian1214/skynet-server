--
-- Author: Kuzhu1990
-- Date: 2017-06-16 18:52:11
-- 进程间内存共享
-- 

local skynet = require "skynet"
local stm = require "skynet.stm"

local addr

local share_memory = {}
local share_data_map = {}

local function init()
	addr = skynet.uniqueservice("share_memoryd")
end

local function get_stmobj(name)
	if share_data_map[name] then
		return share_data_map[name].stmobj
	end
	
	local stmcopy = skynet.call(addr, "lua", "get_stmobj", name)
	if not stmcopy then
		return
	end

	local stmobj = stm.newcopy(stmcopy)
	share_data_map[name] = {}
	share_data_map[name].stmobj = stmobj
	share_data_map[name].data = nil

	return stmobj
end

local function get_share_memory(name)
	--print("get_share_memory name=", name)
	local stmobj = get_stmobj(name)
	if not stmobj then
		return
	end

	local ok, data = stmobj(skynet.unpack)
	if not ok then --旧数据
		return share_data_map[name].data
	end

	share_data_map[name].data = data
	return share_data_map[name].data
end

local function set_share_memory(name, data)
	--print("set_share_memory name=", name, "data=", data)
	local stmobj = get_stmobj(name)
	if not stmobj then
		skynet.call(addr, "lua", "set_stmobj", name, data)
		stmobj = get_stmobj(name)
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


