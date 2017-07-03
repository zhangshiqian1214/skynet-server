local skynet  = require "skynet"
local mysql = require "skynet.db.mysql"

local function dispatch(session, addr, cmd, ...)

end

skynet.start(function()

	skynet.dispatch("lua", dispatch)

end)