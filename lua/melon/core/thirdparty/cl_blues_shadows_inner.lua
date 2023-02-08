
local BSHADOWS = {}

melon.thirdparty = melon.thirdparty or {}
melon.thirdparty.BSHADOWS_inner_shadow_version = BSHADOWS

BSHADOWS.ShadowMaterial = CreateMaterial("bshadows","UnlitGeneric",{
    ["$translucent"] = 1,
    ["$vertexalpha"] = 1,
    ["alpha"] = 1
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

    render.CopyRenderTargetToTexture(BSHADOWS.RenderTarget)

    if blur > 0 then
        render.OverrideAlphaWriteEnable(true, true)
        render.BlurRenderTarget(BSHADOWS.RenderTarget, spread, spread, blur)
        render.OverrideAlphaWriteEnable(false, false) 
    end

    render.PopRenderTarget()

    BSHADOWS.ShadowMaterial:SetTexture("$basetexture", BSHADOWS.RenderTarget)
    BSHADOWS.ShadowMaterial:SetFloat("$alpha", opacity / 255)
    
    render.SetMaterial(BSHADOWS.ShadowMaterial)
    for i = 1 , math.ceil(intensity) do
        render.SetScissorRect(xx, yy, xx + ww, yy + hh, true)
        render.DrawScreenQuad()
        render.SetScissorRect(0, 0, 0, 0, false)
    end

    if not _shadowOnly then
        BSHADOWS.ShadowMaterial:SetTexture("$basetexture", BSHADOWS.RenderTarget)
        render.SetMaterial(BSHADOWS.ShadowMaterial)
        render.DrawScreenQuad()
    end

    cam.End2D()
end