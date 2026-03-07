
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

----
---@dataclass
---@name LuaJITFnInfo
----
---@value (linedefined: number)     Line this function is defined on
---@value (lastlinedefined: number) Last line this function is defined on
---@value (params: number)          How many parameters this function takes
---@value (stackslots: number)      How many stack slots this functions locals take
---@value (upvalues: number)        How many upvalues this function uses
---@value (bytecodes: number)       How many bytecodes this function has
---@value (gcconsts: number)        How many garbage collectible constants
---@value (nconsts: number)         How many lua_Number (double) constants
---@value (children: bool)          Does this function create closures
---@value (currentline: number)     What line are we on
---@value (isvararg: bool)          Does this function use varargs
---@value (source: string)          What file this function is defined on
---@value (loc: string)             A string formatted like "<source>:<line>"
---@value (ffid?: number)           Fast function ID if this is a C function
---@value (addr?: number)           Address if this is a C function
----
---- Return from [melon.fn.jitinfo] and [jit.util.funcinfo]
----

local jitinfocache = {}
----
---@name melon.fn.jitinfo
----
---@arg    (fn) Any function to get data from
---@return (DebugInfo) The debuginfo from it
----
---- Returns cached [jit.util.funcinfo] with all params
---- This is substantially faster that [jit.util.funcinfo] for repeated operations
----
function melon.fn.jitinfo(fn)
    if jitinfocache[fn] then return jitinfocache[fn] end
    local info = jit.util.funcinfo(fn)

    jitinfocache[fn] = info
    return jitinfocache[fn]
end

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

    _pname("jit.util.funcinfo: " .. iters)
    _p(melon.Profile(iters, function()
        return jit.util.funcinfo(f)
    end) .. 's')

    _pname("melon.fn.jitinfo: " .. iters)
    _p(melon.Profile(iters, function()
        return melon.fn.jitinfo(f)
    end) .. 's')
end, true)