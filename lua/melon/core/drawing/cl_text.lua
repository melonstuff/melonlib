
----
---@module
---@name melon.text
---@realm CLIENT
----
---- Misc text handling functions
----

melon.text = melon.text or {}
melon.text.delimiters = melon.text.delimiters or {}

----
---@name melon.text.AddDelimiter
----
---@arg (delimiter: char) Character to count as a delimiter
----
---- Adds a delimiter for string splitting, wrapping, selection, etc
----
function melon.text.AddDelimiter(delim)
    melon.text.delimiters[delim] = true
end

local base_delims = "/\\()\"'-.,:;<>~!@#$%^&*|+=[]{}~?│ \t"
for i = 1, #base_delims do
    melon.text.AddDelimiter(base_delims[i])
end

----
---@name melon.text.Wrap
----
---@arg    (text: string) String to process
---@arg    (font: string) Font of the text
---@arg    (w:    number) Maximum width of the wrapped text
---@arg    (x:    number) Optional, Starting X pos of the text
---@arg    (notrim: bool) Optional, Dont trim the left of each line
---@return (lines: table) Table of all lines wrapped
----
---- Wraps the given text based on newlines and text width, breaks word if it cant resolve a better way. 
---- VERY SLOW, cache this result.
----
function melon.text.Wrap(text, font, w, x, notrim)
    x = x or 0

    local line = ""
    local last_delim = false
    local lines = {}

    surface.SetFont(font)
    local index = 0
    while index <= #text do
        index = index + 1
        local char = text[index]
        local tw = surface.GetTextSize(line .. char)

        if tw >= (w - x) then
            if last_delim then
                table.insert(lines, last_delim[1])
                index = last_delim[2]
                line = ""
                last_delim = false
            else
                table.insert(lines, line)
                line = char
            end

            x = 0
            continue
        elseif char == "\n" then
            table.insert(lines, line)
            line = char
            last_delim = false
            continue
        end

        line = line .. char

        if not notrim then
            line = string.TrimLeft(line)
        end

        if melon.text.delimiters[char] then
            last_delim = {
                line,
                index
            }
        end
    end

    if line != "" then
        table.insert(lines, line)
    end

    return lines
end

----
---@name melon.text.Ellipses
----
---@arg    (text:  string) Text to cut
---@arg    (font:  string) Font to scale the text with
---@arg    (w:     number) Maximum width of the text
---@return (text:  string) Cut text
----
---- Crops text and ends it with ... if it fills the given width or more.
---- VERY SLOW, cache this result.
----
function melon.text.Ellipses(text, font, w)
    surface.SetFont(font)
    local tw = surface.GetTextSize(text)
    if tw <= w then
        return text        
    end

    for i = 1, #text do
        if select(1, surface.GetTextSize(text:sub(1, i))) >= w then 
            return text:sub(1, i - 3) .. "..."
        end
    end

    return "..." -- kek
end

melon.DebugPanel("Panel", function(pnl)
    pnl:SetSize(500, 500)
    pnl:Center()

    function pnl:Paint(w, h)
        surface.SetDrawColor(22,22,22)
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(melon.colors.Rainbow())
        surface.DrawOutlinedRect(1,1,w-2,h-2)

        local font = melon.Font(22)
        local y = 10
        for k,v in pairs(melon.text.Wrap(string.rep("TextWrapTestTextWrapTestTextWr\nTextWrapTestTextWrapTestapTestTextWrapTestTextWrapTestTextWrapTestTextWrapTest", 2, " "), font, w - 20, nil)) do
            local _, th = draw.Text({
                text = v,
                pos = {10, y},
                font = font,
                xalign = 0
            })

            y = y + th
        end

        draw.Text({
            text = melon.text.Ellipses(string.rep("EllipsesTextTest", 10, ""), font, w - 20),
            pos = {w / 2, h - 10},
            xalign = 1,
            yalign = 4,
            font = font
        })
    end
end )
