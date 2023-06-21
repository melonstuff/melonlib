
----
---@concommand
---@name melon.cleer
----
---- "Clears" the console by spamming it with a bunch of empty space
----
concommand.Add("cleer", function()
    melon.clr()
end)