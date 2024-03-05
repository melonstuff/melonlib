
melon.sql = melon.sql or {}

----
---@name melon.sql.QueryParse
----
---@arg    (query: string) The query to parse and convert
---@arg    (escape:  func) The escape function
---@arg    (values: table) The values to be injected into the query
---@return (query: string) The converted query
----
---- Takes an input query with the placeholder `??` or `?<number>?`, eg. `SELECT * FROM ?4?`, and converts it into an escaped query
----
function melon.sql.QueryParse(query, escape, values)
    for k, v in pairs(values) do
        values[k] = escape(v)
    end

    local current = 1

    return ({string.gsub(query, "%?%d?%?", function(rep)
        if #rep == 2 then
            current = current + 1

            return values[current - 1]
        end
        
        rep = string.sub(rep, 2, -2)

        return values[tonumber(rep)]
    end )})[1]
end