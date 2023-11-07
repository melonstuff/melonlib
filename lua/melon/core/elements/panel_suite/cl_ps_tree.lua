
local dockRot = {}
dockRot[LEFT] = 0
dockRot[RIGHT] = 180
dockRot[TOP] = -90
dockRot[BOTTOM] = 90

local PANEL = vgui.Register("Melon:PanelSuite:Tree", {}, "Panel")
AccessorFunc(PANEL, "LineH", "LineH")
AccessorFunc(PANEL, "FontSize", "FontSize")
AccessorFunc(PANEL, "DrawY", "DrawY")
AccessorFunc(PANEL, "ActiveNode", "ActiveNode")

function PANEL:Init()
    self.node_count = 0
    self.node_state = {}
    self.children = {}
    self:SetLineH(30)
    self:SetFontSize(20)
    self:SetDrawY(0)
    self.RealDrawY = 0
end

function PANEL:OnMouseWheeled(d)
    self:SetDrawY(self:GetDrawY() + (d * melon.Scale(20)))
end

function PANEL:Node(panel, real_panel)
    if not real_panel then
        real_panel = self
        self:Init()
    end

    local node = {
        panel = panel,
        children = {},
        Node = function(s, p)
            return self.Node(s, p, real_panel)
        end
    }
    real_panel.node_count = real_panel.node_count + 1

    table.insert(self.children, node)
    return node
end

function PANEL:OnNodeHover(info)
    if not info then
        self:GetParent():SetActivePanel(false)
        return
    end

    if self.hovering == info.node then return end
    self.hovering = info.node

    self:GetParent():SetActivePanel({
        panel = info.node.panel,
        x = info.x,
        y = info.y
    })
end

function PANEL:OnMousePressed(m)
    if m == MOUSE_LEFT then
        self.clicked = true
    end
end

function PANEL:IsLineHovered(y)
    if not self:IsMouseInputEnabled() then return false end

    local lineh = melon.Scale(self:GetLineH())
    if self.cursorx < 0 or self.cursorx > self:GetWide() then
        return false
    end
    return (self.cursory > y) and (self.cursory < y + lineh)
end

function PANEL:CalcClick(node)
    if node == self:GetActiveNode() then
        return
    end
    
    self:GetParent():SetActiveNode(node)
end

function PANEL:PaintNode(node, x, y, w, h)
    local lineh = melon.Scale(self:GetLineH())
    local marginx = melon.Scale(20)

    -- this is extraordinarily performant
    -- we can have THOUSANDS of children with NO performance loss!!!!!!!!!!
    if y > h then return y end
    if y + lineh < 0 then
        for _, n in pairs(node.children) do
            y = self:PaintNode(n, x + marginx, y + lineh, w, h)
        end

        return y
    end

    local hov = self:IsLineHovered(y)
    local v = self.node_state[node]
    if self.ActiveNode == node then
        self.node_state[node] = Lerp(FrameTime() * 10, v or 0, 1)
    elseif hov then
        self.node_state[node] = Lerp(FrameTime() * 10, v or 0, 0.6)
        
        local xx, yy = self:LocalToScreen(w - (lineh / 2), y + lineh / 2)
        self.hovering = {
            node = node,
            x = xx,
            y = yy
        }
    else
        self.node_state[node] = Lerp(FrameTime() * 10, v or 0, 0)

        if self.node_state[node] < 0.01 then
            self.node_state[node] = nil
            v = nil
        end
    end 

    if self.clicked and hov then
        self:CalcClick(node)

        self.clicked = false
    end

    local markerh = melon.Scale(2)
    surface.SetDrawColor(melon.PanelDevSuite.Theme.Midground)
    surface.DrawRect(marginx / 2, y + lineh / 2 - (markerh / 2), x, markerh)

    local accent = melon.PanelDevSuite.Theme.Accent
    if not IsValid(node.panel) then
        accent = melon.PanelDevSuite.Theme.BadAccent
    end

    if v then
        surface.SetDrawColor(accent.r, accent.g, accent.b, self.node_state[node] * 255)
        surface.DrawRect(0, y, w, lineh)
        surface.SetDrawColor(255, 255, 255, self.node_state[node] * 20)
        surface.DrawRect(0, y, w, melon.Scale(2))
        surface.DrawRect(0, y + lineh - melon.Scale(2), w, melon.Scale(2))
        surface.DrawRect(marginx / 2, y + lineh / 2 - (markerh / 2), x, markerh)
    end

    draw.Text({
        text = node.panel.ClassName or node.panel:GetClassName(),
        pos = {marginx + x, y + lineh / 2},
        xalign = 0,
        yalign = 1,
        font = melon.Font(self:GetFontSize()),
        color = melon.PanelDevSuite.Theme.Text
    })

    if node.panel:GetDock() == 0 then
        local pnl_x, pnl_y = node.panel:GetPos()
        local pnl_w, pnl_h = node.panel:GetSize()
        draw.Text({
            text = "[" .. pnl_x .. "," .. pnl_y .. " | " .. pnl_w .. "x" .. pnl_h .. "]",
            pos = {w - marginx, y + lineh / 2},
            xalign = 2,
            yalign = 1,
            font = melon.Font(self:GetFontSize()),
            color = melon.PanelDevSuite.Theme.SecondaryText
        })
    else
        local dock = node.panel:GetDock()
        local boxs = lineh * .8
        surface.SetDrawColor(melon.PanelDevSuite.Theme.SecondaryText)
    
        if dock == FILL then
            surface.DrawRect(w - marginx - boxs, y + lineh / 2 - boxs / 2, boxs, boxs)
        else
            surface.SetMaterial(melon.Material("vgui/gradient-l"))
            surface.DrawOutlinedRect(w - marginx - boxs, y + lineh / 2 - boxs / 2, boxs, boxs, 2)
            surface.DrawTexturedRectRotated(w - marginx - boxs / 2, y + lineh / 2, boxs - 4, boxs - 4, dockRot[dock])
        end 
    end

    for _, n in pairs(node.children) do
        y = self:PaintNode(n, x + marginx, y + lineh, w, h)
    end

    return y
end

function PANEL:PerformLayout(w, h)
    self.total_h = self.node_count * melon.Scale(self:GetLineH())
end

function PANEL:Paint(w, h)
    self.hovering = false
    self.cursorx, self.cursory = self:LocalCursorPos()

    if (not self.children[1]) or (not IsValid(self.children[1].panel)) then
        draw.Text({
            text = "No Nodes",
            pos = {w / 2, h / 2},
            xalign = 1,
            yalign = 1,
            font = melon.Font(50),
            color = melon.PanelDevSuite.Theme.Foreground,
        })

        return
    end

    local th = math.max(self.total_h or 0, h)
    self.RealDrawY = Lerp(FrameTime() * 10, self.RealDrawY or 0, self:GetDrawY())
    self.DrawY = Lerp(FrameTime() * 10, self.DrawY, -math.Clamp(math.abs(self.DrawY), 0, th - h))
    self:PaintNode(self.children[1], 0, self.RealDrawY, w, h)

    if self:GetActiveNode() then
        local xx, yy = self:LocalToScreen(w, h / 2)

        self:OnNodeHover({
            node = self:GetActiveNode(),
            x = xx,
            y = yy
        })
        return
    end

    self:OnNodeHover(self.hovering)
    self.clicked = false
end

function PANEL:PaintOver(w, h)

end

melon.DebugPanel2__TEST()