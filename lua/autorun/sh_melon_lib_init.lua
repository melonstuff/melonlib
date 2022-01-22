
if melon then
    print()
    melon.Log(0, "Reloading")
end

melon = melon or {}
melon.__loadhandlers = melon.__loadhandlers or {}

function melon.AddLoadHandler(handler, func, module_specific)
    melon.__loadhandlers[handler] = {
        func,
        module_specific
    }
end

function melon.LoadDirectory(dir, m)
    local fil, fol = file.Find(dir .. "/*", "LUA")

    for k,v in ipairs(fil) do
        if string.GetExtensionFromFilename(v) != "lua" then
            continue
        end

        local dirs = dir .. "/" .. v
        local spl = string.Split(v, "_")
        local h = melon.__loadhandlers[spl[1]]

        if h then
            if h[2] and h[2] != m then
                return
            end
            h[1](dirs)
        else
            melon.Log(2, "Invalid File Handler '{1}' found when loading '{2}'", spl[1], dirs)
        end
    end

    for k,v in pairs(fol) do
        melon.LoadDirectory(dir .. "/" .. v, m)
    end
end

melon.AddLoadHandler("sh", function(f)
    AddCSLuaFile(f)
    include(f)
end )

melon.AddLoadHandler("sv", function(f)
    if SERVER then
        include(f)
    end
end )

melon.AddLoadHandler("cl", function(f)
    if SERVER then
        AddCSLuaFile(f)
    else
        include(f)
    end
end )

--[[ Preload all needed files ]]
melon.LoadDirectory("melon/preload")
hook.Run("Melon:DoneLoading:PreLoad")
melon.Log(0, "Started Initialization")

--[[ Load all core files ]]
melon.LoadDirectory("melon/core")
hook.Run("Melon:DoneLoading:Core")
melon.Log(0, "Loaded Core")

--[[ Load all modules ]]
local _,fol = file.Find("melon/modules/*", "LUA")

for k,v in pairs(fol) do
    melon.LoadModule(v)
end

hook.Run("Melon:DoneLoading:Modules")
melon.Log(0, "Loaded Modules")

--[[ All done! ]]
hook.Run("Melon:DoneLoading")
melon.Log(0, "Finished Initialization")
