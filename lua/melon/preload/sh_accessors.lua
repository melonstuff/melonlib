
function melon.AccessorTable(tbl)
    tbl = tbl or {}
    tbl.Accessor = function(s, name, default)
        AccessorFunc(s, "val_" .. name, name)
        s["val_" .. name] = default
    end

    return tbl
end