
----
---@module
---@name melon.panels
---@realm CLIENT
----
---- Misc panel helpers
----

melon.panels = melon.panels or {}

function melon.panels.DebugPaint(pnl, w, h)
    surface.SetDrawColor(22, 22, 22)
    surface.DrawOutlinedRect(0, 0, w, h, 3)

    surface.SetDrawColor(22, 22, 22, 100)
    surface.DrawRect(0,0,w,h)
    
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

-- melon.DebugPanel("DPanel", function(pnl)
--     pnl:SetSize(500,500)
--     pnl:Center()
--     pnl.Paint = melon.panels.DebugPaint
-- end )

local lines
----
---@name melon.DebugLine
----
---@arg (x:   number) X Coord to put the line at
---@arg (y:   number) Y Coord to put the line at
---@arg (p:   Panel?) Panel this line is relative to
---@arg (id: string?) String to render next to this line
----
---- Creates a line rendered on screen until the next melon.Debug call
----
function melon.DebugLine(x, y, panel, id)
    id = id or string.char(string.byte('a') + (#(lines or {})))

    if not lines then
        local size = melon.Scale(24)
        local dot = melon.Scale(2)

        local function d(xx, yy)
            surface.DrawRect(xx - size - dot + 1, yy, size, 1)
            surface.DrawRect(xx + dot, yy, size, 1)

            surface.DrawRect(xx, yy - dot - size + 1, 1, size)
            surface.DrawRect(xx, yy + dot, 1, size)

            surface.DrawRect(xx, yy, 1, 1)
        end

        hook.Add("PostRenderVGUI", "Melon:Debug:DrawLines", function()
            for k,v in pairs(lines) do
                surface.SetDrawColor(22, 22, 22)
                d(v[1] + 1, v[2] + 1)

                surface.SetDrawColor(v[3])
                d(v[1], v[2])

                if id then
                    draw.TextShadow({
                        text = v[4],
                        pos = {v[1] + size + (dot * 4), v[2]},
                        yalign = 1,
                    }, 1)
                end
            end
        end )

        lines = {}
    end

    if IsValid(panel) then
        local lx, ly = panel:LocalToScreen(0, 0)
        x = x + lx
        y = y + ly
    end

    table.insert(lines, {x, y, color_white, id}) -- melon.colors.Rainbow(1)
end

hook.Add("Melon:Debug", "ClearLines", function()
    lines = nil
    hook.Remove("PostRenderVGUI", "Melon:Debug:DrawLines")
end )

melon.Debug()
melon.DebugPanel("DPanel", function(p)
    function p:Paint(w, h)
        surface.SetDrawColor(255, 0, 0)
        surface.DrawRect(0,0,w,h)
    end

    function p:OnMousePressed()
        local x,y = self:LocalCursorPos()
        melon.DebugLine(x, y, self)
    end
end )