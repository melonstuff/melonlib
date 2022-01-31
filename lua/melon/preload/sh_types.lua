
local isn = isnumber
function melon.IsColor(col)
    return IsColor(col) or (istable(col) and (isn(col.r) and isn(col.g) and isn(col.b)))
end

local _r = debug.getregistry()
function melon.ToColor(tbl)
    tbl.r = tbl.r or 0
    tbl.g = tbl.g or 0
    tbl.b = tbl.b or 0
    tbl.a = tbl.a or 255

    return setmetatable(table.Copy(tbl), _r.Color)
end