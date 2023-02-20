
melon.colors = melon.colors or {}

function melon.colors.Lerp(amt, from, to)
    return Color(
        Lerp(amt, from.r, to.r),
        Lerp(amt, from.g, to.g),
        Lerp(amt, from.b, to.b),
        Lerp(amt, from.a, to.a)
    )
end

-- Credit: Billy (bvgui_v2.lua:242)
function melon.colors.IsLight(col)
    return (col.r * 0.299 + col.g * 0.587 + col.b * 0.114) > 186
end

function melon.colors.Rainbow()
    return HSVToColor(CurTime() * 20, 0.9, 0.9)
end

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
