
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
        if not istable(val) and not IsEntity(val) then
            return "indexing non-table (" .. tostring(val) .. ")"
        end

        val = val[tonumber(v) or tostring(v)]
    end

    return ((val == tbl) and "") or (notstr and val) or (tostring(val))
end

-- Qualify with filters!
function melon.string.QualifyFil(tbl, to)
    local t = string.Split(to, "|")
    local val

    for k,v in ipairs(t) do
        v = string.Trim(v)

        local call = v:match("%((.-)%)$")
        if call then -- Explicit Filter Call
            val = melon.string.CallFil(v:sub(1, -#call - 3), val, melon.string.ParseArgs(call, tbl))
        else
            val = melon.string.Qualify(tbl, v, true)
            nonfunc = val
        end
    end

    return val
end

-- Call a filter
function melon.string.CallFil(fil, arg, args)
    if arg == nil then
        return "<Error: No argument provided to Filter '" .. tostring(fil) .. "'>"
    end

    if melon.string.filters[fil] then
        return melon.string.filters[fil](arg, unpack(args))
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
        return tostring(melon.string.QualifyFil(varargs, mtch))
    end)
end

-- Parse Arguments
function melon.string.ParseArgs(str, tbl)
    local args = string.Split(str, ",")
    local toret = {}

    for k,v in pairs(args) do
        v = v:Trim()
        if isnumber(tonumber(v)) then
            toret[k] = tonumber(v)
        elseif v[1] == "$" then
            toret[k] = melon.string.QualifyFil(tbl, v:sub(2, -1))
        else
            toret[k] = v
        end
    end

    return toret
end

-- Format Print
function melon.string.print(fmt, ...)
    print(({melon.string.Format(fmt, ...)})[1])
end

melon.clr()
melon.string.print("{1.Nick|call($1)}", LocalPlayer())
