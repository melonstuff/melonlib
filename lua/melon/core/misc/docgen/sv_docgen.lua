
----
---@module
---@name melon.docgen
---@realm SERVER
----
---- Documentation generator for melonlib, handles this right here!
----
melon.docgen = melon.docgen or {}

----
---@name melon.docgen.Generate
----
---@arg    (str: string) Folder to recursively navigate and compile
---@return (docs: table) Table of all documentation 
----
---- Compiles everything from a folder recursively
----
function melon.docgen.Generate(str)
    local docs = {}
    local files, folders = file.Find(str .. "/*", "LUA")

    if files then
        for k,v in pairs(files) do
            if string.GetExtensionFromFilename(v) != "lua" then continue end

            table.Add(docs, melon.docgen.Compile(
                file.Read(str .. "/" .. v, "lua")
            ))
        end
    end

    if folders then
        for k,v in pairs(folders) do
            table.Add(docs, melon.docgen.Generate(str .. "/" .. v))
        end
    end

    return docs
end

----
---@name melon.docgen.GenerateMany
----
---@arg    (all: table ) Table of folders and files to compile together
---@return (docs: table) Table of all documentation 
----
---- Compiles everything in all given folders and files into one table
----
function melon.docgen.GenerateMany(all)
    local docs = {}

    for k,v in pairs(all) do
        if string.GetExtensionFromFilename(v) then
            table.Add(docs, melon.docgen.Compile(
                file.Read(v, "lua")
            ))
        else
            table.Add(docs, melon.docgen.Generate(v))
        end
    end

    return docs
end

----
---@name melon.docgen.Compile
----
---@arg    (str:  string) String to compile 
---@return (items: table) Table of all the documentation thats documented in the file
----
---- Compiles the given string into a table of all the documentation
---- in the file.
----
function melon.docgen.Compile(str)
    local blocks = {}
    local lines = string.Split(str, "\n")
    local index = 0

    while index < #lines do
        index = index + 1

        local line = string.Trim(lines[index])
        
        if string.sub(line, 1, 3) == "---" then
            local i, block = melon.docgen.HandleDocBlock(lines, index)
            index = i

            table.insert(blocks, block)
        end
    end

    return blocks
end

----
---@internal
---@name melon.docgen.HandleDocBlock
----
---- Handles a docblock at the given location in code
----
function melon.docgen.HandleDocBlock(lines, index)
    local params = {}
    local description = {}

    while index < #lines do
        local line = string.Trim(lines[index])
        if string.sub(line, 1, 3) != "---" then
            break
        end
    
        local cmd = string.sub(line, 4, 4)
        local post = string.Trim(string.sub(line, 5, #line))

        if cmd == "@" then 
            local name, value = melon.docgen.HandleParam(post)
            if name then
                if istable(params[name]) then
                    table.insert(params[name], value)
                elseif params[name] then
                    params[name] = {params[name], value}
                else
                    params[name] = value
                end
            end
        elseif cmd == "-" then
            if #post == 0 then
                index = index + 1
                continue
            end

            table.insert(description, post)
        else
            break
        end
    
        index = index + 1
    end

    if lines[index] then
        params["typeof"] = params["typeof"]
            or ((#lines[index] == 0) and "empty")
            or (params.module and "module")
            or ((lines[index]:sub(1, #"function") == "function") and "function")
            or "value"
    end

    local desc = ""
    for k,v in pairs(description) do
        desc = desc .. v:Trim()

        if k != #description then
            desc = desc .. " "
        end
    end

    params.description = desc

    return index, params
end

----
---@concommand
---@name melon.docgen.melon_generate_docs
---@realm SERVER
----
---@arg (target: string) Target to compile to, read misc/docgen/sv_compiler.lua
----
---- Generates all documentation for the melonlib library
----
concommand.Add("melon_generate_docs", function(ply, cmd, args)
    if not SERVER then return end

    melon.docgen.CompileTo(melon.docgen.GenerateMany({
        "autorun/sh_melon_lib_init.lua",
        "melon/core",
        "melon/preload",
    }), args[1] or "json")
end )

melon.Debug(function()
    RunConsoleCommand("melon_generate_docs")
end )