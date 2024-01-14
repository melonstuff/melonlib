
----
---@internal
---@module
---@name melon.PanelDevSuite
---@realm CLIENT
----
---- Everything internally to do with the panel development suite
----
melon.PanelDevSuite = melon.PanelDevSuite or {}
melon.PanelDevSuite.Theme = {}
melon.PanelDevSuite.Theme.Background    = Color(22, 22, 22)
melon.PanelDevSuite.Theme.Midground     = Color(33, 33, 33)
melon.PanelDevSuite.Theme.Foreground    = Color(44, 44, 44)
melon.PanelDevSuite.Theme.Shadow        = Color(10, 10, 10)
melon.PanelDevSuite.Theme.Accent        = Color(61,64,226)
melon.PanelDevSuite.Theme.BadAccent     = Color(226,64,61)
melon.PanelDevSuite.Theme.Text          = Color(255, 255, 255)
melon.PanelDevSuite.Theme.SecondaryText = Color(255, 255, 255, 80)
melon.PanelDevSuite.Theme.AccentText    = Color(131, 133, 255)
melon.PanelDevSuite.Theme.Transparent   = Color(0, 0, 0, -255)

melon.PanelDevSuite.Tabs = {
    -- {"3D View", "Melon:PanelSuite:Tab:3DView"},
    {"Elements", "Melon:PanelSuite:Tab:Elements"},
    {"Render Inspect", "Melon:PanelSuite:Tab:RenderView"},
    -- {"Something Else1", "DPanel"},
    -- {"Another Tab1", "DPanel"},
    -- {"Something Else2", "DPanel"},
    -- {"Another Tab2", "DPanel"},
    -- {"Something Else3", "DPanel"},
    -- {"Another Tab3", "DPanel"},
    -- {"Something Else4", "DPanel"},
    -- {"Another Tab4", "DPanel"},
}
----
---@name melon.DebugPanel2
----
---@arg (name: string) Panel name registered with [vgui.Register]
---@arg (fun:    func) Function thats called with the panel as its only argument
----
---- Creates a debug panel containing the given function, lay this out in fun(), visual and functional improvement of [melon.DebugPanel]
----
function melon.DebugPanel2(name, fn, nofocus)
    if not melon.Debug() then return end
    if melon.DebugPanel2_PanelInstance then
        melon.DebugPanel2_PanelInstance:Remove()
    end

    melon.DebugPanel2_PanelInstance = vgui.Create("Melon:PanelSuite:Main")
    melon.DebugPanel2_PanelInstance:SetSize(ScrW(), ScrH())
    melon.DebugPanel2_PanelInstance:SetPos(0, 0)
    melon.DebugPanel2_PanelInstance:SetSuitePanelType(name)
    melon.DebugPanel2_PanelInstance:SetSuiteFunction(fn)
    melon.DebugPanel2_PanelInstance:SuiteReady()
    
    if nofocus then
        melon.DebugPanel2_PanelInstance:SetMouseInputEnabled(false)
        melon.DebugPanel2_PanelInstance:SetKeyboardInputEnabled(false)
    end

    hook.Add("HUDShouldDraw", "melon.DebugPanel2", function(n)
        if not IsValid(melon.DebugPanel2_PanelInstance) then
            hook.Remove("HUDShouldDraw", "melon.DebugPanel2")
            return
        end

        if not melon.DebugPanel2_PanelInstance.allowed_to_draw then return end
        if melon.DebugPanel2_PanelInstance.allowed_to_draw[n] then
            return
        end
    
        return false
    end )

    hook.Add("PreDrawViewModel", "melon.DebugPanel2", function(vm, pl, wep)
        if not IsValid(melon.DebugPanel2_PanelInstance) then
            hook.Remove("PreDrawViewModel", "melon.DebugPanel2")
            return
        end

        if not melon.DebugPanel2_PanelInstance.allowed_to_draw then return end
        if melon.DebugPanel2_PanelInstance.allowed_to_draw.viewmodel then
            return
        end

        return true
    end )
end

----
---@internal
---@name melon.DebugPanel2_HookPaint
----
function melon.DebugPanel2_HookPaint(pnl, pre, post)
    pnl.DebugPanel2_HookPaint = pnl.DebugPanel2_HookPaint or pnl.Paint

    pnl.Paint = function(s, w, h)
        if not IsValid(melon.DebugPanel2_PanelInstance) then
            return melon.DebugPanel2_UnHookPaint(pnl)
        end

        if pre then
            pre(s, w, h)
        end

        pnl.DebugPanel2_HookPaint(s, w, h)

        if post then
            post(s, w, h)
        end
    end
end

----
---@internal
---@name melon.DebugPanel2_UnHookPaint
----
function melon.DebugPanel2_UnHookPaint(pnl)
    if pnl.DebugPanel2_HookPaint then
        pnl.Paint = pnl.DebugPanel2_HookPaint
        pnl.DebugPanel2_HookPaint = nil
    end
end

melon.DebugPanel2__TEST = function()
    if not melon.Debug() then return end

    local PANEL = vgui.Register("DebugPanel2TestPanel", {}, "DPanel")

    local r = function(s,w,h)
        surface.SetDrawColor(ColorRand())
        surface.DrawRect(0,0,w,h)
    end
    function PANEL:Init()
        for _ = 0, 5 do
            local p = vgui.Create("DPanel", self)
            p:Dock(TOP)
            p:SetTall(100)
            p:DockPadding(math.random(0, 20), 0, math.random(0, 20), 0)
            p.Paint = r

            for _ = 0, 10 do
                local q = vgui.Create("DPanel", p)
                q:Dock(TOP)
                q:SetTall(10)
                q.Paint = r
            end
        end
    end

    melon.DebugPanel2("DebugPanel2TestPanel", function(p)
        p:InvalidateLayout(true)
        -- p:SetSize(500, p:SizeToChildren(false, true))
        p:SizeToChildren(false, true)
        p:Center()
        -- p:CenterHorizontal()
    end )
end

melon.DebugPanel2__TEST()

melon.DebugPanel = melon.DebugPanel2