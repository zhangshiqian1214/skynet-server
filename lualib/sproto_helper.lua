local proto_map = require "proto_map"
local sprotoloader = require "sprotoloader"
local sproto = require "sproto"

local sproto_helper = {}
local package_sp = nil

local function get_sproto_sp(id)
	return sprotoloader.load(id)
end

local function get_package_sp()
	if package_sp then
		return package_sp
	end
	package_sp = 
end

function sproto_helper.pack(header, data)
	local 
end

function sproto_helper.unpack(buffer)

end


function sproto_helper.register(path)
	path = path or "proto/sproto/spb/"
	for id, v in pairs(PROTO_FILES) do
		local fp = assert(io.open(path..v..".spb", "rb"))
		local binary = fp:read "*all"
		sprotoloader.save(binary, id)
	end
end

return sproto_helper




