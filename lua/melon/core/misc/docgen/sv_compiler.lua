
file.CreateDir("melon")
file.CreateDir("melon/docs")

melon.docgen = melon.docgen or {}

----
---@name melon.docgen.Targets
----
---- Table of all compilable targets for CompileTo
----
melon.docgen.Targets = melon.docgen.Targets or {}

function melon.docgen.Targets.json(docs)
    file.CreateDir("melon/docs/json")
    file.Write("melon/docs/json/output.json", util.TableToJSON(docs, true))
end

local function format_function(fn)
    local dat = fn.__DocData__
    local args = ""
    local ol = ""
    local flags = {}

    if dat.arg and dat.arg.name then
        args = dat.arg.name .. ": " .. dat.arg.type
        ol = "1. " .. args .. " - " .. dat.arg.description .. "\n"
    elseif dat.arg then
        for k,v in pairs(dat.arg) do
            if k != 1 then
                args = args .. ", "
            end

            local fnarg = v.name .. ": " .. v.type
            args = args .. fnarg

            ol = ol .. k .. ". " .. fnarg .. " - " .. v.description .. "\n"
        end
    end

    local flaglist = {
        "internal", "debug", "deprecated", "unstable", "todo"
    }

    for k,v in pairs(flaglist) do
        if dat[v] then
            table.insert(flags, v)
        end
    end

    flags = table.concat(flags, ", ")

    return melon.string.Format([[## {data.name}({arglist}) {flags}
{data.description}
{args}{example}]], {
        data = dat,
        arglist = args,
        args = ol,
        flags = #flags == 0 and "" or ("@ " .. flags),
        example = dat.usage and ("\n```lua\n" .. dat.usage .. "\n```\n") or ""
    })
end

function melon.docgen.Targets.ghmd(module)
    file.CreateDir("melon/docs/ghmd")
   
    if not module.__DocData__ then
        module = module.melon
    end

    local text = melon.string.Format([[
# {name}
{description}

]], module.__DocData__)

    local children = {}
    for k,v in pairs(module) do
        if not v.__DocData__ then continue end

        children[v.__DocData__.typeof] = children[v.__DocData__.typeof] or {}

        table.insert(children[v.__DocData__.typeof], v)
    end

    if children["module"] then
        text = text .. "# Modules\n"

        for k,v in pairs(children["module"]) do
            text = text .. "- [" .. v.__DocData__.realname .. "](" .. v.__DocData__.name:lower() .. ".md)\n"

            melon.docgen.Targets.ghmd(v)
        end

        text = text .. "\n"
    end

    if children["function"] then
        text = text .. "# Functions\n"
        local sort = {}
        for k,v in pairs(children["function"]) do
            sort[v.__DocData__.name:lower()] = format_function(v)
        end

        for k,v in SortedPairs(sort) do
            text = text .. v .. "\n"
        end
    end

    if module.__DocData__ then 
        file.Write("melon/docs/ghmd/" .. module.__DocData__.name:lower() .. ".md.txt", text)
    end
end

----
---@name melon.docgen.CompileTo
----
---@args (docs: table   ) Table of docs to compile
---@args (target: string) Target to compile to, read [melon.docgen.Targets]
----
---- Compiles the given docs into the target format, outputs to data/melon/docs/{target}/
----
function melon.docgen.CompileTo(docs, target)
    target = melon.docgen.Targets[target]
    if not target then return end
    
    local modules = {}

    for k,doc in pairs(docs) do
        local tbl, name = melon.docgen.QualifyModule(modules, doc)
    
        if not tbl or not name then
            continue
        end

        doc.realname = name
        tbl[name] = tbl[name] or {}
        tbl[name].__DocData__ = doc
    end

    local err = target(modules)

    if err then
        return print("Failed to compile.")
    end

    print("Output successfully")
end

----
---@internal
---@name melon.docgen.QualifyModule
----
---- Qualifies the module name in the module table and returns a ref to the given module
----
function melon.docgen.QualifyModule(modules, doc)
    local curr = modules
    local split = string.Split(string.Trim(doc.name or ""), ".")

    for k,v in pairs(split) do
        if k == #split then
            return curr, v
        end

        curr[v] = curr[v] or {}
        curr = curr[v]
    end

    return curr, split[#split]
end

melon.Debug(function()
    RunConsoleCommand("melon_generate_docs", "ghmd")
    print()
end )