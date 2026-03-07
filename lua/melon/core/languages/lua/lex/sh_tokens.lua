
local lua = melon.lang.lua

local function m(t)
    return setmetatable(t, {
        __tostring = function(s)
            return lua.GetTokenName(s)
        end
    })
end

function lua.IsValidNameCharacter(ch)
    return melon.char.IsNum(ch) or melon.char.IsAlphaNumeric(ch) or (ch == "_")
end

function lua.IsValidName(name)
    if not melon.char.IsAlpha(name[1]) and name[1] != "_" then return false end

    for i = 2, #name do
        if not melon.lua.IsValidNameCharacter(name[i]) then
            return false
        end
    end

    return true
end


----
---@enumeration
---@name melon.lang.lua.TOKEN_
----
---@enum (IDENTIFIER) An identifier string, "abc", "melon"
---@enum (NUMBER) A number, "123", "0x0f"
---@enum (STRING) A string, made with quotes or apostrophes 
---@enum (MULTILINESTRING) A multiline string, made with [[]]
---@enum (LABEL) A goto label
---@enum (COMMENT) An inline comment, either lua or cstyle
---@enum (MULTILINECOMMENT) A multiline comment, either lua or cstyle
---@enum (SHEBANG) The shebang at the top of a file
----
---@enum (TRUE) True
---@enum (FALSE) False
---@enum (NIL) Nil
----
---@enum (BREAK) Keyword
---@enum (DO) Keyword
---@enum (ELSE) Keyword
---@enum (ELSEIF) Keyword
---@enum (END) Keyword
---@enum (FOR) Keyword
---@enum (FUNCTION) Keyword
---@enum (IF) Keyword
---@enum (IN) Keyword
---@enum (LOCAL) Keyword
---@enum (REPEAT) Keyword
---@enum (RETURN) Keyword
---@enum (THEN) Keyword
---@enum (UNTIL) Keyword
---@enum (WHILE) Keyword
---@enum (GOTO) Keyword
---@enum (CONTINUE) Keyword
----
---@enum (ADD) +
---@enum (SUBTRACT) -
---@enum (MULTIPLY) *
---@enum (DIVIDE) /
---@enum (POWER) ^
---@enum (MODULO) %
----
---@enum (GREATERTHAN) >
---@enum (LESSTHAN) <
---@enum (GREATERTHANEQUAL) >=
---@enum (LESSTHANEQUAL) <=
---@enum (EQUAL) ==
---@enum (NOTEQUALGMOD) !=
---@enum (NOTEQUAL) ~=
----
---@enum (AND) "and"
---@enum (ANDGMOD) &&
---@enum (OR) "or"
---@enum (ORGMOD) ||
---@enum (CONCAT) ..
---@enum (NOT) "not"
---@enum (NOTGMOD) !
----
---@enum (LENGTH) #
---@enum (SEMICOLON) ;
----
---@enum (ASSIGN) =
----
---@enum (DOT) .
---@enum (VARIADIC) ...
----
---@enum (COMMA) ,
---@enum (COLON) :
---@enum (LEFTCURLY) {
---@enum (RIGHTCURLY) }
---@enum (LEFTBRACE) [
---@enum (RIGHTBRACE) ]
---@enum (LEFTPAREN) (
---@enum (RIGHTPAREN) )
----
---- Describes every kind of token and keyword
---- Values are a table of expected keys in the data
----
lua.TOKEN_IDENTIFIER       = m{ "name" }
lua.TOKEN_NUMBER           = m{ "integer", "decimal", "exponent" }
lua.TOKEN_STRING           = m{ "content", "style" }
lua.TOKEN_MULTILINESTRING  = m{ "content", "eqcount" }
lua.TOKEN_LABEL            = m{ "content" }
lua.TOKEN_COMMENT          = m{ "content", "cstyle" }
lua.TOKEN_MULTILINECOMMENT = m{ "content", "cstyle", "eqcount"}
lua.TOKEN_TRUE             = m{}
lua.TOKEN_FALSE            = m{}
lua.TOKEN_NIL              = m{}
lua.TOKEN_BREAK            = m{}
lua.TOKEN_DO               = m{}
lua.TOKEN_ELSE             = m{}
lua.TOKEN_ELSEIF           = m{}
lua.TOKEN_END              = m{}
lua.TOKEN_FOR              = m{}
lua.TOKEN_FUNCTION         = m{}
lua.TOKEN_IF               = m{}
lua.TOKEN_IN               = m{}
lua.TOKEN_LOCAL            = m{}
lua.TOKEN_REPEAT           = m{}
lua.TOKEN_RETURN           = m{}
lua.TOKEN_THEN             = m{}
lua.TOKEN_UNTIL            = m{}
lua.TOKEN_WHILE            = m{}
lua.TOKEN_GOTO             = m{}
lua.TOKEN_CONTINUE         = m{}
lua.TOKEN_ADD              = m{}
lua.TOKEN_SUBTRACT         = m{}
lua.TOKEN_MULTIPLY         = m{}
lua.TOKEN_DIVIDE           = m{}
lua.TOKEN_POWER            = m{}
lua.TOKEN_MODULO           = m{}
lua.TOKEN_GREATERTHAN      = m{}
lua.TOKEN_LESSTHAN         = m{}
lua.TOKEN_GREATERTHANEQUAL = m{}
lua.TOKEN_LESSTHANEQUAL    = m{}
lua.TOKEN_EQUAL            = m{}
lua.TOKEN_NOTEQUALGMOD     = m{}
lua.TOKEN_NOTEQUAL         = m{}
lua.TOKEN_AND              = m{}
lua.TOKEN_ANDGMOD          = m{}
lua.TOKEN_OR               = m{}
lua.TOKEN_ORGMOD           = m{}
lua.TOKEN_CONCAT           = m{}
lua.TOKEN_NOT              = m{}
lua.TOKEN_NOTGMOD          = m{}
lua.TOKEN_LENGTH           = m{}
lua.TOKEN_SEMICOLON        = m{}
lua.TOKEN_ASSIGN           = m{}
lua.TOKEN_DOT              = m{}
lua.TOKEN_VARIADIC         = m{}
lua.TOKEN_COMMA            = m{}
lua.TOKEN_COLON            = m{}
lua.TOKEN_LEFTCURLY        = m{}
lua.TOKEN_RIGHTCURLY       = m{}
lua.TOKEN_LEFTBRACE        = m{}
lua.TOKEN_RIGHTBRACE       = m{}
lua.TOKEN_LEFTPAREN        = m{}
lua.TOKEN_RIGHTPAREN       = m{}

