
----
---@realm SHARED
---@name melon.lua
----
---- Contains utilities relating to meta-lua things, such as a parser.
----
melon.lua = melon.lua or {}

----
---@member
---@name melon.lua.TokenKinds
----
---- List of all kinds of tokens with comments describing what their data should be
---- Taken from https://github.com/gmodls/gmodls/blob/develop/gmodls-analyzer/src/lex.rs
----
melon.lua.TokenKinds = melon.lua.TokenKinds or {}
do --- Token Kinds
    melon.lua.TokenKinds.Eof     = {}
    melon.lua.TokenKinds.Unknown = {} -- (u8)
    
    -- Primitives
    melon.lua.TokenKinds.Name                 = "Name"                 -- (String)
    melon.lua.TokenKinds.Number               = "Number"               -- (String)
    melon.lua.TokenKinds.String               = "String"               -- (String, u8)  Contents and the character the string is created with, eg. ' or "
    melon.lua.TokenKinds.MultilineString      = "MultilineString"      -- (String, u16) Contents and how many ='s?
    melon.lua.TokenKinds.Label                = "Label"                -- (String)      ::label::, span should encompass everything including ::'s
    melon.lua.TokenKinds.CommentGmod          = "CommentGmod"          -- (String)
    melon.lua.TokenKinds.MultiLineCommentGmod = "MultiLineCommentGmod" -- (String)
    melon.lua.TokenKinds.Comment              = "Comment"              -- (String)
    melon.lua.TokenKinds.MultiLineComment     = "MultiLineComment"     -- (String, u16)
    -- 
    -- Singletons
    melon.lua.TokenKinds.True  = "True"
    melon.lua.TokenKinds.False = "False"
    melon.lua.TokenKinds.Nil   = "Nil"
    
    -- Keywords
    melon.lua.TokenKinds.Break    = "Break"
    melon.lua.TokenKinds.Do       = "Do"
    melon.lua.TokenKinds.Else     = "Else"
    melon.lua.TokenKinds.ElseIf   = "ElseIf"
    melon.lua.TokenKinds.End      = "End"
    melon.lua.TokenKinds.For      = "For"
    melon.lua.TokenKinds.Function = "Function"
    melon.lua.TokenKinds.If       = "If"
    melon.lua.TokenKinds.In       = "In"
    melon.lua.TokenKinds.Local    = "Local"
    melon.lua.TokenKinds.Repeat   = "Repeat"
    melon.lua.TokenKinds.Return   = "Return"
    melon.lua.TokenKinds.Then     = "Then"
    melon.lua.TokenKinds.Until    = "Until"
    melon.lua.TokenKinds.While    = "While"
    melon.lua.TokenKinds.Goto     = "Goto"
    melon.lua.TokenKinds.Continue = "Continue"
    
    -- Binary operators
    melon.lua.TokenKinds.Add      = "Add"      -- +
    melon.lua.TokenKinds.Subtract = "Subtract" -- -
    melon.lua.TokenKinds.Multiply = "Multiply" -- *
    melon.lua.TokenKinds.Divide   = "Divide"   -- /
    melon.lua.TokenKinds.Power    = "Power"    -- ^
    melon.lua.TokenKinds.Modulo   = "Modulo"   -- %
    
    melon.lua.TokenKinds.GreaterThan      = "GreaterThan"      -- >
    melon.lua.TokenKinds.LessThan         = "LessThan"         -- <
    melon.lua.TokenKinds.GreaterThanEqual = "GreaterThanEqual" -- >=
    melon.lua.TokenKinds.LessThanEqual    = "LessThanEqual"    -- <=
    
    melon.lua.TokenKinds.Equal        = "Equal"        -- ==
    melon.lua.TokenKinds.NotEqualGmod = "NotEqualGmod" -- !=
    melon.lua.TokenKinds.NotEqual     = "NotEqual"     -- ~=
    melon.lua.TokenKinds.And          = "And"          -- "and"
    melon.lua.TokenKinds.AndGmod      = "AndGmod"      -- &&
    melon.lua.TokenKinds.Or           = "Or"           -- "or"
    melon.lua.TokenKinds.OrGmod       = "OrGmod"       -- ||
    melon.lua.TokenKinds.Concat       = "Concat"       -- ..
    
    -- Unary Operators
    melon.lua.TokenKinds.Not     = "Not"     -- "not" keyword
    melon.lua.TokenKinds.NotGmod = "NotGmod" -- ! symbol
    melon.lua.TokenKinds.Length  = "Length"  -- #
    
    -- Misc
    melon.lua.TokenKinds.Assign = "Assign" -- =
    melon.lua.TokenKinds.Dot    = "Dot"    -- .
    melon.lua.TokenKinds.Dots   = "Dots"   -- ...
    
    melon.lua.TokenKinds.SemiColon = "SemiColon" -- ;
    melon.lua.TokenKinds.Comma     = "Comma"     -- ,
    melon.lua.TokenKinds.Colon     = "Colon"     -- :
    
    melon.lua.TokenKinds.LeftCurly   = "LeftCurly"   -- {
    melon.lua.TokenKinds.RightCurly  = "RightCurly"  -- }
    melon.lua.TokenKinds.LeftSquare  = "LeftSquare"  -- [
    melon.lua.TokenKinds.RightSquare = "RightSquare" -- ]
    melon.lua.TokenKinds.LeftParen   = "LeftParen"   -- (
    melon.lua.TokenKinds.RightParen  = "RightParen"  -- )
