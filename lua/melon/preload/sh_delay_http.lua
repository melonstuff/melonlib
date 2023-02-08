
melon.http = {}
local requests = {}

function melon.HTTP(h)
    if not requests then
        return HTTP(h)
    end

    table.insert(requests, h)
end

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
    
        HTTP(request)
    end
end

melon.http.Post = melon.http.Generator("post")
melon.http.Get = melon.http.Generator("get")
melon.http.Head = melon.http.Generator("head")

hook.Add("InitPostEntity", "Melon:HTTPReady", function()
    for k,v in pairs(requests) do
        HTTP(v)
    end

    requests = false
end )