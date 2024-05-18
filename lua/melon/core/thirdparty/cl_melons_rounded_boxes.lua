--[[
    [Melon's Rounded Boxes]
    Want a rounded box that has a material?
    Want it to look nice? 
    Want also to be able to draw any form of rounded polygons?
    WELL YOURE IN LUCK!
    Remember to cache your polygons
    and to credit me :) (https://github.com/garryspins)
    This doesnt stop you from doing stupid stuff, so dont be stupid
]]--

melon.thirdparty = melon.thirdparty or {}
melon.thirdparty.RoundedBoxes = {}

----
---@name melon.thirdparty.RoundedBoxes.RoundedBox
----
---@arg (radius: number) Radius of the rounded box
---@arg (x:      number) X position of the box
---@arg (y:      number) Y position of the box
---@arg (w:      number) W of the box
---@arg (h:      number) H of the box
---@arg (bl:     number) Should the bottom left be rounded independently, if so how much
---@arg (tl:     number) Should the top left be rounded independently, if so how much
---@arg (tr:     number) Should the top right be rounded independently, if so how much
---@arg (br:     number) Should the bottom right be rounded independently, if so how much
---@arg (detail: number) Number of vertices to put on edges, defaults to 1 for perfect quality, raise this number for how many vertices to skip.
----
---@return (poly: table) Polygon to be drawn with surface.DrawPoly
----
---- Generates a rounded box polygon
----
---`
---` local mat = Material("vgui/gradient-l")
---` local PANEL = vgui.Register("RoundedGradient", {}, "Panel")
---`
---` function PANEL:PerformLayout(w, h)
---`     self.background = melon.thirdparty.RoundedBoxes.RoundedBox(w / 4, 0, 0, w, h)
---` end
---`
---` function PANEL:Paint(w, h)
---`     draw.NoTexture()
---`     surface.SetDrawColor(0, 89, 161)
---`     surface.DrawPoly(self.background)
---` 
---`     surface.SetMaterial(mat)
---`     surface.SetDrawColor(0, 140, 255)
---`     surface.DrawPoly(self.background)
---` end
---`
function melon.thirdparty.RoundedBoxes.RoundedBox(radius, x, y, w, h, bl, tl, tr, br, detail)
    local unround = {
        {
            x = x,
            y = y + h,
            u = 0,
            v = 1,
            radius = isnumber(bl) and bl
        },
        {
            x = x,
            y = y,
            u = 0,
            v = 0,
            radius = isnumber(tl) and tl
        },
        {
            x = x + w,
            y = y,
            u = 1,
            v = 0,
            radius = isnumber(tr) and tr
        },
        {
            x = x + w,
            y = y + h,
            u = 1,
            v = 1,
            radius = isnumber(br) and br
        },
    }

    return melon.thirdparty.RoundedBoxes.RoundedPolygonUV(unround, radius, x, y, w, h, detail)
end

function melon.thirdparty.RoundedBoxes.RoundedPolygonUV(poly, default_radius, x,y,w,h, detail)
    poly = melon.thirdparty.RoundedBoxes.RoundedPolygon(poly, default_radius, detail)

    for k,v in pairs(poly) do
        v.u = (v.x-x) / w
        v.v = (v.y-y) / h
    end

    return poly
end

function melon.thirdparty.RoundedBoxes.RoundedPolygon(poly, default_radius, detail)
    local points = {}

    for k,v in pairs(poly) do
        local last = poly[k - 1] or poly[#poly]
        local curr = v
        local next = poly[k + 1] or poly[1]

        local radius = curr.radius or default_radius
        if radius == 0 then
            table.insert(points, curr)
        continue end

        local ltc_ang = math.atan2(curr.y - last.y, curr.x - last.x) + math.rad(180)
        local ntc_ang = math.atan2(curr.y - next.y, curr.x - next.x) + math.rad(180)

        local lex, ley = math.cos(ltc_ang) * radius, math.sin(ltc_ang) * radius
        local nex, ney = math.cos(ntc_ang) * radius, math.sin(ntc_ang) * radius

        local cx, cy = curr.x + nex + lex, curr.y + ney + ley,

        table.insert(points, {
            x = curr.x + lex,
            y = curr.y + ley,
        })

        local range = math.deg(ltc_ang - ntc_ang) % 360
        for i = 1, range - 1, detail or 1 do
            table.insert(points, {
                x = cx + math.cos(ntc_ang + math.rad(i + 180)) * radius,
                y = cy + math.sin(ntc_ang + math.rad(i + 180)) * radius,
            })
        end

        table.insert(points, {
            x = curr.x + nex,
            y = curr.y + ney,
        })
    end

    return points
end