
local runPostLoad = melon.FinishedLoading or {}

----
---@name melon.PostLoad
----
---@arg (fn: func) Function to call post load
----
---- Call a function post load, needed because of load order issues
----
function melon.PostLoad(fn)
    if melon.FinishedLoading then
        return fn()
    end

    if istable(runPostLoad) then
        return table.insert(runPostLoad, fn)
    end

    fn()
end

hook.Add("Melon:DoneLoading", "melon.PostLoad", function()
    if not istable(runPostLoad) then return end

    for _, fn in pairs(runPostLoad) do
        fn()
    end

    runPostLoad = nil
end )
