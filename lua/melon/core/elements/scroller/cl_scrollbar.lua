
----
---@panel Melon:ScrollBar
---@name melon.elements.ScrollBar
----
---@accessor (ScrollAmount:       number) Current scroll pos in pixels
---@accessor (Canvas:              Panel) Current canvas panel
---@accessor (Horizontal:        boolean) Is the scrollbar horizontal
---@accessor (OverflowAmount:     number) How much is the scrollbar currently overflowing, negative if up
---@accessor (iRealScrollAmount:  number) Internal, current real scroll position, interpolated
---@accessor (iGrabbed:            table) Internal, grab data
---@accessor (iGripColor:          Color) Internal, grip color
---@accessor (iPanning:          boolean) Internal, are we panning?
----
---- Scrollbar for ScrollPanels, handles the actual scrolling logic
----
local PANEL = vgui.Register("Melon:ScrollBar", {}, "Panel")
AccessorFunc(PANEL, "ScrollAmount", "ScrollAmount")
AccessorFunc(PANEL, "Canvas", "Canvas")
AccessorFunc(PANEL, "Horizontal", "Horizontal")
AccessorFunc(PANEL, "OverflowAmount", "OverflowAmount")
AccessorFunc(PANEL, "iRealScrollAmount", "iRealScrollAmount")
AccessorFunc(PANEL, "iGrabbed", "iGrabbed")
AccessorFunc(PANEL, "iGripColor", "iGripColor")
AccessorFunc(PANEL, "iPanning", "iPanning")

function PANEL:Init()
    self.Grip = vgui.Create("Panel", self)

    self:SetScrollAmount(0)
    self:SetiRealScrollAmount(0)
    self:SetiGripColor(Color(0, 0, 0, 160))
    self:SetiPanning(false)

    function self.Grip.OnMousePressed(s, m)
        if m == MOUSE_LEFT then
            self:Grab()
        end
    end
end

function PANEL:Paint(w, h)
    if self:GetDomain() == 0 then return end
  
    local amt = math.Clamp(math.abs(self:GetOverflowAmount() or 0), 0, (self:GetHorizontal() and h or w) * 2)
     
    melon.masks.Start()
        draw.RoundedBox(melon.Scale(4), self.Grip:GetX(), self.Grip:GetY(), self.Grip:GetWide(), self.Grip:GetTall(), self:GetiGripColor())
    melon.masks.Source()
        surface.SetDrawColor(255,255,255)

        if self:GetHorizontal() then
            surface.SetMaterial(melon.Material("vgui/gradient-l"))
            surface.DrawTexturedRect(0, 0, amt, h)
            surface.SetMaterial(melon.Material("vgui/gradient-r"))
            surface.DrawTexturedRect(w - amt + 1, 0, amt, h)
        else
            surface.SetMaterial(melon.Material("vgui/gradient-u"))
            surface.DrawTexturedRect(0, 0, w, amt)
            surface.SetMaterial(melon.Material("vgui/gradient-d"))
            surface.DrawTexturedRect(0, h - amt + 1, w, amt)
        end

    melon.masks.End(melon.masks.KIND_STAMP)
end

function PANEL:OnMousePressed(m)
    if m == MOUSE_MIDDLE and self:GetParent():GetPanningEnabled() then
        self:GetParent():Pan()
    end

    if m != MOUSE_LEFT then return end

    local x, y = self:LocalCursorPos()
    local r = self:GetHorizontal() and (x / self:GetWide()) or (y / self:GetTall())

    self:SetScrollAmount(math.Clamp(r, 0, 1) * (self:GetHorizontal() and self:GetCanvas():GetWide() or self:GetCanvas():GetTall()) - ((self:GetHorizontal() and self.Grip:GetWide() or self.Grip:GetTall()) / 2))
end

function PANEL:PerformLayout(w, h)
    if not IsValid(self:GetCanvas()) then return end

    local cvs = self:GetCanvas()

    local sw, sh = self:GetParent():GetSize()
    local cw, ch = cvs:GetSize()

    if self:GetHorizontal() then
        self.Grip:SetSize(w * (sw / cw), h)
    else
        self.Grip:SetSize(w, h * (sh / ch))
    end
end

function PANEL:GrabThink()
    local grab = self:GetiGrabbed()

    if grab then
        if (not self:GetiPanning() and not input.IsMouseDown(MOUSE_LEFT)) then
            self:SetiGrabbed(nil)
        elseif self:GetiPanning() and (not input.IsMouseDown(MOUSE_MIDDLE)) then
            self:SetiPanning(false)
            self:SetiGrabbed(nil)
        end

        local nx, ny = self:LocalCursorPos()
        local pos = self:GetHorizontal() and (nx - grab.x) or (ny - grab.y)
        local dom = self:GetHorizontal() and (self:GetWide() - self.Grip:GetWide()) or (self:GetTall() - self.Grip:GetTall())
        
        self:SetScrollAmount(
            math.Clamp(
                (pos / dom) * self:GetDomain(),
                -self:GetParent():GetScrollbarMaxOverflow(),
                self:GetDomain() + self:GetParent():GetScrollbarMaxOverflow()
            )
        )
    end
