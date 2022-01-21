
local behavior = {}

function melon.DefineNewBehavior(key, fn)
    behavior[key] = fn
end

setmetatable(melon, {
    __index = function(s, k)
        if behavior[k] then
            return behavior[k]()
        end

        return rawget(s, k)
    end
})