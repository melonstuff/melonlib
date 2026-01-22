
if SERVER then
    util.AddNetworkString("melon_net_notify")
end

melon.net.Awaiting = melon.net.Awaiting or {}

melon.net.NOTIFY_OTHER   = 0
melon.net.NOTIFY_SUCCESS = 1
melon.net.NOTIFY_WARNING = 2
melon.net.NOTIFY_FAILURE = 3
melon.net.NOTIFY_INSUFFICIENT_PERMISSIONS = 4

----
---@realm SERVER
---@name melon.net.Notify
----
---@arg (ply: Player) The player to notify
---@arg (id:  string) The string ID of the notification for callbacks on the client
---@arg (type: melon.net.NOTIFY_) The notification type
---@arg (data: any) Data to send to the client callback, uses net.WriteType so be careful
----
---- Notifies a player of the completion of a serverside task
---- Paired with [melon.net.AwaitNotify]
----
---`
---`net.Receive("create_file", function(_, ply)
---`    local name = net.ReadString()
---`
---`    local f = file.Open(name, "w", "DATA")
---`    if not f then
---`        return melon.net.Notify(ply, "create_file", melon.net.NOTIFY_FAILURE)
---`    end
---` 
---`    f:Write("created!")
---`    f:Close()
---`    melon.net.Notify(ply, "create_file", melon.net.NOTIFY_SUCCESS)
---`end )
---`
function melon.net.Notify(ply, id, type, data)
    net.Start("melon_net_notify")
    net.WriteString(id)
    net.WriteUInt(type, 8)
    net.WriteType(data)
    net.Send(ply)
end

----
---@name melon.net.AwaitNotify
----
---@arg (id: string) The identifier of the notification
---@arg (on: function) The callback, called with the status and data passed from the server
----
---- Awaits a notification from the server
----
---`
---`local loading = true
---`melon.net.AwaitNotify("create_file", function(status)
---`    print("Status: ", status)
---`    loading = false
---`end )
---`
---`net.Start("create_file")
---`net.WriteString("some.txt")
---`net.SendToServer()
---`
function melon.net.AwaitNotify(id, on)
    melon.net.Awaiting[id] = on
end

----
---@name melon.net.ClearAwait
----
---@arg (id: string) The identifier of the notification
----
---- Removes an await notification callback
----
function melon.net.ClearAwait(id)
    melon.net.Awaiting[id] = nil
end

net.Receive("melon_net_notify", function(_, ply)
    if SERVER then return end

    local id = net.ReadString()
    local status = net.ReadUInt(8)
    local data = net.ReadType()

    if melon.net.Awaiting[id] then
        melon.net.Awaiting[id](status, data)
        melon.net.ClearAwait(id)
    end
end )