
function melon.Map(tbl, func)
    local new = {}

    for k,v in pairs(tbl) do
        local nk, nv = func(k, v)
        new[nk] = nv
    end

    return new
end

function melon.KV2VK(tbl)
    return melon.Map(tbl, function(k, v)
        return v, k
    end )
end