end

function PANEL:ScrollThink()
    if not self:GetCanvas() then return end
    if self:GetDomain() == 0 then return end

    self:GrabThink()

    self:SetScrollAmount(
        Lerp(FrameTime() * 10, self:GetScrollAmount(), math.Clamp(self:GetScrollAmount(), 0, self:GetDomain()))
    )

    local rounded = math.Round(self:GetScrollAmount())
    if rounded == 0 then
        self:SetScrollAmount(0)
    elseif rounded == self:GetDomain() then
        self:SetScrollAmount(self:GetDomain())
    end

    self:SetOverflowAmount(self:GetScrollAmount() - math.Clamp(self:GetScrollAmount(), 0, self:GetDomain()))

    local real = self:GetiRealScrollAmount()
    self:SetiRealScrollAmount(Lerp(FrameTime() * 10, real, self:GetScrollAmount()))

    local pos = (self:GetiRealScrollAmount() / self:GetDomain()) * (self:GetHorizontal() and (self:GetWide() - self.Grip:GetWide()) or (self:GetTall() - self.Grip:GetTall()))
    
    if self:GetHorizontal() then
        self.Grip:SetX(pos)
    else
        self.Grip:SetY(pos)
    end

    if self:GetHorizontal() then
        self:GetCanvas():SetX(-(self:GetiRealScrollAmount()))
    else
        self:GetCanvas():SetY(-(self:GetiRealScrollAmount()))
    end
end

function PANEL:Think()
    self:ScrollThink()
end

function PANEL:OnMouseWheeled(d)
    self:AddScroll(d)
end

----
---@method
---@name melon.elements.ScrollBar:AddScroll
----
---@arg (delta:   number) Scroll delta to add
---@arg (pixels: number?) Optional, how many pixels to scroll instead of delta
----
---- Scrolls the scrollbar however much is specified
----
function PANEL:AddScroll(delta, amt_in_pixels)
    if not self:GetCanvas() then return end
    if self:GetDomain() == 0 then return end
    
    self:SetScrollAmount(
        math.Clamp(self:GetScrollAmount() + (amt_in_pixels or self:GetParent():GetScrollPerDelta() * (-delta)), -self:GetParent():GetScrollbarMaxOverflow(), self:GetDomain() + self:GetParent():GetScrollbarMaxOverflow())
    )
end

----
---@method
---@name melon.elements.ScrollBar:ScrollTo
----
---@arg (pos: number) Position to scroll to
----
---- Scrolls to the given coordinate, if horizontal than X, if vertical than Y
----
function PANEL:ScrollTo(coord)
    if not self:GetCanvas() then return end
    if self:GetDomain() == 0 then return end
    
    self:SetScrollAmount(math.Clamp(coord, 0, self:GetHorizontal() and self:GetCanvas():GetWide() or self:GetCanvas():GetTall()))
end

----
---@method
---@name melon.elements.ScrollBar:ScrollToChild
----
---@arg (pnl: Panel) Panel to scroll to
----
---- Scrolls to a child panel, if the panel isnt a child then silently fails
----
function PANEL:ScrollToChild(panel)
    if not self:GetCanvas() then return end
    if self:GetDomain() == 0 then return end
    
    if not self:GetCanvas():IsOurChild(panel) then return end
    
    self:SetScrollAmount(math.Clamp(self:GetHorizontal() and panel:GetX() or panel:GetY(), 0, self:GetHorizontal() and self:GetCanvas():GetWide() or self:GetCanvas():GetTall()))
end

----
---@internal
---@method
---@name melon.elements.ScrollBar:Grab
----
---- Initiates grip grabbing
----
function PANEL:Grab()
    local x, y = self.Grip:LocalCursorPos()
    self:SetiGrabbed({
        x = x,
        y = y,
        xpos = self.Grip:GetX(),
        ypos = self.Grip:GetY(),
    })
end

----
---@method
---@name melon.elements.ScrollBar:GetDomain
----
---@return (num: number) The domain
----
---- Returns the "Domain", the actual scrollable area of the canvas, so (canvas_size - parent_size)
----
function PANEL:GetDomain()
    if not IsValid(self:GetCanvas()) then return end

    if self:GetHorizontal() then
        return math.max(self:GetCanvas():GetWide() - self:GetParent():GetWide(), 0)
    end

    return math.max(self:GetCanvas():GetTall() - self:GetParent():GetTall(), 0)
end

melon.DebugNamed("ScrollPanel")