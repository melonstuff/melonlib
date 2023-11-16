---! no_gma

if not melon.Debug() then return end

local text = Color(77, 77, 77)
local inactive = Color(94, 92, 230, 100)
local active = Color(94, 92, 230)

----
---@internal
---@module
---@name melon.branding
---@realm CLIENT
----
---- Renders MelonLib branding dynamically ingame
---- Feel free to look at this but I dont recommend modifying it lol
---- Always export gifs with 30ms between frames
----
melon.branding = melon.branding or {}
melon.branding.bits = {}
melon.branding.play_state = {
    playing = true,
    frame = 0,
    rendering = false
}
melon.branding.fps = 30

melon.branding.RT = GetRenderTarget("MelonBranding", ScrW(), ScrH())
melon.branding.Mat = CreateMaterial("MelonBranding", "UnlitGeneric", {
    ["$basetexture"] = melon.branding.RT:GetName(),
    ["$translucent"] = "1",
    ["$vertexcolor"] = "1",
    ["$vertexalpha"] = "1"
})

file.CreateDir("melon")
file.CreateDir("melon/branding")

----
---@name melon.branding.Open
----
---- Opens the branding UI
----
function melon.branding.Open()
    if IsValid(melon.branding.UI) then
        melon.branding.UI:Remove()
    end

    melon.branding.UI = vgui.Create("DFrame")
    melon.branding.UI:SetTitle("MelonLib Branding")
    melon.branding.UI:SetSize(ScrW(), ScrH())
    melon.branding.UI:MakePopup()
    melon.branding.UI.Paint = nil

    melon.branding.UI.OnMouseWheeled = function(s, d)
        local max = melon.branding.bits[s.Tabs:GetActiveTab()].frames

        melon.branding.play_state.frame = melon.branding.play_state.frame + d
        melon.branding.play_state.frame = math.Clamp(melon.branding.play_state.frame, 0, max)
    end

    function melon.branding.UI:Think()
        local s = melon.branding.play_state
        local c = melon.branding.bits[melon.branding.UI.Tabs:GetActiveTab()]

        if s.rendering then
            return
        end

        if c.frames == 1 then
            s.frame = 1
            return
        end

        if not s.playing then return end
        s.last = s.last or 0
        if CurTime() < s.last then
            return
        end

        s.last = CurTime() + (1 / melon.branding.fps)

        s.frame = s.frame + 1

        if s.frame > c.frames then
            s.frame = 0
        end
    end
    
    if gui.IsGameUIVisible() then
        gui.HideGameUI()
    end

    melon.branding.UI.Sidebar = vgui.Create("DPanel", melon.branding.UI)
    melon.branding.UI.Tabs = vgui.Create("Melon:Tabs", melon.branding.UI)

    melon.branding.UI.Sidebar:Dock(LEFT)
    melon.branding.UI.Sidebar:SetWide(melon.Scale(200))

    melon.branding.UI.Tabs:Dock(FILL)

    melon.branding.UI.Sidebar.Controls = vgui.Create("Panel", melon.branding.UI.Sidebar)
    melon.branding.UI.Sidebar.Controls:Dock(TOP)
    melon.branding.UI.Sidebar.Controls:SetTall(melon.Scale(34))
    melon.branding.UI.Sidebar.Controls:DockMargin(2, 2, 2, 2)

    melon.branding.UI.Sidebar.Controls.Paint = function(s, w, h)
        draw.Text({
            text = math.Round((melon.branding.play_state.frame / melon.branding.bits[melon.branding.UI.Tabs:GetActiveTab()].frames) * 100) .. "%",
            pos = {w, h / 2},
            xalign = 2,
            yalign = 1,
            font = melon.Font(20, "Inter"),
            color = text
        })
    end

    melon.branding.UI.Sidebar.Controls.PlayPause = vgui.Create("Melon:Button", melon.branding.UI.Sidebar.Controls)
    melon.branding.UI.Sidebar.Controls.PlayPause:Dock(LEFT)
    melon.branding.UI.Sidebar.Controls.PlayPause:SetWide(melon.branding.UI.Sidebar.Controls:GetTall())
    melon.branding.UI.Sidebar.Controls.PlayPause.DoubleClickTime = 0

    melon.branding.UI.Sidebar.Controls.Stop = vgui.Create("Melon:Button", melon.branding.UI.Sidebar.Controls)
    melon.branding.UI.Sidebar.Controls.Stop:Dock(LEFT)
    melon.branding.UI.Sidebar.Controls.Stop:DockMargin(2, 0, 0, 0)
    melon.branding.UI.Sidebar.Controls.Stop:SetWide(melon.branding.UI.Sidebar.Controls:GetTall())
    melon.branding.UI.Sidebar.Controls.Stop.DoubleClickTime = 0

    melon.branding.UI.Sidebar.Controls.Visibility = vgui.Create("Melon:Button", melon.branding.UI.Sidebar.Controls)
    melon.branding.UI.Sidebar.Controls.Visibility:Dock(LEFT)
    melon.branding.UI.Sidebar.Controls.Visibility:DockMargin(2, 0, 0, 0)
    melon.branding.UI.Sidebar.Controls.Visibility:SetWide(melon.branding.UI.Sidebar.Controls:GetTall())
    melon.branding.UI.Sidebar.Controls.Visibility.DoubleClickTime = 0

    melon.branding.UI.Sidebar.Controls.PlayPause.Paint = function(s, w, h)
        local scale = .5
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(melon.Material(melon.branding.play_state.playing and "icon16/control_pause.png" or "icon16/control_play.png"))
        surface.DrawTexturedRectRotated(w / 2, h / 2, w * scale, h * scale, 0)
    end

    melon.branding.UI.Sidebar.Controls.Stop.Paint = function(s, w, h)
        local scale = .5
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(melon.Material("icon16/control_stop.png"))
        surface.DrawTexturedRectRotated(w / 2, h / 2, w * scale, h * scale, 0)
    end

    melon.branding.UI.Sidebar.Controls.Visibility.Paint = function(s, w, h)
        local scale = .5
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(melon.Material(melon.branding.visibility and "icon16/delete.png" or "icon16/eye.png"))
        surface.DrawTexturedRectRotated(w / 2, h / 2, w * scale, h * scale, 0)
    end

    melon.branding.UI.Sidebar.Controls.PlayPause.LeftClick = function()
        if melon.branding.play_state.rendering then return end
    
        melon.branding.play_state.playing = not melon.branding.play_state.playing
    end

    melon.branding.UI.Sidebar.Controls.Stop.LeftClick = function()
        if melon.branding.play_state.rendering then return end

        melon.branding.play_state = {
            playing = false,
            frame = 0
        }
    end

    melon.branding.UI.Sidebar.Controls.Visibility.LeftClick = function()
        if melon.branding.play_state.rendering then return end
       
        melon.branding.visibility = not melon.branding.visibility
    end

    melon.branding.UI.Sidebar.Render = vgui.Create("Melon:Button", melon.branding.UI.Sidebar)
    melon.branding.UI.Sidebar.Render:Dock(BOTTOM)
    melon.branding.UI.Sidebar.Render:SetTall(melon.Scale(34))
    melon.branding.UI.Sidebar.Render:DockMargin(2, 0, 2, 2)

    melon.branding.UI.Sidebar.Render.Paint = function(s,w,h)
        draw.RoundedBox(melon.Scale(6), 0, 0, w, h, melon.branding.play_state.rendering and active or inactive)

        draw.Text({
            text = melon.branding.play_state.rendering and "Rendering..." or "Render",
            pos = {w / 2, h / 2 + 2},
            color = color_white,
            xalign = 1,
            yalign = 1,
            font = melon.Font(30)
        })
    end

    melon.branding.UI.Sidebar.Render.LeftClick = function()
        if melon.branding.play_state.rendering then return end

        melon.branding.play_state = {
            playing = false,
            frame = 0,
            rendering = true
        }
    end

    for k,v in SortedPairsByMemberValue(melon.branding.bits, "order") do
        local btn = vgui.Create("Melon:Button", melon.branding.UI.Sidebar)
        AccessorFunc(btn, "Active", "Active") -- cursed af i know

        btn.DoubleClickTime = 0
        btn:Dock(TOP)
        btn:DockMargin(2, 2, 2, 0)
        btn:SetTall(melon.Scale(34))
        btn:SetActive(melon.branding.UI.Tabs:GetActiveTab() == nil)
        function btn:Paint(w, h)
            self.color = melon.colors.Lerp(FrameTime() * 10, self.color or (self:GetActive() and active or inactive), self:GetActive() and active or inactive)

            draw.RoundedBox(melon.Scale(6), 0, 0, w, h, self.color)

            local pad = melon.Scale(4)
            draw.RoundedBox(melon.Scale(4), pad, pad, w - pad - pad, h - pad - pad, color_white)
            
            draw.Text({
                text = k,
                pos = {w / 2, h / 2},
                xalign = 1,
                yalign = 1,
                font = melon.Font(20, "Inter", 900),
                color = text
            })
        end 

        function btn:LeftClick()
            if melon.branding.play_state.rendering then return end

            melon.branding.UI.Tabs:SetTab(k)
        end

        local tab = vgui.Create("Panel", melon.branding.UI.Tabs)
        melon.branding.UI.Tabs:AddTab(k, tab)
        tab.LinkedButton = btn

        tab.Paint = function(s, w, h)
            local time = melon.branding.play_state.frame / v.frames

            local rw, rh = v.func(w / 2, h / 2, time, s, math.sin(time * 6.2831853071796))

            if not rw or not rh then
                return
            end

            s.RenderSize = {w = rw, h = rh}

            if melon.branding.visibility then
                surface.SetDrawColor(22, 22, 22)
                surface.DrawRect(0, 0, w / 2 - rw / 2, h)
                surface.DrawRect(w / 2 + rw / 2, 0, w / 2 - rw / 2, h)
                surface.DrawRect(w / 2 - rw / 2, 0, rw, h / 2 - rh / 2)
                surface.DrawRect(w / 2 - rw / 2, h / 2 + rh / 2, rw, h / 2 - rh / 2)
                return
            end

            local pad = 4
            surface.SetDrawColor(255, 255, 255, 20)
            surface.DrawLine(pad, pad, w / 2 - rw / 2 - pad, h / 2 - rh / 2 - pad)
            surface.DrawLine(w - pad, pad, w / 2 + rw / 2 + pad, h / 2 - rh / 2 - pad)
            surface.DrawLine(w - pad, h - pad, w / 2 + rw / 2 + pad, h / 2 + rh / 2 + pad)
            surface.DrawLine(pad, h - pad, w / 2 - rw / 2 - pad, h / 2 + rh / 2 + pad)

            surface.SetDrawColor(255, 255, 255)
            surface.DrawLine(w / 2 - rw / 2, h / 2 - rh / 2, w / 2 - rw / 2, h / 2 + rh / 2)
            surface.DrawLine(w / 2 - rw / 2, h / 2 + rh / 2, w / 2 + rw / 2, h / 2 + rh / 2)
            surface.DrawLine(w / 2 + rw / 2, h / 2 + rh / 2, w / 2 + rw / 2, h / 2 - rh / 2)
            surface.DrawLine(w / 2 - rw / 2, h / 2 - rh / 2, w / 2 + rw / 2, h / 2 - rh / 2)
        end
    end

    function melon.branding.UI.Tabs:OnTabChanged(new, old)
        melon.branding.UI.Sidebar.Controls.Stop.LeftClick()
    
        if IsValid(old) then
            old.LinkedButton:SetActive(false)
        end

        melon.branding.OldActive = self:GetActiveTab()
        new.LinkedButton:SetActive(true)
        melon.branding.play_state.playing = true
    end

    if melon.branding.OldActive and melon.branding.UI.Tabs.tabs[melon.branding.OldActive] then
        melon.branding.UI.Tabs:SetTab(melon.branding.OldActive)
    end
