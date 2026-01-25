
----
---@realm SHARED
---@name melon.tool
----
---- Handles runtime (non-file) STool creation
----
melon.tool = melon.tool or {}
melon.tool.Deferred = melon.tool.Deferred or {}
melon.tool.Tools = melon.tool.Tools or {}

melon.tool.SWEP = melon.tool.SWEP or false
melon.tool.ToolObj = melon.tool.ToolObj or false

----
---@internal
---@name melon.tool.LoadToolObj
----
function melon.tool.LoadToolObj()
    melon.tool.SWEP = weapons.GetStored("gmod_tool")

    local _, tool = next(melon.tool.SWEP.Tool)
    melon.tool.ToolObj = getmetatable(tool)

    if not melon.tool.ToolObj then
        return false
    end

    for k, v in pairs(melon.tool.Deferred) do
        melon.tool.Tools[k] = v
        melon.tool.Deferred[k] = nil
        melon.tool.Register(k, v)
    end

    return true
end

----
---@name melon.tool.New
----
---@arg    (class: string) Classname of the tool
---@arg    (t: table) The TOOL table, can be empty
---@return (t: table) The passed in/created TOOL table
----
---- Defines a new hotloaded tool
----
function melon.tool.New(class, t)
    class = class:lower()
    t = t or {
        Name = "#tool." .. class .. ".name",
        Category = "Other",
        Desc = "#tool." .. class .. ".desc",
        Author = "",
        Information = {
            {name = "left", stage = 0},
            {name = "right", stage = 0},
            {name = "reload", stage = 0}
        },
        LeftClick = function()
            if CLIENT then chat.AddText("melonlib - default") end
            return true
        end
    }

    if CLIENT then
        language.Add("tool." .. class .. ".name", "Melonlib - Unnamed Tool")
        language.Add("tool." .. class .. ".desc", "A toolgun description.")
    end

    if melon.tool.ToolObj then
        melon.tool.Tools[class] = t
        melon.tool.Register(class, t)
        return t
    end

    melon.tool.Deferred[class] = t
    return t
end

----
---@internal
---@name melon.tool.Register
---- Internally registers a TOOL
function melon.tool.Register(class, t)
    local TOOL = setmetatable({}, {
        __index = function(s, k)
            return t[k] or melon.tool.ToolObj[k]
        end
    }):Create()
    TOOL.Mode = class

    TOOL:CreateConVars()
    melon.tool.SWEP.Tool[class] = TOOL

    timer.Simple(0, melon.tool.OnReload)
end

----
---@internal
---@name melon.tool.OnReload
----
function melon.tool.OnReload()
    local plys = CLIENT and {LocalPlayer()} or player.GetAll()

    melon.Log(melon.LOG_IMPORTANT, "[Tools] Reloading tools")
    for k, v in pairs(plys) do
        if not IsValid(v) then continue end
        local swep = v:GetWeapon("gmod_tool")

        if not IsValid(swep) then continue end

        swep.Tool = table.Copy(melon.tool.SWEP.Tool)
        swep:InitializeTools()
        melon.Log(melon.LOG_IMPORTANT, "[Tools] Reloaded " .. v:Nick() .. "'s tools")
    end

    if SERVER then return end
    RunConsoleCommand("spawnmenu_reload") 
end

hook.Add("PostGamemodeLoaded", "Melon:HotTools", function()
    if not melon.tool.LoadToolObj() then
        melon.Log(melon.LOG_WARNING, "[Tools] Toolgun SWEP not found, not registering new TOOLs")
        return
    end

    melon.Log(melon.LOG_MESSAGE, "[Tools] Hot-tools loaded successfully!")
end )

melon.Debug(function()
    melon.tool.New("test")
    melon.tool.LoadToolObj()
end, true)
