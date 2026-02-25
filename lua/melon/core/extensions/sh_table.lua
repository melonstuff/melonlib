
----
---@realm SHARED
---@name melon.table
----
---- Contains table helpers
----
melon.table = melon.table or {}

----
---@name melon.table.Top
----
---@arg    (table) Table to get the top value of
---@return (any?) The returned value 
----
---- Gets the top value of the table
----
function melon.table.Top(t)
    return t[#t]
end

----
---@name melon.table.Pop
----
---@arg    (table) Table to pop off of
---@return (any?) The popped value if we got one
----
---- Removes the last element from the table
----
function melon.table.Pop(t)
    if #t == 0 then return end

    return table.remove(t, #t)
end

melon.Debug(function()
    local t = {1, 2, 3, 4, 5}
    
    melon.table.Pop(t)

    melon.AssertEq(4, melon.table.Top(t))
end )