end

local render_queued
function melon.branding.RenderFrame()
    if not melon.branding.play_state.rendering then return end

    if melon.branding.play_state.frame > melon.branding.bits[melon.branding.UI.Tabs:GetActiveTab()].frames then
        melon.branding.play_state.rendering = false
        melon.branding.play_state.frame = 0
        return
    end

    render_queued = true
end

hook.Add("PreRender", "MelonBrandingRender", function()
    melon.branding.RenderFrame()
end )

hook.Add("PostRender", "MelonBrandingRender", function()
    if not render_queued then return end
    
    local p = melon.branding.UI.Tabs.tabs[melon.branding.UI.Tabs:GetActiveTab()]
    local x,y = p:LocalToScreen(p:GetWide() / 2 - p.RenderSize.w / 2, p:GetTall() / 2 - p.RenderSize.h / 2)

    local data = render.Capture({
        format = "png",
        x = x,
        y = y,
        w = p.RenderSize.w,
        h = p.RenderSize.h,
        alpha = false
    })

    local fold = "melon/branding/" .. melon.branding.UI.Tabs:GetActiveTab() .. "/"
    file.CreateDir(fold)
    file.Write(fold .. melon.branding.play_state.frame .. ".png", data)

    melon.branding.play_state.frame = melon.branding.play_state.frame + 1

    render_queued = false
end )

