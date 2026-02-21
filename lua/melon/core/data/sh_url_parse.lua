----
---@class melon.URL
----
---@accessor (name: type) Description
----
---- A URL represented by its component parts
----
local URL = {}
URL.__index = URL
melon.URL = URL

melon.AccessorFunc(URL, "HRef")
melon.AccessorFunc(URL, "Scheme")
melon.AccessorFunc(URL, "Origin")
melon.AccessorFunc(URL, "Path")
melon.AccessorFunc(URL, "PathName")
melon.AccessorFunc(URL, "Authority")
melon.AccessorFunc(URL, "Username")
melon.AccessorFunc(URL, "Password")
melon.AccessorFunc(URL, "Hostname")
melon.AccessorFunc(URL, "Host")
melon.AccessorFunc(URL, "Port")
melon.AccessorFunc(URL, "Fragment")
melon.AccessorFunc(URL, "Searches")
melon.AccessorFunc(URL, "Domain")

function URL:IsValid()
    if #self:GetDomain() < 2 then return false end

    return true
end

function URL:ParseOrigin()
    if not self.Origin then return end
    local origin = self.Origin

    self.Hostname, self.Authority = melon.str.SplitOnceX(origin, "@")
    self.Host, self.Port = melon.str.SplitOnceX(self.Hostname, ":")

    self.Domain = melon.str.Split(self.Host, ".")

    if self.Authority then
        self.Username, self.Password = melon.str.SplitOnce(self.Authority, ":")
    end
end

function URL:ParsePath()
    if not self.Path then return end

    self.PathName, self.Fragment = melon.str.SplitOnce(self.Path, "#")
    self.PathName, self.Searches = melon.str.SplitOnce(self.PathName, "?")
end

----
---@name melon.ParseURL
----
---@arg    (url: string) The URL to parse
---@return (url: melon.URL) The parsed URL object
----
---- Parses a string URL into a [melon.URL] object or nil if it failed
---- This function is slow, cache its results, also its only really designed for http/https URLs
----
function melon.ParseURL(url)
    local parts = setmetatable({}, melon.URL)

    parts:SetHRef(url)
    url, parts.Scheme = melon.str.SplitOnceX(url, "://", 1)
    parts.Origin, parts.Path = melon.str.SplitOnce(url, "/", 1)

    parts:ParseOrigin()
    parts:ParsePath()

    _p(parts)
    if IsValid(url) then return url end
end

melon.Debug(function()
    print(melon.ParseURL("https://i.imgur.com/635PPvg.png"))
end, true)
