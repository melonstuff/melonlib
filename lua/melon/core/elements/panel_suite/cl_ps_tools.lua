
local PANEL = vgui.Register("Melon:PanelSuite:Tools", {}, "Panel")
AccessorFunc(PANEL, "SuitePanel", "SuitePanel")

function PANEL:Init()
    self:SetSize(melon.Scale(400), melon.Scale(700))
    self:SetPos(melon.Scale(10), 0)
    self:CenterVertical()

    self.topbar = vgui.Create("Melon:PanelSuite:Topbar", self)
    self.topbar:SetAreaOf(self)
    self.tabs = vgui.Create("Melon:Tabs", self)
    
    for _, v in pairs(melon.PanelDevSuite.Tabs) do
        self.topbar:AddTabButton(v[1])
        self.tabs:AddTab(v[1], vgui.Create(v[2], self.tabs))
    end

    self.topbar:SetTabPanel(self.tabs)
   
    function self.tabs.OnTabChanged(s, new)
        if not IsValid(new) then return end
        if not IsValid(self:GetSuitePanel()) then return end

        if new.Ready then
            new:Ready(self:GetSuitePanel())
        else
            print("missing ready")
        end
    end 
end

function PANEL:SetSuitePanel(pnl)
    self.SuitePanel = pnl
    self.tabs.tabs[self.tabs:GetActiveTab()]:Ready(pnl)
end

function PANEL:PerformLayout(w, h)
    self.topbar:Dock(TOP)
    self.topbar:SetTall(melon.Scale(30))
    self.tabs:Dock(FILL)
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(melon.PanelDevSuite.Theme.Background)
    surface.DrawRect(0, 0, w, h)
end

function PANEL:PaintOver(w, h)
    local oc = DisableClipping(true)
        surface.SetDrawColor(melon.PanelDevSuite.Theme.Accent)
        surface.DrawOutlinedRect(-1, -1, w + 2, h + 2)
    DisableClipping(oc)
end

melon.DebugPanel2__TEST()