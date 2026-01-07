
melon.lua = melon.lua or {}
melon.lua.KindPrinters = {}

if not melon.lua.NodeKinds then return end

melon.lua.KindPrinters[melon.lua.NodeKinds.GlobalAssign] = function(stream, stmt, pretty, indent)
    for k, v in pairs(stmt.data.variables) do
        local s = melon.lua.PrintNodeToStream(v, pretty)

        stream:Append(s)

        if k != #stmt.data.variables then
            stream:Write(pretty and ", " or ",")
        end
    end

    stream:Write(pretty and " = " or "=")

    for k, v in pairs(stmt.data.exprs) do
        local s = melon.lua.PrintNodeToStream(v, pretty)

        stream:Append(s)

        if k != #stmt.data.exprs then
            stream:Write(pretty and ", " or ",")
        end
    end
end 

melon.lua.KindPrinters[melon.lua.NodeKinds.LocalAssign] = function(stream, stmt, pretty, indent)
    stream:Write("local ")

    for k, v in pairs(stmt.data.names) do
        stream:Write(v)

        if k != #stmt.data.names then
            stream:Write(pretty and ", " or ",")
        end
    end

    stream:Write(pretty and " = " or "=")

    for k, v in pairs(stmt.data.exprs) do
        local s = melon.lua.PrintNodeToStream(v, pretty)

        stream:Append(s)

        if k != #stmt.data.exprs then
            stream:Write(pretty and ", " or ",")
        end
    end
end 
melon.lua.KindPrinters[melon.lua.NodeKinds.DoBlock] = function(stream, stmt, pretty, indent)
    stream:Write("do")
    stream:Write(pretty and "\n" or " ")

    stream:Append(melon.lua.PrintNodeToStream(stmt.data, pretty, indent + 1))

    stream:Write(pretty and "\n" or " ")
    stream:Write("end")
end
melon.lua.KindPrinters[melon.lua.NodeKinds.WhileBlock] = function(stream, stmt, pretty, indent)
    stream:Write("while ")
  
    stream:Append(melon.lua.PrintNodeToStream(stmt.data.expr, pretty, 0))
  
    stream:Write(" do")
    stream:Write(pretty and "\n" or " ")

    stream:Append(melon.lua.PrintNodeToStream(stmt.data.chunk, pretty, indent + 1))

    stream:Write(pretty and "\n" or " ")
    stream:Write("end")
end
melon.lua.KindPrinters[melon.lua.NodeKinds.RepeatUntilBlock] = function(stream, stmt, pretty, indent)
    stream:Write("repeat")
    stream:Write(pretty and "\n" or " ")
  
    stream:Append(melon.lua.PrintNodeToStream(stmt.data.chunk, pretty, 0))
  
    stream:Write(pretty and "\n" or " ")
    stream:Write("until ") -- end

    stream:Append(melon.lua.PrintNodeToStream(stmt.data.expr, pretty, indent + 1))
end
melon.lua.KindPrinters[melon.lua.NodeKinds.IfBlock] = function(stream, stmt, pretty, indent)
    stream:Write("if ")
    stream:Append(melon.lua.PrintNodeToStream(stmt.data.expr, pretty, 0))
    stream:Write(" then")
    stream:Write(pretty and "\n" or " ")
    stream:Append(melon.lua.PrintNodeToStream(stmt.data.chunk, pretty, 0))

    for k, v in pairs(stmt.data.elseifchunks or {}) do
        stream:Write(pretty and "\n" or " ")
        stream:Write("elseif ")
        stream:Append(melon.lua.PrintNodeToStream(v.expr, pretty, 0))
        stream:Write(" then")
        stream:Write(pretty and "\n" or " ")
        stream:Append(melon.lua.PrintNodeToStream(v.chunk, pretty, 0))
    end

    if stmt.data.elsechunk then
        stream:Write(pretty and "\n" or " ")
        stream:Write("else")
        stream:Write(pretty and "\n" or " ")
        stream:Append(melon.lua.PrintNodeToStream(stmt.data.elsechunk, pretty, 0))
    end

    stream:Write(pretty and "\n" or " ")
    stream:Write("end")
end
melon.lua.KindPrinters[melon.lua.NodeKinds.ForBlock] = function(stream, stmt, pretty, indent)
    stream:Write("for ")
    
    for k, v in pairs(stmt.data.names) do
        stream:Write(v)

        if k != #stmt.data.names then
            stream:Write(pretty and ", " or ",")
        end
    end

    stream:Write(" in ")

    for k, v in pairs(stmt.data.exprlist) do
        stream:Append(melon.lua.PrintNodeToStream(v, pretty, 0))
        
        if k != #stmt.data.exprlist then
            stream:Write(pretty and ", " or ",")
        end
    end

    stream:Write(" do")
    stream:Write(pretty and "\n" or " ")
    stream:Append(melon.lua.PrintNodeToStream(stmt.data.chunk, pretty, 0))
    stream:Write(pretty and "\n" or " ")
    stream:Write("end")
