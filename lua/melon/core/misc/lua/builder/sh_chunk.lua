
melon.lua = melon.lua or {}

----
---@class
---@name melon.lua.CHUNK
----
---@value (statements: table) Statements in the chunk
----
local CHUNK = {}
CHUNK.__index = CHUNK
melon.lua.CHUNK = CHUNK

----
---@name melon.lua.NewChunk
----
---@return (melon.lua.CHUNK) The created chunk
----
---- Creates a new empty [melon.lua.CHUNK]
----
function melon.lua.NewChunk()
    return setmetatable({}, CHUNK):Init()
end

----
---@name melon.lua.IsChunk
----
---@arg    (any) Value to check 
---@return (bool) Is this value a chunk?
----
---- Checks if the given value is a [melon.lua.CHUNK]
----
function melon.lua.IsChunk(any)
    return getmetatable(any) == CHUNK
end

function CHUNK:Init()
    self.statements = {}

    return self
end

function CHUNK:PushStatement(kind, data)
    table.insert(self.statements, {
        kind = kind,
        data = data
    })

    return self
end

----
---@method
---@name melon.lua.CHUNK:GlobalAssign
----
---@arg    (names: table<melon.lua.EXPR>) List of variable names
---@arg    (exprs: table<melon.lua.EXPR>) List of expressions
---@return (self)
----
---- Emits a global assignment statement
---- `<names...> = <exprs...>`
----
function CHUNK:GlobalAssign(variables, exprs)
    if melon.Assert(istable(variables), "Global assignment variables should be a table of nodes") then return end
    if melon.Assert(istable(exprs), "Global assignment expressions should be a table of nodes") then return end

    for k, v in pairs(variables) do
        if melon.Assert((istable(v)) and ({Identifier = true, DotIndex = true, BracketIndex = true})[v.kind], "Global assignment variables should be Identifier's or indices") then
            return
        end
    end

    for k, v in pairs(exprs) do
        if melon.Assert((istable(v)) and (melon.lua.ExpressionKinds[v.kind] and true), "Global assignment expressions should be expressions, not {}", v.kind) then
            return
        end
    end

    return self:PushStatement(melon.lua.NodeKinds.GlobalAssign, {
        variables = variables,
        exprs = exprs
    })
end

----
---@method
---@name melon.lua.CHUNK:LocalAssign
----
---@arg    (names: table<melon.lua.EXPR>) List of variable names
---@arg    (exprs: table<melon.lua.EXPR>) List of expressions
---@return (self)
----
---- Emits a local assignment statement
---- `local <names...> = <exprs...>`
----
function CHUNK:LocalAssign(names, exprs)
    if melon.Assert(istable(names), "Local assignment names should be a table of strings") then return end
    if melon.Assert(istable(exprs), "Local assignment expressions should be a table of nodes") then return end

    for k, v in pairs(names) do
        if melon.Assert(isstring(v), "Local assignment names should be strings") then
            return
        end
    end

    for k, v in pairs(exprs) do
        if melon.Assert((istable(v)) and (melon.lua.ExpressionKinds[v.kind] and true), "Local assignment expressions should be expressions, not {}", v.kind) then
            return
        end
    end

    return self:PushStatement(melon.lua.NodeKinds.LocalAssign, {
        names = names,
        exprs = exprs
    })
end

----
---@method
---@name melon.lua.CHUNK:FunctionCall
----
---@arg    (expr: melon.lua.EXPR) Function Call Expression
---@return (self)
----
---- Emits a function call statement
---- `<expr>(<expr.args>)`
----
function CHUNK:FunctionCall(expr)
    if melon.Assert(expr.kind == melon.lua.ExpressionKinds.FunctionCall, "FunctionCall statements take a FunctionCall expression, its confusing but it makes the most sense.") then
        return
    end
    
    return self:PushStatement(melon.lua.NodeKinds.FunctionCall, expr.data)
end

----
---@method
---@name melon.lua.CHUNK:MethodCall
----
---@arg    (expr: melon.lua.EXPR) Method Call Expression
---@return (self)
----
---- Emits a method call statement
---- `<expr>:<expr.method>(<expr.args>)`
----
function CHUNK:MethodCall(expr)
    if melon.Assert(expr.kind == melon.lua.ExpressionKinds.MethodCall, "MethodCall statements take a MethodCall expression, its confusing but it makes the most sense.") then
        return
    end
    
    return self:PushStatement(melon.lua.NodeKinds.MethodCall, expr.data)
end

----
---@method
---@name melon.lua.CHUNK:DoBlock
----
---@arg    (melon.lua.CHUNK) The block chunk
---@return (self)
----
---- Emits a do block statement
---- `do <chunk> end`
----
function CHUNK:DoBlock(chunk)
    if melon.Assert(melon.lua.IsChunk(chunk), "Do Blocks take a chunk") then return end

    return self:PushStatement(melon.lua.NodeKinds.DoBlock, chunk)
end

