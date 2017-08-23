--[[
	@ filename : sproto_helper.lua
	@ author   : zhangshiqian1214@163.com
	@ modify   : 2017-08-23 17:53
	@ company  : zhangshiqian1214
]]

local proto_map = require "proto_map"
local sprotoloader = require "sprotoloader"
local sproto = require "sproto"

local sproto_helper = {}
local sp_pool = {}

local pack_base_type = {
	["integer"] = function(data) return string.pack(">i", data) end,
	["string"] = function(data) return string.pack(">s2", data) end,
	["boolean"] = function(data)
		if data == true then
			return string.pack(">B", 1)
		elseif data == false then
			return string.pack(">B", 2)
		end
		return string.pack(">B", 0)
	end,
}

local unpack_base_type = {
	["integer"] = function(data) return string.unpack(">i", data) end,
	["string"] = function(data) return string.unpack(">s2", data) end,
	["boolean"] = function(data)
		 local bool_type = string.unpack(">B", data)
		 if bool_type == 0 then return nil end
		 if bool_type == 1 then return true end
		 if bool_type == 2 then return false end
	end ,
}



local function get_sproto_sp(module)
	if sp_pool[module] then
		return sp_pool[module]
	end
	local id = PROTO_FILES[module]
	if not id then
		return nil
	end
	sp_pool[module] = sprotoloader.load(id)
	return sp_pool[module]
end

function sproto_helper.pack_header(header)
	local sp = get_sproto_sp("package")
	if not sp then
		return nil
	end
	return sp:encode("Package", header)
end

function sproto_helper.unpack_header(msg, sz)
	local sp = get_sproto_sp("package")
	if not sp then
		return nil
	end
	local binary = sproto.unpack(msg, sz)
	local header, size = sp:decode("Package", binary)
	local content = binary:sub(size + 1)
	return header, content
end

--for test websocket
function sproto_helper.unpack_data(header, content)
	if not header or not header.protoid then
		return nil
	end
	local proto = proto_map.protos[header.protoid]
	if not proto then
		return nil
	end

	local sp = get_sproto_sp(proto.module)
	if not sp then
		return nil
	end

	local result
	if header.response == 1 and proto.response and content and #content > 0 then
		local unpack_func = unpack_base_type[proto.response]
		if unpack_func then
			result = unpack_func(content)
		else
			result = sp:decode(proto.response, content)
		end
	elseif proto.request and content and #content > 0 then
		local unpack_func = unpack_base_type[proto.request]
		if unpack_func then
			result = unpack_func(content)
		else
			result = sp:decode(proto.request, content)
		end
	end
	return header, result
end

function sproto_helper.pack(header, data)
	local proto = proto_map.protos[header.protoid]
	if not proto then
		return nil
	end

	local binary = sproto_helper.pack_header(header)
	if not binary then
		return nil
	end

	local sp = get_sproto_sp(proto.module)
	if not sp then
		return nil
	end

	if header.response == 0 and proto.request and data then
		local pack_func = pack_base_type[proto.request]
		if pack_func then
			binary = binary .. pack_func(data)
		else
			binary = binary .. sp:encode(proto.request, data)
		end
		
	elseif proto.response and data then
		local pack_func = pack_base_type[proto.response]
		if pack_func then
			binary = binary .. pack_func(data)
		else
			binary = binary .. sp:encode(proto.response, data)
		end
	end
	return sproto.pack(binary)
end

function sproto_helper.unpack(msg, size)
	local header, content = sproto_helper.unpack_header(msg, size)
	if not header or not header.protoid then
		return nil
	end
	local proto = proto_map.protos[header.protoid]
	if not proto then
		return nil
	end

	local sp = get_sproto_sp(proto.module)
	if not sp then
		return nil
	end

	local result
	if header.response == 1 and proto.response and content and #content > 0 then
		local unpack_func = unpack_base_type[proto.response]
		if unpack_func then
			result = unpack_func(content)
		else
			result = sp:decode(proto.response, content)
		end
	elseif proto.request and content and #content > 0 then
		local unpack_func = unpack_base_type[proto.request]
		if unpack_func then
			result = unpack_func(content)
		else
			result = sp:decode(proto.request, content)
		end
	end
	return header, result
end


function sproto_helper.register_protos(path)
	path = path or "proto/sproto/spb/"
	for filename, id in pairs(PROTO_FILES) do
		local fp = assert(io.open(path..filename..".spb", "rb"))
		local binary = fp:read "*all"
		sprotoloader.save(binary, id)
	end
end

return sproto_helper




