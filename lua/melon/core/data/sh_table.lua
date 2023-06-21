
----
---@name melon.Map
----
---@arg    (tbl: table) Table to map
---@arg    (fn: func  ) Function that takes k,v and returns a new k,v
---@return (new: table) Table created by the mapper
----
---- Maps a table to a new table, calling func with every key and value.
----
function melon.Map(tbl, func)
    local new = {}

    for k,v in pairs(tbl) do
        local nk, nv = func(k, v)
        new[nk] = nv
    end

    return new
end

----
---@name melon.KV2VK
----
---@arg    (tbl: table) Table to convert
---@return (new: table) Converted table
----
---- Inverts a tables keys and values ([k] = v) into ([v] = k) for every pair in the given table.
----
function melon.KV2VK(tbl)
    return melon.Map(tbl, function(k, v)
        return v, k
    end )
end

----
---@name melon.SubTable
----
---@arg    (tbl: table  ) Table to get the subtable of
---@arg    (from: number) Starting index
---@arg    (to: number  ) Ending index
---@return (sub: table  ) Subtable of the given arguments
----
---- Gets a subtable of the given table from the range of from to to, think string.sub()
----
function melon.SubTable(tbl, from, to)
    local new = {}

    for i = from, to do
        table.insert(new, tbl[i])
    end

    return new
end