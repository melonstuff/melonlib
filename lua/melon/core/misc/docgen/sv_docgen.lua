
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

            if block then
                table.insert(blocks, block)
            end
        end
    end

    return blocks
end

----
---@internal
---@name melon.docgen.NormalizeUsage
----
---- Normalizes code example strings to have consistent everything
----
---`
---` local usage = melon.docgen.NormalizeUsage(tbl)
---` 
---` if not usage then
---`     print("No usage for the given code")
---` end
---`
function melon.docgen.NormalizeUsage(usage)
    if not usage then return false end

    usage = table.concat(usage, "\n")
    
    local lhs = 0
    for i = 1, #usage do
        local ch = usage[i]

        if ch == " " or ch == "\n" then
            lhs = lhs + 1
        else
            break
        end
    end

    if #usage == 0 then return end 
    usage = string.Split(usage, "\n")

    local text = ""
    for k,v in pairs(usage) do
        text = text .. string.TrimRight(v:sub(lhs, #v)) .. "\n"
    end

    return string.Trim(text)
end

----
---@internal
---@name melon.docgen.HandleDocBlock
----
---- Handles a docblock at the given location in code
----
function melon.docgen.HandleDocBlock(lines, index)
    local trackmultiple = {}
    local params = {}
    local description = {}
    local usage = {}

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
                if trackmultiple[name] then
                    table.insert(params[name], value)    
                elseif params[name] then
                    trackmultiple[name] = true
                    params[name] = {params[name], value}
                else
                    params[name] = value
                end
            end
        elseif cmd == "`" then
            table.insert(usage, string.sub(line, 5, #line))
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
        params["typeof"] = params["type"]
            or ((#lines[index] == 0)    and "empty")
            or (params.module           and "module")
            or (params.concommand       and "concommand")
            or (params.panel            and "panel")
            or (params.method           and "method")
            or ((lines[index]:sub(1, #"function") == "function") and "function")
            or ((lines[index]:sub(1, #"local PANEL") == "local PANEL") and "panel")
                or "value"
    end

    local desc = ""
    for k,v in pairs(description) do
        desc = desc .. v:Trim()

        if k != #description then
            desc = desc .. " "
        end
    end

    params.usage = melon.docgen.NormalizeUsage(usage)
    params.description = desc

    if params.todo then
        return index, false
    end

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
    RunConsoleCommand("melon_generate_docs", "ghmd")
end )