
local behavior = {}

----
---@internal
---@deprecated
---@name melon.DefineNewBehavior
----
---- Weird experiment thats not really used, dont use.
----
function melon.DefineNewBehavior(key, fn)
    behavior[key] = fn
end

-- setmetatable(melon, {
--     __index = function(s, k)
--         if behavior[k] then
--             return behavior[k]()
--         end

--         return rawget(s, k)
--     end
-- })