
if SERVER then
    resource.AddSingleFile("resource/fonts/poppins_melon_lib.ttf")
    return
end

----
---@type function
---@name melon.Font
----
---@arg    (size: number) Font size to be scaled
---@arg    (font: string) Optional, font to base the new font off of
---@return (name: string) Font identifier
----
---- For use in 2d rendering hooks, create a font if it doesnt exist with the given size/fontname.
----
local fonts = {}
function melon.Font(size, font)
    font = font or "Poppins"
    fonts[font] = fonts[font] or {}

    if fonts[font][size] then
        return fonts[font][size]
    end

    font = font or "Poppins"
    local name = "melon_lib:" .. font .. ":" .. size
    surface.CreateFont(name, {
        font = font,
        size = melon.Scale(size)
    })

    fonts[font][size] = name

    return name
end


----
---@type function
---@name melon.SpecialFont
----
---@arg    (size: number) Font size
---@arg    (opts: table ) Options to give the font
---@return (name: string) Font identifier
----
---- Same as [melon.Font] except creates it with a [FontData] table instead of a font name.
---- Dont use in rendering hooks as it is exponentially slower
----
local specfonts = {}
function melon.SpecialFont(size, options)
    local ser = melon.QuickSerialize(options) .. "_" .. tostring(size)

    if specfonts[ser] then
        return specfonts[ser]
    end

    options.size = melon.Scale(size)

    surface.CreateFont("melon_lib:spec:" .. ser, options)
    specfonts[ser] = "melon_lib:spec:" .. ser

    return specfonts[ser]
end


----
---@type function
---@name melon.UnscaledFont
----
---@arg    (size: number) Font size raw
---@arg    (font: string) Optional, font to base the new font off of
---@return (name: string) Font identifier
----
---- Same as [melon.Font] except the size is unscale.
----
local unscaled = {}
function melon.UnscaledFont(size, font)
    font = font or "Poppins"
    unscaled[font] = unscaled[font] or {}

    if unscaled[font][size] then
        return unscaled[font][size]
    end

    font = font or "Poppins"
    local name = "melon_lib:unscaled:" .. font .. ":" .. size
    surface.CreateFont(name, {
        font = font,
        size = size
    })

    unscaled[font][size] = name

    return name
end


local gen = {}

----
---@name melon.FontGenerator
----
---@arg    (font: string) Font name for the generator to use
---@return (gen: melon.FontGeneratorObject) [melon.FontGeneratorObject] that has the given font
----
---- Creates a [melon.FontGeneratorObject], an object that allows you to use the font system to
---- consistently create fonts of the same font without constant config indexing.
----
function melon.FontGenerator(fontname)
    return setmetatable({
        font = fontname
    }, {
        __index = gen,
        __call = function(s, f) return s:Font(f) end
    })
end

----
---@type method
---@name melon.FontGeneratorObject.Font
----
---@arg    (size: number) Font size to be scaled
---@return (font: string) Font identifier
----
---- Creates a new font with the given size and font from the object
----
function gen:Font(size)
    return melon.Font(size, self.font)
end

----
---@type method
---@name melon.FontGeneratorObject.Unscaled
----
---@arg    (size: number) Font size
---@return (font: string) Font identifier
----
---- Identical to [melon.FontGeneratorObject.Font] except unscaled
----
function gen:Unscaled(size)
    return melon.UnscaledFont(size, self.font)
end

----
---@internal
---@concommand
---@name melon.melon_reload_fonts
---@realm CLIENT
----
---- Resets all fonts forcefully
----
concommand.Add("melon_reload_fonts", function()
    fonts = {}
    melon.Log(3, "Refreshed Fonts")
end )

hook.Add("OnScreenSizeChanged", "Melon:FontReset", function()
    fonts = {}
    melon.Log(3, "Refreshed Fonts")
end)