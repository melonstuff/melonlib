
melon.Modules = melon.Modules or {}

----
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

function M:CommitHash()
    if SERVER then
        file.AsyncRead("addons/" .. self.ident .. "/.git/refs/heads/main", "GAME", function(_, _, _, data)
            if data then
                SetGlobal2String("melon_commit_hash:" .. self.ident, data:Trim())
            end
        end)
    end

    return GetGlobal2String("melon_commit_hash:" .. self.ident) or ""
end

hook.Add("Melon:Debug", "ReloadHashes", function()
    for k,v in pairs(melon.Modules) do
        v:CommitHash()
    end
end )

----
---@internal
---@name melon.ProcessExtras
----
---- Processes the `extras` parameter of a Module Manifest
----
function melon.ProcessExtras(tbl)
    if not tbl then return {
        preload = {},
        postload = {},
    } end

    local ret = {
        preload = {},
        postload = {}
    }

    for k,v in pairs(tbl) do
        if string.StartsWith(v, "postload:") then
            table.insert(ret.postload, string.Replace(v, "postload:", ""))
            continue
        end

        table.insert(ret.preload, v)
    end

    return ret
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
    m:CommitHash()
    melon.Modules[fold] = m

    AddCSLuaFile("melon/modules/" .. fold .. "/__init__.lua")
    local incs = include("melon/modules/" .. fold .. "/__init__.lua")

    incs = incs or {}

    if incs.global then
        _G[incs.global] = m
    end

    local extras = melon.ProcessExtras(incs.extras)

    for k,v in pairs(extras.preload) do
        melon.LoadDirectory("melon/modules/" .. fold .. "/" .. v, v)
        m:_call("loaded_" .. v)
        melon.Log(3, "Loaded module extra preload:'{1}' successfully!", v)
    end

    if incs.recursive then
        melon.LoadDirectory("melon/modules/" .. fold .. "/src", fold)
        m:_call("loaded")
        melon.Log(3, "Loaded Module '{1}' successfully (recursive)!", fold)

        for k,v in pairs(extras.postload) do
            melon.LoadDirectory("melon/modules/" .. fold .. "/" .. v, v)
            m:_call("loaded_" .. v)
            melon.Log(3, "Loaded module extra postload:'{1}' successfully!", v)
        end

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

    for k,v in pairs(extras.postload) do
        melon.LoadDirectory("melon/modules/" .. fold .. "/" .. v, v)
        m:_call("loaded_" .. v)
        melon.Log(3, "Loaded module extra postload:'{1}' successfully!", v)
    end

    m:_call("loaded")
    melon.Log(3, "Loaded Module '{1}' successfully!", fold)
end