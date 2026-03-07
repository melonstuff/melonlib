
----
---@realm SHARED
---@name melon.lang.lua
----
---- Contains handlers for lexing and parsing (soon) glua source code
----
melon.lang.lua = melon.lang.lua or {}

----
---@name melon.lang.lua.Lex
----
---@arg    (string) Input string to lex
---@return (table<melon.lang.lua.TOKEN>?) If we succeeded, a table of tokens, otherwise nil
---@return (string?) If we failed, why?
----
---- Creates a new temporary [melon.lang.lua.LEXER] and runs it on the given code
---- Note that this shouldnt be used for lexing multiple files, reuse the object
----
function melon.lang.lua.Lex(src)
    local lex = setmetatable({}, melon.lang.lua.LEXER)
    lex:SetSource(src)
    return lex:Run()
end