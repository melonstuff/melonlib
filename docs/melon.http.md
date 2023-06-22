# melon.http
HTTP wrapper that runs http requests when available

# Functions
## melon.http.Generator(type: string) @ internal
Generates a new function to create a request of the given type
1. type: string - Type of HTTP request, POST, HEAD, GET, ect

## melon.http.Get(url: string, onsuccess: func, onfailure: func, headers: table) 
Make a GET request with melon.HTTP
1. url: string - URL to make the request to
2. onsuccess: func - Callback to run on success, gets same as http.Post
3. onfailure: func - Callback to run on failure, gets same as http.Post
4. headers: table - URL to make the request to

## melon.http.Head(url: string, onsuccess: func, onfailure: func, headers: table) 
Make a HEAD request with melon.HTTP
1. url: string - URL to make the request to
2. onsuccess: func - Callback to run on success, gets same as http.Post
3. onfailure: func - Callback to run on failure, gets same as http.Post
4. headers: table - URL to make the request to

## melon.http.Post(url: string, onsuccess: func, onfailure: func, headers: table) 
Make a POST request with melon.HTTP
1. url: string - URL to make the request to
2. onsuccess: func - Callback to run on success, gets same as http.Post
3. onfailure: func - Callback to run on failure, gets same as http.Post
4. headers: table - URL to make the request to

