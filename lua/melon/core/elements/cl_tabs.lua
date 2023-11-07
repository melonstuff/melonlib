
melon.elements = melon.elements or {}

----
---@panel Melon:Tabs
---@name melon.elements.Tabs
----
---@accessor (ActiveTab:   any) Active tab keyname
---@accessor (AnimTime: number) Animation time
---@accessor (InitialTab:  any) First tab keyname
----
---- Handles multiple tabs, think DPropertySheet without the visuals and builtin handling
----
local PANEL = vgui.Register("Melon:Tabs", {}, "EditablePanel")
AccessorFunc(PANEL, "ActiveTab", "ActiveTab")
AccessorFunc(PANEL, "AnimTime", "AnimTime", FORCE_NUMBER)
AccessorFunc(PANEL, "InitialTab", "InitialTab")

melon.elements.Tabs = PANEL

function PANEL:Init()
    self.tabs = {}

    self:SetAnimTime(0.5)
end

----
---@method
---@name melon.elements.Tabs.AddTab
----
---@arg (name:  any  ) Keyname for the tab
---@arg (panel: panel) Valid Panel to add to the tab handler
----
---- Adds the given panel as a tab with the name given to the handler
----
function PANEL:AddTab(name, pnl)
    pnl:SetParent(self)
    self.tabs[name] = pnl

    pnl:SetVisible(false)

    if not self:GetActiveTab() then
        self:SetInitialTab(name)
        self:SetTab(name)
    end
end

----
---@method
---@name melon.elements.Tabs.SetTab
----
---@arg (name: string) Name of the tab to set
----
---- Sets the current tab to the given tab, animates!
----
function PANEL:SetTab(name)
    local old = self.tabs[self:GetActiveTab()]
    local new = self.tabs[name]

    if not new then return end

    if new == old then return end

    self:SetActiveTab(name)
    new:SetVisible(true)

    self.anim = {
        start = CurTime(),
        running = true,
        finished = false,
        progress = 0,

        old = old,
        new = new,
    }

    if new.OnTabSelected then
        new:OnTabSelected(old)
    end

    if old and old.OnTabDeselected then
        old:OnTabDeselected(new)
    end

    self:OnTabChanged(new, old)

    return new
end

----
---@method
---@internal
---@name melon.elements.Tabs.Think
----
---- Handles animation progress stuff, dont touch, if you do touch replace it
----
function PANEL:Think()
    if self.anim then
        self.anim.progress = Lerp((CurTime() - self.anim.start) / self:GetAnimTime(), self.anim.progress or 0, 1)

        if self.anim.progress >= 0.99 then
            self.anim.running = false
            self.anim.progress = 1
            self.anim.finished = true
        end
    end
end

----
---@method
---@internal
---@name melon.elements.Tabs.Paint
----
---- Handles applying animation progress, read the source before replacing the Paint of this, Paint the parent instead
----
function PANEL:Paint()
    if not self.anim then return end
    if self.anim.old then
        self.anim.old:SetAlpha(255 - (255 * self.anim.progress))
    end

    self.anim.new:SetAlpha(255 * self.anim.progress)

    if self.anim.finished then
        if self.anim.old then
            self:AnimDone(self.anim)
            self.anim.old:SetVisible(false)
        end

        self.anim = nil
    end
end

----
---@method
---@name melon.elements.Resizable.AnimDone
----
---- Called when the animation is done, if you replace Paint you need to call this by hand
----
function PANEL:AnimDone() end

----
---@method
---@name melon.elements.Resizable.OnTabChanged
----
---@arg (new: panel) New tab panel
---@arg (old: panel) Old tab panel
----
---- Called when the tab is changed
----
function PANEL:OnTabChanged(new, old) end

function PANEL:PerformLayout(w, h)
    if self:GetActiveTab() then
        self.tabs[self:GetActiveTab()]:SetSize(w, h)
    end
end

melon.DebugPanel("Melon:Tabs", function(p)
    p:SetSize(400, 400)
    p:Center()

    local f = vgui.Create("DFrame", p:GetParent())
    f:SetSize(200, 400)
    f:SetPos(p:GetX() - 205, p:GetY())
    f:SetTitle("Select a tab")
    f:ShowCloseButton(false)

    f.scroll = vgui.Create("DScrollPanel", f)
    f.scroll:Dock(FILL)

    for i = 1, 10 do
        local tab = vgui.Create("DPanel", p)
        tab:SetBackgroundColor(ColorRand())

        p:AddTab(i, tab)

        local btn = vgui.Create("DButton", f.scroll)
        btn:Dock(TOP)
        btn:SetText(i)
        btn:SetTextColor(tab:GetBackgroundColor())

        btn.DoClick = function()
            p:SetTab(i)
        end
    end
end )