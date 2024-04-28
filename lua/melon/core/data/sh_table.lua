
----
---@name melon.Map
----
---@arg    (iter: generator) The iterator to map. Expected to be an iterator which returns a key and a value.
---@arg    (fn: func)        The mapping function. The function is passed the value then the key, and is expected to return a new value.
---@return (new: table)      A table with the mapped elements. 
----
---- Maps an iterator to a new table, calling `fn` with every key/value pair.
----
function melon.Map(iter, fn)
    local new = {}
    for key, value in iter do
        new[key] = fn(value, key)
    end
    return new
end

----
---@name melon.Reduce
----
---@arg    (iter: generator)    The iterator to map. Expected to be an iterator which returns a key and a value.
---@arg    (fn: func)           The reducer function. The function is passed the current value, the value, the key, and returns the next value.
---@arg    (initial_value: any) The initial value passed to `fn`.
---@return (new: any)           The reduced value.
----
---- Performs a reduction on the given `iter` with the given `fn`.
----
function melon.Reduce(iter, fn, initial_value)
    local current_value = initial_value
    for key, value in iter do
        current_value = fn(current_value, value, key)
    end
    return current_value
end

----
---@name melon.KV2VK
----
---@arg    (iter: generator) Iterator to convert.
---@return (new: table)      Converted table.
----
---- Inverts a tables keys and values ([k] = v) into ([v] = k) for every pair in the given table.
----
function melon.KV2VK(iter)
    local o = {}
    for key, value in iter do
        o[value] = key
    end
    return o
end

----
---@name melon.SubTable
----
---@arg    (tbl:   table) Table to get the subtable of
---@arg    (from: number) Starting index
---@arg    (to:   number) Ending index
---@return (sub:   table) Subtable of the given arguments
----
---- Gets a subtable of the given table from the range of from to to, think string.sub()
----
function melon.SubTable(tbl, from, to)
    local new = {}

    for i = from, to do
        table.insert(new, tbl[i])
    end

    return new
end
  
----
---@name melon.Pack
----
---@arg    (args: varargs)  The varargs to pack.
---@return (length: number) The length of the varargs.
---@return (args: table)    A table containing the passed varargs.
----
---- Takes a variable length of arguments and packs them into a table while also returning the length.
----
function melon.Pack(...)
    return select("#", ...), { ... }
end

----
---@name melon.XPack
----
---@arg    (success: bool)  The success value to forward.
---@arg    (args: varargs)  The varargs to pack.
---@return (length: number) The length of the varargs.
---@return (args: table)    A table containing the passed varargs.
----
---- Takes a variable length of arguments and packs them into a table while also returning the length.
----
---- This function also forwards an initial `success` value separately of the rest of the varargs.
----
function melon.XPack(success, ...)
    return success, select("#", ...), { ... }
end