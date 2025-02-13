
----
---@name melon.GenerateSuperellipse
----
---@arg    (n: number) The number that defines the shape of the superellipse
---@arg    (x: number) X coordinate of the superellipse
---@arg    (y: number) Y coordinate of the superellipse
---@arg    (w: number) Width of the superellipse
---@arg    (h: number) Height of the superellipse
---@arg    (resolution: number) Resolution of the superellipse, defaults to 4, lower the number, higher the quality
---@return (poly: table) Polygon table, for use with [surface.DrawPoly]
----
---- Generates a superellipse or "squircle" polygon, see https://en.wikipedia.org/wiki/Superellipse
----
function melon.GenerateSuperellipse(n, x, y, w, h, resolution)
    n = math.max(0, n)

    local poly = {}

    for i = 0, 360, (resolution or 4) do
        local r = math.rad(i)
        local s = math.sin(r)
        local c = math.cos(r)

        local v = (1 / ((math.abs(c) / (w / 2)) ^ n + (math.abs(s) / (h / 2)) ^ n)) ^ (1 / n);

        local xx = (x + w / 2) + (v * c)
        local yy = (y + h / 2) + (v * s)

        table.insert(poly, {
            x = xx,
            y = yy,
            u = xx / w,
            v = yy / h
        })
    end

    return poly
end

----
---@name melon.GenerateSuperellipseMesh
----
---@arg    (n: number) The number that defines the shape of the superellipse 
---@arg    (x: number) X coordinate of the superellipse
---@arg    (y: number) Y coordinate of the superellipse
---@arg    (w: number) Width of the superellipse
---@arg    (h: number) Height of the superellipse
---@arg    (resolution: number) Resolution of the superellipse, defaults to 5, lower the number, higher the quality
---@return (mesh: IMesh) Mesh of the given superellipse
----
---- Identical to [melon.GenerateSuperellipse] except this generates a Mesh instead of a Polygon
----
function melon.GenerateSuperellipseMesh(n, x, y, w, h, resolution)
    local poly = melon.GenerateSuperellipse(n, x, y, w, h, resolution)

    local cv = Vector(x + w / 2, y + h / 2)
    local b = {}

    for k, v in pairs(poly) do
        local next = poly[k + 1] or poly[1]

        table.insert(b, {
            color = color_white,
            pos = Vector(v.x, v.y),
            u = v.u,
            v = v.v
        })

        table.insert(b, {
            color = color_white,
            pos = Vector(next.x, next.y),
            u = next.u,
            v = next.v
        })

        table.insert(b, {
            color = color_white,
            pos = cv,
            u = 0.5,
            v = 0.5
        })
    end

    local m = Mesh()
    m:BuildFromTriangles(b)
    return m
end