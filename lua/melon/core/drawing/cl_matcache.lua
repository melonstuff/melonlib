
local mats = {}

function melon.Material(path, opts)
    opts = opts or "none"
    if mats[path .. opts] then
        return mats[path .. opts]
    end

    mats[path .. opts] = Material(path, opts)
    return mats[path .. opts]
end