local skynet = require "skynet"
local proto_map = require "proto_map"
local socket_msg = require "gate.socket_msg"

local CMD = {}
local SOCKET = {}
local gate
local agent = {}

function SOCKET.open(fd, addr)

end

function SOCKET.close(fd)

end

function SOCKET.error(fd, msg)

end

function SOCKET.warning(fd, size)

end

function SOCKET.data(fd, msg)

end


function CMD.start(conf)
	skynet.call(gate, "lua", "open", conf)
end

function CMD.close()

end

skynet.start(funciton()
	skynet.dispatch("lua", function(session, source, cmd, subcmd, ...)
		if cmd == "socket" then
			local f = socket_msg[subcmd]
			f(...)
			-- socket api don't need return
		else
			local f = assert(CMD[cmd])
			if session > 0 then
				skynet.retpack(f(subcmd, ...))
			else
				f(subcmd, ...)
			end
		end
	end)
	gate = skynet.newservice("gate")
end)
