
----
---@internal
---@name melon.URLExtension
----
---@arg    (url: string) URL to get the file extension of
---@return (ext: string) Extension of the URL given
----
---- Gets the extension of a url, relic of the ancient past, dont use.
----
function melon.URLExtension(url)
    local spl = string.Split(url, ".")

    return spl[#spl]
end

----
---@name melon.SanitizeURL
----
---@arg    (url: string) URL to sanitize
---@return (new: string) Sanitized URL
----
---- Sanitize a URL for use in filenames, literally only allows alpha characters
----
function melon.SanitizeURL(url)
    return ({url:gsub("%W", "")})[1]
end