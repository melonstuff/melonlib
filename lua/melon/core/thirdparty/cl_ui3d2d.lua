
local ui3d2d = {}
melon.thirdparty = melon.thirdparty or {}
melon.thirdparty.ui3d2d = ui3d2d

do --Input handling
    local useBind = input.LookupBinding("+use", true)
    local attackBind = input.LookupBinding("+attack", true)

    do
        local lookupBinding = input.LookupBinding
        timer.Create("ui3d2d.lookupBindings", 5, 0, function() --Keep our use and attack bind keys up to date
            useBind = lookupBinding("+use", true)
            attackBind = lookupBinding("+attack", true)
        end)
    end

    do
        local getRenderTarget, cursorVisible = render.GetRenderTarget, vgui.CursorVisible
        local getKeyCode, isButtonDown = input.GetKeyCode, input.IsButtonDown

        local inputEnabled, isPressing, isPressed

        hook.Add("PreRender", "ui3d2d.inputHandler", function() --Check the input state before rendering UIs
            if getRenderTarget() then inputEnabled = false return end
            if cursorVisible() then inputEnabled = false return end

            local useKey = useBind and getKeyCode(useBind)
            local attackKey = attackBind and getKeyCode(attackBind)

            inputEnabled = true

            local wasPressing = isPressing
            isPressing = (useKey and isButtonDown(useKey)) or (attackKey and isButtonDown(attackKey))
            isPressed = not wasPressing and isPressing
        end)

        function ui3d2d.isPressing() --Returns true if an input is being held
            return inputEnabled and isPressing
        end

        function ui3d2d.isPressed() --Returns true if an input was pressed this frame
            return inputEnabled and isPressed
        end
    end
end

do --Rendering context creation and mouse position getters
    local localPlayer

    hook.Add("PreRender", "ui3d2d.getLocalPlayer", function() --Keep getting the local player until it's available
        localPlayer = LocalPlayer()
        if IsValid(localPlayer) then hook.Remove("PreRender", "ui3d2d.getLocalPlayer") end
    end)

    local traceLine = util.TraceLine

    local baseQuery = {filter = {}}

    local function isObstructed(eyePos, hitPos, ignoredEntity) --Check if the cursor trace is obstructed by another ent
        local query = baseQuery
        query.start = eyePos
        query.endpos = hitPos
        query.filter[1] = localPlayer
        query.filter[2] = ignoredEntity

        return traceLine(query).Hit
    end

    local mouseX, mouseY

    do
        local start3d2d = cam.Start3D2D
        local isCursorVisible, isHoveringWorld = vgui.CursorVisible, vgui.IsHoveringWorld
        local screenToVector, mousePos = gui.ScreenToVector, gui.MousePos
        local intersectRayWithPlane = util.IntersectRayWithPlane

        local isRendering

        function ui3d2d.startDraw(pos, angles, scale, ignoredEntity) --Starts a new 3d2d ui rendering context
            if isRendering then error("[ui3d2d] Attempted to draw a new 3d2d ui without ending the previous one.") return end

            local eyePos = localPlayer:EyePos()
            local eyePosToUi = pos - eyePos

            do --Only draw the UI if the player is in front of it
                local normal = angles:Up()
                local dot = eyePosToUi:Dot(normal)

                if dot >= 0 then return end
            end

            isRendering = true
            mouseX, mouseY = nil, nil

            start3d2d(pos, angles, scale)

            local cursorVisible, hoveringWorld = isCursorVisible(), isHoveringWorld()
            if not hoveringWorld and cursorVisible then return true end

            local eyeNormal
            do
                if cursorVisible and hoveringWorld then
                    eyeNormal = screenToVector(mousePos())
                else
                    eyeNormal = localPlayer:GetEyeTrace().Normal
                end
            end

            local hitPos = intersectRayWithPlane(eyePos, eyeNormal, pos, angles:Up())
            if not hitPos then return true end

            if isObstructed(eyePos, hitPos, ignoredEntity) then return true end

            do
                local diff = pos - hitPos
                mouseX = diff:Dot(-angles:Forward()) / scale
                mouseY = diff:Dot(-angles:Right()) / scale
            end

            return true
        end

        local end3d2d = cam.End3D2D

        function ui3d2d.endDraw() --Safely ends the 3d2d ui rendering context
            if not isRendering then error("[ui3d2d] Attempted to end a non-existant 3d2d ui rendering context.") return end
            isRendering = false
            end3d2d()
        end

        concommand.Add("ui3d2dreset", ui3d2d.endDraw)
    end

    function ui3d2d.getCursorPos() --Returns the current 3d2d cursor position
        return mouseX, mouseY
    end

    function ui3d2d.isHovering(x, y, w, h) --Returns whether the cursor is within a specified area
        local mx, my = mouseX, mouseY
        return mx and my and mx >= x and mx <= (x + w) and my >= y and my <= (y + h)
    end
