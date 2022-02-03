
melon.math = melon.math or {}

function melon.math.max(tbl, key)
    local cur = 0

    for k,v in pairs(tbl) do
        cur = math.max(cur, (key and tbl[key]) or v)
    end

    return cur
end

function melon.math.min(tbl, key)
    local cur = 0

    for k,v in pairs(tbl) do
        cur = math.min(cur, (key and tbl[key]) or v)
    end

    return cur
end