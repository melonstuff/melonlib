
local lua = melon.lang.lua

----
---@dataclass
---@name melon.lang.lua.LEXERERR
----
---@value (position: melon.lang.LOCATION | melon.lang.SPAN) Where the error occurred
---@value (message: string)
----
---- Describes a lexer error
----
---
----
---@class
---@name melon.lang.lua.LEXER
----
---@accessor (Position: melon.lang.LOCATION) Where we are in lexing
---@accessor (Whitespace: string) Any whitespace to push to the next token
---@accessor (Source: melon.DATASTREAM) The source being tokenized
---@accessor (Tokens: table<melon.lang.TOKEN>) A table of tokens
---@accessor (ErrorData: melon.lang.lua.LEXERERR) Last error received
----
---- Lexes lua code into [melon.lang.TOKEN]s
----
local LEXER = {}
LEXER.__index = LEXER
lua.LEXER = LEXER

melon.AccessorFunc(LEXER, "Position")
melon.AccessorFunc(LEXER, "Whitespace")
melon.AccessorFunc(LEXER, "Source")
melon.AccessorFunc(LEXER, "Tokens") 
melon.AccessorFunc(LEXER, "ErrorData") 

function LEXER:SetSource(src)
    src = isstring(src) and melon.NewDataStream(src) or src
    
    self.Source = src
    self.Source.OnConsume = function(stream, k, v, nohook)
        return self:OnConsume(stream, k, v, nohook)
    end
    return self
end

function LEXER:Error(msg, start)
    local pos = self.Position:Copy()
    self.ErrorData = {
        message = msg,
        position = start and melon.lang.NewSpan(start, pos) or pos
    }

    return false
end

function LEXER:OnConsume(src, k, ch, nohook)
    self.Position.Index = self.Position.Index + 1
    self.Position.Column = self.Position.Column + 1

    if ch == "\n" then
        self.Position.Line = self.Position.Line + 1
        self.Position.Column = 0
    end

    if melon.char.IsWhitespace(ch) then
        self.Whitespace = self.Whitespace .. ch

        if not nohook then
            return src:Consume()
        end
    end

    return ch
end

----
---@method
---@name melon.lang.lua.LEXER:Push
----
---@arg    (ty: melon.lang.lua.TOKEN_) Type of token to push
---@arg    (data?: table) Data attached to the token
---@arg    (start?: melon.lang.LOCATION) The starting location of the token
---@return (bool) Did we succeed?
----
---- Pushes a token to the lexer output, checks the data if its valid
---- Sets `self.Error` if there was one
----
function LEXER:Push(ty, data, start)
    if not ty then
        return self:Error(
            "Missing type data in LEXER:Push",
            start
        )
    end

    if ty == true then
        melon.table.Insert(self.Tokens, melon.lang.NewToken(
            "DEBUG",
            data,
            start and melon.lang.NewSpan(start, pos) or pos,
            self.Whitespace
        ))

        return true
    end

    local missing
    for k, v in pairs(ty) do
        if (data or {})[v] == nil then
            missing = missing or {}
            table.insert(missing, "'" .. v .. "'")
        end
    end

    if missing then
        return self:Error(
            "Missing data while pushing token " .. table.concat(missing, ", "),
            start
        )
    end

    local pos = self.Position:Copy()
    melon.table.Insert(self.Tokens, melon.lang.NewToken(
        ty,
        data,
        start and melon.lang.NewSpan(start, pos) or pos,
        self.Whitespace
    ))

    self.Whitespace = ""

    return true
end

