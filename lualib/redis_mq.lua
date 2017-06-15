local class = require "class"
local skynet = require "skynet"
local redis = require "skynet.db.redis"


local RedisMQ = class()
function RedisMQ:_init(conf, onMessage)
	self._db = redis.connect(conf)
	self._subscribeMap = {}
	-- need subscribe
	self._subscribeList = {}
	self._psubscribeList = {}

	-- watch
	self._watch = nil
	self._pause = true
	self._onMessage = onMessage
	local function watching()
		self._watch = redis.watch(conf)
		self._watch:subscribe("watching.pause")
		while true do
			if not self._pause then
				local  data, method = self._watch:message()
				if method ~= "watching.pause" and self._onMessage then
					self._onMessage(method, data)
				end
			end
			
			for _, v in pairs(self._subscribeList) do	
				self._watch:subscribe(v)
				self._subscribeMap[v] = true
			end

			for _, v in pairs(self._psubscribeList) do
				self._watch:psubscribe(v)
				self._subscribeMap[v] = true
			end

			self._subscribeList = {}
			self._psubscribeList = {}

			if not table.empty(self._subscribeMap) then
				self._pause = false
			end
			
		end
	end
	skynet.fork(watching)
end

-- publish message
function RedisMQ:publish(method, message)
	self._db:publish(method, message)
end

-- subscribe message
function RedisMQ:subscribe(method)
	if self._subscribeMap[method] then return end

	table.insert(self._subscribeList, method)
	
	self._pause = true

	self._db:publish("watching.pause", "pause")
	
end

-- psubscribe message
function RedisMQ:psubscribe(method)
	if self._subscribeMap[method] then return end
	
	table.insert(self._psubscribeList, method)
	
	self._pause = true

	self._db:publish("watching.pause", "pause")
end

-- unsubscribe message
function RedisMQ:unsubscribe(method)
	if not self._subscribeMap[method] then return end

end

return RedisMQ
