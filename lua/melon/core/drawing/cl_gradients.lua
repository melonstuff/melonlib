----
---@class builder
---@name melon.GradientBuilderObj
----
---- A multi-stage gradient builder objects
---- This makes a mesh and keeps a reference to it, make it once
----
local gradbuilder = {}
gradbuilder.__index = gradbuilder
melon.GradientBuilderObj = gradbuilder

----
---@internal
---@method
---@name gradbuilder.Init
----
function gradbuilder:Init()
    self.steps = {}

    self.colormod = {}
    self.alpha = {}
    return self
end

----
---@method
---@name gradbuilder.Alpha
----
---@arg    (tl: number) Top left alpha
---@arg    (tr: number) Top right alpha
---@arg    (bl: number) Bottom left alpha
---@arg    (br: number) Bottom right alpha
---@return (self: self) The gradbuilder
----
---- Determines the alpha of the different quadrants
---- Due to how vertexalpha works, this is useless at the moment
---- I'm finding a way to work around this though, potentially with OverrideBlend
----
function gradbuilder:Alpha(tl, tr, bl, br)
    self.alpha = {
        tl = tl,
        tr = tr,
        bl = bl,
        br = br
    }

    return self
end

----
---@method
---@name gradbuilder.ColorMod
----
---@arg    (tl:  Color) Top left color
---@arg    (tr:  Color) Top right color
---@arg    (bl:  Color) Bottom left color
---@arg    (br:  Color) Bottom right color
---@return (self: self) The gradbuilder
----
---- Modifies the color of a certain quadrant of the gradient
----
function gradbuilder:ColorMod(tl, tr, bl, br)
    self.colormod = {
        tl = tl,
        tr = tr,
        bl = bl,
        br = br
    }

    return self
end

----
---@method
---@name gradbuilder.Step
----
---@arg    (perc:  number) The % of where this step is
---@arg    (color:  Color) The color of this step
---@return (self:    self) The gradbuilder
----
---- Adds a step to the gradient with the given %
----
---`
---` melon.GradientBuilder()
---` :Step(0,   red)   --- 0%
---` :Step(50,  green) --- 50%
---` :Step(100, blue)  --- 100%
---`
function gradbuilder:Step(perc, color)
    table.insert(self.steps, {
        u = perc / 100,
        color = color
    })

    return self
end

----
---@method
---@name gradbuilder.LocalTo
----
---@arg    (panel: Panel) The panel that this gradient is local to
---@return (self:   self) The gradbuilder
----
---- Tells the gradient to render at a position local to this panel
---- Instead of 0,0 being -x,-y, it will be x,y, where x,y is the LocalToScreen pos of the panel
----
function gradbuilder:LocalTo(pnl)
    self.localto = pnl

    return self
end

----
---@method
---@name gradbuilder.Vertical
----
---@arg    (vertical: bool) Vertical (true) or horizontal (false)
---@return (self:     self) The gradbuilder
----
---- Should this gradient be top to bottom instead of left to right?
----
function gradbuilder:Vertical(v)
    self.vertical = (v == nil and (not self.vertical)) or v

    return self
end

----
---@method
---@name gradbuilder.Render
----
---@arg (x: number) X coordinate to render this gradient at
---@arg (y: number) Y coordinate to render this gradient at
---@arg (w: number) Width of the gradient
---@arg (h: number) Height of the gradient
---@arg (ign: bool) Ignore the offset of [gradbuilder.LocalTo]?
----
---- Renders the gradient to the screen at the given position
----
function gradbuilder:Render(x, y, w, h, ignore_localto)
    if IsValid(self.localto) and not ignore_localto then
        local px, py = self.localto:LocalToScreen(0, 0)

        x = x + px
        y = y + py
    end

    self.dimensions = self.dimensions or {}
    render.SetColorMaterial()

    if (not self.mesh) or (not IsValid(self.mesh)) or (self.dimensions.x != x) or (self.dimensions.y != y) or (self.dimensions.w != w) or (self.dimensions.h != h) then
        self.dimensions = {
            x = x,
            y = y,
            w = w,
            h = h
        }

        self:Build(x, y, w, h)
        self.mesh:Draw()
        return
    end

    self.mesh:Draw()
end

local nrt = GetRenderTarget("MelonMsGradient_Rt", 1024, 1024)
local nmat = CreateMaterial("MelonMsGradient_Mat", "UnlitGeneric", {
    ["$basetexture"] = nrt:GetName(),
    ["$vertexcolor"] = "1",
    ["$vertexalpha"] = "1" -- this is important for surface calls
})

