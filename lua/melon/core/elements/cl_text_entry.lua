
local REGISTRY = {}

----
---@panel Melon:TextEntry
----
---- Wrapper Panel to allow use of raw TextEntry's without painful manual
----
local PANEL = vgui.Register("Melon:TextEntry", {}, "TextEntry")

function PANEL:Init()
    REGISTRY[self] = true
    self:SetPaintBackgroundEnabled(false)
end

hook.Add("VGUIMousePressed", "Melon:TextEntryFocus", function(panel)
    if not IsValid(panel) then return end
    if vgui.GetKeyboardFocus() and not REGISTRY[vgui.GetKeyboardFocus()] then return end
    if panel == vgui.GetKeyboardFocus() then return end

    while IsValid(panel) do
        if panel:HasHierarchicalFocus() then
            panel:KillFocus()
            return
        end

        panel = panel:GetParent()
    end
end )