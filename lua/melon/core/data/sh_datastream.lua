
----
---@name melon.NewDatastream
----
---@arg    (any) Any data to initally set
---@return (melon.DATASTREAM) The created object
----
---- Creates a new [melon.DATASTREAM]
----
---`
---` local stream = melon.NewDatastream({1, 2, 3})
---` PrintTable(stream:GetData()) -- 1, 2, 3
---`
---` stream:Push(4)
---` PrintTable(stream:GetData()) -- 1, 2, 3, 4
---`
---` local value = stream:Consume()
---` print(stream:GetIndex()) -- 1
---` print(value) -- 1
---` print(stream:GetIndex()) -- 2
---`
function melon.NewDataStream(data)
    return setmetatable({}, melon.DATASTREAM)
        :Init()
        :SetData(data)
end

----
---@class
---@name melon.DATASTREAM
----
---@accessor (Data: any) The data being operated on
---@accessor (Index: number) The current index were on 
----
---- This is a way to handle any given data (table/string) and operate on it
---- Useful for tokenizers/lexers and parsers
----
local DS = {}
DS.__index = DS
DS.__tostring = function(s)
    return "<melon.DATASTREAM (" .. s:Length() .. ")>"
end
melon.DATASTREAM = DS

melon.AccessorFunc(DS, "Data")
melon.AccessorFunc(DS, "Index")

function DS:Init()
    self:SetData(nil)
    self:SetIndex(1)

    return self
end

----
---@method
---@name melon.DATASTREAM:OnConsume
----
---@arg    (index: number) Key/index where we are
---@arg    (any) Any value that got consumed
---@arg    (nohook: bool) Was this called with nohook?
---@return (any) New return value for Consume
----
---- Called whenever a value is consumed from the stream
---- This is useful for tokenizers where you wanna track characters sent through
----
---- Note that this is intended to be overriden
----
function DS:OnConsume(k, v, nohook)
    if isstring(self:GetData()) then return v end
    if nohook then return v end
    self:Set(k, nil)

    return v
end

----
---@method
---@name melon.DATASTREAM:Length
----
---@return (number) Length of the data
----
---- Gets the length of the data inside the datastream
---- Note that this is intended to be overriden for other datatypes
----
function melon.DATASTREAM:Length()
    return #self:GetData()
end

----
---@method
---@name melon.DATASTREAM:Set
----
---@arg    (number) Index to set the value at
---@arg    (any) Any data to set
---@return (self)
----
---- Sets some value in the data contained within the datastream
---- Note that this is intended to be overriden for other datatypes
----
function melon.DATASTREAM:Set(k, v)
    self:GetData()[k] = v
    return self
end

----
---@method
---@name melon.DATASTREAM:Get
----
---@arg    (number) Index to get from
---@return (any) Any data we got
----
---- Gets the data at the given index in the datastream
---- Note that this is intended to be overriden for other datatypes
----
function melon.DATASTREAM:Get(i)
    local v = self:GetData()[i]
    
    --- We enjoy lua strings here
    if isstring(v) and v == "" then return nil end 
    return v
end

----
---@method
---@name melon.DATASTREAM:Peek
----
---@arg    (number?) The index to peek at, relative to where we are
---@return (any) Any data we got
----
---- Peeks at the given index (or 0) from where we currently are in the datastream
----
function DS:Peek(n)
    return self:Get(self:GetIndex() + (n or 0))
end

----
---@method
---@name melon.DATASTREAM:Push
----
---@arg    (any) Any data to push
---@return (self)
----
---- Pushes some data to the top of the inner datastreams data
---- Note that this uses `__newindex`, will error on strings due to them being immutable
----
function melon.DATASTREAM:Push(v)
    self:Set(self:Length() + 1, v)
    return self
end

----
---@method
---@name melon.DATASTREAM:Consume
----
---@arg    (nohook: bool) Should we skip calling OnConsume?
---@return (any) Any data we consumed
----
---- Consumes the current value and returns it
---- This increments the index we are currently on and calls [melon.DATASTREAM:OnConsume]
----
function melon.DATASTREAM:Consume(nohook)
    local k = self:GetIndex()
    local v = self:Get(k)

    self:SetIndex(k + 1)
    v = self:OnConsume(k, v, nohook)

    return v
end

----
---@method
---@name melon.DATASTREAM:ConsumeN
----
---@arg    (number) Number of values to consume
---@arg    (nohook: bool) Should we skip calling OnConsume?
---@return (table<any>) Any data we consumed
----
---- Consumes the given number of values
----
function melon.DATASTREAM:ConsumeN(n, nohook)
    local data = {}

    for i = 1, n do
        table.insert(data, self:Consume(nohook))
    end

    return data
end

----
---@method
---@name melon.DATASTREAM:PeekUntil
----
---@arg    (fn(any, number) -> bool, ...any) Function that determines if we should stop
---@arg    (number?) Index to start at relative to the current index
---@return (table<number, any>) Data that we got
---@return (bool) Did we hit the end of the stream?
---@return (...any) Any extra data returned from the function
----
---- Peeks at the datastream until the given `function` returns `true`
---- The returned data does not include the final piece of data!
---- If the function hits the end of the stream before the function can return true, we return true as the second return
----
function DS:PeekUntil(fn, n)
    n = n or 0

    local data = {}
    local ret = {}
    while self:Peek(n) do
        local v = self:Peek(n)

        ret = {fn(v, n)}
        local pass = table.remove(ret, 1)
        if pass then
            return data, false, unpack(ret)
        end

        table.insert(data, v)
        n = n + 1
    end

    return data, true, unpack(ret)
end

----
---@method
---@name melon.DATASTREAM:ConsumeUntil
----
---@arg    (fn(any, number) -> bool) Function that determines if we should stop
---@arg    (nohook: bool) Should we skip calling OnConsume?
---@return (table<number, any>) Data that we got
---@return (bool) Did we hit the end of the stream?
----
---- Consumes data from the stream until the given `function` returns `true`
---- If the function hits the end of the stream before the function can return true, we return true as the second return
----
function DS:ConsumeUntil(fn, nohook)
    n = n or 0

    local data = {}
    local ret = {}
    while self:Peek() do
        local v = self:Peek()

        ret = {fn(v, n)}
        local pass = table.remove(ret, 1)
        if pass then
            return data, false, unpack(ret)
        end

        table.insert(data, self:Consume(nohook))
        n = n + 1
    end

    return data, true, unpack(ret)
end

----
---@method
---@name melon.DATASTREAM:PeekIs
----
---@arg    (any) Any value to compare against
---@arg    (number?) The index to peek at, relative to where we are
---@return (bool) Is the next value the given value?
----
---- [melon.DATASTREAM:Peek]s at a value and compares against it
---- Note that this is intended to be overriden for other datatypes, as it only supports strings by default
----
function melon.DATASTREAM:PeekIs(is, n)
    for ch, i in melon.str.Chars(is) do
        if self:Peek((n or 0) + (i - 1)) != ch then
            return false
        end
    end

    return true
end

melon.Debug(function()
    local ds = melon.NewDataStream("abcdefghi")

    _p(ds:ConsumeUntil(function(ch, i)
        return ch == "f" and ds:Peek(1) == "g"
    end))
    _p(ds:PeekIs("g"))
end, true)