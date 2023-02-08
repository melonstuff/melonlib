
function melon.ParseVersion(text)
    if not text then return end

    local split = string.Split(text, ".")
    
    local major = tonumber(split[1])
    local minor = tonumber(split[2])
    local patch = tonumber(split[3])

    if not major or not minor or not patch then return end

    return {
        major = major,
        minor = minor,
        patch = patch,
    }
end

melon.UpdateLog = melon.AddDynamicLogHandler(function(msg)
    MsgC(Color(162, 0, 255), "[MelonLib][Update(" .. melon.version .. ")] ", color_white, msg.message, "\n")
end )

melon.Log(melon.UpdateLog, "Checking for updates")

local url = "https://raw.githubusercontent.com/garryspins/melonlib/main/lua/autorun/sh_melon_lib_init.lua"
melon.http.Get(url, function(bod)
    local ver_text = string.gmatch(bod, "melon.version = \"([^\"]+)")()
    local v = melon.ParseVersion(
        ver_text
    )
    local ov = melon.ParseVersion(melon.version)

    if not v then
        melon.Log(melon.UpdateLog, "Could not find a valid version from the given text ({1})", ver_text)
        melon.Log(1, "Read previous error regarding Updating")
        return
    end

    if v.major > ov.major then
        melon.Log(melon.UpdateLog, "New release update found, please update ASAP (-> {1})", ver_text)
    end

    if v.minor > ov.minor then
        melon.Log(melon.UpdateLog, "New feature update found, update whenever you can (-> {1})", ver_text)
    end

    if v.patch > ov.patch then
        melon.Log(melon.UpdateLog, "New patch update found, update only if needed (-> {1})", ver_text)
    end

    melon.Log(melon.UpdateLog, "Youre all up to date!", melon.version)
end, function()
    melon.Log(melon.UpdateLog, "Couldnt connect to github repository to find newer version ({1}), please report issue", url)
    melon.Log(1, "Read previous error regarding Updating")
end )