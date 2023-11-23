
----
---@module
---@name melon.http
----
---- HTTP wrapper that runs http requests when available
----
melon.http = {}
local requests = {}

----
---@name melon.HTTP
----
---@arg    (data: table) [HTTPRequest] data to execute with
----
---- Queues an HTTP request to run whenever available
----
function melon.HTTP(h)
    if not requests then
        return HTTP(h)
    end

    table.insert(requests, h)
end

----
---@internal
---@name melon.http.Generator
----
---@arg    (type: string) Type of HTTP request, POST, HEAD, GET, ect
---@return (func:   func) Function that calls the given request using [melon.HTTP]
----
---- Generates a new function to create a request of the given type
----
function melon.http.Generator(type)
    return function(url, onsuccess, onfailure, header)
        local request = {
            url = url,
            method = type,
            headers = header or {},
    
            success = function(code, body, headers)
                if not onsuccess then return end
                onsuccess(body, body:len(), headers, code)
            end,
    
            failed = function(err)
                if not onfailure then return end
    
                onfailure(err)
            end
        }
    
        melon.HTTP(request)
    end
end

----
---@silence
---@type function
---@name melon.http.Post
----
---@arg    (url:     string) URL to make the request to
---@arg    (onsuccess: func) Callback to run on success, gets same as http.Post
---@arg    (onfailure: func) Callback to run on failure, gets same as http.Post
---@arg    (headers:  table) URL to make the request to
----
---- Make a POST request with melon.HTTP
----
melon.http.Post = melon.http.Generator("post")

----
---@silence
---@type function
---@name melon.http.Get
----
---@arg    (url:     string) URL to make the request to
---@arg    (onsuccess: func) Callback to run on success, gets same as http.Post
---@arg    (onfailure: func) Callback to run on failure, gets same as http.Post
---@arg    (headers:  table) URL to make the request to
----
---- Make a GET request with melon.HTTP
----
melon.http.Get = melon.http.Generator("get")

----
---@silence
---@type function
---@name melon.http.Head
----
---@arg    (url:     string) URL to make the request to
---@arg    (onsuccess: func) Callback to run on success, gets same as http.Post
---@arg    (onfailure: func) Callback to run on failure, gets same as http.Post
---@arg    (headers:  table) URL to make the request to
----
---- Make a HEAD request with melon.HTTP
----
melon.http.Head = melon.http.Generator("head")

hook.Add("Think", "Melon:HTTPReady", function()
    for k,v in pairs(requests) do
        HTTP(v)
    end

    requests = false

    hook.Remove("Think", "Melon:HTTPReady")
end )