local order = 0
----
---@name melon.branding.AddBit
----
---@arg (name:   string) Name of the bit
---@arg (render:   func) Render function for the bit
---@arg (pre:     table) Table of bits to render before this one
---@arg (frames: number) Number of frames to render when rendering this bit
----
---- Adds a "branding bit" which is basically one individual item
----
function melon.branding.AddBit(name, func, pre, frames)
    melon.branding.bits[name] = {
        order = order,
        func = function(...)
            for k, v in ipairs(pre or {}) do
                if melon.branding.bits[v] then
                    melon.branding.bits[v].func(...)
                end
            end

            return func(...) --- (centerx, centery, time, panel, sine_time) -> (w, h)
        end,
        frames = frames or melon.branding.fps
    }
    order = order + 1
end

local brandingsize = ScrW()
melon.branding.AddBit("background", function(cx, cy, time, panel, st)
    local w,h = brandingsize, brandingsize
    local x,y = cx - w / 2, cy - h / 2
    local dist = 45
    local lines = math.ceil(math.max(w, h) / dist)
    surface.SetDrawColor(12, 104, 129)
    surface.DrawRect(x, y, w, h)

    surface.SetMaterial(melon.Material("vgui/gradient-l"))
    surface.SetDrawColor(0, 107, 106)
    surface.DrawTexturedRectRotated(cx, cy, w * 1.5 + st, h * 1.5, st * 20)

    local offset = st * 10
    for i = -1, lines + 1 do
        surface.SetDrawColor(255, 255, 255, 35 - (st * (math.abs(math.sin(i / lines) + st) * 25)))

        local dst = (math.max(w, h) / lines) * i
        surface.DrawLine(x + dst - dist - offset, y, x + dst + dist + offset, y + h)
        surface.DrawLine(x, y + dst + dist + offset, x + w, y + dst - dist - offset)
    end

    return w, h
end, {})