end
melon.lua.KindPrinters[melon.lua.NodeKinds.ForIBlock] = function(stream, stmt, pretty, indent)
    stream:Write("for ")
    stream:Write(stmt.data.name)
    stream:Write(pretty and " = " or "=")
    stream:Append(melon.lua.PrintNodeToStream(stmt.data.startexpr, pretty, 0))
    stream:Write(pretty and ", " or ",")
    stream:Append(melon.lua.PrintNodeToStream(stmt.data.finishexpr, pretty, 0))

    if stmt.data.skipexpr then
        stream:Write(pretty and ", " or ",")
        stream:Append(melon.lua.PrintNodeToStream(stmt.data.skipexpr, pretty, 0))
    end
    
    stream:Write(" do")
    stream:Write(pretty and "\n" or " ")
    stream:Append(melon.lua.PrintNodeToStream(stmt.data.chunk, pretty, 0))
    stream:Write(pretty and "\n" or " ")
    stream:Write("end")
end
melon.lua.KindPrinters[melon.lua.NodeKinds.FunctionDecl] = function(stream, stmt, pretty, indent)
    stream:Write("function ") -- end
    
    for k, v in pairs(stmt.data.funcname) do
        stream:Write(v)
    end

    stream:Write("(")

    for k, v in pairs(stmt.data.params) do
        stream:Write(v)

        if k != #stmt.data.params then
            stream:Write(pretty and ", " or ",")
        end
    end

    stream:Write(")")
    stream:Write(pretty and "\n" or "")

    stream:Append(melon.lua.PrintNodeToStream(stmt.data.chunk, pretty, 0))

    stream:Write(pretty and "\n" or " ")
    stream:Write("end")
end
melon.lua.KindPrinters[melon.lua.NodeKinds.LocalFunctionDecl] = function(stream, stmt, pretty, indent)
    stream:Write("local function ") -- end
    stream:Write(stmt.data.name)
    stream:Write("(")

    for k, v in pairs(stmt.data.params) do
        stream:Write(v)

        if k != #stmt.data.params then
            stream:Write(pretty and ", " or ",")
        end
    end

    stream:Write(")")
    stream:Write(pretty and "\n" or "")

    stream:Append(melon.lua.PrintNodeToStream(stmt.data.chunk, pretty, 0))

    stream:Write(pretty and "\n" or " ")
    stream:Write("end")
end
melon.lua.KindPrinters[melon.lua.NodeKinds.Return] = function(stream, stmt, pretty, indent)
    stream:Write("return ")

    for k, v in pairs(stmt.data) do
        stream:Append(melon.lua.PrintNodeToStream(v, pretty, 0))
        
        if k != #stmt.data then
            stream:Write(pretty and ", " or ",")
        end
    end
end 
melon.lua.KindPrinters[melon.lua.NodeKinds.Break] = function(stream, stmt, pretty, indent) stream:Write("break") end 
melon.lua.KindPrinters[melon.lua.NodeKinds.Goto]  = function(stream, stmt, pretty, indent) stream:Write("goto "):Write(stmt.data) end 
melon.lua.KindPrinters[melon.lua.NodeKinds.Label] = function(stream, stmt, pretty, indent) stream:WriteFmt("::{}::", stmt.data) end 


melon.lua.KindPrinters[melon.lua.NodeKinds.Lambda] = function(stream, expr, pretty, indent)
    stream:Write("function(")
    
    for k, v in pairs(expr.data.params) do
        local s = melon.lua.PrintNodeToStream(v, pretty)

        stream:Append(s)

        if k != #expr.data.params then
            stream:Write(pretty and ", " or ",")
        end
    end

    stream:Write(")")
    stream:Write(pretty and "\n" or "")
    stream:Append(melon.lua.PrintNodeToStream(expr.data.chunk, pretty, indent + 1))
    stream:Write(pretty and "\n" or ";")
    stream:Write("end")
