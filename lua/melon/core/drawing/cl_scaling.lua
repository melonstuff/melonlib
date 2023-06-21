
----
---@name melon.Scale
----
---@arg    (num: number) Number to scale
---@return (num: number) Scaled number
----
---- Scales a number based on [ScrH] / 1080
----
function melon.Scale(v)
    return v * (ScrH() / 1080)
end

----
---@deprecated
---@name melon.ScaleN
----
---@arg    (nums: ...number) Vararg numbers to scale
---@return (nums: ...number) Unpacked scaled numbers
----
---- Scales multiple numbers, dont use, unpack is stupid.
----
function melon.ScaleN(...)
    local t = {...}

    for k,v in pairs(t) do
        t[k] = melon.Scale(v)
    end

    return unpack(t)
end