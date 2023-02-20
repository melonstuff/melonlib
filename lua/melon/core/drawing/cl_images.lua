
file.CreateDir("melon")
file.CreateDir("melon/images")

melon.InvalidImage = melon.InvalidImage or Material("flags16/il.png")
local images = {}
function melon.Image(url, callback)
    if images[url] then
        if callback then callback(true, images[url]) end
        return images[url]
    end

    local sans = melon.SanitizeURL(url)
    local ext = melon.URLExtension(url)
    if file.Exists("melon/images/" .. sans .. "." .. ext , "DATA") then
        images[url] = Material("../data/melon/images/" .. sans .. "." .. ext, "mips smooth")
        if callback then callback(true, images[url]) end
        return images[url]
    end

    melon.Log(3, "Image Fetch made to {1}", "https://external-content.duckduckgo.com/iu/?u=" .. url)
    melon.http.Get("https://external-content.duckduckgo.com/iu/?u=" .. url, function(bod, size, headers, code)
        file.Write("melon/images/" .. sans .. "." .. ext, bod)
        images[url] = Material("../data/melon/images/" .. sans .. "." .. ext, "mips smooth")
        melon.Log(3, "Image Download Success: '{1}' ({2})", url, code)

        if callback then callback(true, images[url]) end
    end, function(err)
        melon.Log(1, "Image Download Failure: '{1}'", err)

        if callback then callback(false, err) end
    end )

    images[url] = melon.InvalidImage

    return images[url]
end

hook.Add("InitPostEntity", "Melon:LoadLoadingImage", function()
    melon.Image("https://i.imgur.com/635PPvg.png", function(success, mat)
        if success then
            melon.InvalidImage = mat
        else
            melon.InvalidImage = true
        end
    end )
end )

function melon.DrawImage(url, x, y, w, h)
    local mat = melon.Image(url)

    if mat == melon.InvalidImage then
        local size = math.min(w, h)
        surface.SetMaterial(mat)
        surface.SetDrawColor(255, 255, 255, 200 + math.sin(CurTime() * 2) * 30)
        surface.DrawTexturedRectRotated(x + w / 2, y + h / 2, size, size, CurTime() * 2)
        return false
    end

    surface.SetMaterial(mat)
    surface.DrawTexturedRect(x, y, w, h)
    return true
end

function melon.DrawImageRotated(url, x, y, w, h, rot)
    local mat = melon.Image(url)

    if mat == melon.InvalidImage then
        local size = math.min(w, h)
        surface.SetMaterial(mat)
        surface.SetDrawColor(255, 255, 255, 200 + math.sin(CurTime() * 2) * 30)
        surface.DrawTexturedRectRotated(x + w / 2, y + h / 2, size, size, CurTime() * 2)
        return false
    end

    surface.SetMaterial(mat)
    surface.DrawTexturedRectRotated(x, y, w, h, rot or 0)
    return true
end

local avatars = {}
function melon.GetPlayerAvatar(steamid)
    if avatars[steamid] then
        return avatars[steamid]
    end

    avatars[steamid] = melon.InvalidImage
    melon.thirdparty.getAvatarMaterial(steamid, function(mat)
        avatars[steamid] = mat
    end )

    return avatars[steamid]
end

function melon.DrawAvatar(steamid, x, y, w, h)
    local mat = melon.GetPlayerAvatar(steamid)

    if mat == melon.InvalidImage then
        local size = math.min(w, h)
        surface.SetMaterial(mat)
        surface.SetDrawColor(255, 255, 255, 200 + math.sin(CurTime() * 2) * 30)
        surface.DrawTexturedRectRotated(x + w / 2, y + h / 2, size, size, CurTime() * 2)
        return false
    end

    surface.SetMaterial(mat)
    surface.DrawTexturedRect(x, y, w, h)
    return true
end