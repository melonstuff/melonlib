
function melon.Debug(f)
    if GAMEMODE then f() end
end

function melon.clr()
    if not GAMEMODE then return end
    print(string.rep("\n\n", 100))
end

function melon.DebugPanel(name, func)
    if not GAMEMODE then return end
    if SERVER then return end
    if IsValid(melon.__Debug__TestPanel) then
        melon.__Debug__TestPanel:Remove()
    end

    melon.__Debug__TestPanel = vgui.Create("Panel")
    melon.__Debug__TestPanel:SetSize(ScrW(), ScrH())
    melon.__Debug__TestPanel:MakePopup()
    melon.__Debug__TestPanel.PerformLayout = function(s,w,h)
        s.close:SetSize(50, 30)
        s.close:SetPos(w - s.close:GetWide(), 0)
    end

    local b = vgui.Create("DButton", melon.__Debug__TestPanel)
    b:SetText("")
    b.Paint = function(s,w,h)
        draw.RoundedBoxEx(6, 0, 0, w, h, HSVToColor(s:IsHovered() and (CurTime() * 1000) or (CurTime() / 10), 0.9, 0.9), false, false, true, false)
        draw.RoundedBoxEx(4, 2, 0, w - 2, h - 2, Color(22, 22, 22), false, false, true, false)

        draw.NoTexture()
        surface.SetDrawColor(255,255,255)
        surface.DrawTexturedRectRotated(w / 2 + 2, h / 2 - 2, 3, h / 2, 45)
        surface.DrawTexturedRectRotated(w / 2 + 2, h / 2 - 2, 3, h / 2, -45)
    end
    b.DoClick = function() melon.__Debug__TestPanel:Remove() end
    melon.__Debug__TestPanel.close = b

    local p = vgui.Create(name, melon.__Debug__TestPanel)
    if func then
        func(p)
    end
end