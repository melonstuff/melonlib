
local applied = {}

----
---@module
---@name melon.Extensions
---@deprecated
---@alias asdasd
---@realm SHARED
----
---- Extends an object at runtime instead of directly altering its metatable.
---- Done this way to potentially avoid conflicts with other systems?
----
melon.Extensions = melon.Extensions or {}

----
---@deprecated
---@member
---@name melon.Extensions.PANEL
---@realm CLIENT
----
---- All extensions to Panels
----
melon.Extensions.PANEL = melon.Extensions.PANEL or {}

----
---@name melon.Extensions.RegisterPanelExtension
----
---@arg (name: string) Name of the extension to register
---@arg (panel: table) Functions to add to the Panel
----
---- Registers an extension for Panels
----
function melon.Extensions.RegisterPanelExtension(name, PANEL)
    melon.Extensions.PANEL[name] = PANEL

    melon.Debug(melon.Extensions.RefreshExtensions)
end

----
---@name melon.Extensions.ApplyPanelExtension
----
---@arg (panel: panel) Panel to apply the extension to
---@arg (name: string) Name of the extension to apply
----
---- Applies a Panel Extension to a Panel
----
function melon.Extensions.ApplyPanelExtension(Panel, name)
    local ext = melon.Extensions.PANEL[name]
    if not ext then return end

    Panel.extensions = Panel.extensions or {}
    Panel.extensions[name] = true

    if ext.OnExtensionAdded then
        ext.OnExtensionAdded(Panel)
    end

    table.Merge(Panel, (isfunction(ext) and ext()) or ext)

    Panel.OnExtensionAdded = nil
end

----
---@internal
---@name melon.Extensions.RefreshExtensions
----
---- Refreshes all extensions on all existing Panels globally, reapplying them. 
----
function melon.Extensions.RefreshExtensions()
    for k, v in pairs(applied) do
        if IsValid(v) then
            v:RefreshExtensions()
        end
    end
end

----
---@todo
----
local meta = FindMetaTable("Panel")
function meta:ApplyExtension(name)
    melon.Extensions.ApplyPanelExtension(self, name)
end

function meta:RefreshExtensions()
    for k, _ in pairs(self.extensions) do
        self:ApplyExtension(k)
    end
end
