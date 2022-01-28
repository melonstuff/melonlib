
function melon.AccessorTable(tbl)
    tbl = tbl or {}
    tbl.__index = tbl
    tbl.Accessor = function(s, name, default)
        AccessorFunc(s, "val_" .. name, name)
        s["val_" .. name] = default
    end
    tbl.New = function(s, ...)
        local m = setmetatable({}, s)

        if m.Init then
            m:Init(...)
        end

        return m
    end

    return tbl
end

melon.AT = melon.AccessorTable