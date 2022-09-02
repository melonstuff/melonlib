
local blurMat = Material("pp/blurscreen")
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
