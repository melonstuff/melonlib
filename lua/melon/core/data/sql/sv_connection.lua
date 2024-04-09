
----
---@realm SERVER
---@name melon.sql
----
---- Contains everything needed to interact with multiple SQL drivers
----
melon.sql = melon.sql or {}

----
---@name melon.sql.NewConnection
----
---@return (conn: melon.sql.Connection) The connection object
----
---- Creates a new connection object
----
function melon.sql.NewConnection()
    return setmetatable({}, melon.sql.Connection):Init()
end

----
---@class melon.sql.Connection
----
---@accessor (SupportedAdapters: table) A table of adapters each query is required to support
---@accessor (Adapter:  string) The connections adapter, what kind of sql variant its using
---@accessor (Host:     string) The remote host of this connection, if applicable
---@accessor (Username: string) The remote username of this connection, if applicable
---@accessor (Password: string) The password of this connection, if applicable
---@accessor (Database: string) The database of this connection, if applicable
---@accessor (Port:     string) The port of this connection, if applicable
----
---- The central SQL connection that handles I/O
----
melon.sql.Connection = {}
melon.sql.Connection.__index = melon.sql.Connection

melon.AccessorFunc(melon.sql.Connection, "SupportedAdapters", {"sqlite", "mysqloo"})
melon.AccessorFunc(melon.sql.Connection, "Adapter", "sqlite")
melon.AccessorFunc(melon.sql.Connection, "Host")
melon.AccessorFunc(melon.sql.Connection, "Username")
melon.AccessorFunc(melon.sql.Connection, "Password")
melon.AccessorFunc(melon.sql.Connection, "Database")
melon.AccessorFunc(melon.sql.Connection, "Port")

function melon.sql.Connection:Init()
    return self
end

----
---@method
---@name melon.sql.Connection:Connect
----
---- Attempts to connect to the sql server, if applicable
----
function melon.sql.Connection:Connect()
    local adapter = melon.sql.Adapters[self:GetAdapter()]

    if not adapter then
        melon.Log(1, "[sql] Invalid adapter {}", self:GetAdapter())

        return false
    end

    if adapter.Connect(self) != false then
        return melon.Log(3, "[sql] Successfully connected on adapter {}", self:GetAdapter())
    end
end

----
---@method
---@name melon.sql.Connection:Query
----
---@arg    (done:      func) The function to call with the output values when finished
---@arg    (adapters: table) A table of adapter keys with query values
---@arg    (...values:  any) Varargs of values to be escaped in those queries
---@return (passed:    bool) Did the query get validated successfully? 
----
---- Sends a query to the connection and calls done with whatever the query returned
----
function melon.sql.Connection:Query(done, adapters, ...)
    local failure = false

    for k, v in pairs(self:GetSupportedAdapters()) do
        if not adapters[v] then
            melon.Log(1, "[sql] Missing required query for adapter '{}', please add it on line {}", v, debug.getinfo(2, "l").currentline)
            failure = true
        end
    end

    if failure then return false end

    local adapter = melon.sql.Adapters[self:GetAdapter()]
    if not adapter then
        melon.Log(1, "[sql] Invalid adapter {}", self:GetAdapter())

        return false
    end

    adapter.Query(
        self,
        done,
        melon.sql.QueryParse(
            adapters[self:GetAdapter()],
            function(val)
                return adapter.Escape(self, val)
            end,
            {...}
        )
    )
end

----
---@method
---@name melon.sql.Connection:QueryNoResult
----
---@arg    (adapters: table) A table of adapter keys with query values
---@arg    (...values:  any) Varargs of values to be escaped in those queries
---@return (passed:    bool) Did the query get validated successfully? 
----
---- Sends a query to the connection
----
function melon.sql.Connection:QueryNoResult(adapters, ...)
    return self:Query(function() end, adapters, ...)
end

melon.Debug(function()
    local conn = melon.sql.NewConnection()

    conn:SetAdapter("mysqloo")

    conn:SetHost("localhost")
    conn:SetUsername("root")
    conn:SetPassword("")
    conn:SetDatabase("goobles")

    conn:Connect()

    conn:Query(function(data)
        _p(data)
    end, {
        sqlite  = "select * from ?2? where steamid='?1?'",
        mysqloo = "select * from ?2? where steamid='?1?'"
    }, "76561198009689185", "achievements")
end, true)