----
---@method
---@name melon.lua.CHUNK:DoBlock
----
---@arg    (expr: melon.lua.EXPR) While loop validation expression
---@arg    (melon.lua.CHUNK) The block chunk
---@return (self)
----
---- Emits a do block statement
---- `while <expr> do <chunk> end`
----
function CHUNK:WhileBlock(expr, chunk)
    if melon.Assert(melon.lua.IsChunk(chunk), "While Blocks take a chunk") then return end
    if melon.Assert(melon.lua.ExpressionKinds[expr.kind] and true, "While blocks take an expression, not a {}", expr.kind) then
        return
    end

    return self:PushStatement(melon.lua.NodeKinds.WhileBlock, {
        expr = expr,
        chunk = chunk
    })
end

----
---@method
---@name melon.lua.CHUNK:RepeatUntilBlock
----
---@arg    (melon.lua.CHUNK) The block chunk
---@arg    (expr: melon.lua.EXPR) Repeat loop validation expression
---@return (self)
----
---- Emits a repeat until statement
---- `repeat <chunk> until <expr>`
----
function CHUNK:RepeatUntilBlock(chunk, expr)
    if melon.Assert(melon.lua.IsChunk(chunk), "RepeatUntil Blocks take a chunk") then return end
    if melon.Assert(melon.lua.ExpressionKinds[expr.kind] and true, "RepeatUntil blocks take an expression, not a {}", expr.kind) then
        return
    end

    return self:PushStatement(melon.lua.NodeKinds.RepeatUntilBlock, {
        chunk = chunk,
        expr = expr,
    })
end

----
---@dataclass
---@name melon.lua.ELSEIFCHUNKEXPR
----
---@value (expr: melon.lua.EXPR) The validator expression
---@value (chunk: melon.lua.CHUNK) The chunk
----
---- Describes a `elseif <expr> then <chunk>` statement
----

----
---@method
---@name melon.lua.CHUNK:IfBlock
----
---@arg    (expr: melon.lua.EXPR) If validation expression
---@arg    (chunk: melon.lua.CHUNK) The block chunk
---@arg    (elsechunk?: melon.lua.CHUNK) The else chunk
---@arg    (elseifs: table<melon.lua.ELSEIFCHUNKEXPR>) The else chunk
---@return (self)
----
---- Emits an if statement
---- `if <expr> then <chunk> [else <elsechunk>] [elseif <elseifs.expr> then <elseifs.chunk>] end`
----
function CHUNK:IfBlock(expr, chunk, elsechunk, elseifchunks)
    if melon.Assert(melon.lua.IsChunk(chunk), "If Blocks take a chunk") then return end
    if melon.Assert(melon.lua.ExpressionKinds[expr.kind] and true, "If blocks take an expression, not a {}", expr.kind) then
        return
    end

    if elsechunk and melon.Assert(melon.lua.IsChunk(chunk), "If Blocks take a chunk") then
        return
    end

    if elseifchunks then
        for k, v in pairs(elseifchunks) do
            if melon.Assert(melon.lua.IsChunk(v.chunk), "Elseif blocks take a chunk") then return end
            if melon.Assert(melon.lua.ExpressionKinds[v.expr.kind] and true, "Elseif blocks take an expression, not a {}", v.kind) then
                return
            end
        end
    end

    return self:PushStatement(melon.lua.NodeKinds.IfBlock, {
        expr = expr,
        chunk = chunk, 
        elsechunk = elsechunk,
        elseifchunks = elseifchunks -- {expr = expr, chunk = chunk}
    })
end

----
---@method
---@name melon.lua.CHUNK:ForBlock
----
---@arg    (names: table<melon.lua.EXPR>) Table of identifier names
---@arg    (exprs: table<melon.lua.EXPR>) Table of expressions, the iterators
---@arg    (chunk: melon.lua.CHUNK) The block chunk
---@return (self)
----
---- Emits a regular for loop
---- `for <names...> in <exprs...> do <chunk> end`
----
function CHUNK:ForBlock(names, exprlist, chunk)
    if melon.Assert(melon.lua.IsChunk(chunk), "For Blocks take a chunk") then return end

    for k, v in pairs(names) do
        if melon.Assert(isstring(v), "ForBlocks take a table of strings for names") then
            return
        end
    end

    for k, v in pairs(exprlist) do
        if melon.Assert(melon.lua.ExpressionKinds[v.kind] and true, "For blocks take a list of expressions, not a {}", v.kind) then
            return
        end
    end

    return self:PushStatement(melon.lua.NodeKinds.ForBlock, {
        names = names,
        exprlist = exprlist,
        chunk = chunk
    })
end

