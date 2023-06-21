
----
---@deprecated
---@name melon.Profile
----
---- Unsure how functional this actually is.
----
function melon.Profile(func, name, stop_profile)
    if stop_profile then
        return func
    end

    return function(...)
        local start = SysTime()
        local ret = func(...)
        local endd = SysTime()
        melon.Log(0, "Finished Profiling Function '{1}', ran in {2}s", name or "unknown", endd - start)
        return ret
    end
end