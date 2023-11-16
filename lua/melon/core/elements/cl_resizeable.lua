
melon.elements = melon.elements or {}

----
---@panel Melon:Resizable
---@name melon.elements.Resizable
----
---- Resizable Panel object
----
---`
---` local p = vgui.Create("Melon:Resizable")
---` p:SetSize(400, 400)
---` p:Center()
---` p:MakePopup()
---`
---` p:SetMaxSize(600, 600)
---` p:SetMinSize(200, 200)
---`
local PANEL = vgui.Register("Melon:Resizable", {}, "EditablePanel")
melon.elements.Resizable = PANEL

function PANEL:Init()
    self:SetDragSize(12, 4)

    self.dragging = false
end

----
---@method
---@name melon.elements.Resizable.SetMaxSize
----
---@arg (w: number) Width of the max size
---@arg (h: number) Height of the max size
----
---- Sets the maximum size for the panel to be resizable to
----
function PANEL:SetMaxSize(w, h)
    self.maxw, self.maxh = w, h
end

----
---@method
---@name melon.elements.Resizable.SetMinSize
----
---@arg (w: number) Width of the min size
---@arg (h: number) Height of the min size
----
---- Sets the minimum size for the panel to be resizable to
----
function PANEL:SetMinSize(w, h)
    self.minw, self.minh = w, h
end

----
---@method
---@name melon.elements.Resizable.SetDragSize
----
---@arg (size: number) Size of the draggable area
---@arg (pad:  number) Padding from the edge of the draggable area
----
---- Sets the draggable corner size and padding
----
function PANEL:SetDragSize(size, pad)
    self.dragsize = size
    self.dragpad = pad or size / 6
end

----
---@method
---@internal
---@name melon.elements.Resizable.WithinDragRegion
----
---@arg    (x:  number) X to check
---@arg    (y:  number) Y to check
---@return (is:   bool) Is it within the draggable region?
----
---- Check if a coord is within the drag region
----
function PANEL:WithinDragRegion(x, y)
    local w, h = self:GetSize()
    local s = self.dragsize + self.dragpad

    return
        (x > (w - s) and x < w) and
        (y > (h - s) and y < h)
end

function PANEL:OnMousePressed(m)
    if m != MOUSE_LEFT then 
        self.dragging = false
        return 
    end

    local x,y = self:LocalCursorPos()
    if not self:WithinDragRegion(x, y) then
        self.dragging = false
        return
    end

    self:StartDragging()
    self.dragging = {
        x, y,
        self:GetSize()
    }
end

function PANEL:OnMouseReleased(m)
    if m == MOUSE_LEFT and self.dragging then
        self.dragging = false
        self:EndDragging()
    end
end

function PANEL:Think()
    if not self.dragging then return end

    if not input.IsMouseDown(MOUSE_LEFT) or gui.IsConsoleVisible() or not system.HasFocus() then
        self:EndDragging()
        self.dragging = false

        return
    end

    local x,y = self:LocalCursorPos()
    local xx,yy = self.dragging[1], self.dragging[2]
    local w,h = self.dragging[3], self.dragging[4]
    self:SetSize(
        math.Clamp(w - (xx - x), self.minw, self.maxw), 
        math.Clamp(h - (yy - y), self.minh, self.maxh)
    )
end

----
---@method
---@name melon.elements.Resizable.StartDragging
----
---- Called when the panel starts being resized, remember to [SetCursor]
----
function PANEL:StartDragging()
    self:SetCursor("sizenwse")
end

----
---@method
---@name melon.elements.Resizable.EndDragging
----
---- Called when the panel stops being resized, remember to [SetCursor]
----
function PANEL:EndDragging()
    self:SetCursor("arrow")
end

function PANEL:PaintOver(w, h)
    local size = self.dragsize
    local pad = self.dragpad
    surface.SetDrawColor(255, 255, 255, 255)
    melon.DrawImage("https://i.imgur.com/KRo8XD4.png", w - size - pad, h - size - pad, size, size)
end

melon.DebugPanel("Melon:Resizable", function(p)
    p:SetSize(400, 400)
    p:Center()

    p:SetMaxSize(600, 600)
    p:SetMinSize(200, 200)
end )