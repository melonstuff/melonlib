
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

    self.opened_from = {}
end

function PANEL:SanitizePath(path)
    return path
        :gsub("^addons/", "")
        :gsub("^melonlib/", "")
        :gsub("^lua/", "")
        :gsub("^melon/", "")
end

function PANEL:SetSuitePanel(pnl)
    self.SuitePanel = pnl
    self.tabs.tabs[self.tabs:GetActiveTab()]:Ready(pnl)

    self.opened_from = {}
    local init, paint = (pnl.Init and debug.getinfo(pnl.Init) or {}), (pnl.Paint and debug.getinfo(pnl.Paint) or {})

    init = self:SanitizePath(init.short_src or "")
    paint = self:SanitizePath(paint.short_src or "")

    if not string.StartsWith(init, "derma/") then
        table.insert(self.opened_from, init)
    end

    if not string.StartsWith(paint, "derma/") then
        table.insert(self.opened_from, paint)
    end

    if init == paint and #self.opened_from == 2 then
        self.opened_from = {init}
    end
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

        local y = h + 4
        
        for k,v in pairs(self.opened_from) do
            local _, th = draw.TextShadow({
                text = v,
                pos = {w / 2, y},
                xalign = 1,
                yalign = 3,
                font = melon.Font(12, "Inter"),
                color = {r = 255, g = 255, b = 255, a = 60}
            }, 2, 100)

            y = y + th
        end
    DisableClipping(oc)
end

melon.DebugPanel2__TEST()