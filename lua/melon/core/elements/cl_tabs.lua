
local PANEL = vgui.Register("Melon:Tabs", {}, "EditablePanel")
AccessorFunc(PANEL, "ActiveTab", "ActiveTab")
AccessorFunc(PANEL, "AnimTime", "AnimTime", FORCE_NUMBER)

function PANEL:Init()
    self.tabs = {}

    self:SetAnimTime(0.5)
end

function PANEL:AddTab(name, pnl)
    pnl:SetParent(self)
    self.tabs[name] = pnl

    pnl:SetVisible(false)

    if not self:GetActiveTab() then
        self:SetTab(name)
    end
end

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

function PANEL:AnimDone() end
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