----
---@name melon.lang.lua.GetTokenName
----
---@arg    (melon.lang.lua.TOKEN_) The token to get the name of
---@return (string) The name of the token
----
---- Gets the printable name of a token
----
function lua.GetTokenName(tok)
    return ({
        [lua.TOKEN_IDENTIFIER]       = "IDENTIFIER",
        [lua.TOKEN_NUMBER]           = "NUMBER",
        [lua.TOKEN_STRING]           = "STRING",
        [lua.TOKEN_MULTILINESTRING]  = "MULTILINESTRING",
        [lua.TOKEN_LABEL]            = "LABEL",
        [lua.TOKEN_COMMENT]          = "COMMENT",
        [lua.TOKEN_MULTILINECOMMENT] = "MULTILINECOMMENT",
        [lua.TOKEN_TRUE]             = "TRUE",
        [lua.TOKEN_FALSE]            = "FALSE",
        [lua.TOKEN_NIL]              = "NIL",
        [lua.TOKEN_BREAK]            = "BREAK",
        [lua.TOKEN_DO]               = "DO",
        [lua.TOKEN_ELSE]             = "ELSE",
        [lua.TOKEN_ELSEIF]           = "ELSEIF",
        [lua.TOKEN_END]              = "END",
        [lua.TOKEN_FOR]              = "FOR",
        [lua.TOKEN_FUNCTION]         = "FUNCTION",
        [lua.TOKEN_IF]               = "IF",
        [lua.TOKEN_IN]               = "IN",
        [lua.TOKEN_LOCAL]            = "LOCAL",
        [lua.TOKEN_REPEAT]           = "REPEAT",
        [lua.TOKEN_RETURN]           = "RETURN",
        [lua.TOKEN_THEN]             = "THEN",
        [lua.TOKEN_UNTIL]            = "UNTIL",
        [lua.TOKEN_WHILE]            = "WHILE",
        [lua.TOKEN_GOTO]             = "GOTO",
        [lua.TOKEN_CONTINUE]         = "CONTINUE",
        [lua.TOKEN_ADD]              = "ADD",
        [lua.TOKEN_SUBTRACT]         = "SUBTRACT",
        [lua.TOKEN_MULTIPLY]         = "MULTIPLY",
        [lua.TOKEN_DIVIDE]           = "DIVIDE",
        [lua.TOKEN_POWER]            = "POWER",
        [lua.TOKEN_MODULO]           = "MODULO",
        [lua.TOKEN_GREATERTHAN]      = "GREATERTHAN",
        [lua.TOKEN_LESSTHAN]         = "LESSTHAN",
        [lua.TOKEN_GREATERTHANEQUAL] = "GREATERTHANEQUAL",
        [lua.TOKEN_LESSTHANEQUAL]    = "LESSTHANEQUAL",
        [lua.TOKEN_EQUAL]            = "EQUAL",
        [lua.TOKEN_NOTEQUALGMOD]     = "NOTEQUALGMOD",
        [lua.TOKEN_NOTEQUAL]         = "NOTEQUAL",
        [lua.TOKEN_AND]              = "AND",
        [lua.TOKEN_ANDGMOD]          = "ANDGMOD",
        [lua.TOKEN_OR]               = "OR",
        [lua.TOKEN_ORGMOD]           = "ORGMOD",
        [lua.TOKEN_CONCAT]           = "CONCAT",
        [lua.TOKEN_NOT]              = "NOT",
        [lua.TOKEN_NOTGMOD]          = "NOTGMOD",
        [lua.TOKEN_LENGTH]           = "LENGTH",
        [lua.TOKEN_SEMICOLON]        = "SEMICOLON",
        [lua.TOKEN_ASSIGN]           = "ASSIGN",
        [lua.TOKEN_DOT]              = "DOT",
        [lua.TOKEN_VARIADIC]         = "VARIADIC",
        [lua.TOKEN_COMMA]            = "COMMA",
        [lua.TOKEN_COLON]            = "COLON",
        [lua.TOKEN_LEFTCURLY]        = "LEFTCURLY",
        [lua.TOKEN_RIGHTCURLY]       = "RIGHTCURLY",
        [lua.TOKEN_LEFTBRACE]        = "LEFTBRACE",
        [lua.TOKEN_RIGHTBRACE]       = "RIGHTBRACE",
        [lua.TOKEN_LEFTPAREN]        = "LEFTPAREN",
        [lua.TOKEN_RIGHTPAREN]       = "RIGHTPAREN",
    })[tok]
