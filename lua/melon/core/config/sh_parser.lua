
melon.cfg = melon.cfg or {}

function melon.cfg.Parse(str)
    local i = 1
    local config = {}

    while i <= #str do
        i = i + 1

        print(i)
    end

    return config
end

PrintTable(melon.cfg.Parse([[
[this]
that = 123

[you]
gay = true

]]))