
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