end

----
---@name melon.lang.lua.GetKeyword
----
---@arg    (string) Gets the keyword tokentype, if we have one
---@return (melon.lang.lua.TOKEN_?)
----
---- Gets the tokentype of the keyword, if we have one
----
function lua.GetKeyword(str)
    return ({
        ["break"]    = melon.lang.lua.TOKEN_BREAK,
        ["do"]       = melon.lang.lua.TOKEN_DO,
        ["else"]     = melon.lang.lua.TOKEN_ELSE,
        ["elseif"]   = melon.lang.lua.TOKEN_ELSEIF,
        ["end"]      = melon.lang.lua.TOKEN_END,
        ["for"]      = melon.lang.lua.TOKEN_FOR,
        ["function"] = melon.lang.lua.TOKEN_FUNCTION,
        ["if"]       = melon.lang.lua.TOKEN_IF,
        ["in"]       = melon.lang.lua.TOKEN_IN,
        ["local"]    = melon.lang.lua.TOKEN_LOCAL,
        ["repeat"]   = melon.lang.lua.TOKEN_REPEAT,
        ["return"]   = melon.lang.lua.TOKEN_RETURN,
        ["then"]     = melon.lang.lua.TOKEN_THEN,
        ["until"]    = melon.lang.lua.TOKEN_UNTIL,
        ["while"]    = melon.lang.lua.TOKEN_WHILE,
        ["goto"]     = melon.lang.lua.TOKEN_GOTO,
        ["continue"] = melon.lang.lua.TOKEN_CONTINUE,
    })[str] or false
end

----
---@name melon.lang.lua.IsKeyword
----
---@arg    (melon.lang.lua.TOKEN_) Token type to test
---@return (bool)
----
---- Gets if this token is a keyword
----
function melon.lang.lua.IsKeyword(ty)
    return ({
        [lua.TOKEN_BREAK]    = true,
        [lua.TOKEN_DO]       = true,
        [lua.TOKEN_ELSE]     = true,
        [lua.TOKEN_ELSEIF]   = true,
        [lua.TOKEN_END]      = true,
        [lua.TOKEN_FOR]      = true,
        [lua.TOKEN_FUNCTION] = true,
        [lua.TOKEN_IF]       = true,
        [lua.TOKEN_IN]       = true,
        [lua.TOKEN_LOCAL]    = true,
        [lua.TOKEN_REPEAT]   = true,
        [lua.TOKEN_RETURN]   = true,
        [lua.TOKEN_THEN]     = true,
        [lua.TOKEN_UNTIL]    = true,
        [lua.TOKEN_WHILE]    = true,
        [lua.TOKEN_GOTO]     = true,
        [lua.TOKEN_CONTINUE] = true,
    })[ty] or false
end

melon.Debug(function()
    melon.AssertEq(lua.GetTokenName(lua.GetKeyword("do")), "DO")
end )