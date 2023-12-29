
if SERVER then
    resource.AddWorkshop("2631771632")
    return
end

----
---@silence
---@name melon.Font
----
---@arg    (size:   number) Font size to be scaled
---@arg    (font:   string) Optional, font to base the new font off of
---@arg    (weight: number) Optional, font weight
---@return (name:   string) Font identifier
----
---- For use in 2d rendering hooks, create a font if it doesnt exist with the given size/fontname.
----
local fonts = {}
function melon.Font(size, font, weight)
    font = font or "Poppins"
    fonts[font] = fonts[font] or {}

    local id = size .. (weight or "normal")
    if fonts[font][id] then
        return fonts[font][id]
    end

    font = font or "Poppins"
    local name = "melon_lib:" .. font .. ":" .. id
    surface.CreateFont(name, {
        font = font,
        size = melon.Scale(size),
        weight = weight
    })

    fonts[font][id] = name

    return name
end

----
---@silence
---@name melon.SpecialFont
----
---@arg    (size: number) Font size
---@arg    (opts:  table) Options to give the font
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
---@silence
---@name melon.UnscaledFont
----
---@arg    (size: number) Font size raw
---@arg    (font: string) Optional, font to base the new font off of
---@return (name: string) Font identifier
----
---- Same as [melon.Font] except the size is unscale.
----
local unscaled = {}
function melon.UnscaledFont(size, font, weight)
    font = font or "Poppins"
    unscaled[font] = unscaled[font] or {}

    local id = size .. (weight or "normal")
    if unscaled[font][id] then
        return unscaled[font][id]
    end

    font = font or "Poppins"
    local name = "melon_lib:unscaled:" .. font .. ":" .. id
    surface.CreateFont(name, {
        font = font,
        size = size,
        weight = weight
    })

    unscaled[font][id] = name

    return name
end

----
---@class
---@name melon.FontGeneratorObject
----
---- Font Generator Object
----
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
        __call = function(s, ...) return s:Font(...) end
    })
end

----
---@method
---@name melon.FontGeneratorObject.Font
----
---@arg    (size:   number) Font size to be scaled
---@arg    (weight: number) Font weight
---@return (font:   string) Font identifier
----
---- Creates a new font with the given size and font from the object
----
function gen:Font(size, weight)
    return melon.Font(self:Preprocess(size, self.font, weight))
end

----
---@method
---@name melon.FontGeneratorObject.Unscaled
----
---@arg    (size:   number) Font size
---@arg    (weight: number) Font weight
---@return (font:   string) Font identifier
----
---- Identical to [melon.FontGeneratorObject.Font] except unscaled
----
function gen:Unscaled(size, weight)
    return melon.UnscaledFont(self:Preprocess(size, self.font, weight))
end

----
---@method
---@name melon.FontGeneratorObject.Preprocess
----
---@arg    (size:   number) Size of the wanted font
---@arg    (font:   string) Font of the wanted font
---@arg    (weight: number) Weight of the wanted font
---@return (size:   number) New size of the wanted font
---@return (weight: number) New font of the wanted font
---@return (font:   string) New weight of the wanted font
----
---- Called every time a font is wanted  
---- This is to be used to adjust font sizes globally, or whatever else you need
----
function gen:Preprocess(size, font, weight)
    return size, font, weight
end

----
---@internal 
---@concommand melon_reload_fonts
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