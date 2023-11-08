
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
---@name melon.ScaleN
----
---@arg    (nums: ...number) Vararg numbers to scale
---@return (nums: ...number) Unpacked scaled numbers
----
---- Scales multiple numbers, dont use, unpack is stupid.
----
function melon.ScaleN(a,b,c,d,e,f)
    return
        a and melon.Scale(a),
        b and melon.Scale(b),
        c and melon.Scale(c),
        d and melon.Scale(d),
        e and melon.Scale(e),
        f and melon.Scale(f)
end

melon.Debug(function()
    cprint(melon.ScaleN(1, 2, 3))
end )