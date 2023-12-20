
melon.elements = melon.elements or {}

----
---@panel Melon:Mask
---@name melon.elements.Mask
----
---- A basepanel thats children render adheres to a mask
----
local PANEL = vgui.Register("Melon:Mask", {}, "Panel")
melon.elements.Mask = PANEL

local rt = GetRenderTargetEx("MelonMaskPanel", ScrW(), ScrH(), RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_SEPARATE, bit.bor(1, 256), 0, IMAGE_FORMAT_BGRA8888)
local mat = CreateMaterial("MelonMaskPanel", "UnlitGeneric", {
    ["$basetexture"] = rt:GetName(),
    ["$translucent"] = "1",
    ["$vertexalpha"] = "1",
    ["$vertexcolor"] = "1",
})

function PANEL:Init()
    self.exclude_from_mask = {}
end

function PANEL:Paint(w, h)
    render.PushRenderTarget(rt)
    cam.Start2D()
    render.Clear(0, 0, 0, 0)
    self:Mask(w, h)
    cam.End2D()
    render.PopRenderTarget()

    for k,v in pairs(self:GetChildren()) do
        if not IsValid(v) then continue end
        v:PaintManual()
    end
end

----
---@internal
---@method
---@name melon.elements.Mask:PaintMaskRelative
----
---- Paints the mask texture relative to the given panel
----
function PANEL:PaintMaskRelative(s)
    local x,y = self:LocalToScreen(0,0)
    local sx, sy = s:LocalToScreen(-x, -y)
    surface.SetMaterial(mat)
    surface.DrawTexturedRect(-sx, -sy, ScrW(), ScrH())
end

----
---@method
---@name melon.elements.Mask:Mask
----
---@arg (w: number) Width of the panel
---@arg (h: number) Height of the panel
----
---- Called once per frame to determine the mask of the panel, override this
----
function PANEL:Mask(w, h) end

function PANEL:Exclude(panel, v)
    self.exclude_from_mask[panel] = (v == nil and true) or v
end

----
---@method
---@name melon.elements.Mask:MakeMask
----
---@arg (panel: panel) Panel to add to this mask
----
---- Adds a panel to this mask, must be called with no arguments in Init after child initialization
---- And this must be called on all children when added
----
---- IMPORTANT, This function overrides Paint and OnChildAdded
----
function PANEL:MakeMask(panels, done, root)
    if ispanel(panels) then
        panels:SetPaintedManually(true)
        panels.OldPaint = panels.Paint
        panels.Paint = self.MaskPaint
        panels.MaskRoot = root or self

        panels.OnChildAdded = function(s)
            s.MaskUpdateRequested = true
        end

        return
    end

    done = done or {}
    panels = panels or self:GetChildren()

    for k, v in pairs(panels) do
        if done[v] then continue end
        if not IsValid(v) then continue end
        -- if v.OldPaint or v.Paint == self.MaskPaint then continue end
        
        done[v] = true

        self:MakeMask(v)
        self:MakeMask(v:GetChildren(), done, self)
    end
end

function PANEL:MaskPaint(w, h)
    if self.MaskUpdateRequested then
        self.MaskRoot:MakeMask(self:GetChildren(), nil, self.MaskRoot)
    end

    self.MaskRoot:DoMask(self, w, h)
end

----
---@method
---@name melon.elements.Mask:DoMask
----
---@arg (pnl: Panel) Panel were rendering the mask of
---@arg (w:  number) Width of the panel
---@arg (h:  number) Height of the panel
----
---- Called when a mask render has been requested
---- Override this if you wish to modify anything about how the mask is rendered, or use stacked masks
---- Remember, call pnl.OldPaint and self:PaintMaskRelative
----
function PANEL:DoMask(pnl, w, h)
    melon.masks.Start()
        pnl:OldPaint(w, h)
    melon.masks.Source()
        self:PaintMaskRelative(pnl)
    melon.masks.End()
end

melon.DebugPanel("Melon:Mask", function(p)
    local tl, bl, tr, br = 
        vgui.Create("Panel", p),
        vgui.Create("Panel", p),
        vgui.Create("Panel", p),
        vgui.Create("Panel", p)

    tl.edge, bl.edge, tr.edge, br.edge = 
        vgui.Create("DPanel", tl),
        vgui.Create("DPanel", bl),
        vgui.Create("DPanel", tr),
        vgui.Create("DPanel", br)

    function p:PerformLayout(w, h)
        tl:SetSize(w / 2, h / 2)
        bl:SetSize(w / 2, h / 2)
        tr:SetSize(w / 2, h / 2)
        br:SetSize(w / 2, h / 2)

        bl:SetPos(0, h / 2)
        tr:SetPos(w / 2, 0)
        br:SetPos(w / 2, h / 2)

        bl.edge:SetPos(0, bl:GetTall() - bl.edge:GetTall())
        tr.edge:SetPos(tr:GetWide() - tr.edge:GetWide())
        br.edge:SetPos(br:GetWide() - br.edge:GetWide(), br:GetTall() - br.edge:GetTall())
    end

    tl.Paint = function(s,w,h) surface.SetDrawColor(melon.colors.Rainbow(45, 0)) surface.DrawRect(0, 0, w, h) end
    tr.Paint = function(s,w,h) surface.SetDrawColor(melon.colors.Rainbow(45, 20)) surface.DrawRect(0, 0, w, h) end
    bl.Paint = function(s,w,h) surface.SetDrawColor(melon.colors.Rainbow(45, 40)) surface.DrawRect(0, 0, w, h) end
    br.Paint = function(s,w,h) surface.SetDrawColor(melon.colors.Rainbow(45, 60)) surface.DrawRect(0, 0, w, h) end

    function p:Mask(w, h)
        local space = 30
        for i = -15, (math.ceil(w / space) - 4) / 2 do
            draw.NoTexture()
            surface.SetDrawColor(255, 255, 255)
            surface.DrawTexturedRectRotated(i * space + ((w / space) * i) - space, h / 2, w / space, h * 2, (CurTime() * 100) - 50)
            surface.DrawTexturedRectRotated(i * space + ((w / space) * i) - space, h / 2, w / space, h * 2, (CurTime() * 100) + 90)
        end
    end
    

    p:MakeMask()
end )