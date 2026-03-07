
melon.elements = melon.elements or {}

----
---@panel Melon:Collapse
---@name melon.elements.Collapse
----
---@accessor (Collapsed: bool) Are we currently collapsed?
---@accessor (CollapsedAnimLength: number) How long should the animation take
---@accessor (CollapsedAnimTime: number?) If were currently animating, when did we start, internal
----
---@accessor (CollapsedWidth: number) How wide should we be when collapsed
---@accessor (CollapsedHeight: number) How tall should we be when collapsed
---@accessor (ExpandedWidth: number) How wide should we be when expanded
---@accessor (ExpandedHeight: number) How tall should we be when expanded
----
---- A generic "collapsible" element with animation logic
----
local PANEL = vgui.Register("Melon:Collapse", {}, "DPanel")
melon.elements.Collapse = PANEL

melon.AccessorFunc(PANEL, "Collapsed", false)
melon.AccessorFunc(PANEL, "CollapseAnimTime", false)
melon.AccessorFunc(PANEL, "CollapseAnimLength", 1)
melon.AccessorFunc(PANEL, "CollapsedWidth", false)
melon.AccessorFunc(PANEL, "CollapsedHeight", 0)
melon.AccessorFunc(PANEL, "ExpandedWidth", false)
melon.AccessorFunc(PANEL, "ExpandedHeight", 0)

----
---@method
---@name melon.elements.Collapse:Collapse
----
---@arg (bool) Should we skip the animation?
----
---- Collapses this element to its minimum size
----
function PANEL:Collapse(now)
    if self:GetCollapsed() then return end
    self:SetCollapsed(true)
    self:SetCollapseAnimTime(CurTime() - (now and self.CollapseAnimLength or 0))
end

----
---@method
---@name melon.elements.Collapse:Expand
----
---@arg (bool) Should we skip the animation?
----
---- Expands this element to its maximum size
----
function PANEL:Expand(now)
    if not self:GetCollapsed() then return end
    self:SetCollapsed(false)
    self:SetCollapseAnimTime(CurTime() - (now and self.CollapseAnimLength or 0))
end

----
---@method
---@name melon.elements.Collapse:Toggle
----
---@arg (bool) Should we skip the animation?
----
---- Toggles from expanded to collapsed
----
function PANEL:Toggle(now)
    if self:GetCollapsed() then
        return self:Expand(now)
    end

    return self:Collapse(now)
end

----
---@method
---@name melon.elements.Collapse:OnAnimSizeChanged
----
---@arg (to_w:   number) Width we are now
---@arg (to_h:   number) Height we are now
---@arg (from_w: number) Width we started with at the beginning of this frame
---@arg (from_h: number) Height we started with at the beginning of this frame
---@arg (time:   number) How far are we from `0` to `1` in the current animation
----
---- Called every `Think` of the animation where the size changes
---- Note for when overriding this, the base implementation invalidates the parent as well
----
function PANEL:OnAnimSizeChanged(tow, toh, fromw, fromh, time)
    if IsValid(self:GetParent()) then
        self:GetParent():InvalidateLayout(true)
    end
end

----
---@method
---@name melon.elements.Collapse:OnAnimDone
----
---- Called when the animation is done
----
function PANEL:OnAnimDone() end

----
---@method
---@name melon.elements.Collapse:Interpolate
----
---@arg    (delta: number) Delta from `0` to `1`
---@arg    (from:  number) Number to interp from
---@arg    (to:    number) Number to interp to
---@return (number) Our interpolated function
----
---- Called whenever we want to interpolate between two sizes
---- Default implementation is just `Lerp`
----
function PANEL:Interpolate(t, from, to)
    return Lerp(t, from, to)
end

----
---@method
---@name melon.elements.Collapse:AnimThink
----
---- The `Think` function for this [Panel]
---- Separate from the actual Panel Think so we can override it if need be without jank
----
function PANEL:AnimThink()
    if not self:GetCollapseAnimTime() then return end

    local closed = self:GetCollapsed()
    local t = math.min(
        (CurTime() - self:GetCollapseAnimTime()) / self:GetCollapseAnimLength(),
        1
    )
    local w, h = self:GetSize()

    local dw = (closed and self.CollapsedWidth) or self.ExpandedWidth
    local dh = (closed and self.CollapsedHeight) or self.ExpandedHeight

    if dw then
        self:SetWide(self:Interpolate(t, w, dw))
    end

    if dh then
        self:SetTall(self:Interpolate(t, h, dh))
    end

    if dw or dh then
        self:OnAnimSizeChanged(
            self:GetWide(), self:GetTall(),
            w, h, t
        )
    end

    if t != 1 then return end
    self:SetCollapseAnimTime(false)
    self:OnAnimDone()
end

PANEL.Think = PANEL.AnimThink

melon.DebugPanel(PANEL, function(p)
    p:CenterHorizontal(0.2)

    p:SetCollapsedHeight(melon.Scale(30))
    p:SetExpandedHeight(melon.Scale(500))

    p:SetCollapsedWidth(melon.Scale(100))
    p:SetExpandedWidth(melon.Scale(500))

    p.btn = vgui.Create("Melon:Button", p)
    p.btn:Dock(TOP)
    p.btn:SetTall(p:GetCollapsedHeight())

    function p.btn.Paint(s, w, h)
        draw.Text({
            text = p.Collapsed and "expand" or "collapse",
            pos = {w / 2, h / 2},
            xalign = 1,
            yalign = 1,
            color = color_black,
            font = melon.Font(30)
        })
    end

    function p.btn.LeftClick()
        p:Toggle()
    end

    function p.btn.RightClick()
        p:Toggle(true)
    end
end )