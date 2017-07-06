local skynet = require "skynet"

local client_msg = {}

function client_msg.dispatch(fd, msg)
	local ok, msg = xpcall(function()
		
	end, debug.traceback)
	if not ok then
		
	end
end

function client_msg.send(fd, ...)
	
end

return client_msg