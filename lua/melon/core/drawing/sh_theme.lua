
-- Progressive Color Theme Building System

melon.ThemeHandlersList = melon.ThemeHandlersList or {}

-- Actual Color Storage
local Theme = {}
Theme.__index = Theme
Theme.Colors = {}

AccessorFunc(Theme, "handler", "Handler")
AccessorFunc(Theme, "id", "ID")
AccessorFunc(Theme, "name", "Name")

function Theme:Color(key, valr, g, b, a)
    local val = (IsColor(valr) and valr) or Color(valr, g, b, a)
    self.Colors[key] = val

    return self
end

function Theme:Done()
    return self:GetHandler()
end

-- Handles Themes
local ThemeHandler = {}
ThemeHandler.__index = ThemeHandler
ThemeHandler.Themes = {}

AccessorFunc(ThemeHandler, "default", "Default", FORCE_STRING)
AccessorFunc(ThemeHandler, "active", "Active")
AccessorFunc(ThemeHandler, "id", "ID")

function ThemeHandler:Init(id)
    self:SetID(id)
    local act = cookie.GetString("melon_lib_theme_" .. id, false)

    self:SetActive(act)
end

function ThemeHandler:NewTheme(ID, name)
    local t = setmetatable({}, Theme)
    t:SetHandler(self)
    t:SetID(ID)
    t:SetName(name)
    self.Themes[ID] = t

    return t
end

function ThemeHandler:SetActive(id)
    if self.Themes[id] then
        self.active = self.Themes[id]
        cookie.Set("melon_lib_theme_" .. self:GetID(), id)
    end
end

-- function ThemeHandler:Get(key)
--     if self.active and self.active[key] then
--         return self.active[key]
--     end

--     return self.Themes[self.default].Colors[key]
-- end

function melon.ThemeHandler(id)
    if melon.ThemeHandlersList[id] then
        return melon.ThemeHandlersList[id]
    end

    local t = setmetatable({}, ThemeHandler)
    t:Init(id)

    melon.ThemeHandlersList[id] = t

    return t
end

-- Creation
local x = melon.ThemeHandler("test")
x:SetDefault("dark")

-- Define Colors
x:NewTheme("dark", "Dark")
    :Color("background", 22, 22, 22)
    :Color("text", 255, 255, 255)
:Done()
:NewTheme("light", "Light")
    :Color("background", 255, 255, 255)
    :Color("text", 0, 0, 0)
:Done()

melon.clr()

print(x:Get("text"), x.Get)