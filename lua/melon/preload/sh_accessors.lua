
----
---@deprecated melon.AccessorFunc
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
---@silence
---@name  melon.AT
---@alias melon.AccessorTable
---- 
melon.AT = melon.AccessorTable

----
---@deprecated melon.AccessorFunc
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

        if t.__on_dirty then
            t:__on_dirty(name, v)
        end

        s["v_" .. name] = v
        return s
    end

    return function(...)
        return melon.AF(t, ...)
    end
end

----
---@name melon.AccessorFunc
----
---@arg (table: table) Table to add the accessor to
---@arg (name: string) String name of the key
---@arg (default: any) Default value of the accessor key
---@arg (type:  TYPE_) Type of the accessor
----
---- Adds an accessor function to the given table and sets the default if needed
----
---- Differences between AccessorFunc
---- - `tbl:Set*()` calls `tbl:OnAccessorChange(name, from, to)` if it exists on the given table
---- - `tbl:Set*()` returns `tbl`
---- - Restricts to a TYPE_ enum instead of a FORCE_
----
function melon.AccessorFunc(tbl, name, def, type)
    tbl.__melon_accessors = tbl.__melon_accessors or {}
    tbl.__melon_accessors[name] = true
    
    tbl["Set" .. name] = function(s, value)
        if type and (TypeID(value) != type) then
            return
        end
        
        if s.OnAccessorChange then
            s:OnAccessorChange(name, s[name], value)
        end

        s[name] = value

        return s
    end

    tbl["Get" .. name] = function(s)
        return s[name]
    end

    if def then
        tbl[name] = def
    end
end