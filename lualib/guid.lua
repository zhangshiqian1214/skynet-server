local template ="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
return function()
        local data = io.open("/dev/urandom", "r"):read(4)
        math.randomseed(os.time() + data:byte(1) + (data:byte(2) * 256) + (data:byte(3) * 65536) + (data:byte(4) * 4294967296))
        return string.gsub(template, "x", function (c)
                local v = (c == "x") and math.random(0, 0xf) or math.random(8, 0xb)
                return string.format("%x", v)
        end)
end

