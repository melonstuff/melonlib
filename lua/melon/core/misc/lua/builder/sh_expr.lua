
melon.lua = melon.lua or {}

----
---@class
---@name melon.lua.EXPR
----
---@value (kind: melon.lua.NodeKinds) The kind of node this is
---@value (data: any) The data of this expression, depends on the kind
---@value (metadata: table) The metadata attached to this expression
----
---- A Lua Expression
----
local EXPR = {}
EXPR.__index = EXPR
melon.lua.EXPR = EXPR

do --- Constructors
    ----
    ---@name melon.lua.Nil
    ----
    ---@arg    (metadata: table) Any metadata to pass
    ---@return (melon.lua.EXPR) The created expression
    ----
    ---- Creates a new [melon.lua.EXPR], set to `nil`
    ----
    function melon.lua.Nil(meta)
        return setmetatable({}, EXPR):Init(melon.lua.NodeKinds.Nil, false, meta)
    end

    ----
    ---@name melon.lua.False
    ----
    ---@arg    (metadata: table) Any metadata to pass
    ---@return (melon.lua.EXPR) The created expression
    ----
    ---- Creates a new [melon.lua.EXPR], set to `false`
    ----
    function melon.lua.False(meta)
        return setmetatable({}, EXPR):Init(melon.lua.NodeKinds.False, false, meta)
    end
    
    ----
    ---@name melon.lua.True
    ----
    ---@arg    (metadata: table) Any metadata to pass
    ---@return (melon.lua.EXPR) The created expression
    ----
    ---- Creates a new [melon.lua.EXPR], set to `true`
    ----    ----
    ---@name melon.lua.False
    ----
    ---@arg    (metadata: table) Any metadata to pass
    ---@return (melon.lua.EXPR) The created expression
    ----
    ---- Creates a new [melon.lua.EXPR], set to `false`
    ----
    function melon.lua.True(meta)
        return setmetatable({}, EXPR):Init(melon.lua.NodeKinds.True, false, meta)
    end

    ----
    ---@name melon.lua.Variadic
    ----
    ---@arg    (metadata: table) Any metadata to pass
    ---@return (melon.lua.EXPR) The created expression
    ----
    ---- Creates a new [melon.lua.EXPR], set to represent `...`
    ----
    function melon.lua.Variadic(meta)
        return setmetatable({}, EXPR):Init(melon.lua.NodeKinds.Variadic, false, meta)
    end

    ----
    ---@name melon.lua.Identifier
    ----
    ---@arg    (name: string) The identifier string
    ---@arg    (metadata: table) Any metadata to pass
    ---@return (melon.lua.EXPR) The created expression
    ----
    ---- Creates a new [melon.lua.EXPR], set to represent an identifier such as `melon` or `print`
    ----
    function melon.lua.Identifier(name, meta)
        if melon.Assert(isstring(name), "Identifier name should be a string") then return end

        return setmetatable({}, EXPR):Init(melon.lua.NodeKinds.Identifier, name, meta)
    end
    
    ----
    ---@name melon.lua.Number
    ----
    ---@arg    (number) The numbers string
    ---@arg    (metadata: table) Any metadata to pass
    ---@return (melon.lua.EXPR) The created expression
    ----
    ---- Creates a new [melon.lua.EXPR], set to represent a number
    ----
    function melon.lua.Number(number, meta)
        if melon.Assert(isstring(number) or isnumber(number), "Number should should be convertable into a string") then return end

        return setmetatable({}, EXPR):Init(melon.lua.NodeKinds.Number, tostring(number), meta)
    end

    ----
    ---@name melon.lua.String
    ----
    ---@arg    (string) The strings contents
    ---@arg    (opening: string) The opening string, such as `[[` or `"`
    ---@arg    (closing: string) The opening string, such as `]]` or `"`
    ---@arg    (metadata: table) Any metadata to pass
    ---@return (melon.lua.EXPR) The created expression
    ----
    ---- Creates a new [melon.lua.EXPR], set to represent a string
    ----
    function melon.lua.String(string, opening, closing, meta)
        if melon.Assert(isstring(string), "String contents should be a string") then return end
        if melon.Assert(isstring(string), "Provide a valid string opener") then return end
        if melon.Assert(isstring(string), "Provide a valid string closer") then return end
      
        return setmetatable({}, EXPR):Init(melon.lua.NodeKinds.String, {
            text = string,
            opening = opening,
            closing = closing,
        }, meta)
    end

    ----
    ---@name melon.lua.Table
    ----
    ---@arg    (metadata: table) Any metadata to pass
    ---@return (melon.lua.EXPR) The created expression
    ----
    ---- Creates a new [melon.lua.EXPR], set to represent an empty table
    ----
    function melon.lua.Table(meta)
        return setmetatable({}, EXPR):Init(melon.lua.NodeKinds.Table, {
            hashfields = {},
            arrayfields = {},
        }, meta)
    end

    ----
    ---@name melon.lua.Lambda
    ----
    ---@arg    (params: table<string>) Any parameters/arguments the lambda should have
    ---@arg    (chunk: melon.lua.CHUNK) The chunk to wrap in the lambda
    ---@arg    (metadata: table) Any metadata to pass
    ---@return (melon.lua.EXPR) The created expression
    ----
    ---- Wraps a [melon.lua.CHUNK] into an expression representing a lambda (`function() end`)
    ----
    function melon.lua.Lambda(params, chunk, meta)
        if melon.Assert(istable(params), "Lambda parameters should be a table of nodes") then return end
        if melon.Assert(melon.lua.IsChunk(chunk), "Chunk should be a valid melon.CHUNK") then return end

        for k, v in pairs(params) do
            if melon.Assert(not isstring(v), "Lambda parameters should be a table of Identifier's or Variadics") then
                return
            end
        end

        return setmetatable({}, EXPR):Init(melon.lua.NodeKinds.Lambda, {
            params = params,
            chunk = chunk
        }, meta)
    end
