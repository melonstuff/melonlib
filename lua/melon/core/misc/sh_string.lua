
melon.string = melon.string or {}

local STR = melon.AT(nil, {
    __tostring = function(s)
        return melon.string.Format("<CharIter:{2|int()}: {1}>", s.text, s.index)
    end,
    __call = function(s, text)
        return s:Iter(text)
    end
})

function STR:Iter(text)
    self.index = 0
    self.text = text

    return function()
        self.index = self.index + 1

        if (self.index <= #self.text) and (self.text[self.index] != "\0") then
            return self, self.text[self.index], self.index
        end
    end
end

function STR:Increment(amt)
    self.index = self.index + 1
    return self.text[self.index]
end

function melon.string.CharIterator()
    return STR:New()
end

melon.Debug(function()
    local test = STR:New()

    for iter, char, index in test("Gay") do
        print(iter, char, index)
    end

end, true)