----
---@method
---@name melon.lang.lua.LEXER:Run
----
---@return (table<melon.lang.TOKEN>?) If we succeeded, a table of tokens, otherwise nil
---@return (string?) If we failed, why?
----
---- Runs the tokenizer on the current source given
----
function LEXER:Run()
    self:SetPosition(melon.lang.NewLocation())
    self:SetWhitespace("")
    self:SetTokens({})

    local straight_conversions = {
        ['+'] = lua.TOKEN_ADD,
        ['*'] = lua.TOKEN_MULTIPLY,
        ['^'] = lua.TOKEN_POWER,
        ['%'] = lua.TOKEN_MODULO,

        ['#'] = lua.TOKEN_LENGTH,
        [';'] = lua.TOKEN_SEMICOLON,

        [','] = lua.TOKEN_COMMA,
        ['{'] = lua.TOKEN_LEFTCURLY,
        ['}'] = lua.TOKEN_RIGHTCURLY,
        [']'] = lua.TOKEN_RIGHTBRACE,
        ['('] = lua.TOKEN_LEFTPAREN,
        [')'] = lua.TOKEN_RIGHTPAREN,
    }

    local functions = {
        ['.'] = self.HandlePeriod,
        ['-'] = self.HandleSub,
        ['/'] = self.HandleDiv,
        [':'] = self.HandleColon,
        ['"'] = self.HandleString,
        ["'"] = self.HandleString,
        ["["] = self.HandleLBrace,
        [">"] = self:HandlePair('=', lua.TOKEN_GREATERTHAN, lua.TOKEN_GREATERTHANEQUAL),
        ["<"] = self:HandlePair('=', lua.TOKEN_LESSTHANEQUAL, lua.TOKEN_LESSTHAN),
        ["!"] = self:HandlePair('=', lua.TOKEN_NOTEQUALGMOD, lua.TOKEN_NOTGMOD),
        ["~"] = self:HandlePair('=', lua.TOKEN_NOTEQUAL, false),
        ["="] = self:HandlePair('=', lua.TOKEN_EQUAL, lua.TOKEN_ASSIGN),
        ["|"] = self:HandlePair('|', lua.TOKEN_ORGMOD, false),
        ["&"] = self:HandlePair('&', lua.TOKEN_ORGMOD, false),
    }

    local src = self:GetSource()
    while src:Peek() do
        local start = self.Position:Copy()
        local char = src:Consume()
        if not char then continue end

        if straight_conversions[char] then
            if not self:Push(straight_conversions[char]) then break end
            continue
        end

        if functions[char] then
            local ty, data, start = functions[char](self, start, char)
            if ty == false then break end
            if not self:Push(ty, data, start) then break end
            continue
        end

        if melon.char.IsNum(char) then
            local ty, data, start = self:HandleNumber(start, char)
            if ty == false then break end
            if not self:Push(ty, data, start) then break end
            continue
        end

        if not self:Push(self:HandleIdentifier(start, char)) then break end
    end

    return (not self.ErrorData) and self:GetTokens(), self.ErrorData
end

function LEXER:GetEq(n)
    local data, hit = self:GetSource():PeekUntil(function(ch, i)
        return ch != "="
    end, n)

    if hit then return false end
    return #data
end

function LEXER:HandlePeriod(start)
    local is_concat = self:GetSource():PeekIs('.')
    local is_va = is_concat and self:GetSource():PeekIs('.', 1)
    local src = self:GetSource()

    if is_concat then src:Consume() end
    if is_va then src:Consume() end

    return
        (is_va and lua.TOKEN_VARIADIC) or
        (is_concat and lua.TOKEN_CONCAT) or
        lua.TOKEN_DOT,

        nil, (is_va or is_concat) and start
end

function LEXER:HandleDiv(start)
    local src = self:GetSource()

    if src:PeekIs('*') then
        src:Consume()

        local data = src:ConsumeUntil(function(ch, i)
            return ch == "*" and src:Peek() == "/"
        end, true)

        src:Consume() -- final /

        return lua.TOKEN_MULTILINECOMMENT, {
            content = table.concat(data),
            cstyle = true,
            eqcount = false
        }, start
    end

    if not src:PeekIs('/') then
        return lua.TOKEN_DIVIDE
    end

    src:Consume()
    local data = src:ConsumeUntil(function(ch, i)
        return ch == "\n"
    end, true)

    return lua.TOKEN_COMMENT, {
        content = table.concat(data),
        cstyle = true
    }, start
end

function LEXER:HandleSub(start)
    local src = self:GetSource()

    if not src:PeekIs("-") then
        return lua.TOKEN_SUBTRACT
    end

    src:Consume()

    local eq = self:GetEq(1)
    local is_ml = src:PeekIs("[", 1 + eq)
    if not is_ml or (not src:PeekIs("[")) then
        local data = src:ConsumeUntil(function(ch, i)
            return ch == "\n"
        end, true)

        return lua.TOKEN_COMMENT, {
            content = table.concat(data),
            cstyle = false
        }, start
    end

    src:ConsumeN(eq + 2, true)

    local data, hit = src:ConsumeUntil(function(ch, i)
        return ch == "]" and src:PeekIs(string.rep('=', eq) .. "]")
    end, true)
    src:ConsumeN(eq + 1, true)

    if hit then
        return self:Error("Unclosed multiline comment, did you forget ]" .. string.rep("=", eq) .. "]?", start)
    end

    return lua.TOKEN_MULTILINECOMMENT, {
        content = table.concat(data),
        cstyle = false,
        eqcount = eq
    }
end

