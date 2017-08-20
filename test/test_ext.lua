function math.round(num)
    return math.floor(num + 0.5)
end

function tonum(v, base)
    return tonumber(v, base) or 0
end

function toint(v)
	return math.round(tonum(v))
end

print(toint(1/2))
print(toint(2/2))
print(toint(3/2))