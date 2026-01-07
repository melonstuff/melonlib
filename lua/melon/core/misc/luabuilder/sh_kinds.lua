
melon.lua = melon.lua or {}

----
---@member
---@name melon.lua.NodeKinds
----
---- Contains all kinds of AST nodes, includes statements and expressions
----
melon.lua.NodeKinds = {}

-- Statements
melon.lua.NodeKinds.GlobalAssign      = "GlobalAssign" 
melon.lua.NodeKinds.LocalAssign       = "LocalAssign" 
melon.lua.NodeKinds.FunctionCall      = "FunctionCall" 
melon.lua.NodeKinds.DoBlock           = "DoBlock" 
melon.lua.NodeKinds.WhileBlock        = "WhileBlock" 
melon.lua.NodeKinds.RepeatUntilBlock  = "RepeatUntilBlock" 
melon.lua.NodeKinds.IfBlock           = "IfBlock" 
melon.lua.NodeKinds.ForBlock          = "ForBlock" 
melon.lua.NodeKinds.ForIBlock         = "ForIBlock" 
melon.lua.NodeKinds.FunctionDecl      = "FunctionDecl" 
melon.lua.NodeKinds.LocalFunctionDecl = "LocalFunctionDecl" 
melon.lua.NodeKinds.Return            = "Return" 
melon.lua.NodeKinds.Break             = "Break" 
melon.lua.NodeKinds.Goto              = "Goto" 
melon.lua.NodeKinds.Label             = "Label" 

-- Expressions
melon.lua.NodeKinds.Nil           = "Nil"
melon.lua.NodeKinds.False         = "False"
melon.lua.NodeKinds.True          = "True"
melon.lua.NodeKinds.Variadic      = "Variadic"
melon.lua.NodeKinds.Number        = "Number"
melon.lua.NodeKinds.String        = "String"
melon.lua.NodeKinds.Identifier    = "Identifier"
melon.lua.NodeKinds.Lambda        = "Lambda"
melon.lua.NodeKinds.DotIndex      = "DotIndex"
melon.lua.NodeKinds.BracketIndex  = "BracketIndex"
melon.lua.NodeKinds.Parenthesized = "Parenthesized"
melon.lua.NodeKinds.FunctionCall  = "FunctionCall"
melon.lua.NodeKinds.MethodCall    = "MethodCall"
melon.lua.NodeKinds.Table         = "Table"
melon.lua.NodeKinds.BinaryOp      = "BinaryOp"
melon.lua.NodeKinds.UnaryOp       = "UnaryOp"

melon.lua.StatementKinds = {
    [melon.lua.NodeKinds.GlobalAssign]      = melon.lua.NodeKinds.GlobalAssign,
    [melon.lua.NodeKinds.LocalAssign]       = melon.lua.NodeKinds.LocalAssign,
    [melon.lua.NodeKinds.FunctionCall]      = melon.lua.NodeKinds.FunctionCall,
    [melon.lua.NodeKinds.DoBlock]           = melon.lua.NodeKinds.DoBlock,
    [melon.lua.NodeKinds.WhileBlock]        = melon.lua.NodeKinds.WhileBlock,
    [melon.lua.NodeKinds.RepeatUntilBlock]  = melon.lua.NodeKinds.RepeatUntilBlock,
    [melon.lua.NodeKinds.IfBlock]           = melon.lua.NodeKinds.IfBlock,
    [melon.lua.NodeKinds.ForBlock]          = melon.lua.NodeKinds.ForBlock,
    [melon.lua.NodeKinds.ForIBlock]         = melon.lua.NodeKinds.ForIBlock,
    [melon.lua.NodeKinds.FunctionDecl]      = melon.lua.NodeKinds.FunctionDecl,
    [melon.lua.NodeKinds.LocalFunctionDecl] = melon.lua.NodeKinds.LocalFunctionDecl,
    [melon.lua.NodeKinds.Return]            = melon.lua.NodeKinds.Return,
    [melon.lua.NodeKinds.Break]             = melon.lua.NodeKinds.Break,
    [melon.lua.NodeKinds.Goto]              = melon.lua.NodeKinds.Goto,
    [melon.lua.NodeKinds.Label]             = melon.lua.NodeKinds.Label,
}

