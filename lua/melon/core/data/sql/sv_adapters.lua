
melon.sql = melon.sql or {}

----
---@member
---@name melon.sql.Adapters
----
---- A table of all created sql adapters
----
melon.sql.Adapters = melon.sql.Adapters or {}

do --- sqlite
    melon.sql.Adapters.sqlite = {}

    function melon.sql.Adapters.sqlite:Connect() end

    function melon.sql.Adapters.sqlite:Query(done, query)
        local q = sql.Query(query)

        if q == false then
            return melon.sql.Adapters.sqlite.Error()
        end

        done(melon.sql.Adapters.sqlite.SortOutput(self, query, q))
    end

    function melon.sql.Adapters.sqlite:Error()
        melon.Log(1, "[sqlite] Error occurred ({})", sql.LastError())
    end
    
    function melon.sql.Adapters.sqlite:Escape(value)
        return isstring(value) and sql.SQLStr(value, true) or value
    end

    function melon.sql.Adapters.sqlite:SortOutput(query, output)
        return output
    end
end

do --- mysqloo
    melon.sql.Adapters.mysqloo = {}
    
    function melon.sql.Adapters.mysqloo:Connect()
        if not mysqloo and not util.IsBinaryModuleInstalled("mysqloo") then
            melon.Log(1, "[mysqloo] Failed to use mysqloo module, are you sure you installed the correct version? ")
            return false
        elseif not mysqloo then
            require("mysqloo")
        end

        if not self:GetHost()     then melon.Log(1, "[mysqloo] Expected Host, Use Connection:SetHost(...)")         return false end
        if not self:GetUsername() then melon.Log(1, "[mysqloo] Expected Username, Use Connection:SetUsername(...)") return false end
        if not self:GetPassword() then melon.Log(1, "[mysqloo] Expected Password, Use Connection:SetPassword(...)") return false end
        if not self:GetDatabase() then melon.Log(1, "[mysqloo] Expected Database, Use Connection:SetDatabase(...)") return false end

        self.InternalMysqlooConnection = mysqloo.connect(
            self:GetHost(),
            self:GetUsername(),
            self:GetPassword(),
            self:GetDatabase(),
            self:GetPort()
        )

        function self.InternalMysqlooConnection.onConnectionFailed(_, err)
            melon.sql.Adapters.mysqloo.Error(self, "Connection Failed! " .. err)
        end

        self.InternalMysqlooConnection:setAutoReconnect(true)
        self.InternalMysqlooConnection:setMultiStatements(false)
        self.InternalMysqlooConnection:connect()

        return true
    end

    function melon.sql.Adapters.mysqloo:Error(message)
        return melon.Log(1, "[mysqloo] An error occurred, {}", message)
    end

    function melon.sql.Adapters.mysqloo:Query(done, query)
        if not (self.InternalMysqlooConnection:status() == mysqloo.DATABASE_CONNECTED) then
            return self:Error("Mysqloo not connected")
        end

        local q = self.InternalMysqlooConnection:query(query)

        function q.onError(_, err, cause)
            self:Error("Query failed (" .. err .. ") from `" .. cause .. "`")
        end

        function q.onSuccess(_, data)
            done(melon.sql.Adapters.mysqloo.SortOutput(self, query, data))
        end
        
        q:start()
    end
    
    function melon.sql.Adapters.mysqloo:Escape(value)
        return self.InternalMysqlooConnection:escape(tostring(value))
    end

    function melon.sql.Adapters.mysqloo:SortOutput(query, output)
        return output
    end
end