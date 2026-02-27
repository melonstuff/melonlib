
----
---@name melon.ParseCommandArgs
----
---@arg    (string) Input string
---@arg    (flags?: table<string, number>) Options for flag handling
---@return (args: table<string>) Arguments given
---@return (flags: table<string, table<string>>) Flags given
----
---- Parse command arguments from `concommand.Add`
---- Turns `argstr` into a set of arguments and flags
----
---- Flags are prefixed with `--` and consume however many arguments are passed or 0 if not specified by the options
---- If no options are given, accepts all
----
function melon.ParseCommandArgs(s, opts)
    opts = opts or {}

    local preargs = {}
    local strch

    for ch in melon.str.Chars(s) do
        if ch == "'" or ch == '"' then
            if not strch then
                strch = ch
                continue
            end

            if ch == strch then
                strch = nil
                continue
            end
        end

        local last = preargs[#preargs]
        if not last then
            table.insert(preargs, ch)
            continue
        end

        if strch then
            preargs[#preargs] = last .. ch
            continue
        end

        if melon.char.IsWhitespace(ch) then
            if last and (#last != 0) then
                table.insert(preargs, "")
            end

            continue
        end

        preargs[#preargs] = last .. ch
    end

    local args = {}
    local flags = {}
    while preargs[1] do
        if melon.StackOverflowProtection("test") then
            return error("overflowed")
        end

        local arg = table.remove(preargs, 1)
        if not string.StartsWith(arg, "--") then
            table.insert(args, arg)
            continue
        end

        arg = string.sub(arg, 3, #arg)
        flags[arg] = flags[arg] or {}

        if not opts[arg] then continue end

        for i = 1, opts[arg] do
            local flagdata = table.remove(preargs, 1)
            table.insert(flags[arg], flagdata)
        end
    end

    return args, flags
end

melon.Debug(function()
    local args, flags = melon.ParseCommandArgs(
        "githubwiki melon --ignore melon/modules",
        { flag = 1 }
    )

    _p(args, flags)
end, true)

