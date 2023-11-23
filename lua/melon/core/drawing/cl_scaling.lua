
----
---@name melon.ScaleBy
----
---@arg    (by:                   number) Number to scale by
---@return (func: func(number) -> number) Function that scales by the given factor
----
---- Creates a function to scale a number by
----
function melon.ScaleBy(by)
    return function(v)
        return v * by
    end
end

----
---@silence
---@name melon.Scale
----
---@arg    (numin:  number) Number to scale
---@return (numout: number) Scaled number
----
---- Scales a number based on [ScrH] / 1080
----
melon.Scale = melon.ScaleBy(ScrH() / 1080)
hook.Add("OnScreenSizeChanged", "Melon:ResetScale", function()
    melon.Scale = melon.ScaleBy(ScrH() / 1080)
end )

----
---@name melon.ScaleN
----
---@arg    (numin:  ...number) Vararg numbers to scale
---@return (numout: ...number) Unpacked scaled numbers
----
---- Scales multiple numbers
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