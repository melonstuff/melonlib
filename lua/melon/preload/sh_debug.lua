
----
---@name melon.Debug
----
---@arg    (f:   func) Function to call on hot refresh
---@arg    (clr: bool) Clear the console before executing?
---@arg    (args: ...) Arguments to pass to the given function
---@return (did: bool) Are debug functions allowed to be ran?
----
---- Executes a function only after the gamemodes loaded, used for hot refreshing and stuff
----
function melon.Debug(f, clr, ...)
    if not GAMEMODE then return end
    if clr then
        melon.clr()
    end

    hook.Run("Melon:Debug", os.time())
    if f then
        xpcall(f, function(err)
            melon.Log(1, "Error recovered from Debug:\n\t{1}\n", err)
        end, ... )
    end

    return true
end

----
---@name melon.DebugWrap
----
---@arg    (fn: func) Function to wrap Debug around
---@return (fn: func) Wrapped function
----
---- Wraps a function in Debug, equal to doing:
---`
---` local x = function(...) melon.Debug(f, _, ...) end
---`
function melon.DebugWrap(fn)
    return function(...)
        melon.Debug(fn, _, ...)
    end
end

----
---@name melon.clr
----
---- "Clears" the console by spamming newlines, only functions post gamemode loaded
----
function melon.clr()
    if not GAMEMODE then return end
    print(string.rep("\n\n", 100))
end

local wassettingsopen
----
---@name melon.DebugPanel
----
---@arg (name: string) Panel name registered with [vgui.Register]
---@arg (fun: func   ) Function thats called with the panel as its only argument
----
---- Creates a debug panel containing the given function, lay this out in fun()
----
function melon.DebugPanel(name, func)
    if not melon.Debug() then return end
    if SERVER then return end
    if IsValid(melon.__Debug__TestPanel) then
        wassettingsopen = IsValid(melon.__Debug__TestPanel.Tree)
        melon.__Debug__TestPanel:Remove()
    end

    melon.__Debug__TestPanel = vgui.Create("Panel")
    melon.__Debug__TestPanel:SetSize(ScrW(), ScrH())
    melon.__Debug__TestPanel:MakePopup()
    melon.__Debug__TestPanel.PerformLayout = function(s,w,h)
        s.close:SetSize(50, 30)
        s.close:SetPos(w - s.close:GetWide(), 0)
        s.settings:SetSize(50, 30)
        s.settings:SetPos(w - s.close:GetWide() - 10 - s.settings:GetWide(), 0)
    end

    local b = vgui.Create("DButton", melon.__Debug__TestPanel)
    b:SetText("")
    b.Paint = function(s,w,h)
        draw.RoundedBoxEx(6, 0, 0, w, h, HSVToColor(s:IsHovered() and (CurTime() * 1000) or (CurTime() / 10), 0.9, 0.9), false, false, true, false)
        draw.RoundedBoxEx(4, 2, 0, w - 2, h - 2, Color(22, 22, 22), false, false, true, false)

        draw.NoTexture()
        surface.SetDrawColor(255,255,255)
        surface.DrawTexturedRectRotated(w / 2 + 2, h / 2 - 2, 3, h / 2, 45)
        surface.DrawTexturedRectRotated(w / 2 + 2, h / 2 - 2, 3, h / 2, -45)
    end
    b.DoClick = function() melon.__Debug__TestPanel:Remove() end
    melon.__Debug__TestPanel.close = b

    local m = vgui.Create("DButton", melon.__Debug__TestPanel)
    m:SetText("")
    m.Paint = function(s,w,h)
        draw.RoundedBoxEx(6, 0, 0, w, h, HSVToColor(s:IsHovered() and (CurTime() * 1000) or (CurTime() / 10), 0.9, 0.9), false, false, true, true)
        draw.RoundedBoxEx(4, 2, 0, w - 4, h - 2, Color(22, 22, 22), false, false, true, true)

        surface.SetMaterial(melon.Material("icon16/cog.png", "mips smooth"))
        surface.SetDrawColor(255,255,255)
        surface.DrawTexturedRectRotated(w / 2, h / 2 - 2, h / 2, h / 2, 0)
    end
    m.DoClick = function()
        melon.__PanelTree(melon.__Debug__TestPanel)
    end
    melon.__Debug__TestPanel.settings = m

    local p = vgui.Create(name, melon.__Debug__TestPanel)
    melon.__Debug__TestPanel.PanelBeingTested = p
    if func then
        func(p)
    end

    if wassettingsopen then
        melon.__PanelTree(melon.__Debug__TestPanel)
    end
end

local hl
function melon.__PanelTree(p)
    local peenl = p.PanelBeingTested

    if IsValid(p.Tree) then
        p.Tree:Remove()
        hl = false
        return
    end

    p.Tree = vgui.Create("DFrame", p)
    p.Tree:SetSize(melon.Scale(300), melon.Scale(800))
    p.Tree:SetPos(ScrW() - p.Tree:GetWide() - 20, 0)
    p.Tree:CenterVertical()
    p.Tree:SetTitle("Hierarchy")

    p.Tree.OnRemove = function() hl = false end

    p.Controls = vgui.Create("DPanel", p.Tree)
    p.Controls:Dock(TOP)
    p.Controls:SetTall(35)
    p.Controls.PerformLayout = function(s,w,h)
        surface.SetFont("default")
        for k,v in pairs(s:GetChildren()) do
            v:SetWide(({surface.GetTextSize(v:GetText())})[1] + 25)
        end
    end

    local stored = {}
    local t = vgui.Create("DTree", p.Tree)
    t:Dock(FILL)
    function t:OnNodeSelected(n)
        if hl == n.panel then
            hl = false
            return
        end
        hl = n.panel
    end

    local function addPanel(pnl, node)
        if not IsValid(pnl) then return end
        if stored[pnl] then return end -- Stops infinite recursion
        stored[pnl] = true

        local n = node:AddNode(pnl:GetClassName())
        n.panel = pnl

        for k,v in ipairs(pnl:GetChildren()) do
            addPanel(v, n)
        end
    end

    local function addControl(name, func)
        local b = vgui.Create("DButton", p.Controls)
        b:Dock(LEFT)
        b:SetText(name)
        b:SetFont("default")
        b:DockMargin(5,5,0,5)
        b.DoClick = function(s)
            func(peenl)
        end
    end

    addPanel(peenl, t)

    addControl("Refocus", function(pp)
        pp:MakePopup()
    end )
end

hook.Add("PostRenderVGUI", "MelonLib:PanelTreeView", function()
    if not IsValid(hl) then
        return
    end

    local x,y = hl:LocalToScreen(0, 0)
    local w,h = hl:GetSize()

    surface.SetDrawColor(0, 183, 255, 143)
    surface.DrawRect(x,y,w,h)
end)

----
---@name melon.ReloadAll
----
---- Reloads melonlib, only functions post gamemode loaded
----
function melon.ReloadAll()
    if not GAMEMODE then return end
    if melon.reloading then
        return
    end
    melon.reloading = true
    melon.__load()
    melon.reloading = false
end

local prot = {}
----
---@deprecated
---@name melon.StackOverflowProtection
----
---@arg    (id: any  ) Identifier used for tracking
---@return (run: bool) Should the loop stop?
----
---- Tracks a loop with the given id to prevent stack overflows, nothing fancy.
----
function melon.StackOverflowProtection(id)
    prot[id] = (prot[id] or 0) + 1

    if prot[id] >= 1000 then
        prot[id] = 0
        return true
    end

    return false
end

----
---@name melon.DebugHook
----
---@arg (enabled: bool) Is this enabled?
---@arg (hook: string) Hook to hook onto
---@arg (fn: function) Function to set the hook to
----
---- Sets a debug hook
----
function melon.DebugHook(en, h, fn)
    melon.Debug(function()
        if not en then
            if not melon.DebugHookSet then return end
            hook.Remove(melon.DebugHookSet, "MelonDebug__")
            return
        end

        if melon.DebugHookSet then
            hook.Remove(melon.DebugHookSet, "MelonDebug__")
        end
    
        hook.Add(h, "MelonDebug__", fn)
    
        melon.DebugHookSet = h
    end)
end

----
---@name melon.DebugRun
----
---@arg    (id:   string) Hook to run
---@arg    (name: string) Hook name to run
---@arg    (args: any...) Any values to give to the hook
---@return (ret:  any...) Any return values
----
---- Runs a Hook debug
----
function melon.DebugRun(id, name, ...)
    return melon.Debug(function(...)
        return hook.GetTable()[id][name](...)
    end, false, ... )
end

----
---@name melon.DebugKeybind
----
---@arg (key:    KEY_) KEY_ enum to hook
---@arg (fn: function) Function to call on press
----
---- Adds a debug keybind, this is overriden on file save so you can only have one
----
function melon.Debugkeybind(key, fn)
    melon.Debug(function()
        local press
        hook.Add("Think", "MelonDebugKeybind", function()
            if input.IsKeyDown(key) then
                if press then return end
                press = true
    
                fn()
            else
                press = false
            end
        end )
    end)
end

----
---@name melon.DebugPlayer
----
---@arg    (bots:     bool) If true, include bots in the search
---@return (player: Player) The first player on the server thats superadmin
----
---- Gets a player for debug use
----
function melon.DebugPlayer(bots)
    if CLIENT then
        return LocalPlayer()
    end

    local p

    for k,v in pairs(bots and player.GetAll() or player.GetHumans()) do
        if v:GetUserGroup() == "superadmin" then
            return v
        end

        p = p or v
    end

    return p
end