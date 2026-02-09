
melon.char = melon.char or {}

function melon.char.Set(...)
    local set = {}
    for k, v in pairs({...}) do
        set[v] = true
    end

    return function(val)
        return set[val] or false
    end
end

function melon.char.Range(from, to)
    to = isstring(to) and string.byte(to) or to
    from = isstring(from) and string.byte(from) or from
    
    return function(val)
        local b = string.byte(val[1])

        return b <= math.max(to, from) and b >= math.min(to, from)
    end
end

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


melon.char.IsUpper = melon.char.Range("A", "Z")
melon.char.IsLower = melon.char.Range("a", "z")
melon.char.IsAlpha = melon.char.Ranges({
    melon.char.IsUpper,
    melon.char.IsLower
})

melon.char.IsNum = melon.char.Range("0", "9")
melon.char.IsAlphaNumeric = melon.char.Ranges({
    melon.char.IsAlpha,
    melon.char.IsNum
})

melon.char.IsKeyboardSymbol = melon.char.Set(
    "!", "@", "#", "$", "%", "^", "&", "*",
    "(", ")", "[", "]", "{", "}", "<", ">",
    ";", ":", ",", ".", "/", "?",
    "|", "\\", "`", "~", "'", "\"",
    "-", "_", "=", "+"
)

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