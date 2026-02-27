
----
---@deprecated
---@module
---@realm SHARED
---@name melon.math
----
---- Misc math functions
----
melon.math = melon.math or {}

----
---@name melon.math.max
----
---@arg    (tbl:  table) Table to get the max of
---@arg    (key:    any) Check a specific key if valid, otherwise all, seems useless? 
---@return (max: number) Max value from the table
----
---- math.max on all table elements
----
function melon.math.max(tbl, key)
    local cur = 0

    for k,v in pairs(tbl) do
        cur = math.max(cur, (key and tbl[key]) or v)
    end

    return cur
end

----
---@name melon.math.min
----
---@arg    (tbl:  table) Table to get the min of
---@arg    (key:    any) Check a specific key if valid, otherwise all, seems useless? 
---@return (max: number) Min value from the table
----
---- math.min on all table elements
----
function melon.math.min(tbl, key)
    local cur = 0

    for k,v in pairs(tbl) do
        cur = math.min(cur, (key and tbl[key]) or v)
    end

    return cur
end

----
---@name melon.math.distance
----
---@arg (x: number) X Coordinate
---@arg (y: number) Y Coordinate
----
---- Gets the distance between x and y
----
function melon.math.distance(x, y)
    return math.abs(x - y)
end

----
---@name melon.math.sum
----
---@arg    (table: table) Table to get the sum of
---@return (sum:  number) Sum of all the tables contents
----
---- Gets the sum of an entire table
----
function melon.math.sum(t)
    local s = 0

    for i = 1, #t do
        s = s + t[i]
    end

    return s
end

----
---@member
---@name melon.math.NumAsChar
----
---- A table of key numbers that correlate to their characters
----
melon.math.NumAsChar = {}

----
---@member
---@name melon.math.CharAsNum
----
---- A table of key strings that correlate to their numbers
----
melon.math.CharAsNum = {}

for i = 10, 35 do
    local s1 = string.byte("a") + (i - 10)
    local s2 = string.byte("A") + (i - 10)

    melon.math.NumAsChar[i] = string.char(s1)
    melon.math.NumAsChar[i + 26] = string.char(s2)

    melon.math.CharAsNum[s1] = i
    melon.math.CharAsNum[s2] = i + 26
end

----
---@name melon.math.tobase
----
---@arg (number) Number to convert
---@arg (base: number) Base to convert to
---@return (string?) Converted number, nil if it failed
---@return (number?) Sign of the number, will either be -1, 1
----
---- Converts a number to the given base
---- Note that floats are not handled by this, due to there not really being a good or useful way to
----
function melon.math.tobase(n, base)
    if math.floor(n) != n then return end
    if base > 61 then return end
    if base <= 1 then return end

    local sign = math.Clamp(n, -1, 1)
    local out

    n = math.abs(n)
    while n > 0 do
        local num = n % base
        out = (melon.math.NumAsChar[num] or num) .. (out or "")
        n = math.floor(n / base)
    end

    return out or "0", sign
end

----
---@name melon.math.frombase
----
---@arg    (string) String to convert
---@arg    (base: number) Base to convert from
---@return (number?) Converted number, nil if it failed
----
---- Converts a [string] number from the input base to base10 
---- Note that this is orders of magnitude slower than `tonumber`! Please use that for bases it supports
----
function melon.math.frombase(n, base)
    if base > 61 then return end
    if base <= 1 then return end

    local out = 0
    
    for ch, i in melon.str.Chars(n) do
        ch = melon.math.CharAsNum[ch] or ch
        out = out + (tonumber(ch) * (base ^ (#n - i)))
    end

    return out
end

melon.Debug(function()
    print(CurTime())
    local n, sign = melon.math.tobase(math.floor(math.random(0, 1000000)), 2)
    local r = melon.math.frombase(n, 2)

    MsgN("tobase:   ", n, " (" .. sign .. ")")
    MsgN("frombase: ", r * sign)
    MsgN("tonumber: ", tonumber(n, 2) * sign)

    local st_frombase = SysTime()
    for i = 0, 1000000 do
        melon.math.frombase(n, 2)
    end
    local end_frombase = SysTime()

    local st_tonumber = SysTime()
    for i = 0, 1000000 do
        tonumber(n, 2)
    end
    local end_tonumber = SysTime()

    print("frombase: ", (end_frombase - st_frombase) .. "s")
    print("tonumber: ", (end_tonumber - st_tonumber) .. "s")
end, true)