----
---@method
---@name gradbuilder.Material
----
---@return (mat: IMaterial) The material of the gradient
----
---- Renders the gradient to a material and returns it
----
function gradbuilder:Material()
    render.PushRenderTarget(nrt)
    render.Clear(0, 0, 0, 0)
    cam.Start2D()

    render.SetMaterial(melon.Material("vgui/white"))
    self:Render(0, 0, 1024, 1024, true)

    cam.End2D()
    render.PopRenderTarget()

    return nmat
end

----
---@internal
---@method
---@name gradbuilder.Build
----
---@arg (x: number) X coordinate to build the mesh to
---@arg (y: number) Y coordinate to build the mesh to
---@arg (w: number) Width of the gradient
---@arg (h: number) Height of the gradient
----
---- Builds the gradient into an [IMesh] and renders it once
---- This function is expensive, not super, but considerably
----
function gradbuilder:Build(x, y, w, h)
    --- these assertions are important, the game crashes if you make a bad IMesh
    assert(isnumber(x), "Expected Number for argument 'x', got '" .. type(x) .. "'")
    assert(isnumber(y), "Expected Number for argument 'y', got '" .. type(y) .. "'")
    assert(isnumber(w), "Expected Number for argument 'w', got '" .. type(w) .. "'")
    assert(isnumber(h), "Expected Number for argument 'h', got '" .. type(h) .. "'")

    if IsValid(self.mesh) then
        self.mesh:Destroy()
    end

    local function color(clr, a)
        mesh.Color(clr.r, clr.g, clr.b, a or clr.a)
    end

    local m = Mesh(melon.Material("vgui/white"))
    mesh.Begin(m, MATERIAL_QUADS, #self.steps)

    local pos = {}
    for k,v in SortedPairsByMemberValue(self.steps, "u") do
        local next = self.steps[k + 1]
        if not next then break end

        local x1, x2, x3, x4
        local y1, y2, y3, y4

        if self.vertical then
            x1, x2, x3, x4 = w, 0, 0, w
            y1, y2, y3, y4 = next.u * h, next.u * h, v.u * h, v.u * h
        else
            x1, x2, x3, x4 = next.u * w, next.u * w, v.u * w, v.u * w
            y1, y2, y3, y4 = 0, h, h, 0
        end

        color(self.colormod.tr or next.color, self.alpha.tr)
        mesh.Position(Vector(x + x1, y + y1))
        mesh.AdvanceVertex()

        color(self.colormod.br or next.color, self.alpha.br)
        mesh.Position(Vector(x + x2, y + y2))
        mesh.AdvanceVertex()

        color(self.colormod.bl or v.color, self.alpha.bl)
        mesh.Position(Vector(x + x3, y + y3))
        mesh.AdvanceVertex()

        color(self.colormod.tl or v.color, self.alpha.tl)
        mesh.Position(Vector(x + x4, y + y4))
        mesh.AdvanceVertex()

        table.insert(pos, {x1, x2, x3, x4, y1, y2, y3, y4})
    end

    render.SetMaterial(melon.Material("vgui/white"))
    mesh.End()
    m:Draw()

    self.mesh = m
end

----
---@method
---@name gradbuilder.ToCSS
----
---@return (css: string) The css repr
----
---- Generates a `linear-gradient()` CSS function call that correlates to this gradient ingame
----
function gradbuilder:ToCSS()
    local css = {}

    for k,v in SortedPairsByMemberValue(self.steps, "u") do
        table.insert(css, "rgb(" .. v.color.r .. ", " .. v.color.g .. ", " .. v.color.b .. ") " .. (v.u * 100) .. "%")
    end

    return "linear-gradient(" .. (self.vertical and 180 or 90) .. "deg, " .. table.concat(css, ", ") .. ")"
end

local gradients = {}

----
---@name melon.GradientBuilder
----
---@arg    (id:              any) The identifier for the builder
---@return (builder: gradbuilder) The gradient builder object
----
---- Creates a [gradbuilder] object
---- The following example creates an image that looks like:   
---- ![img](https://i.imgur.com/Nno9xEz.png)
----
---` local g = melon.GradientBuilder("some_identifier")
---`     :Step(0, Color(255, 0, 0))
---`     :Step(25, Color(255, 0, 255))
---`     :Step(75, Color(0, 255, 0))
---`     :Step(100, Color(0, 0, 255))
---` 
---` hook.Add("HUDPaint", "RenderGradient", function()
---`     g:Render(10, 10, 150, 150)
---` end )

function melon.GradientBuilder(id)
    if not id then
        return setmetatable({}, gradbuilder):Init()
    end

    if gradients[id] then
        return gradients[id]
    end

    gradients[id] = setmetatable({}, gradbuilder):Init()

    return gradients[id]
end


do --- Text gradients

    local gw, gh = ScrW(), ScrH()
    local gx, gy = 0, 0
    local lh = 0
    
    local RT  = GetRenderTargetEx(
        "MelonTextGradientMap", gw, gh,
        RT_SIZE_NO_CHANGE,
        MATERIAL_RT_DEPTH_SEPARATE,
        bit.bor(1, 256),
        0,
        IMAGE_FORMAT_BGRA8888
    )
    local MAT = CreateMaterial("MelonTextGradientMap", "UnlitGeneric", {
        ["$basetexture"]  = RT:GetName(),
        ["$translucent"] = "1",
        ["$vertexalpha"] = "1"
    })
    
    local grads
    ----
    ---@name melon.TextGradient
    ----
    ---@arg (text:     string) The text to render
    ---@arg (font:     string) The font of the text
    ---@arg (x:        number) The X coord to render it at
    ---@arg (y:        number) The Y coord to render it at
    ---@arg (colors:    table) A sequential table of {step:number, color:Color}
    ---@arg (extra_id: string) An extra identifier incase youre running into collision issues with caching
    ----
    ---- Renders a piece of gradient text
    ----
    ---`
    ---` local c = {
    ---`     {0,   Color(84, 158, 200)},
    ---`     {35,  Color(101, 58, 192)},
    ---`     {70,  Color(143, 0, 255)},
    ---`     {90,  Color(152, 43, 138)},
    ---`     {100, Color(156, 62, 84)},
    ---` }
    ---` 
    ---` hook.Add("HUDPaint", "TextGradientRender", function()
    ---`     melon.TextGradient("Some Text", melon.Font(30), 10, 10, c)
    ---` end )
    ---`
    function melon.TextGradient(text, font, x, y, colors, extra_id)
        local name = text .. ":" .. font .. ":" .. #colors .. (extra_id or "noExtraID")
    
        if not grads then
            melon.ResetTextGradients()
        end
    
        if grads[name] then
            local t = grads[name]
    
            surface.SetDrawColor(255, 255, 255)
            surface.SetMaterial(MAT)
            surface.DrawTexturedRectUV(x, y, t.tw, t.th, t.u, t.v, (t.x + t.tw) / gw, (t.y + t.th) / gh)
    
            return t
        end
    
        surface.SetFont(font)
        local tw, th = surface.GetTextSize(text)
    
        lh = math.max(lh, th)
        if gx + tw >= gw then
            gx = 0
            gy = gy + lh
            lh = 0
        end
    
        render.PushRenderTarget(RT)
        render.PushFilterMag(TEXFILTER.POINT)
        render.PushFilterMin(TEXFILTER.POINT)
        cam.Start2D()
    
        local slices = tw
        local steps = {}
    
        for k, v in pairs(colors) do
            local next = colors[k + 1]
            if not next then continue end
    
            local perc = v[1] / 100
            local nperc = next[1] / 100
    
            table.insert(steps, {
                from = perc,
                to = nperc,
    
                left = v[2],
                right = next[2],
                region = slices * (nperc - perc)
            })
        end
    
        local per_slice = tw / slices
        local step = 1
        local incr = 0
        for i = 0, slices do
            local xx = per_slice * i
            local this = steps[step]
            if not this then continue end
    
            local t = (xx / tw)
            local rt = incr / this.region
            if t >= this.to then
                step = step + 1
                incr = 0
            end
    
            incr = incr + 1
    
            render.SetScissorRect(gx + xx, gy, gx + xx + per_slice, gy + th, true)
    
            local c = melon.colors.Lerp(rt, this.left, this.right)
            draw.Text({
                text = text,
                pos = {gx, gy},
                font = font,
                color = c,
            })
    
            render.SetScissorRect(0, 0, 0, 0, false)
        end
    
        cam.End2D()
        render.PopFilterMag()
        render.PopFilterMin()
        render.PopRenderTarget()
    
        grads[name] = {
            x = gx,
            y = gy,
            u = gx / gw,
            v = gy / gh,
    
            colors = colors,
            frame = 1,
            tw = tw,
            th = th,
            font = font,
        }
    
        gx = gx + tw
    
        melon.TextGradient(text, font, x, y, colors)
    
        return grads[name]
    end
    
    ----
    ---@name melon.ResetTextGradients
    ----
    ---- Resets the Text Gradient cache 
    ----
    function melon.ResetTextGradients()
        grads = {}
    
        render.PushRenderTarget(RT)
        render.OverrideAlphaWriteEnable(false, true)
            render.Clear(0, 0, 0, 0, true, true)
        render.OverrideAlphaWriteEnable(false, true)
        render.PopRenderTarget()
    end
end

if not melon.Debug() then return end

melon.ResetTextGradients()

local c = {
    {0,   Color(84, 158, 200)},
    {35,  Color(101, 58, 192)},
    {70,  Color(143, 0, 255)},
    {90,  Color(152, 43, 138)},
    {100, Color(156, 62, 84)},
}

melon.DebugPanel("Panel", function(p)
    p.render = vgui.Create("Panel", p)
    p.material = vgui.Create("Panel", p)
    p.html = vgui.Create("DHTML", p)

    local g = melon.GradientBuilder(p)

    for k,v in ipairs(c) do
        g:Step(v[1], v[2])
    end
    
    g:LocalTo(p.render)

    p.html:SetHTML(melon.string.Format([[
        <html style='background:-webkit-{1}; background:{1}; width:100%; height:100%'></html>
    ]], g:ToCSS()))

    function p:Paint(w, h)
        surface.SetDrawColor(22, 22, 22)
        surface.DrawRect(0, 0, w, h)
    end

    function p:PaintOver(w, h)
        local children = self:GetChildren()
        for k,v in pairs(children) do
            surface.SetFont(melon.Font(34))
            local realtw, realth = surface.GetTextSize(v.Text)
            local tw, th = realtw + 40, realth + 2

            draw.RoundedBox(16, w / 2 - tw / 2, v:GetY() + (v:GetTall() / 2) - (th / 2), tw, th, {r = 255, g = 255, b = 255, a = 255})

            -- draw.Text({
                -- text = v.Text,
                -- pos = {w / 2, v:GetY() + v:GetTall() / 2 + 2},
                -- xalign = 1,
                -- yalign = 1,
                -- font = melon.Font(34)
            -- })

            melon.TextGradient(v.Text, melon.Font(34), w / 2 - realtw / 2, v:GetY() + (v:GetTall() / 2) - (realth / 2) + 2, c)

            if v.SubText then
                draw.Text({
                    text = v.SubText,
                    pos = {w / 2, v:GetY() + v:GetTall() / 2 + th},
                    xalign = 1,
                    yalign = 1,
                    font = melon.Font(20),
                    color = {r = 255, g = 255, b = 255, a = 100}
                })
            end

            if k == #children then return end

            surface.SetDrawColor(22, 22, 22, 255)

            surface.SetMaterial(melon.Material("vgui/gradient-r"))
            surface.DrawTexturedRect(0, v:GetY() + v:GetTall(), w / 2, 2)            

            surface.SetMaterial(melon.Material("vgui/gradient-l"))
            surface.DrawTexturedRect(w / 2, v:GetY() + v:GetTall(), w / 2, 2)
        end
    end

    p.render.Text = "Render"
    function p.render:Paint(w, h)
        g:Render(0, 0, w, h)
    end

    p.material.Text = "Material"
    function p.material:Paint(w, h)
        surface.SetMaterial(g:Material())
        surface.SetDrawColor(255, 255, 255)
        surface.DrawTexturedRect(0, 0, w, h)
    end

    p.html.Text = "HTML"
    p.html.SubText =  (jit.arch == "x64" and "(Chromium)") or "(Awesomium)"

    function p:PerformLayout(w, h)
        local pad = 2
        self:DockPadding(pad, pad, pad, pad)
        self.render:SetSize(w, 200)
        self.render:Dock(TOP)

        self.material:SetSize(w, self.render:GetTall())
        self.material:Dock(TOP)

        self.html:SetSize(w, self.render:GetTall())
        self.html:Dock(TOP)

        self:Center()
        self:SetSize(500, self.render:GetTall() * #self:GetChildren() + pad + pad)
    end
end )