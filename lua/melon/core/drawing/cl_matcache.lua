
local mats = {}

----
---@name melon.Material
----
---@arg    (path:    string) Path to the image
---@arg    (opts:    string) Optional, Options to give the material, identical to [Material]'s second arg
---@return (name: IMaterial) Material to the path given
----
---- Automatically caches and returns materials, helper function for rendering hooks, identical to [Material] except cached
----
function melon.Material(path, opts)
    opts = opts or "none"
    if mats[path .. opts] then
        return mats[path .. opts]
    end

    mats[path .. opts] = Material(path, opts)
    return mats[path .. opts]
end