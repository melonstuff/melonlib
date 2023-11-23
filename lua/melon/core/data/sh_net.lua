
if SERVER then
    util.AddNetworkString("melon")
end

----
---@module
---@name melon.net
---@realm SHARED
----
---- Network handlers and abstractions
----
melon.net = melon.net or {}

----
---@member
---@name melon.net.Listeners
----
---- Table of all network listeners
----
melon.net.Listeners = melon.net.Listeners or {}

----
---@name melon.net.Watch
----
---@arg (msg:  string) Message name added with [util.AddNetworkString] to watch
---@arg (name: string) Identifier for the watcher
---@arg (callback: fn) Function callback for whenever the listener recieves an input
----
---- Watches a network message, replacement for [net.Receive] that takes multiple callbacks
---- Only use if you desperately need
----
---`
---` util.AddNetworkString("ping_net_name")
---`
---` melon.net.Watch("ping_net_name", "Identifier", function(len, ply)
---`     net.Start("ping_net_name")
---`     net.WriteString("Pong :)")
---`     net.Send(ply)
---` end )
---`
---` melon.net.Watch("ping_net_name", "Other Identifier", function(len, ply)
---`     print("Ponged from Identifier :)")
---` end )
---`
function melon.net.Watch(msg, name, callback)
    if not melon.net.Listeners[msg] then
        melon.net.Listeners[msg] = {}

        net.Receive(msg, function(len, ply)
            for _, v in pairs(melon.net.Listeners[msg]) do
                if v(len, ply) == true then
                    break
                end
            end
        end )
    end

    melon.net.Listeners[msg][name] = callback
end

----
---@name melon.net.Unwatch
----
---@arg (msg:  string) Message name added with [util.AddNetworkString]
---@arg (name: string) Identifier of the watcher to be removed
----
---- Unwatches a network message added with [melon.net.Watch]
----
---` melon.net.Unwatch("ping_net_name", "Other Identifier")
function melon.net.Unwatch(msg, name)
    melon.net.Listeners[msg][name] = nil
end

----
---@silence
---@name melon.net.Recv
---@alias melon.net.Watch
----
melon.net.Recv = melon.net.Watch