local scale = .75
local scaled_w, scaled_h = ScrW() * scale, ScrH() * scale
melon.branding.AddBit("demo_background", function(cx, cy, time, panel, st)
    local x, y = cx - (scaled_w / 2), cy - (scaled_h / 2)
    local melonsize = scaled_w * 0.04

    surface.SetDrawColor(255, 255, 255, 20)
    local tw = draw.Text({
        text = "MelonLib",
        pos = {x + 10, y + (melonsize - 10)},
        font = melon.Font(scaled_w * 0.03),
        color = surface.GetDrawColor()
    })

    melon.DrawImage("https://i.imgur.com/rUpDQFy.png", x + 10 + tw / 2 - (melonsize / 2), y, melonsize, melonsize)

    draw.Text({
        text = "rendered ingame",
        pos = {x + 14, y + scaled_h - 10},
        yalign = 4,
        font = melon.Font(scaled_w * 0.02),
        color = {r = 255, g = 255, b = 255, a = 20}
    })

    return scaled_w, scaled_h
end, {"background"})

local isize = 512
melon.branding.AddBit("melonlib", function(cx, cy, time, panel, st)
    local font = melon.Font(isize * .24)
    local mln_size = isize * .4
    local rx, ry = panel:LocalToScreen(0, 0)
    local tx, ty = cx + (st * 10), cy + mln_size / 2

    local center = Vector(cx + rx, cy + ry, 0)
    local matrix = Matrix()
    matrix:Translate(center)
    matrix:Rotate(Angle(0, st * -2, 0))
    matrix:Translate(-center)

    render.PushFilterMag(TEXFILTER.ANISOTROPIC)
    render.PushFilterMin(TEXFILTER.ANISOTROPIC)
    cam.PushModelMatrix(matrix)
    local _, th = draw.Text({
        text = "MelonLib",
        pos = {tx, ty},
        xalign = 1,
        font = font
    })

    local smallfont = melon.Font(isize * .06)
    surface.SetFont(smallfont)
    local tw = surface.GetTextSize("By modern men, for modern men")
    draw.Text({
        text = melon.branding.play_state.frame != 25 and "By modern men, for modern men" or "By modern men, for modern women :3",
        pos = {tx - tw / 2, ty + th * .7},
        font = smallfont,
        color = {r = 255, g = 255, b = 255, a = 60 - (st * 20)}
    })
    cam.PopModelMatrix()
    render.PopFilterMag()
    render.PopFilterMin()

    local smallerfont = melon.Font(isize * .05)
    draw.Text({
        text = "rendered ingame",
        pos = {cx - (isize / 2 - 10), cy + (isize / 2 - 10)},
        xalign = 0,
        yalign = 4,
        font = smallerfont,
        color = {r = 255, g = 255, b = 255, a = 20}
    })

    draw.Text({
        text = "if you dont see the model, hot-refresh on this tab",
        pos = {cx, cy + isize / 2 + 10},
        xalign = 1,
        yalign = 3,
        font = smallerfont,
        color = {r = 255, g = 255, b = 255, a = 20}
    })

    if not IsValid(panel.Model) then
        panel.Model = vgui.Create("DModelPanel", panel)
        panel.Model:SetSize(isize, isize)
        panel.Model:Center()
        panel.Model:SetModel("models/props_junk/watermelon01.mdl")
        panel.Model:SetDirectionalLight(BOX_TOP, Color(100, 255, 100))
        panel.Model:SetDirectionalLight(BOX_RIGHT, Color(100, 255, 100))
        panel.Model:SetDirectionalLight(BOX_FRONT, Color(100, 255, 100))

        function panel.Model:LayoutEntity(e)
            self:SetLookAt(e:GetPos())
            self:SetCamPos(e:GetPos() - Vector(0, 35, 0))
        end

        function panel.Model:Paint( w, h )
            if not IsValid(self.Entity) then return end
        
            local x,y = self:LocalToScreen(0, 0)
        
            self:LayoutEntity(self.Entity)
        
            local ang = self.aLookAngle
            if not ang then
                ang = (self.vLookatPos - self.vCamPos):Angle()
            end

            cam.Start3D(self.vCamPos, ang, self.fFOV, x, y, w, h, 5, self.FarZ)
                render.SuppressEngineLighting( true )
                render.SetLightingOrigin( self.Entity:GetPos() )
                render.ResetModelLighting( self.colAmbientLight.r / 255, self.colAmbientLight.g / 255, self.colAmbientLight.b / 255 )
                render.SetColorModulation( self.colColor.r / 255, self.colColor.g / 255, self.colColor.b / 255 )
                render.SetBlend( ( self:GetAlpha() / 255 ) * ( self.colColor.a / 255 ) ) -- * surface.GetAlphaMultiplier()
            
                for i = 0, 6 do
                    local col = self.DirectionalLight[ i ]
                    if col then
                        render.SetModelLighting( i, col.r / 255, col.g / 255, col.b / 255 )
                    end
                end
            
                self:DrawModel()
            
                render.SuppressEngineLighting(false)
            cam.End3D()

            self.LastPaint = RealTime()
        end
    end

    local r,p,y = 180 * st, 360 * time, 40
    panel.Model.Entity:SetAngles(Angle(r, p, y))

    return isize, isize
end, {"background"}, 25)

