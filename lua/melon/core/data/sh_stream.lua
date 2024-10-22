
----
---@class melon.STREAM
----
---- Simple way to pass around a mutable string builder
----
local STREAM = {}
STREAM.__index = STREAM
melon.STREAM = STREAM

function STREAM:Init()
    self.data = ""
    return self
end

----
---@method
---@name melon.STREAM:Write
----
---@arg    (data: string) The string to write to the buffer
---@return (self)
----
---- Appends a string to the end of the buffer, uses the concatenation operator so if youre using this
---- for tables/objects remember to override this!
----
function STREAM:Write(data)
    self.data = self.data .. data
    return self
end

----
---@method
---@name melon.STREAM:WriteFmt
----
---@arg    (fmt:  string) String format to use, see [melon.string] for a reference
---@arg    (args: ...any) Any values to be passed to the formatter
---@return (self)
----
---- Appends a [melon.string.Format] formatted string to the end of the buffer
----
function STREAM:WriteFmt(fmt, ...)
    return self:Write(({melon.string.Format(fmt, ...)})[1])
end

----
---@method
---@name melon.STREAM:WriteLn
----
---@arg    (data: string) The string to write to the buffer
---@return (self)
----
---- Appends a string to the end of the buffer, identical to [melon.STREAM:Write] except it also appends a newline.
----
function STREAM:WriteLn(data)
    return self:Write(data):Write("\n")
end

----
---@method
---@name melon.STREAM:Consume()
----
---@return (str: string) The written string
----
---- Gets the written string and resets the stream,
----
function STREAM:Consume()
    local d = self.data
    self.data = ""
    return d
end

----
---@method
---@name melon.STREAM:Append
----
---@arg    (stream: melon.STREAM) The stream to append, gets consumed
---@return (self)
----
---- Appends the given stream to the current stream
----
function STREAM:Append(stream)
    self:Write(stream:Consume())
    
    return self
end

----
---@name melon.NewStream
----
---@return (stream: melon.STREAM) The new stream
----
---- Creates a new [melon.STREAM] object, initialized without any data
----
function melon.NewStream()
    return setmetatable({}, STREAM):Init()
end