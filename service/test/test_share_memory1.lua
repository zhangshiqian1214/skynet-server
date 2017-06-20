local skynet = require "skynet"
local share_memory = require "share_memory"

--测试服务间数据交换
local function test()
	skynet.sleep(2 * 100)
	for i=1, 10 do
		local data = share_memory["test"]
		print("data=", data)

		skynet.sleep(1 * 100)

	end
end

skynet.start(function()
	
	skynet.fork(test)

end)