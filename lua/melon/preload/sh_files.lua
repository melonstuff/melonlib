
----
---@internal
---@name melon.__file__
----
function melon.__file__(relative, lvl)
    return debug.getinfo(lvl or 2).short_src:gsub(not relative and "^addons/melon%-lib/lua/" or "", "")
end

----
---@internal
---@name melon.__file_contents__
----
function melon.__file_contents__(name, lvl)
    return file.Read(name or melon.__file__(false, lvl or 3), "LUA")
end

----
---@internal
---@name melon.__file_state__
----
function melon.__file_state__(lvl, name)
    local l = name or string.Split(melon.__file__(true, (lvl or 1) + 1), "/")
    l = l[#l]:sub(1, 3)
    return (l == "sh_" and "shared") or (l == "cl_" and "client") or (l == "sv" and "server") or "unknown", l
end

----
---@internal
---@name melon.__addon__
----
function melon.__addon__(f)
    f = f or melon.__file__()

    local trim = string.TrimLeft(f, "addons/")
    if trim == f then return end

    return ({melon.str.SplitOnce(trim, "/")})[1]
end

----
---@internal
---@name melon.__addonhash__
----
function melon.__addonhash__(addon)
    return melon.git.HEAD(addon or melon.__addon__())
end

melon.Debug(function()
    print(melon.__addonhash__())
end, true)