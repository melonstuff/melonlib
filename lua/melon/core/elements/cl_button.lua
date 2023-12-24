
melon.elements = melon.elements or {}

----
---@panel Melon:Button
---@name melon.elements.Button
----
---- Generic unstyled button
----
local PANEL = vgui.Register("Melon:Button", {}, "Panel")
PANEL.DoubleClickTime = 0.18

melon.elements.Button = PANEL

function PANEL:Init()
    self.pressing = {}
    self.pressing_count = 0
    self.clicked = {}
    self:SetCursor("hand")
end

function PANEL:OnMousePressed(m)
    if self.pressing[m] then
        self.pressing[m] = nil
        self.pressing_count = self.pressing_count - 1
        self:Click(m, true)

        return
    end

    self.pressing_count = self.pressing_count + 1
    self.pressing[m] = CurTime() + self.DoubleClickTime
end

function PANEL:ButtonThink()
    local ct = CurTime()
    for k,v in pairs(self.pressing) do
        if ct < v then continue end

        if not input.IsMouseDown(k) then
            self.pressing[k] = nil
            self:Click(k, false)
            self.pressing_count = self.pressing_count - 1
        end
    end
end

function PANEL:Think()
    self:ButtonThink()
end

function PANEL:Paint(w, h)
    melon.panels.DebugPaint(self, w, h)
end

----
---@method
---@name melon.elements.Button:CanClick
----
---@arg    (enum:    MOUSE_) What was the MOUSE_ enum of the click
---@arg    (double:    bool) Was this click a double click?
---@return (can_click: bool) Should we fire the click event?
---- 
---- Override this to determine whether or not to fire click events
----
function PANEL:CanClick(m, double)
    return true
end

----
---@method
---@name melon.elements.Button:Click
----
---@arg (enum: MOUSE_) What was the MOUSE_ enum of the click
---@arg (double: bool) Was this click a double click?
----
---- Called on any click, dont override this unless you have to
----
function PANEL:Click(m, double)
    if not self:CanClick(m, double) then return end

    if m == MOUSE_LEFT then
        self:LeftClick(double)
        return
    elseif m == MOUSE_RIGHT then
        self:RightClick(double)
        return
    end

    self:OtherClick(m, double)
end

----
---@method
---@name melon.elements.Button:LeftClick
----
---@arg (double: bool) Was this click a double click?
----
---- Called on left click, override this.
----
function PANEL:LeftClick(double)
end

----
---@method
---@name melon.elements.Button:RightClick
----
---@arg (double: bool) Was this click a double click?
----
---- Called on right click, override this.
----
function PANEL:RightClick(double)
end

----
---@method
---@name melon.elements.Button:OtherClick
----
---@arg (enum: MOUSE_) What was the MOUSE_ enum of the click
---@arg (double: bool) Was this click a double click?
----
---- Called on any click that isnt right or left.
----
function PANEL:OtherClick(enum, double)
end

melon.DebugPanel("Melon:Button", function(pnl)
    pnl:SetSize(500, 500)
    pnl:Center()
end)
