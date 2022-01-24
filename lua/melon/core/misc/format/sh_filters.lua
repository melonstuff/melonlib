
-- Filters for the formatting system

melon.string = melon.string or {}
melon.string.filters = melon.string.filters or {}
local f = melon.string.filters

function f.upper(str)
    return string.upper(str)
end

function f.capitalize(str)
    return str:sub(1, 1):upper() .. str:sub(2, -1)
end

function f.int(str)
    return tonumber(str) or "<Error: Invalid Number '" .. str .. "'>"
end

function f.isplural(num)
    num = tonumber(num)

    if not num then
        return "<Error: Invalid Number passed to isplural ('" .. num .. "')>"
    end

    return num == 1 and "" or "s"
end

function f.call(func, ...)
    if not isfunction(func) then
        return "<Error: Attempted to call non-function '" .. tostring(func) .. "'>"
    end

    return func(...)
end

function f.round(num, places)
    local t = tonumber(num)

    if not t then return "<Error: Attempted to round non-number '" .. tostring(num) ..  "'>" end

    return math.Round(num, places)
end

function f.comma(num)
    return string.Comma(num)
end