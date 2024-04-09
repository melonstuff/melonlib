
----
---@member
---@name melon.LogTypes
----
---- List of all log types 
----
melon.LogTypes = melon.LogTypes or {}

local logs = {}
local logtypes = melon.LogTypes

----
---@name melon.AddLogHandler
----
---@arg (level:      number) Number, log level
---@arg (log:  func(table)) Function to call when logging, called with logdata
----
---- Adds a log handler
----
function melon.AddLogHandler(lvl, func)
    logtypes[lvl] = func
end

----
---@name melon.AddDynamicLogHandler
----
---@arg    (log:   func(table)) Function to call when logging, called with logdata
---@return (type:       number) Log Level
----
---- Adds a log handler which just appends to the previous logtypes, returns the level of this handler
----
function melon.AddDynamicLogHandler(func)
    local num = #logtypes + 1

    logtypes[num] = func

    return num
end

----
---@name melon.Log
----
---@arg    (level:   number) The log level
---@arg    (fmt:     string) String format to log
---@arg    (fmtargs: ...any) Arguments for the formatter
----
---- Formats and logs a message, also calls the hook `Melon:Log` with the logdata
----
function melon.Log(lvl, fmt, ...)
    local vg = {...}

    local logMessage
    if melon.string and melon.string.Format then
        logMessage = melon.string.Format(fmt, vg)
    else
        logMessage = string.gsub(fmt, "{%d+}", function(x)
            return ((vg)[tonumber(x:sub(2, -2))]) or x
        end )
    end

    local time = os.time()
    local fmt_time = string.FormattedTime(CurTime(), math.floor(CurTime() / 3600) .. ":%02i:%02i:%02i")

    local l = {
        message = logMessage,
        trace = debug.traceback("", 2),
        time = time,
        level = lvl,
        handler = logtypes[lvl],
        fmt_time = fmt_time
    }
    table.insert(logs, l)

    logtypes[lvl](l)
    hook.Run("Melon:Log", l)
end

----
---@name melon.Assert
----
---@arg (expr:   bool) Did this expression pass? Must be true to pass
---@arg (fmt:  string) Format string error if we failed
---@arg (args: ...any) Arguments for the formatted
----
---- Asserts the expression, returns true if you should return
----
function melon.Assert(expr, fmt, ...)
    if expr == true then -- dont accept truey expressions as valid
        return false
    end

    melon.Log(1, fmt, ...)
    return true
end

concommand.Add("melon_dump_logs", function()
    local str = ""

    for k,v in pairs(logs) do
        str = str ..
        "\n[" .. v.time .. "](" .. v.level .. ") " .. v.message
        str = str ..
        "\n[trace] " .. v.trace .. "\n"
    end

    file.Write("melon_lib_logs.txt", str)
    print(str)

    melon.Log(3, "Wrote logs to file!")
end)

hook.Add("ShutDown", "Melon:Logs:DumpingToFile", function()
    RunConsoleCommand("melon_dump_logs")
end )

-- Handler Definitions
local colors = {
    white = color_white,
    light_blue = Color(38, 248, 255),
    orange = Color(255,255,0),
    red = Color(255,0,0),
    green = Color(100, 255, 100)
}

-- Verbose Stuff, Basically useless nonsense
melon.AddLogHandler(3, function(msg)
    MsgC(colors.light_blue, "[MelonLib (", msg.fmt_time , ")][Message] ", colors.white, msg.message, "\n")
end)

-- Warnings
melon.AddLogHandler(2, function(msg)
    MsgC(colors.orange, "[MelonLib (", msg.fmt_time , ")][Warn] ", colors.white, msg.message, "\n")
end)

-- Errors
melon.AddLogHandler(1, function(msg)
    if CLIENT then
        ErrorNoHaltWithStack("[MelonLib][Error] " .. msg.message)
        return
    end

    MsgC(colors.red, "[MelonLib (", msg.fmt_time , ")][Error] ", colors.white, msg.message, "\n")
end)

-- Mandatory, Non-error messages
melon.AddLogHandler(0, function(msg)
    MsgC(colors.green, "[MelonLib (", msg.fmt_time , ")][Important] ", colors.white, msg.message, "\n")
end )

----
---@enumeration
---@name melon.LOG
----
---@enum (IMPORTANT) Important, green text
---@enum (ERROR) Error, red text or an actual error on the client
---@enum (WARNING) A warning
---@enum (MESSAGE) A verbose message
----
---- Log types
----
melon.LOG_IMPORTANT = 0
melon.LOG_ERROR     = 1
melon.LOG_WARNING   = 2
melon.LOG_MESSAGE   = 3