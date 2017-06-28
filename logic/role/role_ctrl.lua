local offline_ctrl = require "offline.offline_ctrl"
local agent_ctrl = require "agent.agent_ctrl"
local role_ctrl = {}

function role_ctrl.get_role_info(ctx, req)
	local role = agent_ctrl.get_role(ctx.role_id)
	if not role then
		return
	end
	return role:get_role_info(ctx, req)
end

return role_ctrl