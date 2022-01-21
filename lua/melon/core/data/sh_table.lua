
function melon.KV2VK(tbl)
    local new = {}
    for k,v in pairs(tbl) do
        new[v] = k
    end
    return new
end