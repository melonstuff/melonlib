---
--- Melon's Masks
--- https://github.com/melonstuff/melonsmasks/
--- Licensed under MIT
---

----
---@module
---@name masks
---@realm CLIENT
----
---- An alternative to stencils that samples a texture
---- For reference:
----  The destination is what is being masked, so a multi stage gradient or some other complex stuff
----  The source is the text, or the thing with alpha
----
melon.masks = {}

melon.masks.source = {}
melon.masks.dest   = {}

melon.masks.source.rt = GetRenderTargetEx("MelonMasks_Source",      ScrW(), ScrH(), RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_SEPARATE, bit.bor(1, 256), 0, IMAGE_FORMAT_BGRA8888)
melon.masks.dest.rt   = GetRenderTargetEx("MelonMasks_Destination", ScrW(), ScrH(), RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_SEPARATE, bit.bor(1, 256), 0, IMAGE_FORMAT_BGRA8888)

melon.masks.source.mat = CreateMaterial("MelonMasks_Source", "UnlitGeneric", {
    ["$basetexture"] = melon.masks.source.rt:GetName(),
    ["$translucent"] = "1",
    ["$vertexalpha"] = "1",
    ["$vertexcolor"] = "1",
})
melon.masks.dest.mat    = CreateMaterial("MelonMasks_Destination", "UnlitGeneric", {
    ["$basetexture"] = melon.masks.dest.rt:GetName(),
    ["$translucent"] = "1",
    ["$vertexalpha"] = "1",
    ["$vertexcolor"] = "1",
})


----
---@enumeration
---@name melon.masks.KIND
----
---@enum (CUT)   Cuts the source out of the destination
---@enum (STAMP) Cuts the destination out of the source
----
---- Determines the type of mask were rendering
----
melon.masks.KIND_CUT   = {BLEND_ZERO, BLEND_SRC_ALPHA, BLENDFUNC_ADD}
melon.masks.KIND_STAMP = {BLEND_ZERO, BLEND_ONE_MINUS_SRC_ALPHA, BLENDFUNC_ADD}

----
---@name melon.masks.Start
----
----
---- Starts the mask destination render
---- Whats between this and the `melon.masks.Source` call is the destination
---- See the module declaration for an explaination
----
function melon.masks.Start()
    render.PushRenderTarget(melon.masks.dest.rt)
    render.Clear(0, 0, 0, 0, true, true)
    cam.Start2D()
end

----
---@name melon.masks.Source
----
---- Stops the destination render
---- Whats between this and the `melon.masks.End` call is the source
---- See the module declaration for an explaination
----
function melon.masks.Source()
    cam.End2D()
    render.PopRenderTarget()

    render.PushRenderTarget(melon.masks.source.rt)
    render.Clear(0, 0, 0, 0, true, true)
    cam.Start2D()
end

----
---@name melon.masks.And
----
---@arg (kind: melon.masks.KIND_) The kind of mask this is, remember this is not a number enum
----
---- Renders the given kind of mask and continues the mask render
---- This can be used to layer masks 
---- This must be called post [melon.masks.Source]
---- You still need to call End
----
function melon.masks.And(kind)
    cam.End2D()
    render.PopRenderTarget()

    render.PushRenderTarget(melon.masks.dest.rt)
    cam.Start2D()
        render.OverrideBlend(true,
            kind[1], kind[2], kind[3]
        )
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(melon.masks.source.mat)
        surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
        render.OverrideBlend(false)
    melon.masks.Source()
end

----
---@name melon.masks.End
----
---@arg (kind: melon.masks.KIND_) The kind of mask this is, remember this is not a number enum
---@arg (x:         number) The x coordinate to render the rectangle at, defaults to 0
---@arg (y:         number) The y coordinate to render the rectangle at, defaults to 0
---@arg (w:         number) The width of the rectangle to render
---@arg (h:         number) The height of the rectangle to render
----
---- Stops the source render and renders everything finally
---- See the module declaration for an explaination
----
function melon.masks.End(kind, x, y, w, h)
    kind = kind or melon.masks.KIND_CUT

    cam.End2D()
    render.PopRenderTarget()

    render.PushRenderTarget(melon.masks.dest.rt)
    cam.Start2D()
        render.OverrideBlend(true,
            kind[1], kind[2], kind[3]
        )
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(melon.masks.source.mat)
        surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
        render.OverrideBlend(false)
    cam.End2D()
    render.PopRenderTarget()

    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(melon.masks.dest.mat)
    surface.DrawTexturedRect(x or 0, y or 0, w or ScrW(), h or ScrH())
end

----
---@name melon.masks.EndToTexture
----
---@arg (tex:     ITexture)
---@arg (kind: melon.masks.KIND_) The kind of mask this is, remember this is not a number enum
----
---- Stops the source render and renders everything to the given ITexture
----
function melon.masks.EndToTexture(texture, kind)
    kind = kind or melon.masks.KIND_CUT

    cam.End2D()
    render.PopRenderTarget()

    render.PushRenderTarget(melon.masks.dest.rt)
    cam.Start2D()
        render.OverrideBlend(true,
            kind[1], kind[2], kind[3]
        )
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(melon.masks.source.mat)
        surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
        render.OverrideBlend(false)
    cam.End2D()
    render.PopRenderTarget()

    render.CopyTexture(melon.masks.dest.rt, texture)
end