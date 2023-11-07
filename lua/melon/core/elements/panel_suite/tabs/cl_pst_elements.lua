
local docktext = {
    [LEFT] = "Left",
    [RIGHT] = "Right",
    [TOP] = "Top",
    [BOTTOM] = "Bottom",
    [FILL] = "Fill"
}
local drawinfo = false
local realdraw = {}
local PANEL = vgui.Register("Melon:PanelSuite:Tab:Elements", {}, "Panel")
AccessorFunc(PANEL, "Panel", "Panel")
AccessorFunc(PANEL, "ActiveNode", "ActiveNode")

function PANEL:Init()
    self.tree = vgui.Create("Melon:PanelSuite:Tree", self)
    self.tree:Dock(FILL)
    self.display = vgui.Create("Panel", self)
    self.display:SetVisible(false)

    function self.display.OnMousePressed()
        self:CloseDisplay()
    end

    function self.display.Paint(s, w, h)
        if not IsValid(self.activepanel) then
            self:CloseDisplay()
            return
        end

        local aw, ah = self.activepanel:GetSize()
        local ax, ay = self.activepanel:GetPos()
        local apl, apt, apr, apb = self.activepanel:GetDockPadding()
        local aml, amt, amr, amb = self.activepanel:GetDockMargin()
        local dock = self.activepanel:GetDock()

        local bg = melon.PanelDevSuite.Theme.Background
        surface.SetDrawColor(bg.r, bg.g, bg.b, 200)
        surface.DrawRect(0,0,w,h)
        melon.DrawBlur(s, 0, 0, w, h, 4)

        local tw, th = draw.Text({
            text = aw .. " x " .. ah,
            pos = {w / 2, h / 2},
            xalign = 1,
            yalign = 1,
            font = melon.Font(30),
        })

        tw = tw + melon.Scale(20)
        th = th + melon.Scale(10)
        surface.SetDrawColor(melon.PanelDevSuite.Theme.Accent)
        surface.DrawOutlinedRect(w / 2 - tw / 2, h / 2 - th / 2, tw, th, 2)

        local padx, pady = melon.ScaleN(10, 10)
        local left = draw.Text({
            text = apl == 0 and "-" or apl,
            pos = {w / 2 - tw / 2 - padx, h / 2},
            xalign = 2,
            yalign = 1,
            font = melon.Font(26)
        })

        local right = draw.Text({
            text = apr == 0 and "-" or apr,
            pos = {w / 2 + tw / 2 + padx, h / 2},
            xalign = 0,
            yalign = 1,
            font = melon.Font(26)
        })

        local _, top = draw.Text({
            text = apt == 0 and "-" or apt,
            pos = {w / 2, h / 2 - th / 2 - pady},
            xalign = 1,
            yalign = 1,
            font = melon.Font(26)
        })

        local _, bottom = draw.Text({
            text = apb == 0 and "-" or apb,
            pos = {w / 2, h / 2 + th / 2 + pady},
            xalign = 1,
            yalign = 1,
            font = melon.Font(26)
        })

        top = top / 2
        bottom = bottom / 2

        left = left + padx
        right = right + padx

        local bx, by, bw, bh =
            w / 2 - tw / 2 - padx - left,
            h / 2 - th / 2 - pady - top,
            tw + left + right + (padx * 2),
            th + top + bottom + (pady * 2)

        surface.DrawOutlinedRect(bx, by, bw, bh, 2)

        draw.Text({
            text = aml == 0 and "-" or aml,
            pos = {bx - padx, h / 2},
            font = melon.Font(26),
            xalign = 2,
            yalign = 1
        })

        draw.Text({
            text = amr == 0 and "-" or amr,
            pos = {bx + bw + padx, h / 2},
            font = melon.Font(26),
            xalign = 0,
            yalign = 1
        })

        draw.Text({
            text = amt == 0 and "-" or amt,
            pos = {w / 2, by - pady},
            font = melon.Font(26),
            xalign = 1,
            yalign = 1
        })

        draw.Text({
            text = amb == 0 and "-" or amb,
            pos = {w / 2, by + bh + pady},
            font = melon.Font(26),
            xalign = 1,
            yalign = 1
        })

        local lx, ly = bx - melon.Scale(40), by - melon.Scale(40)
        local sw, sh = draw.Text({
            text = ax .. ", " .. ay,
            pos = {lx, ly},
            font = melon.Font(26),
            xalign = 1,
            yalign = 0
        })

        surface.DrawOutlinedRect(lx - sw / 2 - padx, ly - pady / 2, sw + padx * 2, sh + pady, 2)

        local px, py = (lx - sw / 2 - padx) + (sw + padx * 2), ly + sh + pady / 2
        draw.NoTexture()
        surface.DrawPoly({
            {
                x = px,
                y = py + 1
            },
            {
                x = px,
                y = py - 2
            },
            {
                x = bx,
                y = by
            }
        })

        draw.Text({
            text = docktext[dock] or "",
            pos = {w / 2, ly + sh / 2},
            xalign = 1,
            yalign = 1,
            font = melon.Font(20)
        })
    end