end

function EXPR:Init(kind, data, metadata)
    self.kind = kind
    self.data = data
    self.metadata = metadata or {}

    return self
end

----
---@method
---@name melon.lua.EXPR:DotIndex
----
---@arg (name: string) What to index with
---@arg (table?) Metadata of this expression
---@return (self)
----
---- Wraps this expression into a DotIndex expression
---- `<self>.<name>`
----
function EXPR:DotIndex(name, metadata)
    if melon.Assert(melon.lua.LeftSideExpressions[self.kind] and true, "You can only index allowed left-hand-side expressions") then return end

    local lhs = {
        kind = self.kind,
        data = self.data,
        metadata = self.metadata,
    }

    self.kind = melon.lua.NodeKinds.DotIndex
    self.data = {
        lhs = lhs,
        name = name,
    }
    self.metadata = metadata

    return self
end

----
---@method
---@name melon.lua.EXPR:BracketIndex
----
---@arg (expr: melon.lua.EXPR) What to index with
---@arg (table?) Metadata of this expression
---@return (self)
----
---- Wraps this expression into a BracketIndex expression
---- `<self>[<expr>]`
----
function EXPR:BracketIndex(expr, metadata)
    if melon.Assert(melon.lua.LeftSideExpressions[self.kind] and true, "You can only index allowed left-hand-side expressions") then return end
  
    local lhs = {
        kind = self.kind,
        data = self.data,
        metadata = self.metadata,
    }

    self.kind = melon.lua.NodeKinds.BracketIndex
    self.data = {
        lhs = lhs,
        expr = expr,
    }
    self.metadata = metadata

    return self
end

----
---@method
---@name melon.lua.EXPR:Parenthesize
----
---@arg (table?) Metadata of this expression
---@return (self)
----
---- Wraps this expression into a Parenthesized expression
---- `(self)`
----
function EXPR:Parenthesize(metadata)
    local expr = {
        kind = self.kind,
        data = self.data,
        metadata = self.metadata,
    }

    self.kind = melon.lua.NodeKinds.Parenthesized
    self.data = expr
    self.metadata = metadata

    return self
end