----
---@method
---@name melon.lua.CHUNK:ForIBlock
----
---@arg    (name: melon.lua.EXPR) Identifier name of the `i`
---@arg    (start: melon.lua.EXPR) Starting expr of `i`
---@arg    (finish: melon.lua.EXPR) Finishing expr of `i`
---@arg    (skip: melon.lua.EXPR) Skipping expr of `i`
---@arg    (chunk: melon.lua.CHUNK) The block chunk
---@return (self)
----
---- Emits an i-for loop
---- `for <name>=<start>, <finish>[, <skip>] do <chunk> end`
----
function CHUNK:ForIBlock(name, startexpr, finishexpr, skipexpr, chunk)
    if melon.Assert(melon.lua.IsChunk(chunk), "ForI Blocks take a chunk") then return end
 
    if melon.Assert(melon.lua.ExpressionKinds[startexpr.kind] and true, "ForI blocks expect a starting expression, not a {}", startexpr.kind) then
        return
    end

    if melon.Assert(finishexpr and melon.lua.ExpressionKinds[finishexpr.kind] and true, "ForI blocks expect a finishing expression") then
        return
    end

    if skipexpr and melon.Assert(melon.lua.ExpressionKinds[skipexpr.kind] and true, "ForI blocks expect the skipexpr to be a expression") then
        return
    end
 
    return self:PushStatement(melon.lua.NodeKinds.ForIBlock, {
        name = name,
        startexpr = startexpr,
        finishexpr = finishexpr,
        skipexpr = skipexpr,
        chunk = chunk
    })
end

----
---@method
---@name melon.lua.CHUNK:FunctionDecl
----
---@arg    (name: melon.lua.EXPR) Identifier name of the function
---@arg    (params: table<string>) The parameters the function takes as arguments
---@arg    (chunk: melon.lua.CHUNK) The block chunk
---@return (self)
----
---- Emits a global function declaration
---- `function <funcname>(<params>) <chunk> end
----
function CHUNK:FunctionDecl(funcname, params, chunk)
    if melon.Assert(melon.lua.IsChunk(chunk), "FunctionDecl's take a chunk") then return end
  
    for k, v in pairs(params) do
        if melon.Assert(isstring(v), "FunctionDecl's expect a list of strings for parameters") then
            return
        end
    end

    for k, v in pairs(funcname) do
        if melon.Assert(isstring(v), "FunctionDecl's expect a specifically formatted name input, read the docs") then
            return
        end
    end

    return self:PushStatement(melon.lua.NodeKinds.FunctionDecl, {
        funcname = funcname, -- Name {`.´ Name} [`:´ Name] -- not a real expr
        params = params,
        chunk = chunk
    })
end

----
---@method
---@name melon.lua.CHUNK:LocalFunctionDecl
----
---@arg    (name: melon.lua.EXPR) Identifier name of the function
---@arg    (params: table<string>) The parameters the function takes as arguments
---@arg    (chunk: melon.lua.CHUNK) The block chunk
---@return (self)
----
---- Emits a local function declaration
---- `local function <funcname>(<params>) <chunk> end
----
function CHUNK:LocalFunctionDecl(name, params, chunk)
    if melon.Assert(melon.lua.IsChunk(chunk), "ForI Blocks take a chunk") then return end
    if melon.Assert(isstring(name), "LocalFunctionDecl's expect a string name") then
        return
    end

    for k, v in pairs(params) do
        if melon.Assert(isstring(v), "LocalFunctionDecl's expect a list of strings for parameters") then
            return
        end
    end

    return self:PushStatement(melon.lua.NodeKinds.LocalFunctionDecl, {
        name = name,
        params = params,
        chunk = chunk
    })
end

----
---@method
---@name melon.lua.CHUNK:Return
----
---@arg    (table<melon.lua.EXPR>) Return values
---@return (self)
----
---- Emits a return
---- `return <exprs...>`
----
function CHUNK:Return(exprs)
    if melon.Assert(istable(exprs) and table.IsSequential(exprs), "Return should be provided a table of expressions") then return end

    for k, v in pairs(exprs) do
        if melon.Assert((istable(v)) and (melon.lua.ExpressionKinds[v.kind] and true), "Local assignment expressions should be expressions, not {}", v.kind) then
            return
        end
    end

    return self:PushStatement(melon.lua.NodeKinds.Return, exprs)
end

----
---@method
---@name melon.lua.CHUNK:Break
----
---@return (self)
----
---- Emits a break
---- `break`
----
function CHUNK:Break()
    return self:PushStatement(melon.lua.NodeKinds.Break)
end

----
---@method
---@name melon.lua.CHUNK:Label
----
---@arg    (string) Label name
---@return (self)
----
---- Emits a label
---- `::<string>::`
----
function CHUNK:Label(name)
    if melon.Assert(isstring(name), "Label's expect a string name") then return end
    return self:PushStatement(melon.lua.NodeKind.Label, name) 
end

----
---@method
---@name melon.lua.CHUNK:Goto
----
---@arg    (string) Label name
---@return (self)
----
---- Emits a goto
---- `goto <string>`
----
function CHUNK:Goto(name)
    if melon.Assert(isstring(name), "Goto's expect a string name") then return end
    return self:PushStatement(melon.lua.NodeKind.Goto, name) 
end