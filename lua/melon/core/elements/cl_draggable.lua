
local PANEL = vgui.Register("Melon:Draggable", {}, "Panel")
AccessorFunc(PANEL, "area", "AreaOf") -- takes Panel
AccessorFunc(PANEL, "bbp", "Bounded") -- takes Panel or true for parent

function PANEL:Init()
    self:SetBounded(true)
    self:SetAreaOf(self)
    self.dragging = false 
end

function PANEL:OnMousePressed(m)
    if m == MOUSE_LEFT then
        self:StartDragging()
        self.dragging = {self:GetAreaOf():LocalCursorPos()}
        return
    end

    self.dragging = false
end

function PANEL:OnMouseReleased(m)
    if m == MOUSE_LEFT and self.dragging then
        self:EndDragging()
        self.dragging = false
    end
end

function PANEL:CalcDragPos()
    local x, y  = gui.MouseX(), gui.MouseY()
    local xx,yy = self.dragging[1], self.dragging[2]

    return x - xx, y - yy
end

function PANEL:CalcCroppedPos()
    local x,y   = self:CalcDragPos()
    local pw,ph = (
        (ispanel(self:GetBounded()) and self:GetBounded()) or 
        self:GetAreaOf():GetParent()):GetSize()
    local mw,mh = self:GetAreaOf():GetSize()

    return math.Clamp(x, 0, pw - mw), math.Clamp(y, 0, ph - mh)
end

function PANEL:Think()
    if not self.dragging then return end

    if not input.IsMouseDown(MOUSE_LEFT) or gui.IsConsoleVisible() or not system.HasFocus() then
        self:EndDragging()
        self.dragging = false

        return
    end

    local x,y = self:CalcDragPos()

    if self:GetBounded() then
        x, y = self:CalcCroppedPos()
    end

    self:GetAreaOf():SetPos(x, y)
end

function PANEL:StartDragging()
    self:SetCursor("sizeall")
end

function PANEL:EndDragging()
    self:SetCursor("arrow")
end

melon.DebugPanel("DPanel", function(p)
    p:SetSize(400, 400)
    p:Center()

    p.drag = vgui.Create("Melon:Draggable", p)
    p.drag:SetSize(200, 200)
    p.drag:Center()
    p.drag:SetAreaOf(p)
end )