
if melon then
    melon.__reloaded = true
    melon.FinishedLoading = false

    print()
    melon.Log(0, "Reloading")
end

----
---@module
---@name melon
---@realm SHARED
----
---- Main module table for the library
----
melon = melon or {}

----
---@member
---@name melon.version
----
---- Version in major.minor.patch format, see [melon.ParseVersion]
----
melon.version = "1.6.0"
melon.__loadhandlers = melon.__loadhandlers or {}
melon.__loaded = melon.__loaded or {}
melon.__reloaded = melon.__reloaded or false 

----
---@internal
---@name melon.AddLoadHandler
----
---- Adds a load handler for melonlib, sh_, cl_ and sv_ are all loadhandlers
----
function melon.AddLoadHandler(handler, func, module_specific)
    melon.__loadhandlers[handler] = {
        func,
        module_specific
    }
end

----
---@internal
---@name melon.LoadDirectory
----
---- Loads a directory recursively, for core use 
----
function melon.LoadDirectory(dir, m, loaded)
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

        if melon.__reloaded then
            if melon.__loaded[dirs] then
                continue
            end

            hook.Run("Melon:NewFileDetected", dirs, h)
        end

        melon.__loaded[dirs] = true
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

----
---@internal
---@name melon.__load
----
---- Loads everything in the library
----
function melon.__load()
    melon.FinishedLoading = false

    --[[ Preload all needed files ]]
    melon.LoadDirectory("melon/preload")
    hook.Run("Melon:DoneLoading:PreLoad")
    melon.Log(0, "Started Initialization of MelonLib v{1}", melon.version)

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

    melon.FinishedLoading = true
end

melon.__load()

----
---@concommand melon_raw_reload
----
---- Reloads melonlib
----
concommand.Add("melon_raw_reload", function(ply)
    melon.__reloaded = true

    if CLIENT or IsValid(ply) then
        melon.Log(1, "Missing permissions")
        return
    end

    melon.Log(2, "Reloading")
    melon.__load()
end, nil, nil, FCVAR_CHEAT)