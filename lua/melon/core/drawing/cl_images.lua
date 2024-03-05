
file.CreateDir("melon")
file.CreateDir("melon/images")

----
---@silence
---@member
---@name melon.InvalidImage
---@deprecated
----
---- Material for loading images, currently the israeli flag
----
melon.InvalidImage = melon.InvalidImage or Material("flags16/il.png")
local images = {}

----
---@name melon.Image
----
---@arg    (url:    string) URL to the image to download
---@arg    (callback: func) Function to be called when download finished/image retrieved, called with IMaterial
----
---- Remote image downloader and cache handler. Discord is unreliable, use imgur.
----
function melon.Image(url, callback)
    if images[url] then
        if callback then callback(true, images[url]) end
        return images[url]
    end

    local sans = melon.SanitizeURL(url)
    local ext = melon.URLExtension(url)
    local rext = "." .. ext

    if ext == "vtf" then
        rext = ""
    end

    if file.Exists("melon/images/" .. sans .. "." .. ext , "DATA") then
        melon.Log(3, "Image load success from filesystem '{1}.{2}'", sans, ext)

        images[url] = Material("../data/melon/images/" .. sans .. rext, "mips smooth")
        if callback then callback(true, images[url]) end
        return images[url]
    end

    melon.Log(3, "Image Fetch made to {1}", "https://external-content.duckduckgo.com/iu/?u=" .. url)
    melon.http.Get("https://external-content.duckduckgo.com/iu/?u=" .. url, function(bod, size, headers, code)
        file.Write("melon/images/" .. sans .. "." .. ext, bod)
        images[url] = Material("../data/melon/images/" .. sans .. rext, "mips smooth")
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

----
---@name melon.DrawImage
----
---@arg    (url: string) URL to the image you want to draw
---@arg    (x:   number) X of the image to draw
---@arg    (y:   number) Y of the image to draw
---@arg    (w:   number) W of the image to draw
---@arg    (h:   number) H of the image to draw
---@return (drawn: bool) If the image has been drawn or not, false if loading, true if drawn
----
---- Draw an image, handles loading and everything else for you, for use in a 2d rendering hook.
----
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

----
---@name melon.DrawImageRotated
----
---@arg    (url: string) URL to the image you want to draw
---@arg    (x:   number) X of the image to draw
---@arg    (y:   number) Y of the image to draw
---@arg    (w:   number) W of the image to draw
---@arg    (h:   number) H of the image to draw
---@arg    (rot: number) Rotation of the image to draw
---@return (drawn: bool) If the image has been drawn or not, false if loading, true if drawn
----
---- Identical to [melon.DrawImage] except draws it rotated
----
function melon.DrawImageRotated(url, x, y, w, h, rot)
    local mat = melon.Image(url)

    if mat == melon.InvalidImage then
        local size = math.min(w, h)
        surface.SetMaterial(mat)
        surface.SetDrawColor(255, 255, 255, 200 + math.sin(CurTime() * 2) * 30)
        surface.DrawTexturedRectRotated(x, y, size, size, CurTime() * 2)
        return false
    end

    surface.SetMaterial(mat)
    surface.DrawTexturedRectRotated(x, y, w, h, rot or 0)
    return true
end


local avatars = {}
----
---@internal
---@name melon.GetPlayerAvatar
----
---@arg    (stid64:    string) SteamID64 of the players avatar youd like to get
---@return (avatar: IMaterial) Material of the players avatar, unreliable, will return nil if invalid
----
---- Gets a players avatar image from the cache if it exists and initiates downloading it if not, dont use.
----
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

----
---@name melon.DrawAvatar
----
---@arg    (stid: string) SteamID64 of the player to draw the avatar of
---@arg    (x:    number) X of the image to draw
---@arg    (y:    number) Y of the image to draw
---@arg    (w:    number) W of the image to draw
---@arg    (h:    number) H of the image to draw
---@return (drawn:  bool) If the image has been drawn or not, false if loading, true if drawn
----
---- Draws a players avatar image reliably.
----
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