
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

melon.AT = melon.AccessorTable