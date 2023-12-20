
melon.net = melon.net or {}
melon.net.schemas = melon.net.schemas or {}

melon.net.Watch("melon", "ProcessSchemas", function(_, ply)
    local identifier = net.ReadString()
    if not identifier then return end
    
    local s = melon.net.schemas[identifier]
    if not s then return melon.Log(1, "Invalid NetSchema Identifier Sent! {1}", identifier) end


    local recv = s.ReceiveOn
    if recv != melon.net.RECV_ON_SHARED then
        if (recv == melon.net.RECV_ON_SERVER) and CLIENT then
            melon.Log(1, "RECV_ON_SERVER being sent to client ({1})", identifier)
            return false
        end

        if (recv == melon.net.RECV_ON_CLIENT) and SERVER then
            melon.Log(1, "RECV_ON_CLIENT being sent to server ({1}) by ({2}), THIS PROBABLY MEANS THIS USER IS EXPLOITING!!!!!", identifier, ply)
            return false
        end
    end

    local data = s:Read()
    if not data then return end

----
---@hook Melon:NetSchema:Recv
----
---@arg    (data: table) The data sent over the net message
---@arg    (ply: Player) If SERVER, then the player that sent it, otherwise nil
---@return (skip:  bool) If true, skip calling recv on the schema object
----
---- Called when a NetSchema message is sent
----

    if hook.Run("Melon:NetSchema:Recv:" .. identifier, data, ply) then
        return true
    end

    s.Recv(data, ply, s)

    return true
end )

----
---@name melon.net.Schema
----
---@arg    (identifier:       string) String identifier for the schema
---@return (obj: melon.net.SchemaObj) The schema object
----
---- Creates a new schema object
----
---`
---` ---- Creates and registers the schema
---` local schema = melon.net.Schema("unique_name")
---`     --- Contains a string
---`     :Value ("SomeString",  melon.net.TYPE_STRING)
---`     
---`     ---- And another schema
---`     :Schema("SomeSchema", "some_other_schema") 
---` 
---` --- Called when the schema message gets recieved
---` function schema:Recv(sender)
---`     print(self.SomeString) -- "hi!"
---`     print(self.SomeSchema.TestString) -- "hello!"
---`     print(self.SomeSchema.TestInteger) -- nil
---` end
---` 
---` --- Registers another schema
---` melon.net.Schema("some_other_schema")
---`     --- Contains another string
---`     :Value("TestString",  melon.net.TYPE_STRING)
---` 
---`     --- Contains an optional integer
---`     :Value("TestInteger", melon.net.TYPE_INTEGER, true)
---` 
---` --- Due to this being used as a sub-schema, it does not need a recv assigned to it
---` 
---` schema:Send({
---`     SomeString = "hi!",
---`     SomeSchema = {
---`         TestString = "hello!",
---`         --- Omitting TestInteger
---`     }
---` }, player) --- Sending to `player`, if youre sending to the server from the client this can be omitted
---` 
function melon.net.Schema(name)
    return setmetatable({}, melon.net.SchemaObj):Init(name)
end

----
---@name melon.net.SchemaFromTable
----
---@arg    (name:             string) Name of the schema to be registered as
---@arg    (tbl:               table) Table to make a schema out of
---@arg    (done:              table) Table of already created schemas to avoid infinite recursion
---@return (obj: melon.net.SchemaObj) The schema object
----
---- Makes a schema from the given table with the types of values given
---- Generates nested schemas for you, but not arrays
---- Due to this features immediate use case, every value is optional by default
----
function melon.net.SchemaFromTable(name, tbl, done)
    done = done or {}

    if done[tbl] then
        return done[tbl]
    end

    if a then
        return
    end

    local schema = melon.net.Schema(name)
    done[tbl] = schema

    for k,v in pairs(tbl) do
        if not isstring(k) then continue end
        
        local t = melon.net.TypeConversions[TypeID(v)]

        if t then
            schema:Value(k, t, true)
            continue
        end

        if istable(v) and not table.IsSequential(v) then
            melon.net.SchemaFromTable(name .. ":" .. k, v, done)

            schema:Schema(k, name .. ":" .. k, true)
        end
    end

    return schema
