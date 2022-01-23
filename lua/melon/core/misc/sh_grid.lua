
local G = {}
G.__index = G

function G:SetSize(w, h)
    self.w = w
    self.h = h
end

function G:GetSize()
    return self.w, self.h
end

function G:Set(x, y, val)
    if (not self.grid[x]) or (not self.grid[x][y]) then
        return false
    end

    self.grid[x][y] = val
    return true
end

function G:Get(x, y)
    if (not self.grid[x]) then
        return false
    end

    return self.grid[x][y]
end

function G:Increment(x, y)
    if not self.grid[x] then
        return
    end

    if isnumber(self.grid[x][y]) or self.grid[x][y] == nil then
        self.grid[x][y] = (self.grid[x][y] or 0) + 1
    end
end

function G:Update()
    self.grid = {}

    for x = 1, self.w do
        self.grid[x] = {}

        for y = 1, self.h do
            self.grid[x][y] = 0
        end
    end
end

function melon.Grid(w, h)
    local x = setmetatable({}, G)
    x.w = w
    x.h = h
    x:Update()

    return x
end