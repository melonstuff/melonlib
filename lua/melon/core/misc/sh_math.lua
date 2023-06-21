
----
---@deprecated
---@module
---@name melon.math
----
---- Misc math functions
----
melon.math = melon.math or {}

----
---@name melon.math.max
----
---@arg    (tbl: table ) Table to get the max of
---@arg    (key: any   ) Check a specific key if valid, otherwise all, seems useless? 
---@return (max: number) Max value from the table
----
---- math.max on all table elements
----
function melon.math.max(tbl, key)
    local cur = 0

    for k,v in pairs(tbl) do
        cur = math.max(cur, (key and tbl[key]) or v)
    end

    return cur
end

----
---@name melon.math.min
----
---@arg    (tbl: table ) Table to get the min of
---@arg    (key: any   ) Check a specific key if valid, otherwise all, seems useless? 
---@return (max: number) Min value from the table
----
---- math.min on all table elements
----
function melon.math.min(tbl, key)
    local cur = 0

    for k,v in pairs(tbl) do
        cur = math.min(cur, (key and tbl[key]) or v)
    end

    return cur
end