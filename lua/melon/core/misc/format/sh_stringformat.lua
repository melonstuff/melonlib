
----
---@module
---@name melon.string
---@realm SHARED
----
---- String manipulation library, think a templating engine
---- Syntax is simple
----
---`
---` melon.string.Format("{1} {2} {3}", "first", "second", "third")
---` melon.string.Format("{1.1}", {"value in a table"})
---` melon.string.Format("{1.key}", {key = "by a key"})
---` melon.string.Format("{1.key | uppercase}", {key = "by a key"})
---` melon.string.Format("{uppercase($1)}", "make this uppercase")
---` melon.string.Format("the following is escaped: {!uppercase($1)}")
---`
melon.string = melon.string or {}

----
---@member
---@name melon.string.filters
----
---- List of all string filters 
----
melon.string.filters = melon.string.filters or {}

----
---@internal
---@name melon.string.Qualify
----
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

----
---@internal
---@name melon.string.QualifyFil
----
---- Extremely unsafe for user input
----
function melon.string.QualifyFil(tbl, to, current)
    local t = string.Split(to, "|")
    local val

    for k,v in ipairs(t) do
        v = string.Trim(v)

        local call = v:match("%((.-)%)$")
        if call then -- Explicit Filter Call
            local args = melon.string.ParseArgs(call, tbl)
            val = melon.string.CallFil(v:sub(1, -#call - 3), val or table.remove(args, 1), args)
        else
            val = melon.string.Qualify(tbl, current or v, true)
        end
    end

    return val
end

----
---@internal
---@name melon.string.CallFil
----
function melon.string.CallFil(fil, arg, args)
    if arg == nil then
        return "<Error: No argument provided to Filter '" .. tostring(fil) .. "'>"
    end

    if melon.string.filters[fil] then
        return melon.string.filters[fil](arg, unpack(args))
    end
    return "<Error: Unknown Filter '" .. tostring(fil) .. "'>"
end

----
---@name melon.string.Format
----
---@arg    (fmt:  string) String format to use, see [melon.string] for a reference
---@arg    (args: ...any) Any values to be passed to the formatter
---@return (str:  string) Formatted string
----
---- Formats a string using the melonlib formatter
----
function melon.string.Format(fmt, ...)
    local varargs = {...}
    if (#varargs == 1) and istable(varargs[1]) then
        varargs = varargs[1]
    end

    local current = 0
    return string.gsub(fmt, "{(.-)}", function(mtch, ...)
        if mtch[1] == "!" then
            return "{" .. mtch:sub(2, -1) .. "}"
        end

        if mtch == "" then
            current = current + 1
            return tostring(melon.string.QualifyFil(varargs, mtch, current))
        end

        return tostring(melon.string.QualifyFil(varargs, mtch))
    end)
end

----
---@internal
---@name melon.string.ParseArgs
----
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

----
---@name melon.string.print
----
---@arg (fmt:  string) String to be formatted, see [melon.string] for reference
---@arg (args: ...any) Arguments to be passed to the formatter
----
---- Formats and prints the given format, quick function
----
function melon.string.print(fmt, ...)
    print(({melon.string.Format(fmt, ...)})[1])
end