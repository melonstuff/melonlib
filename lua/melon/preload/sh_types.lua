
local isn = isnumber

----
---@name melon.IsColor
----
---@arg    (color: table) Color to check 
---@return (iscol:  bool) Is the given table a color?
----
---- Check if the given value is a color, use istable first.
----
function melon.IsColor(col)
    return IsColor(col) or (istable(col) and (isn(col.r) and isn(col.g) and isn(col.b)))
end

local _r = debug.getregistry()

----
---@name melon.ToColor
----
---@arg    (input: table) Table to convert to a Color
---@return (color: color) New Color object
----
---- Converts the given table into a valid [Color] object
----
function melon.ToColor(tbl)
    tbl.r = tbl.r or 0
    tbl.g = tbl.g or 0
    tbl.b = tbl.b or 0
    tbl.a = tbl.a or 255

    return setmetatable(table.Copy(tbl), _r.Color)
end
