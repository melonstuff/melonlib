
local meta = FindMetaTable("Panel")

----
---@method
---@name Panel.GetClippingBounds
----
---@return (minx: number) Minimum X coord of the panels clipping bounds
---@return (miny: number) Minimum Y coord of the panels clipping bounds
---@return (maxx: number) Maximum X coord of the panels clipping bounds
---@return (maxy: number) Maximum Y coord of the panels clipping bounds
----
---- Gets the clipping bounds of this panel, for use with render.SetScissorRect
---- This goes up the tree to find how much of the panel is *actually* visible
----
function meta:GetClippingBounds(done)
    done = done or {}
    if done[self] then
        return
    end
    done[self] = true

    local minx, miny = self:LocalToScreen(0, 0)
    if minx == 0 and miny == 0 and self:GetWide() == ScrW() and self:GetTall() == ScrH() then
        return
    end

    local maxx, maxy = minx + self:GetWide(), miny + self:GetTall()

    local parent = self:GetParent()
    if not IsValid(parent) then
        return minx, miny, maxx, maxy
    end

    local px, py, pxx, pyy = parent:GetClippingBounds(done)

    if not px then return minx, miny, maxx, maxy end

    minx = math.max(px, minx)
    miny = math.max(py, miny)
    maxx = math.min(maxx, pxx)
    maxy = math.min(maxy, pyy)

    return minx, miny, maxx, maxy
end

melon.DebugPanel("DPanel", function(p)
    local q = vgui.Create("DPanel", p)
    q:SetPos(-p:GetWide() / 2, p:GetTall() / 2)
    q:SetSize(p:GetSize())

    local r = vgui.Create("DPanel", q)
    r:SetSize(p:GetWide(), melon.Scale(20))
    r:SetPos(p:GetWide() - 10, melon.Scale(40))

    p:SetBackgroundColor(Color(22, 22, 22))
    q:SetBackgroundColor(Color(255, 255, 255, 10))
    r:SetBackgroundColor(q:GetBackgroundColor())

    function p:PaintOver()
        local oc = DisableClipping(true)

        local rx, ry = p:LocalToScreen(0, 0)
        local x, y, xx, yy = r:GetClippingBounds()

        render.SetScissorRect(x, y, xx, yy, true)
        surface.SetDrawColor(melon.colors.Rainbow())
        surface.DrawRect(-rx, -ry, ScrW(), ScrH())
        render.SetScissorRect(0, 0, 0, 0, false)

        surface.SetDrawColor(255, 255, 255)
        surface.DrawOutlinedRect(q:GetX(), q:GetY(), q:GetWide(), q:GetTall())

        surface.DrawOutlinedRect(q:GetX() + r:GetX(), q:GetY() + r:GetY(), r:GetWide(), r:GetTall())

        DisableClipping(oc)
    end
end )