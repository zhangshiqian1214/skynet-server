local root       = "../"
local skynetroot = root.."skynet/"
package.path     = skynetroot.."lualib/?.lua;"
package.cpath    = skynetroot.."luaclib/?.so;"


local protoPrefix = root .. "sproto/"
local spbPrefix   = root .. "spb/"
local parser = require "sprotoparser"
local sprotoGen = {}

function sprotoGen.create(files, outfile)
	local output = ""
	for _, v in pairs(files) do
		local filename = protoPrefix .. v
		local f = assert(io.open(filename), "Can't open sproto file")
		local data = f:read "a"
		output = output .. "\n" .. data
	end
	local file = io.open(spbPrefix.. outfile, "w+b")
	file:write(parser.parse(output))
	file:close()
end


local c2sfiles = {
  "package.sproto",
  "gate.sproto",
  "auth.sproto",
  "busi.sproto",
  "role.sproto",
  "lobby.sproto",
  "game.sproto",
  "mahjong.sproto",
  "recorder.sproto",
  "nn.sproto",
  "sandongmj.sproto",
}
sprotoGen.create(c2sfiles, "C2S.spb")
