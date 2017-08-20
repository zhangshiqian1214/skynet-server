local skynet = require "skynet"
local json = require "json"
local md5 = require "md5"
local random = require "random"
local db_helper = require "common.db_helper"
local create_player_config = require "config.create_player_config"
local nickname_config = require "config.nickname_config"

local auth_logic = {}

function auth_logic.init()

end

function auth_logic.register_account(ctx, req)
	local conf = create_player_config[req.create_index]
	local account_info = db_helper.call(DB_SERVICE.account, "auth.get_normal_account", nil, req.account)
	if account_info then
		return AUTH_ERROR.account_exist
	end
	local player_id = db_helper.call(DB_SERVICE.unique, "auth.incr_player_id", nil)
	if not player_id then
		return AUTH_ERROR.player_id_limit
	end
	local nickname = req.nickname or random.random_one(nickname_config)
	local player_info = {
		player_id = player_id,
		head_id = conf.head_id,
		head_url = "",
		nickname = nickname,
		sex = conf.sex,
		gold = conf.gold,
		create_time = os.time(),
	}

	db_helper.call(DB_SERVICE.account, "auth.create_player", nil, player_info)

	local account_info = {
		player_id = player_id,
		telephone = req.telephone,
		account = req.account,
		password = req.password,
		create_time = os.time(),
	}
	db_helper.call(DB_SERVICE.account, "auth.create_normal_account", player_id, account_info)
	return SYSTEM_ERROR.success
end

function auth_logic.login_account(ctx, req)
	
	local account_info = db_helper.call(DB_SERVICE.account, "auth.get_normal_account", nil, req.account)
	if not account_info then
		return AUTH_ERROR.account_not_exist
	end
	if account_info.password ~= req.password then
		return AUTH_ERROR.password_wrong
	end
	local player_info = db_helper.call(DB_SERVICE.account, "auth.get_player", account_info.player_id)
	if not player_info then
		return AUTH_ERROR.player_not_exist
	end
	local reply = {}
	reply.player = player_info
	return SYSTEM_ERROR.success, reply
end

function auth_logic.weixin_login(ctx, req)
	local reply = {}
	local weixin_info = db_helper.call(DB_SERVICE.account, "auth.get_weixin_account", nil, req.union_id)
	if not weixin_info then
		local player_id = db_helper.call(DB_SERVICE.unique, "auth.incr_player_id", nil)
		if not player_id then
			return AUTH_ERROR.player_id_limit
		end
		local conf = random.random_one(create_player_config)
		local player_info = {
			player_id = player_id,
			head_id = conf.head_id,
			head_url = req.head_url,
			nickname = req.nickname,
			sex = req.sex,
			gold = conf.gold,
			create_time = os.time(),
		}
		db_helper.call(DB_SERVICE.account, "auth.create_player", nil, player_info)

		weixin_info = {
			player_id = player_id,
			union_id = visit_token,
			create_time = os.time(),
		}
		db_helper.call(DB_SERVICE.account, "auth.create_weixin_account", player_id, weixin_info)

		reply.player = player_info
		return SYSTEM_ERROR.success, reply
	end

	local player_info = db_helper.call(DB_SERVICE.account, "auth.get_player", weixin_info.player_id)
	if not player_info then
		return AUTH_ERROR.player_not_exist
	end
	
	reply.player = player_info
end

function auth_logic.visitor_login(ctx, req)
	local reply = {}
	req.visit_token = (not req.visit_token or req.visit_token == "") and ctx.session or req.visit_token
	
	local visitor_info = db_helper.call(DB_SERVICE.account, "auth.get_visitor_account", nil, req.visit_token)
	if not visitor_info then
		local player_id = db_helper.call(DB_SERVICE.unique, "auth.incr_player_id", nil)
		if not player_id then
			return AUTH_ERROR.player_id_limit
		end
		local conf = random.random_one(create_player_config)
		local nickname = random.random_one(nickname_config)
		local player_info = {
			player_id = player_id,
			head_id = conf.head_id,
			head_url = "",
			nickname = "游客"..player_id,
			sex = conf.sex,
			gold = conf.gold,
			create_time = os.time(),
		}

		db_helper.call(DB_SERVICE.account, "auth.create_player", nil, player_info)

		visitor_info = {
			player_id = player_id,
			visit_token = req.visit_token,
			create_time = os.time(),
		}
		db_helper.call(DB_SERVICE.account, "auth.create_visitor_account", player_id, visitor_info)
		
		reply.player = player_info
		reply.visit_token = req.visit_token
		return SYSTEM_ERROR.success, reply
	end

	local player_info = db_helper.call(DB_SERVICE.account, "auth.get_player", visitor_info.player_id)
	if not player_info then
		return AUTH_ERROR.player_not_exist
	end
	
	reply.player = player_info
	reply.visit_token = visit_token
	return SYSTEM_ERROR.success, reply
end	

return auth_logic