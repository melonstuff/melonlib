
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
    return HSVToColor(CurTime(), 0.9, 0.9)
end