end

function melon.lua.IsWhitespace(ch)
    return ch == " " or ch == "\t"
end

function melon.lua.IsNumeric(ch)
    ch = string.byte(ch)

    return ch >= 48 and ch <= 57
end

function melon.lua.IsHex(ch)
    return melon.lua.IsNumeric(ch) or ({a = true, b = true, c = true, d = true, e = true, f = true})[ch:lower()] -- lenny trollface emoji troll discord under the bridge haha
end

--#todo make this more extensive/accurate to luajit
function melon.lua.IsAlpha(ch)
    ch = string.byte(ch)

    return (ch >= 97 and ch <= 122) or (ch >= 65 and ch <= 90)
end

function melon.lua.IsValidNameCharacter(ch)
    return melon.lua.IsNumeric(ch) or melon.lua.IsAlpha(ch) or (ch == "_")
end

function melon.lua.IsValidName(name)
    if not melon.lua.IsAlpha(name[1]) and name[1] != "_" then return false end

    for i = 2, #name do
        if not melon.lua.IsValidNameCharacter(name[i]) then
            return false
        end
    end

    return true
end

function melon.lua.Tokenize(str)
    local tokens = {}
    local errors = {}
    local start
    local pos = {index = 1, line = 1, column = 1}
    local whitespace = ""
    local comments = {}

    local function consume(amt)
        if amt == 0 then return end

        if (amt or 0) > 1 then
            consume(amt - 1)
        end
        
        local ch = str[pos.index]

        if melon.lua.IsWhitespace(ch) then
            whitespace = whitespace .. ch
        end

        pos.index = pos.index + 1
        pos.column = pos.column + 1

        if ch == "\n" then
            pos.line = pos.line + 1
            pos.column = 1
        end

        return ch
    end

    local function copy_pos()
        return table.Copy(pos)
    end

    local function peek(fwd) return str[pos.index + (fwd or 0)] end
    local function push_error(s)
        table.insert(errors , {
            str = s,
            span = {
                from = start,
                to = copy_pos()
            },
        })
    end

    local function push_token(kind, data)
        table.insert(tokens, {
            kind = kind,
            data = data,
            whitespace = whitespace,
            comments = comments,
            span = {
                from = start,
                to = copy_pos()
            }
        })

        whitespace = ""
        comments = {}

        if kind == melon.lua.TokenKinds.Unknown then
            push_error("unknown symbol '" .. data .. "'")
        end

        return tokens[#tokens]
    end

    local function num_eq()
        local i = 0

        while (pos.index + i) <= #str do
            local ch = peek(i)

            if ch == '=' then
                i = i + 1
                continue
            end

            return i
        end
    end
    
    local symbols = {
        ['+'] = melon.lua.TokenKinds.Add,
        ['*'] = melon.lua.TokenKinds.Multiply,
        ['^'] = melon.lua.TokenKinds.Power,
        ['%'] = melon.lua.TokenKinds.Modulo,
        ['#'] = melon.lua.TokenKinds.Length,
        [';'] = melon.lua.TokenKinds.SemiColon,
        [','] = melon.lua.TokenKinds.Comma,
        ['{'] = melon.lua.TokenKinds.LeftCurly,
        ['}'] = melon.lua.TokenKinds.RightCurly,
        [']'] = melon.lua.TokenKinds.RightSquare,
        ['('] = melon.lua.TokenKinds.LeftParen,
        [')'] = melon.lua.TokenKinds.RightParen,
    }

    local doubles = {
        ["="] = {"=", melon.lua.TokenKinds.Assign, melon.lua.TokenKinds.Equal},
        [">"] = {"=", melon.lua.TokenKinds.GreaterThan, melon.lua.TokenKinds.GreaterThanEqual},
        ["<"] = {"=", melon.lua.TokenKinds.LessThan, melon.lua.TokenKinds.LessThanEqual},
        ["!"] = {"=", melon.lua.TokenKinds.NotGmod, melon.lua.TokenKinds.NotEqualGmod},
        ["~"] = {"=", melon.lua.TokenKinds.Unknown, melon.lua.TokenKinds.NotEqual},
        ["|"] = {"|", melon.lua.TokenKinds.Unknown, melon.lua.TokenKinds.OrGmod},
        ["&"] = {"&", melon.lua.TokenKinds.Unknown, melon.lua.TokenKinds.AndGmod},
    }

    local keywords = {
        ["break"]    = melon.lua.TokenKinds.Break,
        ["do"]       = melon.lua.TokenKinds.Do,
        ["else"]     = melon.lua.TokenKinds.Else,
        ["elseif"]   = melon.lua.TokenKinds.ElseIf,
        ["end"]      = melon.lua.TokenKinds.End,
        ["for"]      = melon.lua.TokenKinds.For,
        ["function"] = melon.lua.TokenKinds.Function,
        ["if"]       = melon.lua.TokenKinds.If,
        ["in"]       = melon.lua.TokenKinds.In,
        ["local"]    = melon.lua.TokenKinds.Local,
        ["repeat"]   = melon.lua.TokenKinds.Repeat,
        ["return"]   = melon.lua.TokenKinds.Return,
        ["then"]     = melon.lua.TokenKinds.Then,
        ["until"]    = melon.lua.TokenKinds.Until,
        ["while"]    = melon.lua.TokenKinds.While,
        ["goto"]     = melon.lua.TokenKinds.Goto,
        ["continue"] = melon.lua.TokenKinds.Continue,

        ["true"]     = melon.lua.TokenKinds.True,
        ["false"]    = melon.lua.TokenKinds.False,
        ["nil"]      = melon.lua.TokenKinds.Nil,

        ["and"] = melon.lua.TokenKinds.And,
        ["or"]  = melon.lua.TokenKinds.Or
    }

    local cnt = 0
    while pos.index <= #str do
        ::begin::

        cnt = cnt + 1
        if cnt >= (#str * 2) then
            error("stack overflow")
            break
        end

        start = copy_pos()
  
        local ch = peek()
        if ch == "" then push_token(melon.lua.TokenKinds.Eof) break end


        if melon.lua.IsWhitespace(ch) then
            whitespace = whitespace .. ch
            consume()
            continue
        end

        if ch == "\n" or ch == "\r" then
            consume()
            continue
        end

        ---
        --- Single character symbols
        --- '#', '*', ect
        ---
        if symbols[ch] then
            consume()
            push_token(symbols[ch])
            continue
        end

        ---
        --- Double character symbols
        --- "==", ">="
        ---
        if doubles[ch] then
            consume()

            if doubles[ch][1] == peek() then
                consume()
                push_token(doubles[ch][3])
                continue
            end

            push_token(doubles[ch][2])
            continue
        end

        ---
        --- Dot handling
        ---
        if ch == "." then
            consume()

            if peek() == "." then
                consume()

                if peek() == "." then
                    consume()
                    push_token(melon.lua.TokenKinds.Dots)             
                    continue
                end

                push_token(melon.lua.TokenKinds.Concat)
                continue
            end

            push_token(melon.lua.TokenKinds.Dot)
            continue
        end

        ---
        --- Label handling
        ---
        if ch == ":" then
            consume()

            if peek() == ":" then
                consume()

                local label = ""
                local errored = false
                while pos.index <= #str do
                    local label_ch = peek()

                    if not label_ch then break end
                    if label_ch == ":" then
                        break
                    end

                    if not melon.lua.IsValidNameCharacter(label_ch) and not errored then
                        push_error("malformed label name")
                        errored = true
                    end

                    consume()
                    label = label .. label_ch
                end

                if peek() == ":" then consume() elseif not errored then errored = true push_error("missing ':' in label declaration") end
                if peek() == ":" then consume() elseif not errored then errored = true push_error("missing ':' in label declaration") end

                if not melon.lua.IsValidName(label) and not errored then
                    push_error("malformed label name")
                end

                push_token(melon.lua.TokenKinds.Label, label)
                continue
            end

            push_token(melon.lua.TokenKinds.Colon)
            continue
        end

        ---
        --- Comment handling
        ---
        if ch == "-" then
            consume()

            if peek() == "-" then
                consume()

                local text = ""
                if peek() == "[" then
                    consume()
                    local amt_eq = num_eq()

                    if peek(amt_eq) != "[" then
                        goto regular_comment      
                    end

                    consume(amt_eq)
                    consume()

                    while true do
                        local c_ch = consume()
                        if c_ch == "" then break end

                        if c_ch == "]" then
                            local ceq = num_eq()

                            if ceq == amt_eq and peek(ceq) == "]" then
                                consume(amt_eq)
                                consume()

                                push_token(melon.lua.TokenKinds.MultiLineComment, {
                                    text = text,
                                    amount = ceq
                                })
                                
                                goto begin
                            end
                        end

                        text = text .. c_ch
                    end

                    push_error("missing closing for multiline comment (did you forget a ']" .. string.rep("=", amt_eq) .. "]'?)")

                    continue
                end

                ::regular_comment::
                while pos.index <= #str do
                    local c_ch = consume()

                    if c_ch == "\n" then break end
                
                    text = text .. c_ch
                end

                push_token(melon.lua.TokenKinds.Comment, text)
                continue
            end

            push_token(melon.lua.TokenKinds.Subtract)
            continue
        end

        if ch == "/" then
            consume()

            if peek() == "/" then
                consume()

                local text = ""
                while pos.index <= #str do
                    local c_ch = consume()

                    if c_ch == "\n" then break end
                
                    text = text .. c_ch
                end

                push_token(melon.lua.TokenKinds.CommentGmod, text)
                continue
            end

            if peek() == "*" then
                consume()

                local text = ""

                while pos.index <= #str do
                    local c_ch = consume()
                    local c_chnext = peek()

                    if c_ch == "*" and c_chnext == "/" then
                        consume()
                        
                        break
                    end
                
                    text = text .. c_ch
                end

                push_token(melon.lua.TokenKinds.MultiLineCommentGmod, text)
                continue
            end

            push_token(melon.lua.TokenKinds.Divide)
        end

        ---
        --- Inline String handling
        ---
        if ch == '\"' or ch == '\'' then
            consume()

            local text = ""
            while true do
                ::s::
                local s_ch = consume()

                if s_ch == '\\' then
                    text = text .. s_ch .. consume()
                    goto s
                end

                if s_ch == ch then
                    break
                end

                if s_ch == "" then
                    push_error("unclosed string, expected '" .. ch .. "'")
                    break
                end

                if s_ch == "\n" then
                    push_error("unclosed string, expected '" .. ch .. "', use [[]] for multiline strings")
                    break
                end

                text = text .. s_ch
            end

            push_token(melon.lua.TokenKinds.String, {
                text = text,
                starter = ch
            })

            continue
        end

        ---
        --- Multiline string handling
        ---
        if ch == "[" then
            consume()

            local amt_eq = num_eq()
            if peek(amt_eq) != "[" then
                push_token(melon.lua.TokenKinds.RightSquare)
                
                continue
            end

            consume(amt_eq)
            consume()

            local text = ""
            while true do
                local s_ch = consume()

                if s_ch == "]" then
                    local eq = num_eq()

                    if (eq == amt_eq) and peek(eq) == "]" then
                        consume(amt_eq)
                        consume()

                        push_token(melon.lua.TokenKinds.MultilineString, {
                            text = text,
                            amount = eq,
                        })
                        goto begin
                    end
                end

                text = text .. s_ch
            end
        end

        ---
        --- Number handling
        --- <hex/int>[.<int>][<e/p><int>]
        ---
        if melon.lua.IsNumeric(ch) then
            local errored = false
            local is_hex = false
            local number = consume()
            local float = false
            local exponent = false 

            if number == "0" and peek():lower() == "x" then
                is_hex = true
                number = number .. consume()

                while pos.index <= #str do
                    local n_ch = peek()

                    if melon.lua.IsHex(n_ch) then
                        number = number .. consume()
                        continue
                    end

                    if melon.lua.IsValidNameCharacter(n_ch) then
                        if not errored then
                            push_error("malformed number")
                        end
                        
                        number = number .. consume()
                        errored = true
                        continue
                    end

                    break
                end
            else 
                while pos.index <= #str do
                    local n_ch = peek()

                    if melon.lua.IsNumeric(n_ch) then
                        number = number .. consume()
                        continue
                    end

                    if melon.lua.IsValidNameCharacter(n_ch) then
                        if not errored then
                            push_error("malformed number")
                        end
                        
                        number = number .. consume()
                        errored = true
                        continue
                    end

                    break
                end
            end

            if peek() == "." then
                consume()
                float = ""
                while pos.index <= #str do
                    local n_ch = peek()

                    if melon.lua.IsNumeric(n_ch) then
                        float = float .. consume()
                        continue
                    end

                    if n_ch == (is_hex and 'p' or 'e') then
                        break
                    end

                    if melon.lua.IsValidNameCharacter(n_ch) then
                        if not errored then
                            push_error("malformed number")
                        end
                        
                        float = float .. consume()
                        errored = true
                        continue
                    end

                    break
                end
            end

            if peek() == (is_hex and 'p' or 'e') then
                consume()
                exponent = ""

                while pos.index <= #str do
                    local n_ch = peek()

                    if melon.lua.IsNumeric(n_ch) then
                        exponent = exponent .. consume()
                        continue
                    end

                    if melon.lua.IsValidNameCharacter(n_ch) then
                        if not errored then
                            push_error("malformed number")
                        end
                        
                        exponent = exponent .. consume()
                        errored = true
                        continue
                    end

                    break
                end
            end

            push_token(melon.lua.TokenKinds.Number, {
                number = number,
                float = float,
                exponent = exponent
            })

            continue
        end

        ---
        --- Keyword and Identifier handling
        ---
        if not melon.lua.IsValidNameCharacter(ch) then
            push_token(melon.lua.TokenKinds.Unknown, ch)
            continue
        end

        local text = ""
        while pos.index <= #str do
            local i_ch = peek()

            if melon.lua.IsValidNameCharacter(i_ch) then
                text = text .. consume()
                continue
            end

            break
        end

        push_token(keywords[text] or melon.lua.TokenKinds.Name, text)
    end

    return tokens, errors
end

-- local text = file.Read(debug.getinfo(1).short_src:sub(21, -1), "LUA")
local text = ""

melon.Debug(function()
    local tokens, errors = melon.lua.Tokenize(text)

    for k, v in pairs(tokens) do
        print(v.kind, (isstring(v.data) and v.data) or (istable(v.data) and util.TableToJSON(v.data)) or "")
    end
    
    if #errors == 0 then return end 
    print("\n--- errors ---")

    for k, v in pairs(errors) do
        print(k .. ":  " .. v.str, v.span.from.index, v.span.to.index)
    end
end, true)