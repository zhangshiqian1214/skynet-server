local skynet = require "skynet"
local context = require "context"
local queue = require "skynet.queue"
local cd_ctrl = {}

local cs = queue()
local incr_id = 0
local cache_cds = {}
local cd_callbacks = {}
local cd_listeners = {}

local function queue_func(func, ...)
	local args = {...}
	local ok, msg = xpcall(function()
		func(table.unpack(args))
	end, debug.traceback)
	if not ok then
		error(msg)
	end
end

local function get_incr_id()
	incr_id = incr_id + 1
	return incr_id
end

local function handle_cd_result(cd_type, id, ...)
	local cd = cache_cds[id]
	if not cd then
		return
	end
	local callback = cd_callbacks[cd_type]
	if not callback then
		return
	end
	cs(queue_func, callback, cd_type, id, ...)

	cd_ctrl.del_cd(id)
	return
end

function cd_ctrl.register_callback(cd_type, func)
	cd_callbacks[cd_type] = func
end

function cd_ctrl.register_listener(cd_type, ctx)
	cd_listeners[cd_type] = cd_listeners[cd_type] or {}
	cd_listeners[cd_type][ctx.player_id] = ctx
end

function cd_ctrl.unregister_listener(cd_type, ctx)
	if cd_listeners[cd_type] and cd_listeners[cd_type][ctx.player_id] then
		cd_listeners[cd_type][ctx.player_id] = nil
	end
end

function cd_ctrl.add_cd(cd_type, seconds, ...)
	local id = get_incr_id()
	local args = {...}
	local cd = {
		id = id,
		cd_type = cd_type,
		end_time = os.time() + seconds,
		args = args,
	}
	cache_cds[id] = cd
	skynet.timeout(seconds * 100, function() handle_cd_result(cd_type, id, table.unpack(args)) end)
	if cd_listeners[cd_type] then
		local event = {
			id = id,
			cd_type = cd.cd_type,
			cd_time = seconds,
		}
		for player_id, ctx in pairs(cd_listeners[cd_type]) do
			context.send_client_event(ctx, M_DESK.add_cd_event, event)
		end
	end
	return id
end

function cd_ctrl.del_cd(id)
	local cd = cache_cds[id]
	if cd then
		cache_cds[id] = nil
		if cd_listeners[cd.cd_type] then
			local event = {
				id = id,
				cd_type = cd.cd_type,
			}
			for player_id, ctx in pairs(cd_listeners[cd.cd_type]) do
				context.send_client_event(ctx, M_DESK.del_cd_event, event)
			end
		end
	end
end

function cd_ctrl.on_login(ctx)
	for _, v in pairs(cache_cds) do
		if cd_listeners[v.cd_type] and  cd_listeners[v.cd_type][ctx.player_id] then
			local event = {
				id = id,
				cd_type = v.cd_type,
				cd_time = v.end_time - os.time(),
			}
			context.send_client_event(ctx, M_DESK.add_cd_event, event)
		end
	end
end

function cd_ctrl.on_logout(ctx)
	
end

return cd_ctrl