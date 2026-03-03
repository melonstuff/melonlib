
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
    return file.Read("addons/" .. repo .. "/.git/FETCH_HEAD", "GAME")
end

melon.Debug(function()
    print(melon.git.HEAD("melonlib"))
end, true)