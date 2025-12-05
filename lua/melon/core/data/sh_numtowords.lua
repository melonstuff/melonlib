
local low_words = {
    [0] = "zero",
    "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten",

    "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", 
    "eighteen", "nineteen", "twenty"
}

local high_words = {
    [1000] = "thousand",
    [100] = "hundred",
    [9] = "ninety", 
    [8] = "eighty", 
    [7] = "seventy",
    [6] = "sixty", 
    [5] = "fifty", 
    [4] = "forty",
    [3] = "thirty",
    [2] = "twenty",
}

function melon.NumToWords(num)
    if num > 9999 then return num end
    if low_words[num] then return low_words[num] end

    local left = ""
    local mid = ""
    local right = ""
    local ones = num % 10

    num = (num - ones) / 10
    local tens = num % 10
    
    num = (num - tens) / 10
    local hunds = num % 10
    
    num = (num - hunds) / 10
    local thous = num % 10

    if thous > 0 then
        left = left .. low_words[thous] .. " thousand "
        mid = "and "
    end

    if hunds > 0 then
        left = left .. low_words[hunds] .. " hundred "
    end

    if tens > 0 and high_words[tens] then
        right = right .. high_words[tens] .. " "
    end

    if tens > 0 and not high_words[tens] then
        return left .. "and " .. low_words[tonumber(tens .. ones)]
    end

    if ones == 0 and left != "" and right != "" then
        return left .. mid .. right
    end

    right = right .. low_words[ones]

    return left .. (right == "" and "" or (mid .. right))
end