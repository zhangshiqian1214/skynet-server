local skynet = require "skynet"
local share_memory = require "share_memory"

local function test()
	for i=1, 10 do

		--print(share_memory["test"])

		local data = share_memory["test"]

		data = "test"..i

		share_memory["test"] = data

		skynet.sleep(1 * 100)
	end
end

skynet.start(function()

	skynet.fork(test)

end)