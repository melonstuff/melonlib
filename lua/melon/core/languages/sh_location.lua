----
---@name melon.lang.NewLocation
---@return (melon.lang.LOCATION)
----
---- Creates a new [melon.lang.LOCATION]
----
function melon.lang.NewLocation()
    return setmetatable({}, melon.lang.LOCATION)
end

----
---@name melon.lang.NewSpan
----
---@arg    (start?: melon.lang.LOCATION) The start of the span
---@arg    (end?: melon.lang.LOCATION) The end of the span
---@return (melon.lang.LOCATION)
----
---- Creates a new [melon.lang.SPAN]
----
function melon.lang.NewSpan(start, e)
    return setmetatable({}, melon.lang.SPAN)
        :SetStart(start or melon.lang.NewLocation())
        :SetEnd(e or melon.lang.NewLocation())
end

----
---@name melon.lang.IsLocation
----
---@arg    (any) Any value
---@return (bool) Is this a location?
----
---- Gets if the given value is a [melon.lang.LOCATION]
----
function melon.lang.IsLocation(v)
    return getmetatable(v) == melon.lang.LOCATION
end


----
---@name melon.lang.IsSpan
----
---@arg    (any) Any value
---@return (bool) Is this a span?
----
---- Gets if the given value is a [melon.lang.SPAN]
----
function melon.lang.IsSpan(v)
    return getmetatable(v) == melon.lang.SPAN
end

----
---@class
---@name melon.lang.LOCATION
----
---@accessor (Index: number) Where in code is this spot?
---@accessor (Line: number) What line is it on?
---@accessor (Column: number) What column is it on?
----
---- A place of a token/node in source code
----
local LOC = {}
LOC.__index = LOC
melon.lang.LOCATION = LOC

melon.AccessorFunc(LOC, "Index", 1)
melon.AccessorFunc(LOC, "Line", 1)
melon.AccessorFunc(LOC, "Column", 0)

function LOC:__tostring()
    return self:GetColumn() .. ":" .. self:GetLine()
end

function LOC:Copy()
    return table.Copy(self)
end

----
---@class
---@name melon.lang.SPAN
----
---@accessor (Start: melon.lang.LOCATION) Where this span starts
---@accessor (End: melon.lang.LOCATION) Where this span end 
----
---- A place of a token/node in source code between two [melon.lang.LOCATION]s
----
local SPAN = {}
SPAN.__index = SPAN
melon.lang.SPAN = SPAN

melon.AccessorFunc(SPAN, "Start")
melon.AccessorFunc(SPAN, "End")

function SPAN:__tostring()
    return tostring(self:GetStart()) .. " to " .. tostring(self:GetEnd())
end

function SPAN:Copy()
    return table.Copy(self)
end
    
melon.Debug(function()
    local st = melon.lang.NewLocation()
    local en = melon.lang.NewLocation()

    print(
        melon.lang.NewSpan(st, en)
    )
end )