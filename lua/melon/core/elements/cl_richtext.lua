
melon.elements = melon.elements or {}

----
---@panel Melon:RichText
----
---@accessor (name: type) Description

---@accessor (Color: Color) Color of the tetx
---@accessor (Font: string) Font of the text
---@accessor (Underline: number) Should the text be underlined? If so, how far should it be from the text baseline, scaled.
---@accessor (Strikethrough: bool) Should the text be struck through?
---@accessor (Interactable: fn) Function to run on text click
---@accessor (Custom: fn) Function to run instead of rendering the text
----
---- A richtext renderer and layout system
----
local PANEL = vgui.Register("Melon:RichText", {}, "Melon:Button")

do --- deferred accessors arent something I do often enough to account for
    function PANEL:SetColor(v)         self.state.color = v         end
    function PANEL:SetFont(v)          self.state.font = v          end
    function PANEL:SetUnderline(v)     self.state.underline = v     end
    function PANEL:SetStrikethrough(v) self.state.strikethrough = v end
    function PANEL:SetInteractable(v)  self.state.interactable = v  end
    function PANEL:SetCustom(v)        self.state.custom = v        end

    function PANEL:GetColor()         return self.state.color         end
    function PANEL:GetFont()          return self.state.font          end
    function PANEL:GetUnderline()     return self.state.underline     end
    function PANEL:GetStrikethrough() return self.state.strikethrough end
    function PANEL:GetInteractable()  return self.state.interactable  end
    function PANEL:GetCustom()        return self.state.custom        end
end

melon.elements.RichText = PANEL

function PANEL:Init()
    self.segments = {}
    self.renderables = {}

    self.state = {
        color = Color(255, 0, 0), 
        font = melon.Font(30),
                
        underline = false,
        strikethrough = false,

        interactable = false,
        custom = false 
    }

    self:SetCursor("arrow")
end

function PANEL:PushText(text)
    local segs = string.Split(text, "\n")
    for k, v in pairs(segs) do
        table.insert(self.segments, {
            text = v,
            state = table.Copy(self.state),
        })

        if k == #segs then continue end
        table.insert(self.segments, {
            linebreak = true,
            state = {font = self.state.font},
            text = "W"
        })
    end

    self:InvalidateLayout(true)
end

function PANEL:PushLink(text, link, color, underline)
    local state = table.Copy(self.state)

    self:SetColor(color or Color(80, 130, 255))
    self:SetUnderline(underline or true)
    self:SetInteractable(function()
        gui.OpenURL(link)
    end )
    self:PushText(text)
    
    self.state = state
end

function PANEL:PerformLayout(w, h)
    local x = 0
    local y = 0

    local lineh = 0

    self.renderables = {}
    for k, v in pairs(self.segments) do
        surface.SetFont(v.state.font)
        local tw, th = surface.GetTextSize(v.text)

        lineh = math.max(lineh, th)

        if v.linebreak then
            y = y + lineh
            x = 0
            continue
        end

        if x + tw < w then
            table.insert(self.renderables, {
                x = x,
                y = y,
                text = v.text,
                segment = v
            })

            x = x + tw
            continue
        end

        local wrap = melon.text.Wrap(v.text, v.state.font, w, x)

        for i, wrapseg in pairs(wrap) do
            table.insert(self.renderables, {
                x = i == 1 and x or 0,
                y = y,
                text = wrapseg,
                segment = v
            })

            if i != #wrap then
                y = y + lineh
                totalh = y
            end

            surface.SetFont(v.state.font)
            tw, th = surface.GetTextSize(wrapseg)
            x = tw
        end
    end

    self.totalh = y + lineh
end

function PANEL:LeftClick()
    if self.hovering_interactable then
        self.hovering_interactable.state.interactable(MOUSE_LEFT)
    end
end
function PANEL:RightClick()
    if self.hovering_interactable then
        self.hovering_interactable.state.interactable(MOUSE_RIGHT)
    end
end

function PANEL:Paint(w, h)
    if self.hovering_interactable then
        self:SetCursor("arrow")
        self.hovering_interactable = nil
    end

    local lh = melon.Scale(2)
    local cx, cy = self:LocalCursorPos()

    for _, v in pairs(self.renderables) do
        local tw, th = draw.Text({
            text = v.text,
            pos = {v.x, v.y},
            font = v.segment.state.font,
            color = v.segment.state.color,
        })

        if v.segment.state.underline then
            surface.SetDrawColor(v.segment.state.color)
            surface.DrawRect(v.x, v.y + th - lh - melon.Scale(isnumber(v.segment.state.underline) and v.segment.state.underline or 0), tw, lh)
        end

        if v.segment.state.strikethrough then
            surface.SetDrawColor(v.segment.state.color)
            surface.DrawRect(v.x, v.y  + th / 2 - lh / 2, tw, lh)
        end

        -- surface.SetDrawColor(255, 0, 0)
        -- surface.DrawOutlinedRect(v.x + 1, v.y + 1, tw - 2, th - 2, 1)

        if
            v.segment.state.interactable and
            cx > v.x and cy > v.y and
            cx < v.x + tw and cy < v.y + th 
        then
            if not self.hovering_interactable then
                self:SetCursor("hand") -- avoids weird flickering issues
              end

            self.hovering_interactable = v.segment
        end
    end
end

melon.DebugPanel("DPanel", function(p)
    p:SetSize(400, 400)
    p:Center()
    p:SetX(100)

    p.rich = vgui.Create("Melon:RichText", p)
    p.rich:Dock(FILL)

    p.rich:SetColor(Color(255, 0, 0))
    p.rich:PushText("red")

    p.rich:SetUnderline(6)
    p.rich:SetColor(Color(0, 255, 0))
    p.rich:PushText("green")
    p.rich:SetUnderline(false)

    p.rich:SetFont(melon.Font(20))
    p.rich:SetColor(Color(0, 0, 255))
    p.rich:PushText("blue")
    p.rich:SetFont(melon.Font(80))
    p.rich:SetColor(Color(0, 0, 0))

    p.rich:SetStrikethrough(true)
    p.rich:PushText("black")
    p.rich:SetFont(melon.Font(30))
    p.rich:SetStrikethrough(false)

    p.rich:SetFont(melon.Font(30, "Courier New"))
    p.rich:PushLink("poopfart", "https://google.com/")
    p.rich:SetFont(melon.Font(30))

    p.rich:SetInteractable(function(segment)
        print(123)
    end)
    p.rich:PushText("this will end up on the next lineeeeaaaaa ")
    p.rich:PushText("\nnextline")
end )