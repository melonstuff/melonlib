
melon.docgen = melon.docgen or {}
----
---@internal
---@name melon.docgen.ParamTypes
----
---- A table of all parameter types
---- like internal and name!
----
melon.docgen.ParamTypes = melon.docgen.ParamTypes or {}

melon.docgen.ParamTypes["arg"] = function(param)
    local name = ""
    local type = ""

    for i = 1, #param do
        local ch = param[i]

        if ch == "(" then continue end
        if ch == ")" then
            param = param:sub(i + 1, #param):Trim()
            break
        end

        name = name .. ch
    end

    local split = string.Split(name, ":")
    name = split[1]:Trim()
    type = split[2]:Trim()

    return "arg", {
        name = name,
        type = type,
        description = param
    }
end

melon.docgen.ParamTypes["returns"] = function(param)
    local _, ret = melon.docgen.ParamTypes["arg"](param)

    return "returns", ret
end

----
---@internal
---@name melon.docgen.HandleParam
----
---- Handles a parameter definition after ---@
----
function melon.docgen.HandleParam(post)
    local name = ""

    for i = 1, #post do
        local ch = post[i]:upper():byte()

        if (ch >= 65 and ch <= 90) or (ch == 46) then
            name = name .. post[i]
            continue
        end

        break
    end

    if melon.docgen.ParamTypes[name] then
        return melon.docgen.ParamTypes[name](post:sub(#name + 1, #post):Trim())
    end

    return name, post:sub(#name + 1, #post):Trim()
end

melon.Debug(function()
    _p(melon.docgen.Compile(file.Read("melon/core/data/sh_net.lua", "LUA")))
end )