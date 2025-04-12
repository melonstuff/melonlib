
melon.lua = melon.lua or {}

local EXPR = {}
EXPR.__index = EXPR

do --- Constructors
    function melon.lua.Nil(meta)
        return setmetatable({}, EXPR):Init(melon.lua.NodeKinds.Nil, false, meta)
    end

    function melon.lua.False(meta)
        return setmetatable({}, EXPR):Init(melon.lua.NodeKinds.False, false, meta)
    end
    
    function melon.lua.True(meta)
        return setmetatable({}, EXPR):Init(melon.lua.NodeKinds.True, false, meta)
    end

    function melon.lua.Variadic(meta)
        return setmetatable({}, EXPR):Init(melon.lua.NodeKinds.Variadic, false, meta)
    end

    function melon.lua.Identifier(name, meta)
        if melon.Assert(isstring(name), "Identifier name should be a string") then return end

        return setmetatable({}, EXPR):Init(melon.lua.NodeKinds.Identifier, name, token)
    end
    
    function melon.lua.Number(number, meta)
        if melon.Assert(isstring(number) or isnumber(number), "Number should should be convertable into a string") then return end

        return setmetatable({}, EXPR):Init(melon.lua.NodeKinds.Number, tostring(number), meta)
    end

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

    function melon.lua.Table(tokens)
        return setmetatable({}, EXPR):Init(melon.lua.NodeKinds.Table, {
            hashfields = {},
            arrayfields = {},
        }, tokens)
    end

    function melon.lua.Lambda(params, chunk, tokens)
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
        }, tokens)
    end
end

function EXPR:Init(kind, data, metadata)
    self.kind = kind
    self.data = data
    self.metadata = metadata or {}

    return self
end

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

function EXPR:TableHashField(keyexpr, valexpr)
    if melon.Assert(melon.lua.ExpressionKinds[keyexpr.kind] and true, "Table HashField Key expression must be an expression") then return end
    if melon.Assert(melon.lua.ExpressionKinds[valexpr.kind] and true, "Table HashField Value expression must be an expression") then return end

    table.insert(self.hashfields, {keyexpr, valexpr})
    return self
end

function EXPR:TableArrayField(expr)
    if melon.Assert(melon.lua.ExpressionKinds[expr.kind] and true, "Table ArrayField expression must be an expression") then return end
    table.insert(self.arrayfields, expr)
    return self
end