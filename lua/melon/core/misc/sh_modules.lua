
melon.Modules = {}

----
---@deprecated
---@name melon.MODULE
----
---@arg    (name: string) Module to get the object of
---@return (mod: melon.ModuleObject) Module object of the name
----
---- Get the [melon.ModuleObject] of the given name if it exists.
----
function melon.MODULE(name)
    return melon.Modules[name]
end

local M = {}
M.__index = M
AccessorFunc(M, "name", "Name", FORCE_STRING)
AccessorFunc(M, "desc", "Description", FORCE_STRING)
AccessorFunc(M, "ident", "ID", FORCE_STRING)

function M:_call(name, ...)
    if self[name] then
        self[name](self, ...)
    end
end

----
---@name melon.LoadModule
----
---@arg (folder: string) Module folder name to load
----
---- Loads a module from modules/ dynamically, reading __init__ and everything else.
----
function melon.LoadModule(fold)
    if not file.Exists("melon/modules/" .. fold .. "/__init__.lua", "LUA") then
        melon.Log(1, "Invalid Module '{1}', __init__.lua not found!", fold)
        return
    end

    local m = setmetatable({}, M)
    m:SetID(fold)
    m:SetName(fold)
    melon.Modules[fold] = m

    AddCSLuaFile("melon/modules/" .. fold .. "/__init__.lua")
    local incs = include("melon/modules/" .. fold .. "/__init__.lua")

    incs = incs or {}

    if incs.extras then
        for k,v in pairs(incs.extras) do
            melon.LoadDirectory("melon/modules/" .. fold .. "/" .. v, v)
            m:_call("loaded_" .. v)
            melon.Log(3, "Loaded module extra '{1}' successfully!", v)
        end
    end

    if incs.recursive then
        melon.LoadDirectory("melon/modules/" .. fold .. "/src", fold)
        m:_call("loaded")
        melon.Log(3, "Loaded Module '{1}' successfully (recursive)!", fold)
        return
    end

    incs.shared = incs.sh or incs.shared or {}
    incs.server = incs.sv or incs.server or {}
    incs.client = incs.cl or incs.client or {}

    -- Shared
    for k,v in pairs(incs.shared) do
        include("melon/modules/" .. fold .. "/" .. v)
    end

    -- Server
    if SERVER then
        for k,v in pairs(incs.server) do
            include("melon/modules/" .. fold .. "/" .. v)
        end
    end

    -- Client
    local f = (SERVER and AddCSLuaFile or include)
    for k,v in pairs(incs.client) do
        f("melon/modules/" .. fold .. "/" .. v)
    end

    m:_call("loaded")
    melon.Log(3, "Loaded Module '{1}' successfully!", fold)
end