end
melon.lua.KindPrinters[melon.lua.NodeKinds.Nil]           = function(stream, expr, pretty, indent) stream:Write("nil") end
melon.lua.KindPrinters[melon.lua.NodeKinds.False]         = function(stream, expr, pretty, indent) stream:Write("false") end
melon.lua.KindPrinters[melon.lua.NodeKinds.True]          = function(stream, expr, pretty, indent) stream:Write("true") end
melon.lua.KindPrinters[melon.lua.NodeKinds.Variadic]      = function(stream, expr, pretty, indent) stream:Write("...") end
melon.lua.KindPrinters[melon.lua.NodeKinds.Number]        = function(stream, expr, pretty, indent) stream:Write(expr.data) end
melon.lua.KindPrinters[melon.lua.NodeKinds.String]        = function(stream, expr, pretty, indent) stream:WriteFmt("{}{}{}", expr.data.opening or "\"", expr.data.text, expr.data.closing or "\"") end
melon.lua.KindPrinters[melon.lua.NodeKinds.Identifier]    = function(stream, expr, pretty, indent) stream:Write(expr.data) end
melon.lua.KindPrinters[melon.lua.NodeKinds.DotIndex]      = function(stream, expr, pretty, indent)
    stream:Append(melon.lua.PrintNodeToStream(expr.data.lhs, pretty, 0)):Write("."):Write(expr.data.name)
end
melon.lua.KindPrinters[melon.lua.NodeKinds.BracketIndex]  = function(stream, expr, pretty, indent)
    stream:Append(melon.lua.PrintNodeToStream(expr.data.lhs, pretty, 0)):Write("["):Append(melon.lua.PrintNodeToStream(expr.data.expr, pretty, 0)):Write("]")
end
melon.lua.KindPrinters[melon.lua.NodeKinds.Parenthesized] = function(stream, expr, pretty, indent) stream:Write("("):Append(melon.lua.PrintNodeToStream(expr.data, pretty, 0)):Write(")") end
melon.lua.KindPrinters[melon.lua.NodeKinds.FunctionCall] = function(stream, expr, pretty, indent)
    stream:Append(melon.lua.PrintNodeToStream(expr.data.calling, pretty, 0)):Write("(")

    for k, v in pairs(expr.data.args) do
        stream:Append(melon.lua.PrintNodeToStream(v, pretty, 0))

        if k != #expr.data.args then
            stream:Write(pretty and ", " or ",")
        end
    end

    stream:Write(")")
end
melon.lua.KindPrinters[melon.lua.NodeKinds.MethodCall] = function(stream, expr, pretty, indent)
    stream:Append(melon.lua.PrintNodeToStream(expr.data.calling, pretty, 0))
    :WriteFmt(":{}(", expr.data.name)

    for k, v in pairs(expr.data.args) do
        stream:Append(melon.lua.PrintNodeToStream(v, pretty, 0))

        if k != #expr.data.args then
            stream:Write(pretty and ", " or ",")
        end
    end

    stream:Write(")")
end
melon.lua.KindPrinters[melon.lua.NodeKinds.Table] = function(stream, expr, pretty, indent) print(expr.kind, ":exprstub") end
melon.lua.KindPrinters[melon.lua.NodeKinds.BinaryOp] = function(stream, expr, pretty, indent)
    stream:Append(melon.lua.PrintNodeToStream(expr.data.lhs, pretty, 0))
    :WriteFmt("{1}{2}{1}", ((expr.data.op == melon.lua.BinOpKinds.And) or (expr.data.op == melon.lua.BinOpKinds.Or)) and " " or "", expr.data.op)
    :Append(melon.lua.PrintNodeToStream(expr.data.rhs, pretty, 0))
end
melon.lua.KindPrinters[melon.lua.NodeKinds.UnaryOp] = function(stream, expr, pretty, indent)
    stream:Write(expr.data.op)

    if expr.data.op == melon.lua.UnOpKinds.Not then
        stream:Write(" ")
    end

    stream:Append(melon.lua.PrintNodeToStream(expr.data.expr, pretty, 0))
end

function melon.lua.PrintNodeToStream(node, pretty, indent)
    indent = indent or 0

    local stream = melon.NewStream()
    function stream:Indent(amt)
        return self:Write(string.rep("    ", amt))
    end

    if melon.lua.IsChunk(node) then
        for k, v in pairs(node.statements) do
            melon.lua.KindPrinters[v.kind](stream, v, pretty, indent)

            if k == #node.statements then continue end
            stream:Write(pretty and "\n" or ";")
        end        
    else
        if not melon.lua.KindPrinters[node.kind] then
            return melon.Log(1, "Failed to find melon.lua.KindPrinters[{}]", node.kind)
        end
        melon.lua.KindPrinters[node.kind](stream, node, pretty, indent)
    end

    return stream
end

function melon.lua.PrintNode(node, pretty, indent)
    return MsgN(melon.lua.PrintNodeToStream(node, pretty, indent):Consume())
end

