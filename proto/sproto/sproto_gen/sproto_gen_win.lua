local root    = "../"
package.path  = "lualib/?.lua;"
package.cpath = "luaclib/?.dll;"
local parser  = require "sprotoparser"

local protoDir = root .. "sproto/"
local spbDir   = root .. "spb/"
local sprotoGen = {}

function sprotoGen.create(files)
	local dumpFiles = {}
	
	for k, v in pairs(files) do
		local filename = protoDir .. v
		local f = assert(io.open(filename), "Can't open sproto filename["..filename.."]")
		local data = f:read "a"
		dumpFiles[k] = dumpFiles[k] or ""
		dumpFiles[k] = dumpFiles[k] .. data
	end

	for k, v in pairs(dumpFiles) do
		local file = io.open(spbDir .. k ..".spb", "w+b")
		file:write(parser.parse(v))
		file:close()
	end
end

local files = {
  package = "package.sproto",
  gate = "gate.sproto",
  auth = "auth.sproto",
  hall = "hall.sproto",
  player = "player.sproto",
  bank = "bank.sproto",
  cash = "cash.sproto",
  push = "push.sproto",
  message = "message.sproto",
  room = "room.sproto",
  desk = "desk.sproto",
  xpnn = "xpnn.sproto",
  lrnn = "lrnn.sproto",
  ddz = "ddz.sproto",
  zjh = "zjh.sproto",
  lrsh = "lrsh.sproto",
}

sprotoGen.create(files)



