# melon.net
Network handlers and abstractions

# Functions
## melon.net.Unwatch(msg: string, name: string) 
Unwatches a network message added with [melon.net.Watch]
1. msg: string - Message name added with [util.AddNetworkString]
2. name: string - Identifier of the watcher to be removed

```lua
melon.net.Unwatch("ping_net_name", "Other Identifier")
```

## melon.net.Watch(msg: string, name: string, callback: fn) 
Watches a network message, replacement for [net.Receive] that takes multiple callbacks Only use if you desperately need
1. msg: string - Message name added with [util.AddNetworkString] to watch
2. name: string - Identifier for the watcher
3. callback: fn - Function callback for whenever the listener recieves an input

```lua
util.AddNetworkString("ping_net_name")

melon.net.Watch("ping_net_name", "Identifier", function(len, ply)
    net.Start("ping_net_name")
    net.WriteString("Pong :)")
    net.Send(ply)
end )

melon.net.Watch("ping_net_name", "Other Identifier", function(len, ply)
    print("Ponged from Identifier :)")
end )
```

