
if SERVER then
    resource.AddSingleFile("resource/fonts/poppins_melon_lib.ttf")
    return
end

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

local specfonts = {}
function melon.SpecialFont(size, options)
    local ser = melon.QuickSerialize(options) .. "_" .. tostring(size)

    if specfonts[ser] then
        return specfonts[ser]
    end

    options.size = melon.Scale(size)

    surface.CreateFont("melon_lib:" .. ser, options)
    specfonts[ser] = "melon_lib:" .. ser

    return specfonts[ser]
end

hook.Add("OnScreenSizeChanged", "Melon:FontReset", function()
    fonts = {}
    specsize = {}
    melon.Log(3, "Refreshed Fonts")
end)

concommand.Add("melon_reload_fonts", function()
    fonts = {}
    specsize = {}
    melon.Log(3, "Refreshed Fonts")
end )