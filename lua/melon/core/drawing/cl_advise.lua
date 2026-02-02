
local advisories = {}

function melon.Advise(text, length, color, font, x, y, xmul, ymul, dist)
    return melon.AdviseX({
        text = text,
        length = length,
        color = color,
        font = font,
        x = x,
        y = y,
        xmul = xmul,
        ymul = ymul,
        dist = dist
    })
end

function melon.AdviseX(t)
    t = t or {}

    t.time = t.time or CurTime()
    t.text = t.text or "<unset>"
    t.length = t.length or 4

    t.pos = t.pos or {}
    t.x = t.pos[1] or t.x or gui.MouseX()
    t.y = t.pos[2] or t.y or gui.MouseY()

    t.xmul = t.xmul or 0
    t.ymul = t.ymul or 0

    t.sinmul = t.sinmul or 4
    t.xsin = t.xsin or 0
    t.ysin = t.ysin or 0

    t.dist = t.dist or melon.Scale(400)

    t.font = t.font or melon.Font(20)
    t.color = t.color or color_white

    t.render = t.render or false

    return table.insert(advisories, t)
end

function melon.KillAdvise(k)
    if not k then return end
    if not advisories[k] then return end

    table.remove(advisories, k)
end

hook.Add("DrawOverlay", "Melon:Advisories", function()
    local ct = CurTime()

    local removed = false
    for k, v in pairs(advisories) do
        local time = (ct - v.time) / v.length
        local dist = v.dist * time
        local sin = math.sin(ct * v.sinmul)

        if v.render then
            v.render(v, time, dist, sin)
            continue
        end

        draw.Text({
            text = v.text,
            pos = {
                v.x + (dist * v.xmul) + (sin * v.xsin),
                v.y + (dist * v.ymul) + (sin * v.ysin)
            },
            xalign = 1,
            yalign = 1,
            font = v.font,
            color = melon.colors.Alpha(v.color, v.color.a - (time * v.color.a)),
        })

        if removed then continue end
        if time < 1 then continue end
        
        removed = true
        melon.KillAdvise(k)
    end
end )

melon.DebugPanel("DPanel", function(p)
    p:CenterHorizontal(0.15)
    
    function p:PaintOver(w, h)
        local size = melon.Scale(6)
        draw.RoundedBox(100, w / 2 - size / 2, h / 2 - size / 2, size, size, color_black)
    end

    p.top = vgui.Create("Melon:Button", p)
    p.bottom = vgui.Create("Melon:Button", p)
    p.left = vgui.Create("Melon:Button", p)
    p.right = vgui.Create("Melon:Button", p)

    p.top.mul = {0, -1}
    p.bottom.mul = {0, 1}
    p.left.mul = {-1, 0}
    p.right.mul = {1, 0}

    local last 
    local function click(s)
        local rx, ry = p:LocalToScreen(
            p:GetWide() / 2,
            p:GetTall() / 2
        )
        -- melon.Advise(
        --     "Some text! (" .. s.mul[1] .. ", " .. s.mul[2] .. ")", 
        --     4, color_black, nil, rx, ry,
        --     s.mul[1], s.mul[2]
        -- )

        melon.KillAdvise(last)
        last = melon.AdviseX({
            text = "Some text! (" .. s.mul[1] .. ", " .. s.mul[2] .. ")",
            font = melon.Font(20),
            length = 4,
            x = rx,
            y = ry,
            xmul = s.mul[1],
            ymul = s.mul[2],
            color = color_black
        })
    end

    p.top.LeftClick = click
    p.bottom.LeftClick = click
    p.left.LeftClick = click
    p.right.LeftClick = click

    timer.Simple(0.1, function()
        click(p.bottom)
    end )

    function p:PerformLayout(w, h)
        local bw = melon.Scale(40)

        self.left:SetSize(bw, h - bw - bw)
        self.right:SetSize(bw, h - bw - bw)
        self.top:SetSize(w - bw - bw, bw)
        self.bottom:SetSize(w - bw - bw, bw)

        self.left:SetPos(0, bw)
        self.right:SetPos(w - bw, bw)

        self.top:SetPos(bw, 0)
        self.bottom:SetPos(bw, h - bw)
    end
end )