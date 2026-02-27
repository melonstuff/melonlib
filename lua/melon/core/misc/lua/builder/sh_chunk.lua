
melon.lua = melon.lua or {}

local CHUNK = {}
CHUNK.__index = CHUNK

function melon.lua.NewChunk()
    return setmetatable({}, CHUNK):Init()
end

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

-- Statements
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

function CHUNK:FunctionCall(expr)
    if melon.Assert(expr.kind == melon.lua.ExpressionKinds.FunctionCall, "FunctionCall statements take a FunctionCall expression, its confusing but it makes the most sense.") then
        return
    end
    
    return self:PushStatement(melon.lua.NodeKinds.FunctionCall, expr.data)
end

function CHUNK:DoBlock(chunk)
    if melon.Assert(melon.lua.IsChunk(chunk), "Do Blocks take a chunk") then return end

    return self:PushStatement(melon.lua.NodeKinds.DoBlock, chunk)
end

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

function CHUNK:Return(exprs)
    if melon.Assert(istable(exprs) and table.IsSequential(exprs), "Return should be provided a table of expressions") then return end

    for k, v in pairs(exprs) do
        if melon.Assert((istable(v)) and (melon.lua.ExpressionKinds[v.kind] and true), "Local assignment expressions should be expressions, not {}", v.kind) then
            return
        end
    end

    return self:PushStatement(melon.lua.NodeKinds.Return, exprs)
end

function CHUNK:Break()
    return self:PushStatement(melon.lua.NodeKinds.Break)
end

function CHUNK:Label(name)
    if melon.Assert(isstring(name), "Label's expect a string name") then return end
    return self:PushStatement(melon.lua.NodeKind.Label, name) 
end

function CHUNK:Goto(name)
    if melon.Assert(isstring(name), "Goto's expect a string name") then return end
    return self:PushStatement(melon.lua.NodeKind.Goto, name) 
end