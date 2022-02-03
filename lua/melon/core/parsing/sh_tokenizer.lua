
melon.tokenizer = melon.tokenizer or {}

function melon.tokenizer.IsAlpha(str)
    if #str == 0 then return false end
    local code = utf8.codepoint(tostring(str):lower())

    if code > 122 then return false end
    if code < 48 then return false end
    if (code > 57) and (code < 96) then return false end

    return true
end


function melon.tokenizer.Tokenize(str, types, options)
    options = options or {
        string_chars = {                -- Characters that indicate the start of a string
            ["\""]  = true,
            ["'"]   = true
        },
        newlines = true,                -- Omit a newline token every newline? (auto minifies)
        whitespace = true,              -- Omit a whitespace token every whitespace character (space and \t)
        whitespace_minify = true,       -- Only give one whitespace token at a time
        numbers = true,                 -- Omit number tokens
        identifiers = true              -- Omit identifier tokens
    }

    types = types or {
        symbolic = {},
        keyword = {}
    }

    local charno = 0
    local lineno = 1

    local tokens = {}
    local i = 0

    while i <= #str do
        if melon.StackOverflowProtection(CurTime()) then return end
        i = i + 1

        charno = charno + 1
        local char = str[i]

        if types.symbolic[char] then
            table.insert(tokens, {
                type = "symbolic",
                value = char,
                char = charno,
                line = lineno
            })

            continue
        end


        if options.whitespace and (char == " " or char == "\t") then
            if options.whitespace_minify and tokens[#tokens] and tokens[#tokens].type == "whitespace" then
                continue
            end


            table.insert(tokens, {
                type = "whitespace",
                value = char,
                char = charno,
                line = lineno
            })

            continue
        end

        if options.newlines and (char == "\\") then
            if str[i + 1] == "\n" then
                i = i + 1
                lineno = lineno + 1
                charno = 0
            else
                return tokens, "Invalid Escape Sequence", lineno, charno
            end
            continue
        end

        if options.newlines and (char == "\n") then
            lineno = lineno + 1
            charno = 0

            if tokens[#tokens] and tokens[#tokens].type == "newline" then
                continue
            end

            table.insert(tokens, {
                type = "newline",
                value = char,
                char = charno,
                line = lineno
            })
        end

        if options.string_chars and options.string_chars[char] then
            local new_string = ""
            local valid_string = false

            i = i + 1
            for ni=i,#str do
                local nchar = str[ni]

                if nchar == char then
                    valid_string = true
                    i = ni + 1
                    break
                else
                    new_string = new_string .. nchar
                end
            end

            if not valid_string then
                return tokens, "Failed to close string", lineno, charno
            end

            table.insert(tokens, {
                type = "string",
                value = new_string,
                char = charno,
                line = lineno
            })

            continue
        end

        if not melon.tokenizer.IsAlpha(char) then
            if #char == 0 then continue end
            table.insert(tokens, {
                type = "invalid",
                value = char,
                char = charno,
                line = lineno
            })
            continue
        end

        if options.identifiers then
            local ident = ""
            local valid_ident = false

            for ni=i,#str do
                if melon.StackOverflowProtection(CurTime() + 25) then return end
                local nchar = str[ni]
                i = ni
                if not melon.tokenizer.IsAlpha(nchar) then
                    valid_ident = true
                    i = ni - 1
                    break
                else
                    ident = ident .. nchar
                end
            end

            if #string.Trim(ident) == 0 then
                continue
            end

            if (not valid_ident) and (i != #str) then
                return tokens, "Invalid Identifier " .. i .. ":" .. #str, lineno, charno
            end

            local type =
            (types.keyword[ident] and "keyword") or
            (types.symbolic[ident] and "symbolic") or
            (tonumber(ident) and "number") or
            "ident"

            table.insert(tokens, {
                type = type,
                value = ident,
                char = charno,
                line = lineno
            })

            continue
        end
    end

    return tokens
end

melon.Debug(function()
    PrintTable(melon.tokenizer.Tokenize([[
valid;valid=123]], {
    symbolic = {
        ["="] = "eq"
    },
    keyword = {}
}))
end, true)
