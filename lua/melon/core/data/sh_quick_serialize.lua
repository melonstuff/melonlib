
----
---@name melon.QuickSerialize
----
---@arg    (tbl:  table) Table to serialize
---@return (str: string) Serialized table
----
---- Serializes a table very simply, only allows string keys and values
----
---- format is key::'value;key2::'value2;
----
function melon.QuickSerialize(tbl)
    local s = ""

    for k,v in pairs(tbl) do
        s = s .. tostring(k) .. "::'" .. tostring(v) .. ";"
    end

    return s
end

----
---@name melon.DeQuickSerialize
----
---@arg    (str: string) String to deserialize
---@return (tbl:  table) Deserialized table
----
---- Deserialized a table serialized with [melon.QuickSerialize]
----
function melon.DeQuickSerialize(s)
    local split = string.Split(s, ";")
    local toret = {}

    for k,v in pairs(split) do
        local spl = string.Split(s, "::'")
        toret[spl[1]] = spl[2]
    end

    return toret
end

