
file.CreateDir("melon")
file.CreateDir("melon/images")

local images = {}
function melon.Image(url)
    if images[url] then
        return images[url]
    end

    local sans = melon.SanitizeURL(url)
    local ext = melon.URLExtension(url)
    if file.Exists("melon/images/" .. sans .. "." .. ext , "DATA") then
        images[url] = Material("../data/melon/images/" .. sans .. "." .. ext, "mips smooth")
        return images[url]
    end

    http.Fetch("https://external-content.duckduckgo.com/iu/?u=" .. url, function(bod, size, headers, code)
        file.Write("melon/images/" .. sans .. "." .. ext, bod)
        images[url] = Material("../data/melon/images/" .. sans .. "." .. ext, "mips smooth")
        melon.Log(3, "Image Download Success: '{1}' ({2})", url, code)
    end, function(err)
        melon.Log(1, "Image Download Failure: '{1}'", err)
    end )

    images[url] = Material("flags16/il.png")

    return images[url]
end
