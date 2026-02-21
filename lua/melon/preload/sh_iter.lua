----
---@realm SHARED
---@name melon.iter
----
---- Contains functions relating to custom iterators
----
melon.iter = melon.iter or {}
melon.iter.CurrentIterState = false

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
        state = table.Copy(state or {})
        state.index = 0
        melon.iter.CurrentIterState = state

        local args = {...}
        local overflow = 0
        return function()
            state.index = state.index + 1

            overflow = overflow + 1
            if overflow >= 100 then return error("overflowed") end
            
            local ret = {fn(state.index, unpack(args))}
            if ret[1] == nil then
                melon.iter.CurrentIterState = false
                state.index = 0
                return nil
            end
            
            return unpack(ret)
        end
    end
end

----
---@name melon.iter.Skip
----
---@arg (i: number) How many indices to skip
----
---- Skips the given number of indices into the future of the iterator
---- Only to be called inside a [melon.iter.NewIter] wrapped iterator 
----
function melon.iter.Skip(i)
    if not melon.iter.CurrentIterState then
        return melon.Log(melon.LOG_ERROR, "Attempting to melon.iter.Skip outside of a melonlib iterator!")
    end

    melon.iter.CurrentIterState.index = melon.iter.CurrentIterState.index + i
end

----
---@name melon.iter.Goto
----
---@arg (i: number) The index to jump to
----
---- Jumps to the given index in the active iterator
---- Only to be called inside a [melon.iter.NewIter] wrapped iterator 
----
function melon.iter.Goto(i)
    if not melon.iter.CurrentIterState then
        return melon.Log(melon.LOG_ERROR, "Attempting to melon.iter.Goto outside of a melonlib iterator!")
    end

    melon.iter.CurrentIterState.index = i
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
        if ch == "c" then
            melon.iter.Skip(1)
        end

        print(i, ch)
    end

    melon.clr()

    print(melon.iter.ReverseArgs(1, 2, 3, 4))
end, true)