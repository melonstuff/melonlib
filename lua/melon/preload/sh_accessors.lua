
function melon.AccessorTable()
    return {
        Accessor = function(s, name, default)
            AccessorFunc(s, "val_" .. name, name)
            s["val_" .. name] = default
        end
    }
end