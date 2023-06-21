
----
---@deprecated
---@module
---@name melon.panels
---@realm CLIENT
----
---- Old panel registering library, we are modern men now, dumb idea.
----
melon.panels = melon.panels or {}
melon.panels.list = melon.panels.list or {}

function melon.panels.New(name, base)
    if not name then return end
    base = base or "Panel"

    local PANEL = {}
    PANEL.__info = {
        name = name,
        base = base,
        trace = debug.getinfo(2)
    }

    PANEL.Init = function(s)
        s:SetSize(100, 100)
    end
    PANEL.Paint = function(s,w,h) -- Just a base debug paint function
        surface.SetDrawColor(225, 126, 9)
        surface.DrawRect(0,0,w,h)
        surface.SetDrawColor(255,255,255)
        surface.DrawOutlinedRect(0,0,w,h,2)

        local _w, _h = draw.Text({
            text = s.__info.name,
            pos = {6, 6},
            font = melon.Font(20)
        })

        local newh = 6 + _h + 2
        surface.DrawRect(6, newh, _w, 1)
        newh = newh + 2

        local ww, wh = draw.Text({
            text = w,
            pos = {6, newh},
            font = melon.Font(30)
        })

        local xw = draw.Text({
            text = "x",
            pos = {6 + ww, newh + wh - 5},
            font = melon.Font(15),
            yalign = 4
        })

        draw.Text({
            text = h,
            pos = {6 + ww + xw, newh},
            font = melon.Font(30)
        })
    end

    return vgui.Register(name, PANEL, base)
end
