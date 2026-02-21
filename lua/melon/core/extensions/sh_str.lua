
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
---@name melon.str.SplitOnce
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

melon.Debug(function()
    _p(melon.str.Split("a|c|d|e|fghijk", "|", 3))
end, true)

