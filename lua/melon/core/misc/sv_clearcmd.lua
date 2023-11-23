
----
---@concommand cleer
----
---- "Clears" the console by spamming it with a bunch of empty space
----
concommand.Add("cleer", function(ply)
    if IsValid(ply) then return end
    if CLIENT then return end
    
    melon.clr()
end)