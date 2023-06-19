
melon.net = melon.net or {}
melon.net.Listeners = melon.net.Listeners or {}

function melon.net.Watch(msg, name, callback)
    if not melon.net.Listeners[msg] then
        melon.net.Listeners[msg] = {}

        net.Receive(msg, function(len, ply)
            for _, v in pairs(melon.net.Listeners[msg]) do
                v(len, ply)
            end
        end )
    end

    melon.net.Listeners[msg][name] = callback
end

function melon.net.Unwatch(msg, name)
    melon.net.Listeners[msg][name] = nil
end

melon.net.Recv = melon.net.Watch