function LEXER:HandleColon(start)
    local src = self:GetSource()
    if not src:PeekIs(':') then
        return lua.TOKEN_COLON
    end

    src:Consume()
    local data, hit = src:ConsumeUntil(function(ch, i)
        return ch == ":" and src:Peek() == ":"
    end, true)

    if hit then
        return self:Error("Expected end of label (\"::\")", start)
    end

    data = table.concat(data)
    if not lua.IsValidName(data:Trim()) then
        return self:Error("Malformed name in label \"" .. data:Trim() .. "\"")
    end

    return lua.TOKEN_LABEL, {
        content = data
    }, start
end

function LEXER:HandleString(start, strch)
    local src = self:GetSource()
    
    local data, hit, is_newline = src:ConsumeUntil(function(ch, i)
        if (ch == strch) and (src:Peek(-2) != "\\") then return true end
        if ch == "\n" then return true, true end
    end, true)

    if hit then
        return self:Error("Expected '" .. strch .. "', got EOF")
    end

    if is_newline then
        return self:Error("Newlines are not allowed in " .. strch:rep(2) .. " strings, use \"[[]]\"")
    end

    return lua.TOKEN_STRING, {
        content = table.concat(data),
        style = strch
    }
end

function LEXER:HandleLBrace(start)
    local src = self:GetSource()
    local eq = self:GetEq()
    local is_ml = src:PeekIs("[", eq)

    if not is_ml then
        return lua.TOKEN_LEFTBRACE
    end

    src:ConsumeN(eq + 1, true)
    local data, hit = src:ConsumeUntil(function(ch, i)
        return ch == "]" and src:PeekIs(string.rep("=", eq) .. "]")
    end, true)
    src:ConsumeN(eq + 1, true)

    if hit then
        return self:Error("Unclosed multiline string, did you forget ]" .. string.rep("=", eq) .. "]?", start)
    end

    return lua.TOKEN_MULTILINESTRING, {
        content = table.concat(data),
        eqcount = eq
    }
end

function LEXER:HandlePair(is, iseq, isnteq)
    local src = self:GetSource()
    return function(s, start, char)
        if src:PeekIs(is) then
            src:Consume()
            return iseq, nil, start
        end

        if not isnteq then
            return s:Error("Expected '" .. char .. is .. "', got '" .. char .. (src:Peek() or "EOF") .. "'")
        end

        return isnteq
    end
end

function LEXER:HandleIdentifier(start, ch)
    local src = self:GetSource()

    local data = src:ConsumeUntil(function(ch)
        return not lua.IsValidNameCharacter(ch)
    end, true)

    local name = ch .. table.concat(data)
    local kw = lua.GetKeyword(name)
    if kw then
        return kw, nil, start
    end

    return lua.TOKEN_IDENTIFIER, {
        name = name,
    }, start
end

function LEXER:GetNum(is_hex)
    local src = self:GetSource()
    return table.concat(({src:ConsumeUntil(function(ch)
        print("ch:", ch)
        return not (melon.char.IsNum(ch) or (is_hex and melon.char.IsHex(ch)))
    end, true)})[1])
end

function LEXER:GetExponent(is_hex)
    local src = self:GetSource()
    local exp = (src:Peek() or ""):lower()

    if (exp == "e" and not is_hex) or (is_hex and exp == "p") then
        return src:Consume() .. self:GetNum()
    end
end

function LEXER:GetDecimal()
    local src = self:GetSource()
    local dot = src:Peek()

    if dot != "." then return end
        
    return src:Consume() .. self:GetNum()
end

function LEXER:HandleNumber(start, ch)
    local src = self:GetSource()
    local is_hex = ch == "0" and (src:PeekIs("x") or src:PeekIs("X"))

    if is_hex then
        ch = ch .. src:Consume()
    end

    local integer = ch .. self:GetNum(is_hex)
    local exponent = self:GetExponent(is_hex)
    local decimal = self:GetDecimal()

    if
        (exponent and #exponent <= 1) or
        (decimal and #decimal <= 1)
    then
        return self:Error("Malformed number (" .. integer .. (exponent or "") .. (decimal or "") .. ")")
    end

    local next = src:Peek()
    if next and (melon.char.IsAlphaNumeric(next) or next == "_") then
        return self:Error("Malformed number (" .. integer .. (exponent or "") .. (decimal or "") .. next .. ")")
    end

    return lua.TOKEN_NUMBER, {
        integer = integer, 
        decimal = decimal or "bad", 
        exponent = exponent or "bad"
    }
end

melon.Debug(function()
    print("---")
    local tok, errs = melon.lang.lua.Lex(
        string.Trim([======================[
123e123]======================]))

    print(string.rep("\n", 1))

    _pname("tokens")
    _p(tok)
    
    if errs then
        print()
        _pname("errors")
        _p(errs)
    else
        print()
        _pname("no errors")
        _p()
    end
end, true)