
----
---@realm CLIENT
---@name melon.noise
----
---- Handles noise generation and materials
----
melon.noise = melon.noise or {}

melon.noise.size = 2048 * 2
melon.noise.pixels = 0
melon.noise.rt = GetRenderTargetEx("MelonLib_Noise1", melon.noise.size, melon.noise.size, RT_SIZE_OFFSCREEN, MATERIAL_RT_DEPTH_NONE, bit.bor(1, 256), 0, IMAGE_FORMAT_RGBA8888)
melon.noise.mat = CreateMaterial("MelonLib_Noise1", "UnlitGeneric", {
    ["$basetexture"] = melon.noise.rt:GetName(),
    ["$translucent"] = "1",
    ["$vertexalpha"] = "1",
    ["$vertexcolor"] = "1",
})

render.PushRenderTarget(melon.noise.rt)
render.Clear(255, 255, 255, 0)
render.PopRenderTarget()

----
---@name melon.noise.GetMaterial
----
---@return (noise: IMaterial) The Noise Material
----
---- Gets the noise material generated
----
function melon.noise.GetMaterial()
    return melon.noise.mat
end

----
---@name melon.noise.Draw
----
---@arg (x:    number) X Coord
---@arg (y:    number) Y Coord
---@arg (w:    number) Width
---@arg (h:    number) Height
---@arg (xoff: number) X Offset
---@arg (yoff: number) Y Offset
----
---- Draws the noise material with the given offsets
----
function melon.noise.Draw(x, y, w, h, xoff, yoff)
    xoff = xoff or 0
    yoff = yoff or 0

    surface.SetMaterial(melon.noise.mat)
    surface.DrawTexturedRectUV(x, y, w, h, xoff, yoff, xoff + melon.noise.size / w + (x / w), yoff + melon.noise.size / h + (y / h))
end

----
---@internal
---@name melon.noise.DrawRandomPixel
---- Adds a pixel to the material
function melon.noise.DrawRandomPixel()
    local x, y, alpha = math.Rand(0, melon.noise.size), math.Rand(0, melon.noise.size), math.Rand(0, 255)

    surface.SetDrawColor(255, 255, 255, alpha)
    surface.DrawRect(x, y, 1, 1)
end

-- melon.DebugPanel("DPanel", function(p)
--     p:SetSize(ScrW(), ScrH() / 2)
--     p:Center()
--     function p:Paint(w, h)
--         surface.SetDrawColor(22, 22, 22)
--         surface.DrawRect(0, 0, w, h)

--         surface.SetDrawColor(255, 255, 255, 20)
--         surface.SetMaterial(melon.noise.mat)
    
--         melon.noise.Draw(0, 0, w, h)
--     end
-- end )

hook.Add("Think", "Melon:NoiseGenerate", function()
    local oc = DisableClipping(true)

    render.PushRenderTarget(melon.noise.rt)
    cam.Start2D()

    for i = 0, (1 / FrameTime()) * 6 do
        melon.noise.pixels = melon.noise.pixels + 1
        melon.noise.DrawRandomPixel()
    end

    cam.End2D()
    render.PopRenderTarget()

    DisableClipping(oc)

    if melon.noise.pixels >= 1500000 then
        melon.Log(3, "Noise Material Finished Generating!")
        melon.noise.pixels = false
        hook.Remove("Think", "Melon:NoiseGenerate")
    end
end )