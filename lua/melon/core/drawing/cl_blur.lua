
local blurMat = Material("pp/blurscreen")

----
---@name melon.DrawBlur
----
---@arg (panel: panel) Panel to draw the blur on
---@arg (localX: number) X relative to 0 of the panel
---@arg (localY: number) Y relative to 0 of the panel
---@arg (w:      number) W of the blur
---@arg (h:      number) H of the blur
---@arg (passes: number) How many passes to run, basically the strength of the blur
----
---- Draws blur!
----
function melon.DrawBlur(panel, localX, localY, w, h, passes)
    if passes == 0 then return end
    local x, y = panel:LocalToScreen(localX, localY)
    local scrw, scrh = ScrW(), ScrH()

    surface.SetMaterial(blurMat)
    surface.SetDrawColor(255, 255, 255)

    for i = 0, (passes or 6) do
        blurMat:SetFloat("$blur", i * .33)
        blurMat:Recompute()
    end
    render.UpdateScreenEffectTexture()
    surface.DrawTexturedRect(x * -1, y * -1, scrw, scrh)
end

----
---@name melon.DrawPanelBlur
----
---@arg (panel: panel) Panel to draw the blur on
---@arg (passes: type) How many passes to run, basically the strength of the blur
----
---- Draws blur based on a given panels dimensions
----
function melon.DrawPanelBlur(panel, passes)
    local x,y = panel:LocalToScreen(0, 0)
    local w,h = panel:GetSize()
    return melon.DrawBlur(panel, x, y, w, h, passes)
end