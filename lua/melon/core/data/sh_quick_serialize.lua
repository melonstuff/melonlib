
function melon.QuickSerialize(tbl)
    local s = ""

    for k,v in pairs(tbl) do
        s = s .. tostring(k) .. "::'" .. tostring(v) .. ";"
    end

    return s
end

function melon.DeQuickSerialize(s)
    local split = string.Split(s, ";")
    local toret = {}

    for k,v in pairs(split) do
        local spl = string.Split(s, "::'")
        toret[spl[1]] = spl[2]
    end

    return toret
end

