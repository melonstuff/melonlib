
----
---@realm SHARED
---@name melon.fs
----
---- Contains helpers for the gmod filesystem
----
melon.fs = melon.fs or {} 

----
---@name melon.fs.NormalizePath
----
---@arg    (string) Path to normalize
---@return (string) Normalized path
----
---- Normalizes a path in the following ways:
---- 1. Converts Windows slashes into '/'
---- 2. Strips leading and trailing path slashes
---- 3. Lowercases everything for OS compatability
---- 4. Converts "//" into "/"
----
function melon.fs.NormalizePath(path)
    local out = ""

    for ch in melon.str.Chars(path) do
        ch = (ch == "\\") and "/" or ch

        if ch == "/" then
            if out == "" then continue end
            if out[#out] == ch then continue end
            if not melon.iter.Next() then continue end
        end

        out = out .. ch:lower()
    end

    return string.TrimRight(out, "/")
end

----
---@name melon.fs.RmDir
----
---@arg    (string) Directory to remove
---@arg    (recur: bool) Should we recursively remove subdirectories?
---@return (table<string>) Table of removed files and folders
----
---- Removes everything in a directory, always relative to `data/`
----
function melon.fs.RmDir(path, recur, removed)
    removed = removed or {}
    path = melon.fs.NormalizePath(path)

    local fils, fols = file.Find(path .. "/*", "DATA")
    if recur then
        for k, v in pairs(fols) do
            melon.fs.RmDir(path .. "/" .. v)
        end
    end

    for k, v in pairs(fils) do
        removed[path .. "/" .. v] = true
        file.Delete(path .. "/" .. v, "DATA")
    end

    if file.Delete(path) then
        removed[path] = true
    end

    return removed
end

melon.Debug(function()
    file.CreateDir("melon/test/testdir")
    file.CreateDir("melon/test/testdir/empty")
    file.CreateDir("melon/test/testdir/full")

    file.Write("melon/test/testdir/test1.txt", "")
    file.Write("melon/test/testdir/test2.txt", "")
    file.Write("melon/test/testdir/test3.txt", "")
    file.Write("melon/test/testdir/full/test1.txt", "")
    file.Write("melon/test/testdir/full/test2.txt", "")
    file.Write("melon/test/testdir/full/test3.txt", "")

    melon.fs.RmDir("melon/test/testdir/", true)
end, true)