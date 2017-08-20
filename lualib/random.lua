local skynet = require "skynet"
local mt19937 = require "mt19937"
local random = {}

local random_type = tonumber(skynet.getenv("random_type"))
local __randomseed = os.time() + skynet.self()


function random.randi(i, j)
	__randomseed = __randomseed + 1
	if random_type == RANDOM_TYPE.mt_19937 then --随机性低,快
		mt19937.init(__randomseed)
		if not j then
			j = i + 1 
			return mt19937.randi(1, i+1)
		else
			return mt19937.randi(i, j+1)
		end
	elseif random_type == RANDOM_TYPE.linux_urandom then --随机性中,快
		local data = io.open("/dev/urandom", "r"):read(4)
        math.randomseed(os.time() + data:byte(1) + (data:byte(2) * 256) + (data:byte(3) * 65536) + (data:byte(4) * 4294967296))
        return math.random(i, j)
    elseif random_type == RANDOM_TYPE.linux_random then --随机性高,慢
    	local data = io.open("/dev/random", "r"):read(4)
        math.randomseed(os.time() + data:byte(1) + (data:byte(2) * 256) + (data:byte(3) * 65536) + (data:byte(4) * 4294967296))
        return math.random(i, j)
	else --随机性极低
		math.randomseed(__randomseed)
		return math.random(i, j)
	end
end

function random.random_one(list)
	return list[random.randi(1, #list)]
end

function random.random_shuffle(list)
	
end

return random
