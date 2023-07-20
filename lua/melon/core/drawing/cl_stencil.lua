
----
---@module
---@name melon.stencil
---@realm CLIENT
----
---- Stencil helpers
----
---` melon.stencil.Start()
---`    surface.SetDrawColor(255, 255, 255)
---`    surface.DrawTexturedRectRotated(w / 2, h / 2, w, 50, CurTime() * 10)
---` melon.stencil.Cut()
---`    draw.Text({
---`        text = "Some Text",
---`        pos = {w / 2, h / 2},
---`        yalign = 1,
---`        xalign = 1,
---`        font = melon.Font(60),
---`        color = Color(255, 0, 0)
---`    })
---` melon.stencil.End()
melon.stencil = melon.stencil or {}
melon.stencil.open = false

----
---@name melon.stencil.Start
----
---- Starts the cutout
----
function melon.stencil.Start()
    if melon.stencil.open then
        Error("Starting a stencil without closing it")
        debug.Trace()
        
        melon.stencil.End()
        return 
    end

    melon.stencil.open = true
    render.ClearStencil()
    render.SetStencilEnable(true)
    
    render.SetStencilWriteMask(1)
    render.SetStencilTestMask(1)
    
    render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
    render.SetStencilPassOperation(STENCILOPERATION_ZERO)
    render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
    render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
    render.SetStencilReferenceValue(1)
end

----
---@name melon.stencil.Cut
----
---- Tells the stencil to start cutting
----
function melon.stencil.Cut()
    render.SetStencilFailOperation(STENCILOPERATION_ZERO)
    render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
    render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
    render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
    render.SetStencilReferenceValue(1)
end

----
---@name melon.stencil.Deny
----
---- Tells the stencil to start cutting but flip it, deny everything thats drawn!
----
function melon.stencil.Deny()
    render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
    render.SetStencilPassOperation(STENCILOPERATION_ZERO)
    render.SetStencilZFailOperation(STENCILOPERATION_REPLACE)
    render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
    render.SetStencilReferenceValue(0)
end

----
---@name melon.stencil.End
----
---- Ends the cutout
----
function melon.stencil.End()
    melon.stencil.open = false
    render.SetStencilEnable(false)
    render.ClearStencil()
end

melon.DebugPanel("DPanel", function(p)
    p:SetSize(500, 500)
    p:Center()

    local TestText = "Testing Text Hehe"
    function p:Paint(w, h)
        surface.SetFont(melon.Font(60))
        draw.Text({
            text = TestText,
            pos = {w / 2, h / 2},
            yalign = 1,
            xalign = 1,
            font = melon.Font(60),
            color = Color(0, 255, 0)
        })

        melon.stencil.Start()
            surface.SetDrawColor(255, 255, 255)
            surface.DrawTexturedRectRotated(w / 2, h / 2, w, 50, CurTime() * 10)
        melon.stencil.Deny()
            draw.Text({
                text = TestText,
                pos = {w / 2, h / 2},
                yalign = 1,
                xalign = 1,
                font = melon.Font(60),
                color = Color(255, 0, 0)
            })
        melon.stencil.End()
    end
end )