melon.lua.ExpressionKinds = {
    [melon.lua.NodeKinds.Nil]           = melon.lua.NodeKinds.Nil,
    [melon.lua.NodeKinds.False]         = melon.lua.NodeKinds.False,
    [melon.lua.NodeKinds.True]          = melon.lua.NodeKinds.True,
    [melon.lua.NodeKinds.Variadic]      = melon.lua.NodeKinds.Variadic,
    [melon.lua.NodeKinds.Identifier]    = melon.lua.NodeKinds.Identifier,
    [melon.lua.NodeKinds.Number]        = melon.lua.NodeKinds.Number,
    [melon.lua.NodeKinds.String]        = melon.lua.NodeKinds.String,
    [melon.lua.NodeKinds.Lambda]        = melon.lua.NodeKinds.Lambda,
    [melon.lua.NodeKinds.DotIndex]      = melon.lua.NodeKinds.DotIndex,
    [melon.lua.NodeKinds.BracketIndex]  = melon.lua.NodeKinds.BracketIndex,
    [melon.lua.NodeKinds.Parenthesized] = melon.lua.NodeKinds.Parenthesized,
    [melon.lua.NodeKinds.FunctionCall]  = melon.lua.NodeKinds.FunctionCall,
    [melon.lua.NodeKinds.MethodCall]    = melon.lua.NodeKinds.MethodCall,
    [melon.lua.NodeKinds.Table]         = melon.lua.NodeKinds.Table,
    [melon.lua.NodeKinds.BinaryOp]      = melon.lua.NodeKinds.BinaryOp,
    [melon.lua.NodeKinds.UnaryOp]       = melon.lua.NodeKinds.UnaryOp,
}

melon.lua.LeftSideExpressions = {
    [melon.lua.NodeKinds.Identifier]    = melon.lua.NodeKinds.Identifier,
    [melon.lua.NodeKinds.DotIndex]      = melon.lua.NodeKinds.DotIndex,
    [melon.lua.NodeKinds.BracketIndex]  = melon.lua.NodeKinds.BracketIndex,
    [melon.lua.NodeKinds.Parenthesized] = melon.lua.NodeKinds.Parenthesized,
    [melon.lua.NodeKinds.FunctionCall]  = melon.lua.NodeKinds.FunctionCall,
    [melon.lua.NodeKinds.MethodCall]    = melon.lua.NodeKinds.MethodCall,
}

melon.lua.BinOpKinds = {}
melon.lua.BinOpKinds.Add      = "+"
melon.lua.BinOpKinds.Subtract = "-"
melon.lua.BinOpKinds.Multiply = "*"
melon.lua.BinOpKinds.Divide   = "/"
melon.lua.BinOpKinds.Power    = "^"
melon.lua.BinOpKinds.Modulo   = "%"

melon.lua.BinOpKinds.GreaterThan      = ">"
melon.lua.BinOpKinds.LessThan         = "<"
melon.lua.BinOpKinds.GreaterThanEqual = ">="
melon.lua.BinOpKinds.LessThanEqual    = "<="

melon.lua.BinOpKinds.Equal        = "=="
melon.lua.BinOpKinds.NotEqualGmod = "!="
melon.lua.BinOpKinds.NotEqual     = "~="
melon.lua.BinOpKinds.And          = "and"
melon.lua.BinOpKinds.AndGmod      = "&&"
melon.lua.BinOpKinds.Or           = "or"
melon.lua.BinOpKinds.OrGmod       = "||"
melon.lua.BinOpKinds.Concat       = ".."

melon.lua.UnOpKinds = {}
melon.lua.UnOpKinds.Not     = "not"
melon.lua.UnOpKinds.NotGmod = "!"
melon.lua.UnOpKinds.Length  = "#"

