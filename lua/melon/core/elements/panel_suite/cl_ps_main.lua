
---- This is all internal, so im not gonna bother documenting it
local last = false
local PANEL = vgui.Register("Melon:PanelSuite:Main", {}, "EditablePanel")
AccessorFunc(PANEL, "SuitePanelType", "SuitePanelType")
AccessorFunc(PANEL, "SuiteFunction", "SuiteFunction")
AccessorFunc(PANEL, "SuitePanel", "SuitePanel")

function PANEL:Init()
    self.allowed_to_draw = false
    self:MakePopup()

    self.text_color = Color(255, 255, 255, 50)

    self.close = vgui.Create("Melon:Button", self)
    self.close:SetPaintedManually(true)
    self.close.Paint = function(s,w,h)
        local xw = h * .5
        local xh = melon.Scale(4)
        
        surface.SetDrawColor(melon.PanelDevSuite.Theme.Background)
        surface.DrawRect(0, 0, w, h)

        draw.NoTexture()
        surface.SetDrawColor(255, 255, 255)
        surface.DrawTexturedRectRotated(w / 2, h / 2, xw - xh / 2, xh / 2, 45)
        surface.DrawTexturedRectRotated(w / 2, h / 2, xw - xh / 2, xh / 2, -45)

        local oc = DisableClipping(true)
        surface.SetDrawColor(melon.colors.Rainbow(s:IsHovered() and 1000 or 20))
        surface.DrawOutlinedRect(-2, -2, w + 4, h + 4, 2)
        DisableClipping(oc)
    end
    self.close.LeftClick = function()
        self:Remove()
    end

    self.toolbtn = vgui.Create("Melon:Button", self)
    self.toolbtn:SetPaintedManually(true)
    self.toolbtn.Paint = function(s,w,h)
        surface.SetDrawColor(melon.PanelDevSuite.Theme.Background)
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(255, 255, 255)
        local size = h * .45
        melon.DrawImageRotated("https://i.imgur.com/v2PAI0a.png", w / 2, h / 2, size, size, 0)

        local oc = DisableClipping(true)
        surface.SetDrawColor(melon.colors.Rainbow(s:IsHovered() and 1000 or 20))
        surface.DrawOutlinedRect(-2, -2, w + 4, h + 4, 2)
        DisableClipping(oc)
    end
    self.toolbtn.LeftClick = function()
        self:ToggleTools()
    end
end

function PANEL:PerformLayout(w, h)
    self.close:SetSize(melon.Scale(50), melon.Scale(30))
    self.close:SetPos(w - self.close:GetWide(), 0)

    self.toolbtn:SetSize(melon.Scale(50), melon.Scale(30))
    self.toolbtn:SetPos(w - self.close:GetWide() - self.close:GetWide() - melon.Scale(7), 0)
end

-- function PANEL:Think()
    -- if input.IsKeyDown(KEY_F2) and input.IsShiftDown() then
    --     if self.pressing then return end
    --     self.pressing = true

    --     if self.allowed_to_draw then
    --         self.allowed_to_draw = false
    --         return
    --     end

    --     self.allowed_to_draw = {
    --         ["CHudGMod"] = true
    --     }
    -- else
    --     self.pressing = false
    -- end

    -- if input.IsKeyDown(KEY_F3) and input.IsShiftDown() then
    --     if self.pressing2 then return end
    --     self.pressing2 = true

    --     self:ToggleTools()
    -- else
    --     self.pressing2 = false
    -- end
-- end

function PANEL:Paint(w, h)
    if self.allowed_to_draw then return end
    -- local _, th = draw.Text({
    --     text = "Press Shift+F2 to hide display",
    --     pos = {melon.ScaleN(10, 10)},
    --     font = melon.Font(18),
    --     xalign = 0,
    --     yalign = 0,
    --     color = self.text_color
    -- })

    -- draw.Text({
    --     text = "Press Shift+F3 to show tools",
    --     pos = {melon.Scale(10), melon.Scale(10) + th},
    --     font = melon.Font(18),
    --     xalign = 0,
    --     yalign = 0,
    --     color = self.text_color
    -- })

    self.close:PaintManual()
    self.toolbtn:PaintManual()

    if IsValid(self.tools) then
        self.tools:PaintManual()
    end

    self.close:SetZPos(32766)

    if self:IsMouseInputEnabled() then
        return
    end

    draw.Text({
        text = "shift+L to close debugger",
        pos = {w / 2, self.close:GetTall() / 2},
        xalign = 1,
        yalign = 1,
        font = melon.Font(20),
        color = {r = 255, g = 255, b = 255, a = 20}
    })

    if input.IsKeyDown(KEY_L) and input.IsShiftDown() then
        self:Remove()
    end
end

function PANEL:OnMousePressed(m)
    if m == MOUSE_MIDDLE then
        self:Remove()
    end
end

function PANEL:OnRemove()
    if IsValid(self:GetSuitePanel()) then
        self:GetSuitePanel():Remove()
    end
end

function PANEL:SuiteReady()
    local pnl
    if isstring(self:GetSuitePanelType() or "DPanel") then
        pnl = vgui.Create(self:GetSuitePanelType() or "DPanel", self)
    else
        pnl = vgui.CreateFromTable(self:GetSuitePanelType(), self)
    end

    self:SetSuitePanel(pnl)

    pnl:SetSize(500, 500)
    pnl:Center()
    
    if self:GetSuiteFunction() then
        self:GetSuiteFunction()(pnl)
    end

    if last then
        self:ToggleTools(true)
    end
end

function PANEL:ToggleTools(t)
    if not t then
        last = not last
    end

    if IsValid(self.tools) then
        self.tools:Remove()
        return
    end

    self.tools = vgui.Create("Melon:PanelSuite:Tools", self)
    self.tools:SetSuitePanel(self:GetSuitePanel())
end

melon.DebugPanel2__TEST()