end

----
---@enumeration
---@name melon.net.RECV_ON
----
---@enum (CLIENT) Recieve on the client
---@enum (SERVER) Recieve on the server
---@enum (SHARED) Recieve from both
----
melon.net.RECV_ON_CLIENT = 1
melon.net.RECV_ON_SERVER = 2
melon.net.RECV_ON_SHARED = 3

----
---@enumeration
---@name melon.net.TYPE
----
---@enum (STRING)  String
---@enum (INTEGER) I32
---@enum (FLOAT)   Double
---@enum (ENUM)    U8
---@enum (BOOL)    Boolean
---@enum (ANGLE)   Angle
---@enum (VECTOR)  Vector
---@enum (ENTITY)  Entity
---@enum (PLAYER)  Player (sent via UserID)
---@enum (SCHEMA)  Another NetSchema
---@enum (ARRAY)   An array of primitives
----
melon.net.TYPE_STRING   = "STRING"
melon.net.TYPE_INTEGER  = "INTEGER"
melon.net.TYPE_FLOAT    = "FLOAT"
melon.net.TYPE_ENUM     = "ENUM"
melon.net.TYPE_BOOL     = "BOOL"
melon.net.TYPE_ANGLE    = "ANGLE"
melon.net.TYPE_VECTOR   = "VECTOR"
melon.net.TYPE_ENTITY   = "ENTITY"
melon.net.TYPE_PLAYER   = "PLAYER"
melon.net.TYPE_SCHEMA   = "SCHEMA"
melon.net.TYPE_ARRAY    = "ARRAY"

melon.net.TypeConversions = {
    [TYPE_STRING] = melon.net.TYPE_STRING,
    [TYPE_NUMBER] = melon.net.TYPE_FLOAT,
    [TYPE_BOOL]   = melon.net.TYPE_BOOL,
    [TYPE_ANGLE]  = melon.net.TYPE_ANGLE,
    [TYPE_VECTOR] = melon.net.TYPE_VECTOR,
    [TYPE_ENTITY] = melon.net.TYPE_ENTITY,
}

----
---@class
---@name melon.net.SchemaObj
----
---@accessor (Identifier: string) String identifier for this message
----
---- Net Schema Object
----
local NETSCHEMA = {}
NETSCHEMA.__index = NETSCHEMA
melon.net.SchemaObj = NETSCHEMA

AccessorFunc(NETSCHEMA, "Identifier", "Identifier", FORCE_STRING)

melon.net.SchemaObj.ArrayTypes = {
    [melon.net.TYPE_STRING]  = true,
    [melon.net.TYPE_INTEGER] = true,
    [melon.net.TYPE_FLOAT]   = true,
    [melon.net.TYPE_ENUM]    = true,
    [melon.net.TYPE_BOOL]    = true,
    [melon.net.TYPE_ANGLE]   = true,
    [melon.net.TYPE_VECTOR]  = true,
    [melon.net.TYPE_ENTITY]  = true,
    [melon.net.TYPE_PLAYER]  = true,
}

----
---@method
---@name melon.net.SchemaObj.Recv
----
---@arg (data:    table) The data recieved
---@arg (sender: Player) If on the server then this is the player that sent the message
---@arg (obj: SchemaObj) The SchemaObj
----
---- Function to call when recieving data
---- You should treat this like a method even though it isnt really one, as seen in the example
----
function melon.net.SchemaObj:Recv(player, obj)
    melon.Log(1, "Unhandled NetSchema message for '{1}'", obj:GetIdentifier())
end

