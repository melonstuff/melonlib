
----
---@name melon.Profile
----
---@arg (number) How many times to call this function
---@arg (fn) Function to call
---@arg (...any) Any arguments to pass to the function call
---@return (number) How many seconds this operation took
----
---- Profiles a function, outputs how long it took
----
function melon.Profile(iters, fn, ...)
    local start = SysTime()

    for i = 0, iters do
        fn(...)
    end

    return SysTime() - start
end