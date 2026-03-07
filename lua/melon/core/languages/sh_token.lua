
----
---@name melon.lang.NewToken
----
---@arg    (type: any) Any type identifier for the token
---@arg    (data: any) Any data the token holds
---@arg    (pos: melon.lang.LOCATION | melon.lang.SPAN) The position of the token
---@arg    (whitespace: string) Any whitespace to attach to the token
---@return (melon.lang.TOKEN)
----
---- Creates a new [melon.lang.TOKEN]
----
function melon.lang.NewToken(t, dat, pos, ws)
    return setmetatable({}, melon.lang.TOKEN)
        :SetType(t)
        :SetData(dat)
        :SetPos(pos)
        :SetWhitespace(ws or "")
end

----
---@class
---@name melon.lang.TOKEN
----
---@accessor (Type: any) The type of this token
---@accessor (Data: any) The data inside this token
---@accessor (Whitespace: string) Any whitespace preceding the token
---@accessor (Pos: melon.lang.LOCATION | melon.lang.SPAN) The location of this token
----
---- A token in some source code
----
local TOK = {}
TOK.__index = TOK
melon.lang.TOKEN = TOK

melon.AccessorFunc(TOK, "Type")
melon.AccessorFunc(TOK, "Data")
melon.AccessorFunc(TOK, "Whitespace")
melon.AccessorFunc(TOK, "Pos")

----
---@method
---@name melon.lang.TOKEN:Is
----
---@arg (any) Type to compare against
---@return (bool) Is this this type?
----
---- Compares the inner type to the given type
----
function TOK:Is(ty)
    return self:GetType() == ty
end

melon.Debug(function()
    local tok = melon.lang.NewToken("eq")

    print(tok:Is"eq")
end, true)
