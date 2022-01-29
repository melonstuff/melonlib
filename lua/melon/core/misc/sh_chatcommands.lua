
local commands = {}
local function parseArgs(args)
    local toret = {}

    local i = 0
    local str = ""
    while (i <= #args) and (args[i] != "\0") do
        i = i + 1

        local char = args[i]

        if (char == "\"") or (char == "'") then
            local type = char

            repeat
                i = i + 1
                str = str .. args[i]
            until ((args[i + 1] == type) or args[i] == "\0")

            table.insert(toret, str)
            str = ""
            i = i + 2
        elseif char != " " then
            str = str .. char
        else
            table.insert(toret, str)
            str = ""
        end
    end

    return toret
end

function melon.ChatCommand(name, func)
    commands[name] = func
end

function melon.__ChatHook(ply, text, team)
    local args = parseArgs(text)
    local cmd = commands[table.remove(args, 1)]

    if cmd then
        return cmd(ply, args, text, team)
    end
end

hook.Add("PlayerSay", "MelonLib:ChatCommands", melon.__ChatHook)
hook.Add("OnPlayerChat", "MelonLib:ChatCommands", melon.__ChatHook)

melon.Debug(function()
    PrintTable(parseArgs("this 0x01 'that and \" this' and or that"))
end, true)