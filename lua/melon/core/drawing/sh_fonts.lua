
if SERVER then
    resource.AddSingleFile("resource/fonts/poppins_melon_lib.ttf")
    return
end

local fonts = {}
function melon.Font(size)
    if fonts[size] then
        return fonts[size]
    end

    surface.CreateFont("melon_lib:" .. tostring(size), {
        font = "Poppins",
        size = melon.Scale(size)
    })

    fonts[size] = "melon_lib:" .. tostring(size)

    return fonts[size]
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
    melon.Log(3, "Refreshed Fonts", fold)
end)