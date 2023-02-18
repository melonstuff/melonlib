
function melon.Scale(v)
    return v * (ScrH() / 1080)
end

function melon.ScaleN(...)
    local t = {...}

    for k,v in pairs(t) do
        t[k] = melon.Scale(v)
    end

    return unpack(t)
end