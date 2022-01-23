
function melon.Profile(func, name)
    return function(...)
        local start = SysTime()
        local ret = func(...)
        melon.Log(0, "Finished Profiling Function '{1}', ran in {2}s", name or "unknown", math.Round(SysTime() - start, 2))
        return ret
    end
end