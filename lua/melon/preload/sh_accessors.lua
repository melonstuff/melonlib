
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

        local old = s[name]
        s[name] = value

        if s["OnSet" .. name] then
            s["OnSet" .. name](value, old)
        end

        return s
    end

    tbl["Get" .. name] = function(s)
        return s[name]
    end

    tbl[name] = (istable(def) and table.Copy(def)) or def
end

----
---@alias melon.AccessorFunc
---@name melon.AF
----
melon.AF = melon.AccessorFunc