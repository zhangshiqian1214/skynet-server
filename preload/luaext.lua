function table.empty(t)
	return _G.next(t) == nil
end

function table.tostring(root)
    if root == nil then
        return "nil"
    end
    local cache = {  [root] = "." }
    local function _dump(t,space,name)
        local temp = {}
        for k,v in pairs(t) do
            local key = tostring(k)
            if cache[v] then
                table.insert(temp,"+" .. key .. " {" .. cache[v].."}")
            elseif type(v) == "table" then
                local new_key = name .. "." .. key
                cache[v] = new_key
                table.insert(temp,"+" .. key .. _dump(v,space .. (next(t,k) and "|" or " " ).. string.rep(" ",#key),new_key))
            else
                if type(v) == "string" then
                    table.insert(temp,"+" .. key .. " [\"" .. tostring(v).."\"]")
                else
                    table.insert(temp,"+" .. key .. " [" .. tostring(v).."]")
                end
                
            end
        end
        return table.concat(temp,"\n"..space)
    end
    return (_dump(root, "",""))
end