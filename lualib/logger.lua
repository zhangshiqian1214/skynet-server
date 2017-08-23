--[[
	@ filename : logger.lua
	@ author   : zhangshiqian1214@163.com
	@ modify   : 2017-08-23 17:53
	@ company  : zhangshiqian1214
]]

local skynet = require "skynet"
local assert = assert
local error  = error
local print = print
local tconcat = table.concat
local tinsert = table.insert
local srep = string.rep
local type = type
local pairs = pairs
local tostring = tostring
local next = next

local addr
local logger = {}
local starttime = skynet.starttime()

logger.NOLOG    = 0   --不打日志
logger.DEBUG    = 10  --只在调试时使用
logger.INFO     = 20  --记录信息时使用
logger.WARNING  = 30  --警告级别
logger.ERROR    = 40  --错误日志
logger.CRITICAL = 50  --严重错误
logger.FATAL    = 60  --致命错误

local _default_module_name = "skynet"
local _logger_name = nil
local _module_name = nil
local _to_screen = true
local _log_level = logger.DEBUG
local _log_src = true
local _dump_level = logger.NOLOG
local _dum_num = 100
local _dump_list = { tail = 1, len = _dum_num }
local _tag_table = {}
local _tags = nil
local _stack_level = 3

local function _lnew(n)
    local l = {}
    l.tail = 1
    l.len = n
    return l
end

local function _lreset(l)
    l.tail = 1
    return l
end

local function _lpush(l,...)
    l[l.tail] = {...}
    l[l.tail - l.len] = nil
    l.tail = l.tail + 1
end

local function _lempty(l)
    return l.tail == 1
end

local function _lrange(l)
    if l.tail <= l.len then
        return 1, l.tail-1
    end

    return l.tail - l.len, l.tail-1
end


local function init()
	addr = skynet.uniqueservice("loggerd")
end

local function log_to_disk(...)
	skynet.send(addr, "lua", "log", ...)
end

local function dump_log_to_disk(t)
	for i=1, #t do
		log_to_disk(table.unpack(t[i]))
	end
end

local function get_log_src(level)
	local info = debug.getinfo(level+1)
	local src = info.source
	return src..":"..info.currentline..":"
end

local function log_timestamp(timestamp)
	local sec = timestamp / 100
	local ms  = timestamp % 100
	local f = os.date("%Y-%m-%d %H:%M:%S", math.floor(starttime + sec))
	f = string.format("%s.%02d", f, ms)
    return f
end

local function table_serialize(root)
	local cache = {  [root] = "." }
	local function _dump(t,space,name)
		local temp = {}
		for k,v in pairs(t) do
			local key = tostring(k)
			if cache[v] then
				tinsert(temp,"+" .. key .. " {" .. cache[v].."}")
			elseif type(v) == "table" then
				local new_key = name .. "." .. key
				cache[v] = new_key
				tinsert(temp,"+" .. key .. _dump(v,space .. (next(t,k) and "|" or " " ).. srep(" ",#key),new_key))
			else
				tinsert(temp,"+" .. key .. " [" .. tostring(v).."]")
			end
		end
		return tconcat(temp,"\n"..space)
	end
	return (_dump(root, "",""))
end

local function log_format(level, ...)
	local t = {...}
	local out  = ''
	for _, v in pairs(t) do
		if level <= logger.DEBUG and type(v) == "table" then
			v_str = "table:" .. table_serialize(v)
		else
			v_str = tostring(v)
		end
		if out == '' then
			out = v_str
		else
			out = out .. "\t" .. v_str
		end
	end
	return out
end

local function tag_table_to_args(tag_table)
	if tag_table and next(tag_table) then
        local tags = {}
        for k,v in pairs(tag_table) do
            tags[#tags + 1] = k..":"..v
        end
        return tags
    end
end

function logger.cache(...)
	_lpush(_dump_list, ...)
end

function logger.get_log_message(level, timestamp, src, ...)
	local msg = log_format(level, ...)
    local modname = _module_name or _default_module_name
    local name = _logger_name or modname
    local timestamp = log_timestamp(timestamp)
    return name, modname, level, timestamp, msg, src, tags
end

function logger.dump()
	if _lempty(_dump_list) then
		return
	end

	local head, tail = _lrange(_dump_list)

	local log_message_list = {}
    for i= head,tail do
        log_message_list[#log_message_list + 1] = {logger.get_log_message(table.unpack(_dump_list[i]))}
    end
    dump_log_to_disk(log_message_list)
    _lreset(_dump_list)
end

function logger.log_i(...)
	log_to_disk(logger.get_log_message(...))
end

function logger.log(level, ...)
	if _dump_level == logger.NOLOG and level < _log_level then
        return
    end

    local timestamp = skynet.now()
    local src = _log_src and get_log_src(_stack_level) or ''

    if level < _log_level then
        logger.cache(level, timestamp, src, ...)
    else
        logger.log_i(level, timestamp, src, ...)
        if _dump_level ~= logger.NOLOG and level >= _dump_level then
            logger.dump()
        end
    end
end


function logger.debug(...)
	logger.log(logger.DEBUG, ...)
end

function logger.debugf(format, ...)
	logger.log(logger.DEBUG, string.format(format, ...))
end

function logger.info(...)
	logger.log(logger.INFO, ...)
end

function logger.infof(format, ...)
	logger.log(logger.INFO, string.format(format, ...))
end

function logger.warning(...)
	logger.log(logger.WARNING, ...)
end

function logger.warningf(format, ...)
	logger.log(logger.WARNING, string.format(format, ...))
end

function logger.error(...)
	logger.log(logger.ERROR, ...)
end

function logger.errorf(format, ...)
	logger.log(logger.ERROR, string.format(format, ...))
end

function logger.fatal(...)
	logger.log(logger.FATAL, ...)
end

function logger.fatalf(format, ...)
	logger.log(logger.FATAL, string.format(format, ...))
end

function logger.assert(v, message)
	if not v then
		logger.log(logger.ERROR, "assert:"..tostring(message))
	end
	assert(v, message)
end

function logger.set_module(modname)
	_module_name = modname
end

function logger.set_tag(key, value)
	_tag_table[key] = value
	_tags = tag_table_to_args(_tag_table)
end

function logger.unset_tag(key)
	_tag_table[key] = nil
	_tags = tag_table_to_args(_tag_table)
end

function logger.set_config(t)
	if t["logger_name"] ~= nil then
		_logger_name = t["logger_name"]
	end

	if t["module_name"] ~= nil then
		_module_name = t["module_name"]
	end

	if t["to_screen"] ~= nil then
		_to_screen = t["to_screen"]
	end

	if t["log_level"] ~= nil then
		_log_level = t["log_level"]
	end

	if t["log_src"] ~= nil then
		_log_src = t["log_src"]
	end

	if t["dump_level"] ~= nil then
		_dump_level = t["dump_level"]
	end

	if _dump_level ~= logger.NOLOG then
		assert(_dump_level > _log_level)
	end
end

skynet.init(init)

return logger
