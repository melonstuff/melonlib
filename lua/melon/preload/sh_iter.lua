----
---@realm SHARED
---@name melon.iter
----
---- Contains functions relating to custom iterators
----
melon.iter = melon.iter or {}
melon.iter.StateStack = {}
melon.iter.OverflowProtect = 1000
melon.iter.MaxStackSize = 1024
melon.iter.CurrentStackSize = 0

----
---@name melon.iter.NewIter
----
---@arg    (input: fn) The iterator function
---@arg    (state?: table) The input state, copied
---@return (fn) The wrapped iterator function
----
---- Wraps the input iterator function to allow for [melon.iter].* functions to work
---- This is only designed for non state-altering iterators that are number indexed
----
function melon.iter.NewIter(fn, state)
    return function(...)
        melon.iter.CurrentStackSize = melon.iter.CurrentStackSize + 1

        state = table.Copy(state or {})
        state.id = #melon.iter.StateStack + 1
        state.index = 0
        state.iterations = 0
        table.insert(melon.iter.StateStack, state)

        local args = {...}
        return function()
            local state = melon.iter.Top()
            state.index = state.index + 1
            state.iterations = state.iterations + 1

            if state.iterations >= melon.iter.OverflowProtect then
                melon.Log(1, "Iterator overflowed!")
                return error("see above error")
            end

            if melon.iter.CurrentStackSize >= melon.iter.MaxStackSize then
                melon.Log(1, "Iterator MaxStackSize overflowed!")
                return error("see above error")
            end

            local ret = {fn(state.index, unpack(args))}
            if ret[1] == nil then
                melon.iter.Break()
                return nil
            end
            
            return unpack(ret)
        end
    end
end

----
---@name melon.iter.SetOverflowProtect
----
---@arg (number) How many iterations before [melon.iter.NewIter] iterators error out
----
---- Sets the number of iterations before all iterators cancel
----
function melon.iter.SetOverflowProtect(i)
    melon.iter.OverflowProtect = i
end

----
---@name melon.iter.Top
----
---@return (table) Stack state
----
---- Returns the top of the current iterator stack
----
function melon.iter.Top()
    return melon.table.Top(melon.iter.StateStack)
end

----
---@name melon.iter.GetState
----
---@arg    (lvl: number) How many levels down from the top should we go
---@return (table?) The state from the stack if it was found
----
---- Gets a stack state from the given level, providing 0 gives you the Top 
----
function melon.iter.GetState(i)
    return melon.iter.StateStack[#melon.iter.StateStack - i]
end

----
---@name melon.iter.Skip
----
---@arg (i: number) How many indices to skip
---@arg (lvl: number) How many levels down in the stack should be run this on
----
---- Skips the given number of indices into the future of the iterator
---- Only to be called inside a [melon.iter.NewIter] wrapped iterator 
----
function melon.iter.Skip(i, lvl)
    if not melon.iter.Top() then
        return melon.Log(1, "Attempting to melon.iter.Skip outside of a melonlib iterator!")
    end

    local state = melon.iter.GetState(lvl or 0)
    if not state then
        return melon.Log(1, "Attempting to melon.iter.Skip on an invalid stack level (provided {}, max {})", lvl, #melon.iter.StateStack)
    end

    state.index = state.index + i
end

----
---@name melon.iter.Goto
----
---@arg (i: number) The index to jump to
---@arg (lvl: number) How many levels down in the stack should be run this on
----
---- Jumps to the given index in the active iterator
---- Only to be called inside a [melon.iter.NewIter] wrapped iterator 
----
function melon.iter.Goto(i, lvl)
    if not melon.iter.Top() then
        return melon.Log(1, "Attempting to melon.iter.Goto outside of a melonlib iterator!")
    end

    local state = melon.iter.GetState(lvl or 0)
    if not state then
        return melon.Log(1, "Attempting to melon.iter.Goto on an invalid stack level (provided {}, max {})", lvl, #melon.iter.StateStack)
    end

    state.index = i
end

----
---@name melon.iter.Break
----
---- Breaks the current iter
---- Only to be called inside a [melon.iter.NewIter] wrapped iterator 
----
function melon.iter.Break()
    melon.iter.CurrentStackSize = melon.iter.CurrentStackSize - 1
    local top = melon.table.Pop(melon.iter.StateStack)
    top.index = 0
end

----
---@name melon.iter.ReverseArgs
----
---@arg    (...) Args to reverse
---@return (...) Reversed arguments
----
---- Reverses the given arguments
----
function melon.iter.ReverseArgs(...)
    return unpack(table.Reverse({...}))
end

melon.Debug(function()
    local iter = melon.iter.NewIter(function(i, str)
        if str[i] == "" then return nil end

        return str[i], i
    end)

    for ch, i in iter("abcdef") do
        for ch2 in iter("12345") do
            print(ch, ch2)
        end
    end

    -- melon.clr()

    -- print(melon.iter.ReverseArgs(1, 2, 3, 4))
end, true)