
local applied = {}
melon.Extensions = melon.Extensions or {}
melon.Extensions.PANEL = melon.Extensions.PANEL or {}

function melon.Extensions.RegisterPanelExtension(name, PANEL)
    melon.Extensions.PANEL[name] = PANEL

    melon.Debug(melon.Extensions.RefreshExtensions)
end

function melon.Extensions.RefreshExtensions()
    for k, v in pairs(applied) do
        if IsValid(v) then
            v:RefreshExtensions()
        end
    end
end

local meta = FindMetaTable("Panel")
function meta:ApplyExtension(name)
    local ext = melon.Extensions.PANEL[name]
    if not ext then return end

    self.extensions = self.extensions or {}
    self.extensions[name] = true

    if ext.OnExtensionAdded then
        ext.OnExtensionAdded(self)
    end

    table.Merge(self, (isfunction(ext) and ext()) or ext)

    self.OnExtensionAdded = nil
end

function meta:RefreshExtensions()
    for k, _ in pairs(self.extensions) do
        self:ApplyExtension(k)
    end
end
