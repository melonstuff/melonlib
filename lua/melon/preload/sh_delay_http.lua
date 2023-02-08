
local requests = {}

function melon.HTTP(h)
    if not requests then
        return HTTP(h)
    end

    table.insert(requests, h)
end

hook.Add("InitPostEntity", "Melon:HTTPReady", function()
    for k,v in pairs(requests) do
        HTTP(v)
    end

    requests = false
end )