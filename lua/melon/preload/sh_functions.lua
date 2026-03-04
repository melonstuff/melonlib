
----
---@realm SHARED
---@name melon.fn
----
---- Utilities for handling functions
----
melon.fn = melon.fn or {}

----
---@name melon.fn.detour
----
---@arg    (fn) Function to detour
---@arg    (detour: fn(fn, ...any)) The actual detour
---@return (fn) The detoured function
----
---- Creates a new, detoured function
---- It is the detours responsibility to call the source function
----
function melon.fn.detour(f, det)
    return function(...)
        return det(f, ...)
    end
end

local infocache = {}
----
---@name melon.fn.info
----
---@arg    (fn) Any function to get data from
---@return (DebugInfo) The debuginfo from it
----
---- Returns cached [debug.getinfo] with all params
---- This is substantially faster that [debug.getinfo] for repeated operations
----
function melon.fn.info(fn)
    if infocache[fn] then return infocache[fn] end
    local info = debug.getinfo(fn)

    infocache[fn] = info
    return infocache[fn]
end

melon.Debug(function()
    local add = function(a, b)
        return a + b
    end

    add = melon.fn.detour(add, function(f, a, b)
        return f(a, b * 2)
    end )

    print(add(1, 2))
end )

melon.Debug(function()
    local f = function(a, b, c)
        print("never called")
    end
    
    local iters = 1000000
    _pname("debug.getinfo: " .. iters)
    _p(melon.Profile(iters, function()
        return debug.getinfo(f)
    end) .. 's')

    _pname("melon.fn.info: " .. iters)
    _p(melon.Profile(iters, function()
        return melon.fn.info(f)
    end) .. 's')
end )