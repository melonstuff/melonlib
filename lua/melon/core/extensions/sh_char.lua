
----
---@realm SHARED
---@name melon.char
----
---- Contains useful functions for matching characters against sets of characters efficiently
----
melon.char = melon.char or {}

----
---@name melon.char.Set
----
---@arg    (chars: char...) All specific characters to match against
---@return (match: fn(char) -> bool) The generated function
----
---- Creates a new function that checks against the given characters
----
function melon.char.Set(...)
    local set = {}
    for k, v in pairs({...}) do
        set[v] = true
    end

    return function(val)
        return set[val] or false
    end
end

----
---@name melon.char.Range
----
---@arg    (from: char) The starting character
---@arg    (to:   char) The ending character
---@return (match: fn(char) -> bool) The generated function
----
---- Creates a new function that checks if the given char is within the two given codepoints inclusively
----
function melon.char.Range(from, to)
    to = isstring(to) and string.byte(to) or to
    from = isstring(from) and string.byte(from) or from
    
    return function(val)
        local b = string.byte(val[1])

        return b <= math.max(to, from) and b >= math.min(to, from)
    end
end

----
---@name melon.char.Ranges
----
---@arg    (ranges: table<fn(char) -> bool>) Table of functions to check against
---@arg    (intersects: bool) Should the checking requirement match only if its in all ranges?
---@return (match: fn(char) -> bool) The generated function
----
---- Creates a new function that checks if the given character is in the given ranges  
---- If intersects is true, checks if its in all ranges
----
function melon.char.Ranges(ranges, intersects)
    return function(val)
        for _, v in pairs(ranges) do
            local res = v(val)

            if intersects and not res then
                return false
            elseif intersects then
                continue
            end

            if res then
                return true
            end
        end

        return intersects or false
    end
end

----
---@name melon.char.IsUpper
----
---@arg    (char) The character to check
---@return (bool) Is this character in the given set
----
---- Is the given character an Alphabetical Upper-Case 
----
melon.char.IsUpper = melon.char.Range("A", "Z")

----
---@name melon.char.IsLower
----
---@arg    (char) The character to check
---@return (bool) Is this character in the given set
----
---- Is the given character an Alphabetical Lower-Case 
----
melon.char.IsLower = melon.char.Range("a", "z")

----
---@name melon.char.IsAlpha
----
---@arg    (char) The character to check
---@return (bool) Is this character in the given set
----
---- Is the given character an Alphabetic character 
----
melon.char.IsAlpha = melon.char.Ranges({
    melon.char.IsUpper,
    melon.char.IsLower
})

----
---@name melon.char.IsNum
----
---@arg    (char) The character to check
---@return (bool) Is this character in the given set
----
---- Is the given character a Numeric character 
----
melon.char.IsNum = melon.char.Range("0", "9")

----
---@name melon.char.IsAlphaNumeric
----
---@arg    (char) The character to check
---@return (bool) Is this character in the given set
----
---- Is the given character an AlphaNumeric character
----
melon.char.IsAlphaNumeric = melon.char.Ranges({
    melon.char.IsAlpha,
    melon.char.IsNum
})

----
---@name melon.char.IsKeyboardSymbol
----
---@arg    (char) The character to check
---@return (bool) Is this character in the given set
----
---- Is the given character a "keyboard symbol", aka any character enterable through a standard US keyboard
----
melon.char.IsKeyboardSymbol = melon.char.Set(
    "!", "@", "#", "$", "%", "^", "&", "*",
    "(", ")", "[", "]", "{", "}", "<", ">",
    ";", ":", ",", ".", "/", "?",
    "|", "\\", "`", "~", "'", "\"",
    "-", "_", "=", "+"
)

----
---@name melon.char.IsHex
----
---@arg    (char) The character to check
---@return (bool) Is this character in the given set
----
---- Is the given character a hexadecimal character, (0-9, a-f, A-F)
----
melon.char.IsHex = melon.char.Ranges({
    melon.char.IsNum,
    melon.char.Range("a", "f"),
    melon.char.Range("A", "F"),
})

melon.Debug(function()
    local function teststr(fn, str)
        Msg(fn, ": ")
        Msg(string.rep(" ", 18 - #fn))

        for i = 1, #str do
            MsgC(
                melon.char[fn](str[i]) and
                    melon.colors.FC(100, 255, 100) or Color(100, 100, 100),
                str[i]
            )
        end

        MsgN()
    end
    
    local function aroundch(char, num)
        return string.char(string.byte(char) + num)
    end

    local function around(str, num)
        num = num or 1

        for i = 1, num do
            str = aroundch(str[1], -1) .. str .. aroundch(str[#str], 1)
        end

        return str
    end

    teststr("IsUpper", around"AZaz")
    teststr("IsLower", around"AZaz")

    teststr("IsAlpha", around"az123AZ")
    teststr("IsNum", around"az123AZ")

    teststr("IsAlphaNumeric", around"az123AZ")

    teststr("IsKeyboardSymbol", around("09", 6))
    teststr("IsHex", around("aA09fF", 6))
end, true)