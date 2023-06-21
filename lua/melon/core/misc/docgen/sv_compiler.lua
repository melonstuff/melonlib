
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

        tbl[name] = tbl[name] or {}
        tbl[name].__DocData__ = {
            name = name,
            fullname = doc.name,
            realm = doc.realm,
            internal = doc.internal,
            description = doc.description,
            type = doc.typeof
        }
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
    RunConsoleCommand("melon_generate_docs")
    print()
end )