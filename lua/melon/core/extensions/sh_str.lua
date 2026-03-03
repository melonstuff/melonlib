
----
---@realm SHARED
---@name melon.str
----
---- Contains string analysis functions
----
melon.str = melon.str or {}

----
---@iterator
---@name melon.str.Chars
----
---@arg    (string) Input string to iterate over
---@return (char) The current character
---@return (number) The current index
----
---- Iterates over a strings contents
----
melon.str.Chars = melon.iter.NewIter(function(index, str)
    if str[index] == "" then return end
    return str[index], index
end )

----
---@alias
---@name functionname
----
melon.str.Iter = melon.str.Chars

----
---@iterator
---@name melon.str.Lines
----
---@arg    (string) Input string to iterate over
---@return (string) The current line
---@return (number) The current index
----
---- Iterates over a strings lines
----
melon.str.Lines = melon.iter.NewIter(function(index, str)
    local state = melon.iter.Top()
    local function nextline(last)
        local ch = str[state.index]
        if not ch or ch == "" then return last end
        last = last or ""

        if ch == "" then
            print("END ")
            melon.iter.Skip()
            return last
        end

        if ch != "\n" then
            melon.iter.Skip()
            return nextline(last .. ch)
        end

        return last
    end

    -- if str[index] == "" then return end
    return nextline(), index
end )

----
---@name melon.str.CompareSub
----
---@arg    (input: string) The string to compare with
---@arg    (cmp:   string) The string to check for
---@arg    (index: number) The starting index
---@return (bool) Was the string found at this index
----
---- Checks if a string is within the given input string at the given index, including that index
----
function melon.str.CompareSub(input, cmp, index)
    return string.sub(input, index, index + (#cmp - 1)) == cmp
end

----
---@name melon.str.Split
----
---@arg    (string) String to split
---@arg    (delimiter: string) Delimiter to split by
---@arg    (times?:     number) How many times to split the string
---@return (split: table) The split string
----
---- Splits a string given an arbitrary length delimiter however many times given
---- Providing nil to times will split infinitely
----
function melon.str.Split(s, delim, cnt)
    local out = {""}

    for char, i in melon.str.Chars(s) do
        if cnt == 0 then
            out[#out] = string.sub(s, i, #s)
            melon.iter.Break()
            break
        end

        if not melon.str.CompareSub(s, delim, i) then
            out[#out] = out[#out] .. char
            continue
        end

        melon.iter.Skip(#delim - 1)
        cnt = (cnt and (cnt - 1)) or cnt
        table.insert(out, "")
    end

    return out
end

----
---@name melon.str.SplitOnce
----
---@arg    (string) String to split
---@arg    (delim: string) Delimiter to split by
---@return (lhs: string) The left side of the split
---@return (rhs: string) The right side of the split
----
---- Splits a string once given the arbitrary sized delimiter
----
function melon.str.SplitOnce(s, delim)
    local split = melon.str.Split(s, delim, 1)

    return split[1], split[2]
end

----
---@name melon.str.SplitOnceX
----
---@arg    (string) String to split
---@arg    (delim: string) Delimiter to split by
---@return (rhs: string) The right side of the split
---@return (lhs: string) The left side of the split
----
---- Splits a string once given the arbitrary sized delimiter
---- Reverses the arguments so the trailing text is always first
----
function melon.str.SplitOnceX(s, delim)
    local split = melon.str.Split(s, delim, 1)

    if not split[2] then return split[1] end
    return split[2], split[1]
end

----
---@name melon.str.SplitN
----
---@arg    (string) String to split
---@arg    (number) How many chars per sub-string
---@return (split: table) Output strings
----
---- Splits the input string so N chars are in every sub-string
----
function melon.str.SplitN(s, n)
    local out = {}

    for ch in melon.str.Chars(s) do
        if #(out[#out] or "") == n then
            table.insert(out, "")
        end

        out[#out] = (out[#out] or "") .. ch
    end

    return out
end

----
---@name melon.str.StripChar
----
---@arg    (string) String to strip characters from
---@arg    (char | fn(char) -> bool) Character or function to determine if a char should be stripped
---@return (string) The stripped string
----
---- Strips all characters from a string that qualify from the given function or are the given char
---- If the given function returns true, we strip
---- Intended for use with [melon.char] functions
----
---`
---` print(melon.str.StripChar("abcdef", "d")) -- abcef
---` print(melon.str.StripChar("a1b2c3", melon.char.IsNum)) -- abc
---`
function melon.str.StripChar(str, strip)
    if isstring(strip) then
        local stchar = strip
        strip = function(ch)
            return ch == stchar
        end
    end

    local out = ""

    for ch in melon.str.Chars(str) do
        out = out .. (strip(ch) and "" or ch)
    end

    return out
end

----
---@name melon.str.Strip
----
---@arg    (string) String to get stripped
---@arg    (strip: string) String to strip from this
---@return (string) The stripped string
----
---- Strips a string of all instances of the given string
----
function melon.str.Strip(str, strip)
    return table.concat(melon.str.Split(str, strip), "")
end

melon.Debug(function()
    print(melon.str.StripChar([[a213afdaf4123zfdaf590]], melon.char.IsNum))
    print(melon.str.Strip([[abcdef_Gabcd_G_Gef_G_g_Ga]], "_G"))
end, true)

-- melon.Debug(function()
--     -- _p(melon.str.Split("a|c|d|e|fghijk", "|", 3))
--     _p(melon.str.SplitN("1234123412341234", 4))
-- end, true)

