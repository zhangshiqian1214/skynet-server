--[[
	@ filename : loggerd.lua
	@ author   : zhangshiqian1214@163.com
	@ modify   : 2017-08-23 17:53
	@ company  : zhangshiqian1214
]]

require "skynet.manager"
local skynet = require "skynet"
local logpath = skynet.getenv("logpath") or "./log"
local command = {}
local file_list = {}

local log_level_desc = {
    [0]   = "NOLOG",
    [10]  = "DEBUG",
    [20]  = "INFO",
    [30]  = "WARNING",
    [40]  = "ERROR",
    [50]  = "CRITICAL",
    [60]  = "FATAL",
}

local function init()
	local logfile = skynet.getenv("logfile") or "default.log"
	os.execute("mkdir -p " .. logpath)
	local file = assert(io.open(logpath.."/"..logfile, "a"), "log file open failed")
	file_list["default"] = file
end

local function dumplog(name, text)
	local file = file_list[name]
	if not file then
		return
	end

	file:write(text)
	file:write("\n")
	file:flush()
end

local function log_format(object)
	if object.tags and next(object.tags) then
        return string.format("[%s %s] [%s]%s %s", object.timestamp, object.level,table.concat(object.tags, ","), object.src, object.msg)
    else
        return string.format("[%s %s]%s %s", object.timestamp, object.level, object.src, object.msg)
    end
end

function command.log(name, modname, level, timestamp, msg, src, tags)
	dumplog("default", log_format {
		name = name,
		modname = modname,
		level = log_level_desc[level],
		timestamp = timestamp,
		msg = msg,
		src = src or '',
		tags = tags,
	})
end

function command.new_log(name, filename)
	local file = assert(io.open(logpath.."/"..filename, "a"), "log file open failed")
	file_list[name] = file
end

local function dispatch(session, address, cmd, ...)
	local func = assert(command[cmd], string.format("command[%s] is nil", tostring(cmd)))
	if session > 0 then
		skynet.retpack(func(...))
	else
		func(...)
	end
end

skynet.start(function()
	init()
	skynet.dispatch("lua", dispatch)
end)