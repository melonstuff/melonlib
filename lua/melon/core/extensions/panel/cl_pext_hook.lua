
--[[
    Hook extension for Panel objects
    this allows panels to directly interact with hooks without some weird intermediate
    and without cluttering up hookspace
]]

melon.Extensions.PANEL.HOOKWatching = melon.Extensions.PANEL.HOOKWatching or {}
local w = melon.Extensions.PANEL.HOOKWatching

local PANEL = {}

function PANEL:WatchHook(name)
    if not w[name] then
        hook.Add(name, "MelonLib:PanelWatch", function(...)
            for pnl, valid in w[name] do
                if IsValid(pnl) and valid then
                    pnl["Hook_" .. name](pnl, ...)
                else
                    w[name][pnl] = nil
                end
            end
        end )
    end
    
    w[name][self] = true
end

function PANEL:UnwatchHook(name)
    w[name] = w[name] or {}
    w[name][self] = nil

    if table.IsEmpty(w[name]) then
        w[name] = nil
        hook.Remove(name, "MelonLib:PanelWatch")
    end
end

melon.Extensions.RegisterPanelExtension("hook", PANEL)