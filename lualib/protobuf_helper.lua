local protobuf = require "protobuf"
local proto_map = require "proto_map"
local protobuf_helper = {}


function protobuf_helper.pack(header, data)

end

function protobuf_helper.unpack(buffer)

end

function protobuf_helper.register(path)
	path = path or "proto/protobuf/pb/"
	for _, file in pairs(PROTO_FILES) do
		protobuf.register_file(path .. file..".pb")
	end
end

return protobuf_helper