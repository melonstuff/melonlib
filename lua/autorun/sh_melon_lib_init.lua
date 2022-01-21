
melon = melon or {}

function melon.LoadDirectory(dir)
    local fil, fol = file.Find(dir .. "/*", "LUA")

    for k,v in ipairs(fil) do
        if string.GetExtensionFromFilename(v) != "lua" then
            continue
        end

        local dirs = dir .. "/" .. v

        if v:StartWith("cl_") then
            if SERVER then AddCSLuaFile(dirs)
            else include(dirs) end
        elseif v:StartWith("sh_") then
            AddCSLuaFile(dirs)
            include(dirs)
        else
            if SERVER then include(dirs) end
        end
    end

    for k,v in pairs(fol) do
        melon.LoadDirectory(dir .. "/" .. v)
    end
end

local function loadModules(dir)
    local _,fol = file.Find(dir .. "/*", "LUA")

    for k,v in pairs(fol) do
        melon.LoadModule(v)
    end
end

melon.LoadDirectory("melon/preload")
hook.Run("Melon:DoneLoading:PreLoad")
melon.Log(0, "Started Initialization")

melon.LoadDirectory("melon/core")
hook.Run("Melon:DoneLoading:Core")
melon.Log(0, "Loaded Core")

loadModules("melon/modules")
hook.Run("Melon:DoneLoading:Modules")
melon.Log(0, "Loaded Modules")

hook.Run("Melon:DoneLoading")
melon.Log(0, "Finished Initialization")
