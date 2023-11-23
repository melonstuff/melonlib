
local G = {}
G.__index = G

----
---@class
---@name melon.GridObject
----
---- Grid Object Class
----

----
---@method
---@name melon.GridObject.SetSize
----
---@arg (w: number) Width to set
---@arg (h: number) Height to set
----
---- Set the size of the grid
----
function G:SetSize(w, h)
    self.w = w
    self.h = h
end

----
---@method
---@name melon.GridObject.GetSize
----
---@return (w: number) Width of the object
---@return (h: number) Height of the object
----
---- Get the size of the grid
----
function G:GetSize()
    return self.w, self.h
end

----
---@method
---@name melon.GridObject.Set
----
---@arg (x: number) X to set
---@arg (y: number) Y to set
---@arg (val:  any) Value to set the coord to
----
---- Sets a value at X and Y to the given value
----
function G:Set(x, y, val)
    if (not self.grid[x]) or (not self.grid[x][y]) then
        return false
    end

    self.grid[x][y] = val
    return true
end

----
---@method
---@name melon.GridObject.Get
----
---@arg (x:   number) X to get
---@arg (y:   number) Y to get
---@return (val: any) Value of the coord
----
---- Gets a value at the given coords
----
function G:Get(x, y)
    if (not self.grid[x]) then
        return false
    end

    return self.grid[x][y]
end

----
---@method
---@name melon.GridObject.Increment
----
---@arg (x: number) X to get
---@arg (y: number) Y to get
----
---- Increments the value at the given coord
----
function G:Increment(x, y)
    if not self.grid[x] then
        return
    end

    if isnumber(self.grid[x][y]) or self.grid[x][y] == nil then
        self.grid[x][y] = (self.grid[x][y] or 0) + 1
    end
end

----
---@method
---@name melon.GridObject.Update
----
---- Updates the grid object
----
function G:Update()
    self.grid = {}

    for x = 1, self.w do
        self.grid[x] = {}

        for y = 1, self.h do
            self.grid[x][y] = 0
        end
    end
end

----
---@name melon.Grid
----
---@arg    (w: number) Width to create the grid as
---@arg    (h: number) Height to create the grid as
---@return (grid: melon.GridObject) Grid object that was created
----
---- Creates a [melon.GridObject]
----
function melon.Grid(w, h)
    local x = setmetatable({}, G)
    x.w = w
    x.h = h
    x:Update()

    return x
end