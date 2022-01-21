
function melon.URLExtension(url)
    local spl = string.Split(url, ".")

    return spl[#spl]
end

function melon.SanitizeURL(url)
    return ({url:gsub("%W", "")})[1]
end