----
---@method
---@name melon.net.SchemaObj.RecvOn
----
---@arg    (on: melon.net.RECV_ON_) Where to allow recieving from
---@return (self:             self) The SchemaObj
----
---- This is set to recv on CLIENT by default, you need to switch this in order to be
---- able to recieve on server.
---- This is here to prevent abuse where the client can send large schemas over the network
---- and the server has to sit there and take it, just to reject it later
----
function melon.net.SchemaObj:RecvOn(on)
    self.ReceiveOn = on
    return self
end

----
---@internal
---@method
---@name melon.net.SchemaObj.Init
----
---- Internal initialization for a Schema Object
----
function melon.net.SchemaObj:Init(name)
    ---
    --- Ordered tables containing {name, type, optional, type_specific}
    --- The type_specific value is just for anything that the type needs, like a schema id
    ---
    self.keys = {}

    self.ordered_keys = {}

    self:SetIdentifier(name)
    melon.net.schemas[name] = self

    self:RecvOn(melon.net.RECV_ON_CLIENT)

    return self
end

----
---@internal
---@method
---@name melon.net.SchemaObj.Add
----
function melon.net.SchemaObj:Add(name, t)
    self.ordered_keys[name] = (self.ordered_keys[name] or #self.keys) + 1
    table.insert(self.keys, self.ordered_keys[name], t)
end

----
---@method
---@name melon.net.SchemaObj.Value
----
---@arg    (name:          string) Keyname of the value
---@arg    (type: melon.net.TYPE_) Type of the value
---@arg    (optional:        bool) Is this value optional?
---@return (self:            self) The SchemaObj
----
---- Adds a value row to the schema
----
function melon.net.SchemaObj:Value(name, type, optional)
    self:Add(name, {name, type, optional})

    return self
end

----
---@method
---@name melon.net.SchemaObj.Schema
----
---@arg    (name:       string) Keyname of the schema
---@arg    (identifier: string) Identifier for the schema thats registered in melon.net.schemas
---@arg    (optional:     bool) Is this schema optional?
---@return (self:         self) The SchemaObj
----
---- Adds a schema row to the schema, used to send nested schemas
----
function melon.net.SchemaObj:Schema(name, identifier, optional)
    if identifier == self:GetIdentifier() then
        return self
    end

    self:Add(name, {name, melon.net.TYPE_SCHEMA, optional, identifier})

    return self
end

----
---@method
---@name melon.net.SchemaObj.Array
----
---@arg    (name:          string) Keyname of the array
---@arg    (type: melon.net.TYPE_) Type enum of the data being sent
---@arg    (optional:        bool) Is this array optional?
---@return (self:            self) The SchemaObj
----
---- Adds an array to the schema, which sends a sequental table of allowed types
---- Tables are always scrubbed for server safety
----
function melon.net.SchemaObj:Array(name, type, optional)
    if not self.ArrayTypes[type] then
        melon.Log(1, "Attempting to add an array to schema '{1}' with an invalid type of '{2}' ({3})", self:GetIdentifier(), type, name)
        return self
    end

    self:Add(name, {name, melon.net.TYPE_ARRAY, optional, type})

    return self
end

----
---@method
---@name melon.net.SchemaObj.Validate
----
---@arg    (args: table) Table to validate if it meets the schema or not
---@return (does:  bool) Does this table match the schema?
---@return (key: number) If not valid, key of the bad value
---@return (value:  any) If not valid, the invalid schema name
----
---- Is the argument table provided valid to this schema
----
function melon.net.SchemaObj:Validate(tbl)
    if not istable(tbl) then return false end

    for k, v in pairs(self.keys) do
        local valid, dk, dv = self:ValidateValue(v, tbl[v[1]])
        if not valid then
            return false, dk or self.keys[k][1], dv or self:GetIdentifier()
        end
    end

    return true
end

----
---@internal
---@method
---@name melon.net.SchemaObj.ValidateValue
----
function melon.net.SchemaObj:ValidateValue(v, value)
    local t = v[2]

    if value == nil then
        return v[3]
    end

    if t == melon.net.TYPE_STRING then
        return isstring(value)
    end

    if t == melon.net.TYPE_INTEGER then
        return isnumber(value) and (math.floor(value) == value)
    end

    if t == melon.net.TYPE_FLOAT then
        return isnumber(value)
    end

    if t == melon.net.TYPE_ENUM then
        return isnumber(value) and (math.floor(value) == value) and (value <= 255)
    end

    if t == melon.net.TYPE_BOOL then
        return (value == true) or (value == false)
    end

    if t == melon.net.TYPE_ANGLE then
        return isangle(value)
    end

    if t == melon.net.TYPE_VECTOR then
        return isvector(value)
    end

    if t == melon.net.TYPE_ENTITY then
        return IsEntity(value) and (value != NULL)
    end

    if t == melon.net.TYPE_PLAYER then
        return IsEntity(value) and (value != NULL) and value:IsPlayer()
    end

    if t == melon.net.TYPE_SCHEMA and v[4] then
        local ns = melon.net.schemas[v[4]]
        if not ns then return false end

        local valid, dk, dv = ns:Validate(value)
        return valid, dk, dv or ns:GetIdentifier()
    end

    if t == melon.net.TYPE_ARRAY and v[4] then
        if not istable(value) then return false end

        for k, val in ipairs(value) do
            if val == value then return false end
            
            if self:ValidateValue({
                nil, v[4], false, false
            }, val) then continue end

            return false
        end

        return true
    end

    return false
end

----
---@method
---@name melon.net.SchemaObj.Send
----
---@arg    (tbl:       table) Table to write 
---@arg    (to: Player|table) A table of players or a player, accepts what net.Send does, doesn't matter on the client since it uses net.SendToServer.
---@return (success:    bool) Was the write successful?
----
---- Starts the `melon` net message and sends the schema
---- Writes the actual net.Write* calls to the netbuffer
----
function melon.net.SchemaObj:Send(tbl, to)
    local valid, badk, badi = self:Validate(tbl)

    if not valid then
        melon.Log(1, "Failed to write schema object key '{1}' for '{2}'", badk, badi)
        return false
    end

    local started_this
    if not melon.net.started then
        started_this = true
        melon.net.started = true

        net.Start("melon")

        net.WriteString(self:GetIdentifier())
    end

    for k,v in ipairs(self.keys) do
        local value = tbl[v[1]]

        if v[3] then
            net.WriteBool(value != nil)

            if value == nil then
                continue
            end
        end

        self:WriteValue(v[2], value, v)
    end

    if started_this then
        if SERVER then
            net.Send(to)
        else
            net.SendToServer()
        end

        melon.net.started = false
    end

    return true
end

----
---@internal
---@method
---@name melon.net.SchemaObj.WriteValue
----
function melon.net.SchemaObj:WriteValue(t, value, v)
    if t == melon.net.TYPE_STRING then
        return net.WriteString(value)
    end

    if t == melon.net.TYPE_INTEGER then
        return net.WriteUInt(value, 32)
    end

    if t == melon.net.TYPE_FLOAT then
        return net.WriteDouble(value)
    end

    if t == melon.net.TYPE_ENUM then
        return net.WriteUInt(value, 8)
    end

    if t == melon.net.TYPE_BOOL then
        return net.WriteBool(value)
    end
    
    if t == melon.net.TYPE_ANGLE then
        return net.WriteAngle(value)
    end

    if t == melon.net.TYPE_VECTOR then
        return net.WriteVector(value)
    end

    if t == melon.net.TYPE_ENTITY then
        return net.WriteEntity(value)
    end

    if t == melon.net.TYPE_PLAYER then
        return net.WriteInt(value:UserID(), 16)
    end

    if t == melon.net.TYPE_SCHEMA then
        return melon.net.schemas[v[4]]:Send(value)
    end
    
    if t == melon.net.TYPE_ARRAY then
        net.WriteUInt(#value, 16)

        for k, val in ipairs(value) do
            self:WriteValue(v[4], val, val)
        end

        return
    end
end

----
---@method
---@name melon.net.SchemaObj.Read
----
---@return (tbl: table) The read schema table
----
---- Reads the schema table from the net message
----
function melon.net.SchemaObj:Read()
    local t = {}

    for k,v in ipairs(self.keys) do
        if v[3] and not net.ReadBool() then
            continue
        end

        t[v[1]] = self:ReadValue(v)
    end

    return t
end

----
---@internal
---@method
---@name melon.net.SchemaObj.ReadValue
----
function melon.net.SchemaObj:ReadValue(v, ty)
    local t = ty or v[2]

    if t == melon.net.TYPE_STRING then
        return net.ReadString()
    end

    if t == melon.net.TYPE_INTEGER then
        return net.ReadInt(32)
    end

    if t == melon.net.TYPE_FLOAT then
        return net.ReadDouble()
    end

    if t == melon.net.TYPE_ENUM then
        return net.ReadUInt(8)
    end

    if t == melon.net.TYPE_BOOL then
        return net.ReadBool()
    end

    if t == melon.net.TYPE_ANGLE then
        return net.ReadAngle()
    end

    if t == melon.net.TYPE_VECTOR then
        return net.ReadVector()
    end

    if t == melon.net.TYPE_ENTITY then
        return net.ReadEntity()
    end

    if t == melon.net.TYPE_PLAYER then
        return Player(net.ReadUInt(16))
    end

    if t == melon.net.TYPE_SCHEMA then
        return melon.net.schemas[v[4]]:Read()
    end

    if t == melon.net.TYPE_ARRAY then
        local array = {}
        local to = net.ReadUInt(16)

        for i = 1, to do
            array[i] = self:ReadValue(nil, v[4])
        end

        return array
    end
end

melon.Debug(function()
    local t = melon.net.Schema("test")
        :Value ("TestString",  melon.net.TYPE_STRING)
        :Value ("TestInteger", melon.net.TYPE_INTEGER)
        :Value ("TestFloat",   melon.net.TYPE_FLOAT)
        :Value ("TestBool",    melon.net.TYPE_BOOL)
        :Value ("TestAngle",   melon.net.TYPE_ANGLE)
        :Value ("TestVector",  melon.net.TYPE_VECTOR)
        :Value ("TestEntity",  melon.net.TYPE_ENTITY)
        :Value ("TestPlayer",  melon.net.TYPE_PLAYER)
        :Schema("TestSchema", "inner_test")
        :Array ("TestArray",  melon.net.TYPE_STRING)

    function t:Recv(sender)
        _p(self, sender)
    end

    melon.net.Schema("inner_test")
        :Value("InnerTestString",  melon.net.TYPE_STRING)
        :Value("InnerTestInteger", melon.net.TYPE_INTEGER)
        :Schema("InnerTestSchema", "inner_test_inner")

    melon.net.Schema("inner_test_inner")
        :Value("InnerInnerTestString",  melon.net.TYPE_STRING)

    if CLIENT then
        print("Waiting for net message...")
        return
    end

    --- This timer is important because the net message gets sent before the updated lua file does
    --- Meaning that the original, pre-modified net Recv will be called, instead of the new on the client
    timer.Simple(1, function()
        t:Send({
            TestString = "This is a test string",
            TestInteger = 123,
            TestFloat = 123.456,
            TestBool = true,
            TestAngle = Angle(6, 9, 1),
            TestVector = Vector(256, 256, 0),
            TestEntity = melon.DebugPlayer(),
            TestPlayer = melon.DebugPlayer(),
            TestSchema = {
                InnerTestString = "asd",
                InnerTestInteger = 123,
                InnerTestSchema = {
                    InnerInnerTestString = "Test String"
                }
            },
            TestArray = {
                "ass",
                "asddasdsd"
            }
        }, melon.DebugPlayer())
    end )
end )