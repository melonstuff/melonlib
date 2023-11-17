
-- Filters for the formatting system

melon.string = melon.string or {}
melon.string.filters = melon.string.filters or {}
local f = melon.string.filters

local function err(msg)
    return "<Error: " .. msg .. ">"
end

-- String Ops
function f.upper(str)
    return string.upper(str)
end

function f.capitalize(str)
    return str:sub(1, 1):upper() .. str:sub(2, -1)
end

-- Num Ops
function f.isplural(num)
    num = tonumber(num)

    if not num then
        return err("Invalid Number passed to isplural ('" .. num .. "')")
    end

    return num == 1 and "" or "s"
end

function f.round(num, places)
    local t = tonumber(num)

    if not t then return err("Attempted to round non-number '" .. tostring(num) ..  "'") end

    return math.Round(num, places)
end

function f.comma(num)
    return string.Comma(num)
end

-- Func Ops
function f.call(func, ...)
    if not isfunction(func) then
        return err("Attempted to call non-function '" .. tostring(func) .. "'")
    end

    return func(...)
end

-- Type Ops
function f.int(str)
    return math.Round(tonumber(str), 0) or err("Invalid Number '" .. str .. "'")
end

function f.str(val)
    return tostring(val)
end

function f.prettycolor(col)
    if not melon.IsColor(col) then
        return err("Invalid Color '" .. tostring(col) .. "'")
    end

    return "col(" .. col.r .. ", " .. col.g .. ", " .. col.b .. ")"
end

function f.realcolor(col)
    if not melon.IsColor(col) then
        return err("Invalid Color '" .. tostring(col) .. "'")
    end

    return "Color(" .. col.r .. ", " .. col.g .. ", " .. col.b .. ", " .. (col.a or 255) .. ")"
end

-- Money ops
function f.money(val)
    if not isnumber(val) then
        return err("Invalid number '" .. tostring(val) .. "'")
    end

    if not DarkRP then
        return err("Cannot format money outside of DarkRP")
    end

    return DarkRP.formatMoney(val)
end