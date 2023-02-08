
local BSHADOWS = {}

melon.thirdparty = melon.thirdparty or {}
melon.thirdparty.BSHADOWS = BSHADOWS

BSHADOWS.ShadowMaterial = CreateMaterial("bshadows","UnlitGeneric",{
    ["$translucent"] = 1,
    ["$vertexalpha"] = 1,
    ["alpha"] = 1
})

BSHADOWS.ShadowMaterialGrayscale = CreateMaterial("bshadows_grayscale","UnlitGeneric",{
    ["$translucent"] = 1,
    ["$vertexalpha"] = 1,
    ["$alpha"] = 1,
    ["$color"] = "0 0 0",
    ["$color2"] = "0 0 0"
})

local xx,yy,ww,hh = 0,0,0,0
BSHADOWS.BeginShadow = function(x, y, w, h)
    render.PushRenderTarget(BSHADOWS.RenderTarget)
    render.OverrideAlphaWriteEnable(true, true)
    render.Clear(0,0,0,0)
    render.OverrideAlphaWriteEnable(false, false)

    BSHADOWS.RenderTarget = GetRenderTarget("bshadows_original", w, h)
    BSHADOWS.RenderTarget2 = GetRenderTarget("bshadows_shadow",  w, h)

    xx,yy,ww,hh = x,y,w,h
    cam.Start2D()
end

BSHADOWS.EndShadow = function(intensity, spread, blur, opacity, direction, distance, _shadowOnly)
    opacity = opacity or 255
    direction = direction or 0
    distance = distance or 0
    _shadowOnly = _shadowOnly or false

    render.CopyRenderTargetToTexture(BSHADOWS.RenderTarget2)

    if blur > 0 then
        render.OverrideAlphaWriteEnable(true, true)
        render.BlurRenderTarget(BSHADOWS.RenderTarget2, spread, spread, blur)
        render.OverrideAlphaWriteEnable(false, false) 
    end

    render.PopRenderTarget()

    BSHADOWS.ShadowMaterial:SetTexture("$basetexture", BSHADOWS.RenderTarget)
    BSHADOWS.ShadowMaterialGrayscale:SetTexture("$basetexture", BSHADOWS.RenderTarget2)
    
    local xOffset = math.sin(math.rad(direction)) * distance 
    local yOffset = math.cos(math.rad(direction)) * distance

    BSHADOWS.ShadowMaterialGrayscale:SetFloat("$alpha", opacity / 255)
    render.SetMaterial(BSHADOWS.ShadowMaterialGrayscale)
    for i = 1 , math.ceil(intensity / 2) do
        render.SetScissorRect(xx, yy, xx + ww, yy + hh, true)
        render.DrawScreenQuad(xOffset, yOffset, ww, hh)
        render.SetScissorRect(xx, yy, xx + ww, yy + hh, false)
    end

    if not _shadowOnly then
        BSHADOWS.ShadowMaterial:SetTexture("$basetexture", BSHADOWS.RenderTarget)
        render.SetMaterial(BSHADOWS.ShadowMaterial)
        render.DrawScreenQuad()
    end

    cam.End2D()
end