--- this is meant to be pretty, not optimized
--- do NOT copy from this istg
melon.branding.AddBit("gradients", function(cx, cy, time, panel, st)
    local c = {
        {0,   HSVToColor((time * 360) + 0,   0.9, 0.9)},
        {35,  HSVToColor((time * 360) + 25,  0.9, 0.9)},
        {70,  HSVToColor((time * 360) + 50,  0.9, 0.9)},
        {90,  HSVToColor((time * 360) + 75,  0.9, 0.9)},
        {100, HSVToColor((time * 360) + 100, 0.9, 0.9)},
    }

    local c2 = {
        {0,   c[5][2]},
        {35,  c[4][2]},
        {70,  c[3][2]},
        {90,  c[2][2]},
        {100, c[1][2]},
    }

    local g = melon.GradientBuilder()
    
    for k,v in pairs(c) do
        g:Step(v[1], v[2])
    end

    g:LocalTo(panel)

    local size = 300
    g:Render(cx - size / 2, cy - size / 2, size, size)

    surface.SetDrawColor(22, 22, 22, 100)
    surface.DrawOutlinedRect(cx - size / 2, cy - size / 2, size, size, 2)

    local dtext = "this is real"
    local font = melon.Font(40)
    surface.SetFont(font)
    local tw, th = surface.GetTextSize(dtext)
    
    draw.NoTexture()
    surface.DrawTexturedRectRotated(cx, cy, size - 4, th + 20, 0)

    draw.Text({
        text = dtext,
        pos = {cx + 1, cy + 1},
        xalign = 1,
        yalign = 1,
        font = font,
        color = surface.GetDrawColor()
    })

    melon.TextGradient(dtext, font, cx - tw / 2, cy - th / 2, c2)

    return scaled_w, scaled_h
end, {"demo_background"}, 60)

