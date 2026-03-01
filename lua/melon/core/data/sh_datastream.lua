
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
---@arg    (any) Any key for the data
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
    return self:GetData()[i]
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
    self:GetData()[self:Length() + 1] = v
    return self
end

----
---@method
---@name melon.DATASTREAM:Consume
----
---@return (any) Any data we consumed
----
---- Consumes the current value and returns it
----
function DS:Consume()
    local k = self:GetIndex()
    local v = self:Get(k)
    self:SetIndex(k + 1)
    self:Set(k, nil)

    return v
end

melon.Debug(function()
    local ds = melon.NewDataStream({1, 2, 3})
    ds:Push(4)
    ds:Consume()

    print(ds:Peek())
end, true)