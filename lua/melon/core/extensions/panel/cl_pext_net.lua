
--[[
    Net extension for Panel objects
    Allows panels to interact with net messages directly instead of jank workarounds
]]

local PANEL = {}

function PANEL:OnExtensionAdded()
    self.NetWatching = {}
end

function PANEL:WatchNet(msg)
    self.NetWatching[msg] = true

    melon.net.Watch(msg, self, function(len, ply)
        if IsValid(self) and self.NetWatching[msg] then
            self["Net_" .. msg](self, len, ply)
        else
            melon.net.Unwatch(msg, self)
        end
    end )
end

function PANEL:UnwatchNet(msg)
    self.NetWatching[msg] = false

    melon.net.Unwatch(msg, self)
end

melon.Extensions.RegisterPanelExtension("net", PANEL)