melon.branding.AddBit("despawn", function(cx, cy, time, panel, st)
    surface.SetDrawColor(26, 26, 26)
    surface.DrawRect(0, 0, ScrW(), ScrH())

    if not IsValid(panel.Model) then
        panel.Model = vgui.Create("DModelPanel", panel)
        panel.Model:SetSize(512, 512)
        panel.Model:Center()
        panel.Model:SetModel("models/weapons/w_toolgun.mdl")
        panel.Model:SetPaintedManually(true)

        function panel.Model:LayoutEntity(e)
            local center = e:GetPos() + Vector(6,0,2)
            self:SetLookAt(center)
            self:SetCamPos(center - Vector(0, 15, 0))
        end

        function panel.Model:PreDrawModel(e) 
            -- self.Entity:SetMaterial("Models/effects/comball_tape")
            -- self.Entity:DrawModel()

            self:Scissor()
            self.Entity:SetMaterial("models/props_combine/tprings_globe")
            -- self.Entity:DrawModel()
        end

        function panel.Model:Scissor(o, y)
            local rx, ry = self:LocalToScreen()

            ry = ry + (y or 0)
            local offset = ry - ((self:GetTall() * 2) * self.time) + self:GetTall() + (o or 0)
            render.SetScissorRect(-rx, offset, rx + ScrW(), offset + self:GetTall(), true)
        end
    end

    panel.Model.material = melon.GradientBuilder("branding_despawn")
        :Reset()
        :Step(0,   melon.colors.Lerp(st, Color(88, 154, 202), Color(151, 185, 237)))
        :Step(50, Color(113, 47, 255))
        :Step(100, melon.colors.Lerp(st, Color(113, 47, 255), Color(116, 237, 215)))
        :Material()
    panel.Model.time = time
    panel.Model.Entity:SetAngles(Angle(10 * st, 20 * st, 20 * st + (5 * st)))

    local x,y = cx - 256, cy - 256
    local dist = 35
    
    melon.masks.Start()
        surface.SetDrawColor(255,255,255)
        surface.SetMaterial(panel.Model.material)
        surface.DrawTexturedRectRotated(cx, cy, 512, 512, 0)

        for i = -1, (512 / dist) + 1 do
            local pos = i * dist
            surface.SetDrawColor(255, 255, 255, 80)
            surface.DrawLine(x + pos - dist, y, x + pos + dist, y + 512)
        end
    melon.masks.Source()
        panel.Model:PaintAt(cx - 256, cy - 256, 512, 512)

        local t = {
            text = "despawn",
            pos = {cx, cy},
            xalign = 1,
            yalign = 1,
            font = melon.Font(110, "SF Pro Rounded Heavy"),
        }

        panel.Model:Scissor(512, -30)
        draw.Text(t)

        panel.Model:Scissor(-512, -30)
        draw.Text(t)
    
        -- t.text = "labs"
        -- t.pos[2] = cy + 256
        -- t.yalign = 4
        -- draw.Text(t)

        render.SetScissorRect(0,0,0,0,false)
    
        for i = -1, (512 / dist) + 1 do
            local pos = i * dist
            surface.SetDrawColor(255, 255, 255, 40)
            surface.DrawLine(x, y + pos - dist, x + 512, y + pos + dist)
        end
    melon.masks.End()

    return 512, 512
end, nil, 60)

melon.Debug(melon.branding.Open)