melon.Debug(function()
    local chunk = melon.lua.NewChunk()

    local a = melon.lua.Identifier("a")
    local b = melon.lua.Identifier("b"):DotIndex("f")
    
    local c = melon.lua.Identifier("users")
        :BracketIndex(melon.lua.Identifier("steamid"))
        :Parenthesize()
        :MethodCall("GetBanFunction", {melon.lua.Identifier("time")})
        :Call({a, b})
        :UnaryOp(melon.lua.UnOpKinds.Not)
        :BinaryOp(melon.lua.BinOpKinds.And, a)

    chunk:GlobalAssign({melon.lua.Identifier("success")}, {c})

    melon.lua.PrintNode(chunk, true)
end, true)

if 1 then return end
melon.Debug(function()
    local chunk = melon.lua.NewChunk()

    chunk:LocalAssign({"a", "b", "c"}, {melon.lua.Identifier("unpack"):Call({melon.lua.Variadic()})})
    chunk:Return({melon.lua.Identifier("toret")})

    melon.lua.PrintNode(chunk, true)
end)

melon.Debug(function()
    local chunk = melon.lua.NewChunk()
    local chunk_lambda = melon.lua.NewChunk()

    chunk_lambda:LocalAssign({"a", "b", "c"}, {melon.lua.Identifier("unpack"):Call({melon.lua.Variadic()})})
    chunk_lambda:Return({melon.lua.Identifier("c"), melon.lua.Identifier("b"), melon.lua.Identifier("a")})

    chunk:LocalAssign({"somelambda"}, {
        melon.lua.Lambda({melon.lua.Variadic()}, chunk_lambda)
    })

    melon.lua.PrintNode(chunk, true)
end)

melon.Debug(function()
    local chunk = melon.lua.NewChunk()

    local c = melon.lua.Identifier("users")
        :BracketIndex(melon.lua.Identifier("steamid"))
        :Parenthesize()
        :MethodCall("GetBanFunction", {melon.lua.Identifier("time")})
        :UnaryOp(melon.lua.UnOpKinds.Not)

    chunk:GlobalAssign({melon.lua.Identifier("success")}, {c})

    melon.lua.PrintNode(melon.lua.NewChunk():DoBlock(chunk), true)
    melon.lua.PrintNode(melon.lua.NewChunk():WhileBlock(melon.lua.True(), chunk), true)
    melon.lua.PrintNode(melon.lua.NewChunk():RepeatUntilBlock(chunk, melon.lua.True()), true)
end)

melon.Debug(function()
    local c = melon.lua.Identifier("something"):Call({melon.lua.Variadic()})

    melon.lua.PrintNode(
        melon.lua.NewChunk():IfBlock(
            c, -- expr
            melon.lua.NewChunk():FunctionCall(c), -- truechunk
            melon.lua.NewChunk():FunctionCall(c), -- elsechunk
            {
                {expr = melon.lua.True(), chunk = melon.lua.NewChunk():LocalAssign({"a"}, {melon.lua.False()})},
                {expr = melon.lua.False(), chunk = melon.lua.NewChunk():LocalAssign({"a"}, {melon.lua.True()})},
            }
        )
    )
end)

melon.Debug(function()
    local chunk = melon.lua.NewChunk()

    local c = melon.lua.Identifier("users")
        :BracketIndex(melon.lua.Identifier("steamid"))
        :Parenthesize()
        :MethodCall("GetBanFunction", {melon.lua.Identifier("time")})
        :UnaryOp(melon.lua.UnOpKinds.Not)

    chunk:GlobalAssign({melon.lua.Identifier("success")}, {c})

    melon.lua.PrintNode(melon.lua.NewChunk():ForBlock({"k, v"}, {melon.lua.Identifier("pairs"):Call({melon.lua.Identifier("player"):DotIndex("GetAll"):Call()})}, chunk), true)
end)

melon.Debug(function()
    local chunk = melon.lua.NewChunk()
    chunk:FunctionCall(melon.lua.Identifier("print"):Call({melon.lua.Identifier("i")}))

    melon.lua.PrintNode(melon.lua.NewChunk():ForIBlock("i", melon.lua.Number(0), melon.lua.Number(100), melon.lua.Number(5), chunk))
end)

melon.Debug(function()
    local chunk = melon.lua.NewChunk()
    chunk:Return({melon.lua.Identifier("string"):DotIndex("Explode"):Call({melon.lua.Identifier("delimiter"), melon.lua.Identifier("str")})})

    melon.lua.PrintNode(melon.lua.NewChunk():LocalFunctionDecl("strsplit", {"str", "delimiter"}, chunk))
end)