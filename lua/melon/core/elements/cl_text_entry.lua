
melon.elements = melon.elements or {}
local REGISTRY = {}

----
---@name melon.elements.TextEntry
---@panel Melon:TextEntry
----
---- Wrapper Panel to allow use of raw TextEntries without manual focus checking
----
local PANEL = vgui.Register("Melon:TextEntry", {}, "TextEntry")
melon.elements.TextEntry = PANEL

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