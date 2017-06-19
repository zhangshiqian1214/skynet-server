local class = require "class"
local skynet = require "skynet"
local redis = require "skynet.db.redis"

local RedisMQ = class()
function RedisMQ:_init(conf, on_message)
	self._db = redis.connect(conf)
	self._subscribe_map = {}
	-- need subscribe
	self._subscribe_list = {}
	self._psubscribe_list = {}

	-- watch
	self._watch = nil
	self._pause = true
	self._on_message = on_message
	local function watching()
		self._watch = redis.watch(conf)
		self._watch:subscribe("watching.pause")
		while true do
			if not self._pause then
				local  data, method = self._watch:message()
				if method ~= "watching.pause" and self._on_message then
					self._on_message(method, data)
				end
			end
			
			for _, v in pairs(self._subscribe_list) do	
				self._watch:subscribe(v)
				self._subscribe_map[v] = true
			end

			for _, v in pairs(self._psubscribe_list) do
				self._watch:psubscribe(v)
				self._subscribe_map[v] = true
			end

			self._subscribe_list = {}
			self._psubscribe_list = {}

			if not table.empty(self._subscribe_map) then
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
	if self._subscribe_map[method] then return end

	table.insert(self._subscribe_list, method)
	
	self._pause = true

	self._db:publish("watching.pause", "pause")
	
end

-- psubscribe message
function RedisMQ:psubscribe(method)
	if self._subscribe_map[method] then return end
	
	table.insert(self._psubscribe_list, method)
	
	self._pause = true

	self._db:publish("watching.pause", "pause")
end

-- unsubscribe message
function RedisMQ:unsubscribe(method)
	if not self._subscribe_map[method] then return end

end

return RedisMQ
