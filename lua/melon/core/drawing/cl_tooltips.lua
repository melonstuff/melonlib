
local tooltip

function melon.Tooltip(text, panel, placement, identifier, paint, font, delay)
    if not IsValid(panel) then return end

    if not text then return end
    if not panel then return end
    if tooltip and tooltip.identifier and tooltip.identifier == identifier then
        return
    end

    tooltip = {
        identifier = identifier,

        start = CurTime() + ((delay or 0.2) - 0.2),
        open = true,

        text = text,
        panel = panel,
        placement = placement,
        paint = paint or melon.TooltipPaint,
        font = font or melon.Font(18),
        seen = false,

        x = false,
        y = false,
    }

    tooltip.wrap = melon.text.Wrap(tooltip.text, tooltip.font, melon.Scale(300), 0, false)
end

function melon.TooltipX(t)
    melon.Tooltip(t.text, t.panel, t.placement, t.identifier, t.paint, t.font, t.delay)
end

function melon.KillTooltip()
    if not tooltip then return end
    if not tooltip.open then return end

    tooltip.start = CurTime()
    tooltip.open = false
end

function melon.TooltipPaint(x, y, w, h, alpha, tip)
    local pad = melon.Scale(4)
    x = x - (pad * 2)
    y = y - pad
    w = w + (pad * 4)
    h = h + (pad * 2)

    local oa = surface.GetAlphaMultiplier()
    surface.SetAlphaMultiplier(alpha)

    draw.RoundedBox(6, x, y, w, h, melon.colors.FC(44, 44, 44))

    if #tooltip.wrap == 1 then
        draw.Text({
            text = tip.text,
            pos = {x + w / 2, y + h / 2},
            xalign = 1,
            yalign = 1,
            font = tip.font
        })
        return
    end

    for k, v in pairs(tooltip.wrap) do
        local _, th = draw.Text({
            text = v,
            pos = {x + w / 2, y + pad / 2},
            xalign = 1,
            yalign = 3,
            font = tip.font
        })

        y = y + th
    end

    surface.SetAlphaMultiplier(oa)
end

hook.Add("DrawOverlay", "Melon:DrawTooltips", function()
    if not tooltip then return end
    
    local t = math.min((CurTime() - tooltip.start) / 0.2, 1)
    t = tooltip.open and t or (not tooltip.seen and 0) or (1 - t)

    if tooltip.open then
        tooltip.seen = t > 0
    end

    surface.SetFont(tooltip.font)
    local tw, th = 0, 0
    local px, py = 0, 0
    local pw, ph = 0, 0
    local pad = melon.Scale(10)

    for k, v in pairs(tooltip.wrap) do
        local ttw, tth = surface.GetTextSize(v)
        tw = math.max(tw, ttw)
        th = th + tth
    end
    
    if not IsValid(tooltip.panel) or not tooltip.panel:IsHovered() then
        melon.KillTooltip()
    else
        px, py = tooltip.panel:LocalToScreen(0, 0)
        pw, ph = tooltip.panel:GetSize()
    end

    local place = ({
        [LEFT]   = {px - tw - pad, py + ph / 2 - th / 2},
        [RIGHT]  = {px + pw + pad, py + ph / 2 - th / 2},
        [TOP]    = {px + pw / 2 - tw / 2, py - th - pad},
        [BOTTOM] = {px + pw / 2 - tw / 2, py + ph + pad}
    })[tooltip.placement]

    tooltip.x = tooltip.x or place[1]
    tooltip.y = tooltip.y or place[2]

    tooltip.paint(tooltip.x, tooltip.y, tw, th, t, tooltip)
end )

melon.DebugPanel("DPanel", function(p)
    p.AddButton = function(s, name, enum)
        local b = vgui.Create("DButton", p)
        b:Dock(TOP)
        b:SetText(name)
        b:SetTall(melon.Scale(30))

        b.DoClick = function()
            melon.TooltipX({
                text = string.rep("Some really long tooltip ", 6),
                panel = b,
                placement = enum,
                delay = 0
            })
        end
    end

    p:AddButton("Left", LEFT)
    p:AddButton("Right", RIGHT)
    p:AddButton("Top", TOP)
    p:AddButton("Bottom", BOTTOM)
end )