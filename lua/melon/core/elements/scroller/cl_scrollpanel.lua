
melon.elements = melon.elements or {}

----
---@panel Melon:ScrollPanel
---@name melon.elements.ScrollPanel
----
---@accessor (ScrollPerDelta:           number) How many pixels to scroll per-scroll wheel delta, unscaled
---@accessor (ScrollbarSize:            number) How wide should the scrollbars be?
---@accessor (ScrollbarPad:             number) How much padding should the scrollbars have
---@accessor (ScrollbarMaxOverflow:     number) How much overflow in pixels should we allocate to the scrollbars, unscaled 
---@accessor (PanningEnabled:          boolean) Should we allow panning on the scrollbars with middle mouse button? note you need to call :Pan() yourself
---@accessor (Canvas:                    Panel) Canvas panel
---@accessor (VerticalScrollEnabled:   boolean) Should we allow vertical scrolling?
---@accessor (HorizontalScrollEnabled: boolean) Should we allow horizontal scrolling?
----
---- A general purpose unstyled scrollpanel rewrite containing over-content scrollbars, smooth scrolling and canvas based scrolling.
----
local PANEL = vgui.Register("Melon:ScrollPanel", {}, "Panel")
AccessorFunc(PANEL, "ScrollPerDelta", "ScrollPerDelta")
AccessorFunc(PANEL, "ScrollbarSize", "ScrollbarSize")
AccessorFunc(PANEL, "ScrollbarPad", "ScrollbarPad")
AccessorFunc(PANEL, "ScrollbarMaxOverflow", "ScrollbarMaxOverflow")
AccessorFunc(PANEL, "PanningEnabled", "PanningEnabled")
AccessorFunc(PANEL, "Canvas", "Canvas")
AccessorFunc(PANEL, "VerticalScrollEnabled", "VerticalScrollEnabled")
AccessorFunc(PANEL, "HorizontalScrollEnabled", "HorizontalScrollEnabled")

melon.elements.ScrollPanel = PANEL

function PANEL:SetCanvas(cvs)
    self.Canvas = cvs

    cvs:SetParent(self)
    self:InvalidateLayout(true)

    self.VScroll:SetCanvas(cvs)
    self.HScroll:SetCanvas(cvs)

    self.VScroll:SetZPos(2)
    self.HScroll:SetZPos(2)
end

function PANEL:SetVerticalScrollEnabled(en)
    self.VerticalScrollEnabled = en

    self.VScroll:SetVisible(en)
    self.VScroll:SetMouseInputEnabled(en)
end

function PANEL:SetHorizontalScrollEnabled(en)
    self.HorizontalScrollEnabled = en

    self.HScroll:SetVisible(en)
    self.HScroll:SetMouseInputEnabled(en)
end

function PANEL:Init()
    self.VScroll = vgui.Create("Melon:ScrollBar", self)
    self.HScroll = vgui.Create("Melon:ScrollBar", self)
    self.HScroll:SetHorizontal(true)

    self:SetScrollPerDelta(127)
    self:SetScrollbarSize(8)
    self:SetScrollbarPad(4)
    self:SetScrollbarMaxOverflow(250)
    self:SetPanningEnabled(false)

    self:SetVerticalScrollEnabled(true)
    self:SetHorizontalScrollEnabled(true)
end

function PANEL:ScrollPerf(w, h)
    local size = melon.Scale(self:GetScrollbarSize())
    local pad = melon.Scale(self:GetScrollbarPad())

    self.VScroll:SetSize(size, h - (pad * 2))
    self.VScroll:SetPos(w - size - pad, pad)

    self.HScroll:SetSize(w - ((self:GetVerticalScrollEnabled() and self.VScroll:GetDomain() != 0) and (size + (pad * 3)) or (pad * 2)), size)
    self.HScroll:SetPos(pad, h - size - pad)
end

function PANEL:PerformLayout(w, h)
    self:ScrollPerf(w, h)
end

function PANEL:OnMouseWheeled(d)
    if (
        (self.VScroll:IsHovered() and self.VScroll:GetDomain() != 0) or (self.HScroll:IsHovered() and self.HScroll:GetDomain() != 0)
    ) or (
        self.VScroll:IsChildHovered() or self.HScroll:IsChildHovered()
    ) then return end

    if self:GetHorizontalScrollEnabled() and (input.IsShiftDown() or self.VScroll:GetDomain() == 0) then
        return self.HScroll:OnMouseWheeled(d)
    end

    self.VScroll:OnMouseWheeled(d)
end

function PANEL:OnMousePressed(m)
    if m == MOUSE_MIDDLE then
        self:Pan()
    end
end

----
---@method
---@name melon.elements.ScrollPanel:Pan
----
---- Start panning, should only be called while MOUSE_MIDDLE is down
---- Automatically abides by the PanningEnabled accessor
----
function PANEL:Pan()
    if not self:GetPanningEnabled() then
        return
    end

    self.VScroll:SetiPanning(true)
    self.VScroll:Grab()

    if self:GetHorizontalScrollEnabled() then
        self.HScroll:SetiPanning(true)
        self.HScroll:Grab()
    end
end

melon.DebugNamed("ScrollPanel", function()
    melon.DebugPanel(PANEL, function(p)
        local canvas = vgui.Create("Panel", p)

        p:SetCanvas(canvas)
        canvas:SetSize(p:GetWide() * 1, p:GetTall() * 20)

        for i = 0, 40 do
            local b = vgui.Create("Panel", canvas)
            b:Dock(TOP)
            -- b:SetText(i)
        end
    end )
end )