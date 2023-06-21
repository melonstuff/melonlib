
----
---@module
---@name melon.colors
---@realm CLIENT
----
---- Handles color modification and other things
----
melon.colors = melon.colors or {}

----
---@name melon.colors.Lerp
----
---@arg    (amt: number) Amount to interpolate by
---@arg    (from: color) From color
---@arg    (to: color  ) To color
---@return (new: color ) New color object
----
---- Returns a new [Color] thats interpolated by from/to
----
function melon.colors.Lerp(amt, from, to)
    return Color(
        Lerp(amt, from.r, to.r),
        Lerp(amt, from.g, to.g),
        Lerp(amt, from.b, to.b),
        Lerp(amt, from.a, to.a)
    )
end

-- Credit: Billy (bvgui_v2.lua:242)
----
---@name melon.colors.IsLight
----
---@arg    (col: color) Color to check
---@return (dark: bool) Is the color light or dark
----
---- Get if a color is dark or light, primarily for dynamic text colors
----
function melon.colors.IsLight(col)
    return (col.r * 0.299 + col.g * 0.587 + col.b * 0.114) > 186
end

----
---@name melon.colors.Rainbow
----
---@return (color: Color) Rainbow color
----
---- Generates a consistent rainbow color
----
function melon.colors.Rainbow()
    return HSVToColor(CurTime() * 20, 0.9, 0.9)
end

----
---@name melon.colors.FromHex
----
---@arg    (hex: string) Hex color
---@return (col: color ) New color object
----
---- Converts a hex color of 3, 4, 6 or 8 characters into a [Color] object
----
function melon.colors.FromHex(hex)
    local str = hex
    if #str == 3 then
        str = (hex[1] .. hex[1]) .. (hex[2] .. hex[2]) .. (hex[3] .. hex[3]) 
    elseif #str == 4 then
        str = (hex[1] .. hex[1]) .. (hex[2] .. hex[2]) .. (hex[3] .. hex[3]) .. (hex[4] .. hex[4])
    end

    if #str == 6 then
        str = str .. "FF" -- alpha
    end

    local r = tonumber("0x" .. str:sub(1, 2))
    local g = tonumber("0x" .. str:sub(3, 4))
    local b = tonumber("0x" .. str:sub(5, 6))
    local a = tonumber("0x" .. str:sub(7, 8))

    if r and g and b and a then
        return Color(r, g, b, a)
    end
end
