
----
---@module
---@name melon.colors
---@realm CLIENT
----
---- Handles color modification and other things
----
melon.colors = melon.colors or {}

----
---@name melon.colors.Copy
----
---@arg    (original: Color) To color
---@return (new:      Color) New color object
----
---- Returns a new [Color] thats a copy of the original given
----
function melon.colors.Copy(original)
    return Color(
        original.r,
        original.g,
        original.b,
        original.a
    )
end

----
---@name melon.colors.CopyShallow
----
---@arg    (original: Color) To color
---@return (new:      table) New color
----
---- Returns a new table thats a copy of the original given,
---- same as [melon.colors.Copy] but without the metatable
----
function melon.colors.CopyShallow(original)
    return {
        r = original.r,
        g = original.g,
        b = original.b,
        a = original.a
    }
end

----
---@name melon.colors.Lerp
----
---@arg    (amt: number) Amount to interpolate by
---@arg    (from: Color) From color
---@arg    (to:   Color) To color
---@return (new:  Color) New color object
----
---- Returns a new [Color] thats interpolated by from/to
----
function melon.colors.Lerp(amt, from, to)
    return {
        r = Lerp(amt, from.r, to.r),
        g = Lerp(amt, from.g, to.g),
        b = Lerp(amt, from.b, to.b),
        a = Lerp(amt, from.a, to.a)
    }
end

----
---@name melon.colors.LerpMod
----
---@arg (amt: number) Amount to interpolate by
---@arg (mod:  Color) Color to modify
---@arg (to:   Color) To color
----
---- Modifies the given color for optimization reasons, be careful.
----
function melon.colors.LerpMod(amt, mod, to)
    mod.r = Lerp(amt, mod.r, to.r)
    mod.g = Lerp(amt, mod.g, to.g)
    mod.b = Lerp(amt, mod.b, to.b)
    mod.a = Lerp(amt, mod.a, to.a)
end

-- Credit: Billy (bvgui_v2.lua:242)
----
---@name melon.colors.IsLight
----
---@arg    (col: Color) Color to check
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
---@return (col:  Color) New color object
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

----
---@name melon.colors.ToHex
----
---@arg    (color: Color) Real Color
---@return (hex:  string) Hex Color Output
----
---- Converts a Color to a hex color of 3, 4, 6 or 8 chars
----
function melon.colors.ToHex(color)
    local function isd(t)
        return t[1] == t[2]
    end
    
    local r = bit.tohex(color.r, 2)
    local g = bit.tohex(color.g, 2)
    local b = bit.tohex(color.b, 2)
    local a = bit.tohex(color.a, 2)

    if isd(r) and isd(g) and isd(b) and isd(a) then
        r,g,b,a = r[1], g[1], b[1], a[1]
    end

    if color.a == 255 then a = "" end

    return r .. g .. b .. a
end
