--
-- Author: Kuzhu1990
-- Date: 2013-12-16 18:52:11
-- redis pubsub
-- 

local class = require "class"
local skynet = require "skynet"
local redis = require "skynet.db.redis"

local RedisMQ = class()
function RedisMQ:_init(conf, on_message)
	self._db_conf = conf
	self._db = redis.connect(conf)
	self._subscribe_map = {}
	-- need subscribe
	self._subscribe_list = {}
	self._psubscribe_list = {}

	-- watch
	self._watch = nil
	self._pause = true
	self._on_message = on_message
	self._watch = redis.watch(self._db_conf)
end

function RedisMQ:start_watching()
	self._pause = false
	local function watching()

		self._watch:subscribe("watching.pause")

		while not self._pause do
			local  data, method = self._watch:message()
			if method ~= "watching.pause" and self._on_message then
				self._on_message(method, data)
			end
		end
	end
	skynet.fork(watching)
end

function RedisMQ:stop_watching()
	self._pause = true
	self._db:publish("watching.pause", "pause")
end

-- publish message
function RedisMQ:publish(method, message)
	self._db:publish(method, message)
end

-- subscribe message
function RedisMQ:subscribe(method)
	if self._subscribe_map[method] then return end

	--self:stop_watching()

	self._watch:subscribe(method)

	self._subscribe_map[method] = true	

	--self:start_watching()
end

-- psubscribe message
function RedisMQ:psubscribe(method)
	if self._subscribe_map[method] then return end
	
	--self:stop_watching()

	self._watch:psubscribe(method)

	self._subscribe_map[method] = true

	--self:start_watching()

end

-- unsubscribe message
function RedisMQ:unsubscribe(method)
	if not self._subscribe_map[method] then return end
end

function RedisMQ:get_redis_db()
	return self._db
end

return RedisMQ
