
----
---@internal
---@name melon.__file__
----
---- If you dont understand the source for this, dont use it.
----
function melon.__file__(relative, lvl)
    return debug.getinfo(lvl or 2).short_src:gsub(not relative and "^addons/melon%-lib/lua/" or "", "")
end

----
---@internal
---@name melon.__file_contents__
----
---- If you dont understand the source for this, dont use it.
----
function melon.__file_contents__(name, lvl)
    return file.Read(name or melon.__file__(false, lvl or 3), "LUA")
end

----
---@internal
---@name melon.__file_state__
----
---- If you dont understand the source for this, dont use it.
----
function melon.__file_state__(lvl, name)
    local l = name or string.Split(melon.__file__(true, (lvl or 1) + 1), "/")
    l = l[#l]:sub(1, 3)
    return (l == "sh_" and "shared") or (l == "cl_" and "client") or (l == "sv" and "server") or "unknown", l
end