
local PANEL = vgui.Register("Melon:PanelSuite:Topbar", {}, "Melon:Draggable")
AccessorFunc(PANEL, "TabPanel", "TabPanel")

function PANEL:Init()
    self.tabs = {}
    self.lhs = vgui.Create("Panel", self)
    self.rhs = vgui.Create("Panel", self)

    self:AddRhsButton(function(s,w,h)
        draw.NoTexture()
        surface.SetDrawColor(s.Color)
        surface.DrawTexturedRectRotated(w / 2, h / 2, w / 2, melon.Scale(2), 45)
        surface.DrawTexturedRectRotated(w / 2, h / 2, w / 2, melon.Scale(2), -45)
    end, function()
        self:GetParent():Remove()
    end )

    self:AddRhsButton(function(s,w,h)
        draw.NoTexture()
        surface.SetDrawColor(s.Color)
        melon.DrawImageRotated("https://i.imgur.com/IOyRtM7.png", w / 2, h / 2, w / 2, h / 2)
    end, function()
        self:GetTabPanel():SetTab("settings")
    end )

    self.lhs.Think = self.LHSThink
    self.lhs.PerformLayout = self.LHSPerformLayout

    function self.lhs:OnMouseWheeled(d)
        self.WantedScrollX = self.WantedScrollX + (d * 50)
    end

    function self.lhs:PaintOver(w,h)
        local active_i_hate_you_tbh = self:GetParent():GetTabPanel():GetActiveTab() or ""
        local btn = self:GetParent().tabs[active_i_hate_you_tbh]

        if btn then
            self.accentX = Lerp(FrameTime() * 10, self.accentX or btn:GetX(), btn:GetX())
            self.accentW = Lerp(FrameTime() * 10, self.accentW or btn:GetWide(), btn:GetWide())
            self.accentH = Lerp(FrameTime() * 10, self.accentH or 3, melon.Scale(3))
        else
            self.accentH = Lerp(FrameTime() * 10, self.accentH or 0, 0)
        end

        surface.SetDrawColor(melon.PanelDevSuite.Theme.Accent)
        surface.DrawRect(self.accentX, h - self.accentH, self.accentW, self.accentH)

        self.RealItemW = self.RealItemW or 0
        if self.RealItemW < w then return end
        local pos = math.abs(self.ScrollX) / (self.RealItemW - w)
        
        local shadow = melon.PanelDevSuite.Theme.Shadow
        surface.SetMaterial(melon.Material("vgui/gradient-l"))
        surface.SetDrawColor(shadow.r, shadow.g, shadow.b, pos * 255)
        surface.DrawTexturedRect(0, 0, h, h)

        surface.SetMaterial(melon.Material("vgui/gradient-r"))
        surface.SetDrawColor(shadow.r, shadow.g, shadow.b, 255 - (pos * 255))
        surface.DrawTexturedRect(w - h, 0, h, h)
    end
end

function PANEL:AddTabButton(text)
    local btn = vgui.Create("DButton", self.lhs)
    self.tabs[text] = btn
    btn:SetText("")
    btn.text = text

    btn.Color = melon.colors.CopyShallow(melon.PanelDevSuite.Theme.SecondaryText)
    btn.Paint = function(s, w, h)
        draw.Text({
            text = s.text,
            pos = {w / 2, h / 2},
            xalign = 1,
            yalign = 1,
            font = melon.Font(26),
            color = s.Color
        })
    end
    btn.Think = function(s)
        melon.colors.LerpMod(FrameTime() * 10, s.Color, s:IsHovered() and melon.PanelDevSuite.Theme.Text or melon.PanelDevSuite.Theme.SecondaryText)
    end
    btn.DoClick = function(s)
        self:GetTabPanel():SetTab(text)
    end

    return btn
end

function PANEL:AddRhsButton(paint, fn)
    local btn = vgui.Create("DButton", self.rhs)
    btn.Paint = paint
    btn.DoClick = fn
    btn:SetText("")
    btn:Dock(RIGHT)

    btn.Color = melon.colors.CopyShallow(melon.PanelDevSuite.Theme.SecondaryText)
    btn.Think = function(s)
        melon.colors.LerpMod(FrameTime() * 10, s.Color, s:IsHovered() and melon.PanelDevSuite.Theme.Text or melon.PanelDevSuite.Theme.SecondaryText)
    end
end

function PANEL:LHSThink()
    self.WantedScrollX = self.WantedScrollX or 0
    self.ScrollX = self.ScrollX or 0

    local iw = 0
    for _,v in pairs(self:GetChildren()) do
        if not v.RealX then return end
        v:SetPos(v.RealX + self.ScrollX, 0)
        iw = iw + v:GetWide()
    end

    self.RealItemW = iw
    self.WantedScrollX = Lerp(FrameTime() * 10, self.WantedScrollX, math.Clamp(self.WantedScrollX, -(iw - self:GetWide()), 0))
    self.ScrollX = Lerp(FrameTime() * 10, self.ScrollX, self.WantedScrollX)
end

function PANEL:LHSPerformLayout(w, h)
    surface.SetFont(melon.Font(26))

    self.RealItemW = 0
    for k,v in pairs(self:GetChildren()) do
        local tw = surface.GetTextSize(v.text)
        v:SetSize(tw + melon.Scale(20), h)
        v.RealX = self.RealItemW
        self.RealItemW = self.RealItemW + v:GetWide()

        if not self.FinishedFirstLayout then
            v:SetPos(v.RealX, 0)
        end
    end

    self.FinishedFirstLayout = true
end

function PANEL:PerformLayout(w, h)
    self.rhs:SetSize(#self.rhs:GetChildren() * h, h)
    self.rhs:SetPos(w - self.rhs:GetWide(), 0)

    for k,v in pairs(self.rhs:GetChildren()) do
        v:SetWide(h)
    end
    
    self.lhs:SetSize(w - self.rhs:GetWide(), h)
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(melon.PanelDevSuite.Theme.Foreground)
    surface.DrawRect(0, 0, w, h)
end

melon.DebugPanel2__TEST()