
----
---@deprecated
---@name melon.AccessorTable
----
---- Dont use this
----
function melon.AccessorTable(tbl, metatable)
    tbl = tbl or {}
    tbl.__index = tbl
    tbl.Accessor = function(s, name, default)
        AccessorFunc(s, "val_" .. name, name)
        s["val_" .. name] = default
    end
    tbl.New = function(s, ...)
        local m = setmetatable({}, s.__metatable)

        for k,v in pairs(s) do
            m[k] = v
        end

        if m.Init then
            m:Init(...)
        end

        return m
    end

    tbl.__metatable = metatable or {}
    setmetatable(tbl, tbl.__metatable)
    return tbl
end

---- 
---@name  melon.AT
---@alias melon.AccessorTable
---- 
melon.AT = melon.AccessorTable

----
---@name melon.AF
----
---@arg (table: table) Table to add the accessor to
---@arg (name: string) String name for the accessor
---@arg (default: any) Default value for the accessor
----
---- Good replacement for AccessorFunc
----
function melon.AF(t, name, default)
    t["v_" .. name] = default

    t[name] = function(s, v)
        if v == nil then
            return s["v_" .. name]
        end

        s["v_" .. name] = v
        return s
    end

    return function(...)
        melon.AF(t, ...)
    end
end