----
---@method
---@name melon.lua.EXPR:Call
----
---@arg (args: table<melon.lua.EXPR>) Arguments to call this function with
---@arg (table?) Metadata of this expression
---@return (self)
----
---- Wraps this expression into a FunctionCall expression
---- `<self>(<args...>)`
----
function EXPR:Call(args, metadata)
    if melon.Assert(melon.lua.LeftSideExpressions[self.kind] and true, "You can only call allowed left-hand-side expressions") then return end
    
    local calling = {
        kind = self.kind,
        data = self.data,
        metadata = self.metadata,
    }

    self.kind = melon.lua.NodeKinds.FunctionCall
    self.data = {
        calling = calling,
        args = args or {},
    }
    self.metadata = metadata
    
    return self    
end

----
---@method
---@name melon.lua.EXPR:MethodCall
----
---@arg (name: string) Name of the method to call
---@arg (args: table<melon.lua.EXPR>) Arguments to call this function with
---@arg (table?) Metadata of this expression
---@return (self)
----
---- Wraps this expression into a MethodCall expression
---- `<self>:<name>(<args...>)`
----
function EXPR:MethodCall(name, args, metadata)
    if melon.Assert(melon.lua.LeftSideExpressions[self.kind] and true, "You can only call allowed left-hand-side expressions") then return end
   
    local calling = {
        kind = self.kind,
        data = self.data,
        metadata = self.metadata,
    }

    self.kind = melon.lua.NodeKinds.MethodCall
    self.data = {
        name = name,
        calling = calling,
        args = args,
    }
    self.metadata = metadata
    
    return self    
end

----
---@method
---@name melon.lua.EXPR:BinaryOp
----
---@arg (melon.lua.BinOpKinds) Binary (infix) operation
---@arg (rhs: melon.lua.EXPR) Right hand side of the expression
---@arg (table?) Metadata of this expression
---@return (self)
----
---- Wraps this expression into a BinaryOp expression
---- `<self> <op> <rhs>`
----
function EXPR:BinaryOp(op, rhs, metadata)
    local lhs = {
        kind = self.kind,
        data = self.data,
        metadata = self.metadata,
    }

    self.kind = melon.lua.NodeKinds.BinaryOp
    self.data = {
        lhs = lhs,
        op = op,
        rhs = rhs,
    }
    self.metadata = metadata
 
    return self    
end

----
---@method
---@name melon.lua.EXPR:UnaryOp
----
---@arg (melon.lua.UnaryOpKinds) Unary (prefix) operation
---@arg (table?) Metadata of this expression
---@return (self)
----
---- Wraps this expression into a UnaryOp expression
---- `<op> <self>`
----
function EXPR:UnaryOp(op, metadata)
    local expr = {
        kind = self.kind,
        data = self.data,
        metadata = self.metadata,
    }

    self.kind = melon.lua.NodeKinds.UnaryOp
    self.data = {
        op = op,
        expr = expr,
    }
    self.metadata = metadata
    
    return self    
end

----
---@method
---@name melon.lua.EXPR:TableHashField
----
---@arg (key: melon.lua.EXPR) Key expression
---@arg (value: melon.lua.EXPR) Value expression
---@return (self)
----
---- Pushes a Hash (Expression Key) Field to the Table
---- `{ [<key>] = <value>, }`
----
function EXPR:TableHashField(keyexpr, valexpr)
    if melon.Assert(self.kind == melon.lua.ExpressionKinds.Table, "You can only push table values to a Table") then return end
    if melon.Assert(melon.lua.ExpressionKinds[keyexpr.kind] and true, "Table HashField Key expression must be an expression") then return end
    if melon.Assert(melon.lua.ExpressionKinds[valexpr.kind] and true, "Table HashField Value expression must be an expression") then return end

    table.insert(self.data.hashfields, {keyexpr, valexpr})
    return self
end

----
---@method
---@name melon.lua.EXPR:TableArrayField
----
---@arg (melon.lua.EXPR) Value expression
---@return (self)
----
---- Pushes an Array Field to the Table
---- `{ <value>, }`
----
function EXPR:TableArrayField(expr)
    if melon.Assert(self.kind == melon.lua.ExpressionKinds.Table, "You can only push table values to a Table") then return end
    if melon.Assert(melon.lua.ExpressionKinds[expr.kind] and true, "Table ArrayField expression must be an expression") then return end
    
    table.insert(self.data.arrayfields, expr)
    return self
end