end

-- Ui3d2d Extras
do --3d2d VGUI Drawing
    local insert = table.insert

    local function getParents(panel)
        local parents = {}
        local parent = panel:GetParent()

        while parent do
            insert(parents, parent)
            parent = parent:GetParent()
        end

        return parents
    end

    local ipairs = ipairs

    local function absolutePanelPos(panel)
        local x, y = panel:GetPos()
        local parents = getParents(panel)

        for _, parent in ipairs(parents) do
            local parentX, parentY = parent:GetPos()
            x = x + parentX
            y = y + parentY
        end

        return x, y
    end

    local function pointInsidePanel(panel, x, y)
        local absoluteX, absoluteY = absolutePanelPos(panel)
        local width, height = panel:GetSize()

        return panel:IsVisible() and x >= absoluteX and y >= absoluteY and x <= absoluteX + width and y <= absoluteY + height
    end

    local pairs = pairs
    local reverseTable = table.Reverse

    local function checkHover(panel, x, y, found, hoveredPanel)
        local validChild = false
        for _, child in pairs(reverseTable(panel:GetChildren())) do
            if not child:IsMouseInputEnabled() then continue end

            if checkHover(child, x, y, found or validChild) then validChild = true end
        end

        if not panel.isUi3d2dSetup then
            panel.IsHovered = function(s)
                return s.Hovered
            end

            panel:SetPaintedManually(true)
            panel.isUi3d2dSetup = true
        end

        if found then
            if panel.Hovered then
                panel.Hovered = false
                if panel.OnCursorExited then panel:OnCursorExited() end
            end
        else
            if not validChild and pointInsidePanel(panel, x, y) then
                panel.Hovered = true

                if panel.OnMousePressed then
                    local key = input.IsKeyDown(KEY_LSHIFT) and MOUSE_RIGHT or MOUSE_LEFT

                    if panel.OnMousePressed and ui3d2d.isPressed() then
                        panel:OnMousePressed(key)
                    end

                    if panel.OnMouseReleased and not ui3d2d.isPressing() then
                        panel:OnMouseReleased(key)
                    end
                elseif panel.DoClick and ui3d2d.isPressed() then
                    panel:DoClick()
                end

                if panel.OnCursorEntered then panel:OnCursorEntered() end

                return true
            else
                panel.Hovered = false
                if panel.OnCursorExited then panel:OnCursorExited() end
            end
        end
    end

    local oldMouseX, oldMouseY = gui.MouseX, gui.MouseY

    function ui3d2d.drawVgui(panel, pos, angles, scale, ignoredEntity)
        if not (IsValid(panel) and ui3d2d.startDraw(pos, angles, scale, ignoredEntity)) then return end

        do
            local cursorX, cursorY = ui3d2d.getCursorPos()
            cursorX, cursorY = cursorX or -1, cursorY or -1

            function gui.MouseX()
                return cursorX
            end

            function gui.MouseY()
                return cursorY
            end

            checkHover(panel, cursorX, cursorY)
        end

        panel:PaintManual()

        gui.MouseX, gui.MouseY = oldMouseX, oldMouseY

        ui3d2d.endDraw()
    end
end