end

function PANEL:OpenDisplay(pnl)
    self.open = true
    self.activepanel = pnl
    self.start = CurTime()

    self.display:SetVisible(true)
end

function PANEL:CloseDisplay()
    if not self.open then return end
    self.open = false
    self.start = CurTime()
    self:SetActiveNode(false)
end

function PANEL:Think()
    if not self.start then return end
    local time = ((CurTime() - self.start) / 0.2)

    self.display:SetAlpha((self.open and (time * 255)) or (255 - (time * 255)))
    
    if time >= 1 then
        self.start = false

        if not self.open then
            self.display:SetVisible(false)
        end
    end
end

function PANEL:Ready(pnl)
    if self.AlreadyReady then return end
    self.AlreadyReady = true

    self:SetPanel(pnl)
    local recursively_add
    recursively_add = function(node, p)
        for _, child in ipairs(p:GetChildren()) do
            local childnode = node:Node(child)

            recursively_add(childnode, child)
        end
    end
    recursively_add(self.tree:Node(pnl), pnl)
end

function PANEL:SetActivePanel(info)
    if info then
        info.owner = self
    end

    drawinfo = info
end

function PANEL:SetActiveNode(node)
    self.tree:SetActiveNode(node)
    self.tree:SetMouseInputEnabled(not node)

    if not node then return end
    self:OpenDisplay(node.panel)
end

function PANEL:PerformLayout(w, h)
    self.tree:SetPos(0, 0)
    self.tree:SetSize(w, h)
    self.display:SetPos(0, 0)
    self.display:SetSize(w, h)
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(melon.PanelDevSuite.Theme.Background)
    surface.DrawRect(0, 0, w, h)
end

hook.Add("DrawOverlay", "Melon:PanelSuite:Tab:Elements", function()
    local ft = FrameTime() * 10
    if realdraw.h then
        local a = melon.PanelDevSuite.Theme.Accent
        surface.SetDrawColor(a.r, a.g, a.b, realdraw.a)
        surface.DrawLine(
            realdraw.dx, 
            realdraw.dy, 
            realdraw.x, 
            realdraw.y + (realdraw.h / 2)
        )
        surface.DrawOutlinedRect(
            realdraw.x, 
            realdraw.y, 
            realdraw.w, 
            realdraw.h, 
            2
        )
    end

    if not drawinfo then
        realdraw.a = Lerp(ft, realdraw.a or 0, 0)
        return
    end

    draw.NoTexture()
    local x, y
    local w, h

    if IsValid(drawinfo.panel) and IsValid(drawinfo.owner) and drawinfo.owner:IsVisible() then
        x, y = drawinfo.panel:LocalToScreen(0, 0)
        w, h = drawinfo.panel:GetSize()
        realdraw.valid = true
    else
        realdraw.a = Lerp(ft, realdraw.a or 0, 0)
        realdraw.valid = false
    end

    if (not x) or (not w) then
        realdraw.valid = false
    end

    if not realdraw.valid then return end

    realdraw = {
        x   = Lerp(ft, realdraw.x  or x,          x         ),
        y   = Lerp(ft, realdraw.y  or y,          y         ),
        w   = Lerp(ft, realdraw.w  or w,          w         ),
        h   = Lerp(ft, realdraw.h  or h,          h         ),
        dx  = Lerp(ft, realdraw.dx or drawinfo.x, drawinfo.x),
        dy  = Lerp(ft, realdraw.dy or drawinfo.y, drawinfo.y),
        a   = Lerp(ft, realdraw.a  or 255,        255       ),
    }
end )

melon.DebugPanel2__TEST()