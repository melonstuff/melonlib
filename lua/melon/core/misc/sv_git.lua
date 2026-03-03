
----
---@realm SERVER
---@name melon.git
----
---- Provides function for interacting with git repos
----
melon.git = melon.git or {}

----
---@name melon.git.HEAD
----
---@arg    (addon: string) String name of the addon
---@return (string?) The head commit if we found it
----
---- Gets the head of a repository relative to `addons/`
----
function melon.git.HEAD(repo)
    local head = file.Read("addons/" .. repo .. "/.git/FETCH_HEAD", "GAME")
    if not head then return end

    return melon.str.Split(head, "\t")[1]
end

melon.Debug(function()
    _p(melon.git.HEAD("melonlib"))
end, true)