
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
---@return (any?) The value 
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

----
---@name melon.table.Insert
----
---@arg    (table) Table to insert into
---@arg    (any) Value to insert
---@arg    (number?) Index to insert into
---@return (number) Index the element was inserted into
----
---- Identical to `table.insert()`, except the index value is last so it can be omitted it easily
----
function melon.table.Insert(t, val, index)
    if not index then
        t[#t + 1] = val
        return #t
    end

    return table.insert(t, index, val)
end


melon.Debug(function()
    local t = {1, 3, 4}
    melon.table.Insert(t, 5)
    melon.table.Insert(t, 2, 2)
    
    PrintTable(t)
end, true)

melon.Debug(function()
    local t = {1, 2, 3, 4, 5}
    
    melon.table.Pop(t)
    melon.AssertEq(4, melon.table.Top(t))
end )