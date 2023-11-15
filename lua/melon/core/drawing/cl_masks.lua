
----
---@module
---@name melon.masks
---@realm CLIENT
----
---- An alternative to stencils that samples a texture
---- For reference:
----  The destination is what is being masked, so a multi stage gradient or some other complex stuff
----  The source is the text, or the thing with alpha
----
melon.masks = melon.masks or {}
melon.masks.source = {}
melon.masks.dest   = {}

melon.masks.source.rt = GetRenderTargetEx(melon.DebugID "MelonMasks_Source",      ScrW(), ScrH(), RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_SEPARATE, bit.bor(1, 256), 0, IMAGE_FORMAT_BGRA8888)
melon.masks.dest.rt   = GetRenderTargetEx(melon.DebugID "MelonMasks_Destination", ScrW(), ScrH(), RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_SEPARATE, bit.bor(1, 256), 0, IMAGE_FORMAT_BGRA8888)

melon.masks.source.mat = CreateMaterial(melon.DebugID "MelonMasks_Source", "UnlitGeneric", {
    ["$basetexture"] = melon.masks.source.rt:GetName(),
    ["$translucent"] = "1",
    ["$vertexalpha"] = "1",
    ["$vertexcolor"] = "1",
})
melon.masks.dest.mat    = CreateMaterial(melon.DebugID "MelonMasks_Destination", "UnlitGeneric", {
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
---@name melon.masks.End
----
---@arg (type: melon.masks.KIND_) The kind of mask this is, remember this is not a number enum
----
---- Stops the source render and renders everything finally
---- See the module declaration for an explaination
----
function melon.masks.End(kind)
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
    surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
end

melon.DebugHook(false, "HUDPaint", function()
    local x,y = 0, 100
    
    surface.SetDrawColor(255, 0, 0)
    surface.DrawRect(x, y, 256, 256)

    melon.masks.Start()
        melon.TestGradient():Render(x, y, 256, 256)
    melon.masks.Source()
        surface.DrawLine(x, y, x + 256, y + 256)
        surface.DrawLine(x, y + 256, x + 256, y)

        surface.DrawOutlinedRect(x, y, 256, 256)

        draw.Text({
            text = "This text is a gradient",
            pos = {x + 128, y + 256},
            xalign = 1,
            yalign = 4,
            font = melon.Font(30)
        })
    melon.masks.End(melon.masks.KIND_STAMP)
end )

melon.DebugHook(false, "PostDrawTranslucentRenderables", function()
    local tr = LocalPlayer():GetEyeTrace()
    local ang = tr.HitNormal:Angle()
    
    local size = 1024
    local x,y = 0, 0
    local scale = 0.1

    ang:RotateAroundAxis(ang:Right(), -90)
    ang:RotateAroundAxis(ang:Up(), 90)
    cam.Start3D2D(tr.HitPos + (ang:Up() * 10) - (ang:Forward() * (size / 2) * scale) - (ang:Right() * (size / 2) * scale), ang, scale)
    
    melon.masks.Start()
        melon.TestGradient():Render(x, y, size, size)
    melon.masks.Source()
        surface.DrawLine(x, y, x + size, y + size)
        surface.DrawLine(x, y + size, x + size, y)

        surface.DrawOutlinedRect(x, y, size, size)

        draw.Text({
            text = "This text is a gradient",
            pos = {x + (size / 2), y + size},
            xalign = 1,
            yalign = 4,
            font = melon.Font(size * 0.1)
        })
    melon.masks.End(melon.masks.KIND_STAMP)

    cam.End3D2D()
end )

