local proto_map = require "proto_map"
local sprotoloader = require "sprotoloader"
local sproto = require "sproto"

local sproto_helper = {}
local sp_pool = {}

local toboolean
local base_type = {
	["integer"] = tonumber ,
	["string"] = tostring ,
	["boolean"] = toboolean ,
}

local function toboolean(v)
	if v == "true" then return true end
	if v == "false" then return false end
	return nil
end

local function get_sproto_sp(id)
	if sp_pool[id] then
		return sp_pool[id]
	end
	sp_pool[id] = sprotoloader.load(id)
	return sp_pool[id]
end

function sproto_helper.pack_header(header)
	local sp = get_sproto_sp(PROTO_FILES.package)
	if not sp then
		return nil
	end
	return sp:encode("Package", header)
end

function sproto_helper.unpack_header(msg, sz)
	local sp = get_sproto_sp(PROTO_FILES.package)
	if not sp then
		return nil
	end
	local binary = sproto.unpack(msg, sz)
	local header, size = sp:decode("Package", binary)
	local content = binary:sub(size + 1)
	return header, content
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

	local proto = proto_map.protos[header.protoid]
	if not proto then
		return nil
	end

	local id = PROTO_FILES[proto.module]
	if not id then
		return nil
	end

	local sp = get_sproto_sp(id)
	if not sp then
		return nil
	end

	if header.response == 0 and proto.request and data then
		local switch_func = base_type[proto.request]
		if switch_func then
			binary = binary .. tostring(data)
		else
			binary = binary .. sp:encode(proto.request, data)
		end
		
	elseif proto.response and data then
		local switch_func = base_type[proto.response]
		if switch_func then
			binary = binary .. tostring(data)
		else
			binary = binary .. sp:encode(proto.response, data)
		end
	end
	return sproto.pack(binary)
end

function sproto_helper.unpack(msg, sz)
	local header, content = sproto_helper.unpack_header(msg, size)
	if not header or not header.protoid then
		return nil
	end
	local proto = proto_map.protos[header.protoid]
	if not proto then
		return nil
	end
	local id = PROTO_FILES[proto.module]
	if not id then
		return nil
	end
	local sp = get_sproto_sp(id)
	if not sp then
		return nil
	end

	local result
	if header.response == 1 and proto.response and content and #content > 0 then
		local switch_func = base_type[proto.response]
		if switch_func then
			result = switch_func(content)
		else
			result = sp:decode(proto.response, content)
		end
	elseif proto.request and content and #content > 0 then
		local switch_func = base_type[proto.request]
		if switch_func then
			result = switch_func(content)
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




