
----
---@silence
---@internal
---@deprecated
---@name melon.attr
----
---- Weird experiment thats not really used, dont use.
----
melon.attr = setmetatable({}, {
    __call = function(s, name, fn)
        if not s[name] then
            print("[MelonLib] Attribute '" .. name .. "' not found!")
            return
        end

        return function(...)
            return s[name](fn, ...)
        end
    end
})
