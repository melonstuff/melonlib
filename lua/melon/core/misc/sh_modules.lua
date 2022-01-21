
melon.Modules = {}

function melon.MODULE(name)
    return melon.Modules[name]
end

-- Module Object
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

-- Load Modules
function melon.LoadModule(fold)
    if not file.Exists("melon/modules/" .. fold .. "/__init__.lua", "LUA") then
        melon.Log(1, "Invalid Module '{1}', __init__.lua not found!", fold)
        return
    end

    local m = setmetatable({}, M)
    m:SetID(fold)
    m:SetName(fold)
    melon.Modules[fold] = m

    local incs = include("melon/modules/" .. fold .. "/__init__.lua")

    incs = incs or {}

    if incs.recursive then
        melon.LoadDirectory("melon/modules/" .. fold .. "/src")
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

function melon.Test()

end