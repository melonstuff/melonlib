
----
---@module
---@name melon.panels
---@realm CLIENT
----
---- Misc panel helpers
----

melon.panels = melon.panels or {}

function melon.panels.DebugPaint(pnl, w, h)
    melon.DrawBlur(pnl, 0, 0, w, h, 5)

    surface.SetDrawColor(22, 22, 22)
    surface.DrawOutlinedRect(0, 0, w, h, 3)

    surface.SetDrawColor(melon.colors.Rainbow())
    surface.DrawOutlinedRect(1, 1, w - 2, h - 2)

    draw.Text({
        text = pnl.ClassName or "anonPanel",
        pos = {w / 2 + 2, h / 2 + 2},
        xalign = 1,
        yalign = 1,
        font = melon.Font(40),
        color = Color(22, 22, 22)
    })

    draw.Text({
        text = pnl.ClassName or "anonPanel",
        pos = {w / 2, h / 2},
        xalign = 1,
        yalign = 1,
        font = melon.Font(40),
    })
end

melon.DebugPanel("DPanel", function(pnl)
    pnl:SetSize(500,500)
    pnl:Center()
    pnl.Paint = melon.panels.DebugPaint
end )