
-- This is a string templating library
-- QualifyFil is extremely unsafe for user input

melon.string = melon.string or {}
melon.string.filters = melon.string.filters or {}

-- Qualify a value in a table from a string
function melon.string.Qualify(tbl, to, notstr)
    to = string.gsub(to, "%s", "")
    local keys = string.Explode("[%.%:]", to, true)
    local val = tbl

    for k,v in ipairs(keys) do
        if not istable(val) then
            return "invalid key (" .. v .. ")"
        end

        val = val[tonumber(v) or tostring(v)]
    end

    return ((val == tbl) and "") or (notstr and val) or (tostring(val))
end

-- Qualify with filters!
function melon.string.QualifyFil(tbl, to)
    local t = string.Split(to, "|")
    local val = nil

    for k,v in ipairs(t) do
        v = string.Trim(v)

        if v:sub(-2, -1) == "()" then -- Explicit Filter Call
            val = melon.string.CallFil(v:sub(1, -3), val)
        else
            val = melon.string.Qualify(tbl, v, true)
        end
    end

    return val
end

-- Call a filter
function melon.string.CallFil(fil, arg)
    if arg == nil then
        return "<Error: No argument provided to Filter '" .. tostring(fil) .. "'>"
    end

    if melon.string.filters[fil] then
        return melon.string.filters[fil](arg)
    end
    return "<Error: Unknown Filter '" .. tostring(fil) .. "'>"
end

-- Formatting function
function melon.string.Format(fmt, ...)
    local varargs = {...}
    if (#varargs == 1) and istable(varargs[1]) then
        varargs = varargs[1]
    end

    return string.gsub(fmt, "{(.-)}", function(mtch, ...)
        if mtch[1] == "!" then
            return "{" .. mtch:sub(2, -1) .. "}"
        end
        return melon.string.QualifyFil(varargs, mtch)
    end)
end

-- Format Print
function melon.string.print(fmt, ...)
    print(({melon.string.Format(fmt, ...)})[1])
end