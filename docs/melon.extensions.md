# melon.Extensions
Extends an object at runtime instead of directly altering its metatable. Done this way to potentially avoid conflicts with other systems?

# Functions
## melon.Extensions.ApplyPanelExtension(panel: panel, name: string) 
Applies a Panel Extension to a Panel
1. panel: panel - Panel to apply the extension to
2. name: string - Name of the extension to apply

## melon.Extensions.RefreshExtensions() @ internal
Refreshes all extensions on all existing Panels globally, reapplying them.

## melon.Extensions.RegisterPanelExtension(name: string, panel: table) 
Registers an extension for Panels
1. name: string - Name of the extension to register
2. panel: table - Functions to add to the Panel

