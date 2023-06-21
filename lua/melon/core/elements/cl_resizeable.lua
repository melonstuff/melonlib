
----
---@todo
---@name Melon:Resizable
----
---- Resizable Panel object
----
local PANEL = vgui.Register("Melon:Resizable", {}, "Panel")

function PANEL:Init()
    self:SetDragSize(12, 4)

    self.dragging = false
end

function PANEL:SetMaxSize(w, h)
    self.maxw, self.maxh = w, h
end

function PANEL:SetMinSize(w, h)
    self.minw, self.minh = w, h
end

function PANEL:SetDragSize(size, pad)
    self.dragsize = size
    self.dragpad = pad or size / 6
end

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

function PANEL:StartDragging()
    self:SetCursor("sizenwse")
end

function PANEL:EndDragging()
    self:SetCursor("arrow")
end

function PANEL:PaintOver(w, h)
    local size = self.dragsize
    local pad = self.dragpad
    melon.DrawImage("https://i.imgur.com/KRo8XD4.png", w - size - pad, h - size - pad, size, size)
end

melon.DebugPanel("Melon:Resizable", function(p)
    p:SetSize(400, 400)
    p:Center()

    p:SetMaxSize(600, 600)
    p:SetMinSize(200, 200)
end )