--[[
    HyperSaveInstance - High-Performance Base64 Encoder / Decoder
]]

local Base64 = {}

local b = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

-- Build lookup tables
local encodeTable = {}
local decodeTable = {}

for i = 1, #b do
    local char = string.sub(b, i, i)
    encodeTable[i - 1] = char
    decodeTable[string.byte(char)] = i - 1
end
decodeTable[string.byte("=")] = 0

function Base64.Encode(data: string): string
    local bit = bit32 or bit
    local l = #data
    local result = table.create(math.ceil(l / 3) * 4)
    local idx = 1

    for i = 1, l, 3 do
        local b1 = string.byte(data, i, i) or 0
        local b2 = string.byte(data, i + 1, i + 1) or 0
        local b3 = string.byte(data, i + 2, i + 2) or 0

        local n = bit.bor(bit.lshift(b1, 16), bit.lshift(b2, 8), b3)

        local c1 = encodeTable[bit.band(bit.rshift(n, 18), 63)]
        local c2 = encodeTable[bit.band(bit.rshift(n, 12), 63)]
        local c3 = encodeTable[bit.band(bit.rshift(n, 6), 63)]
        local c4 = encodeTable[bit.band(n, 63)]

        local remaining = l - i + 1
        if remaining == 1 then
            c3 = "="
            c4 = "="
        elseif remaining == 2 then
            c4 = "="
        end

        result[idx] = c1
        result[idx + 1] = c2
        result[idx + 2] = c3
        result[idx + 3] = c4
        idx = idx + 4
    end

    return table.concat(result)
end

function Base64.Decode(data: string): string
    local bit = bit32 or bit
    local clean = string.gsub(data, "%s+", "")
    local l = #clean
    if l % 4 ~= 0 then return "" end

    local padding = 0
    if string.sub(clean, -1) == "=" then padding = padding + 1 end
    if string.sub(clean, -2) == "==" then padding = padding + 1 end

    local result = table.create(math.floor(l * 3 / 4) - padding)
    local idx = 1

    for i = 1, l, 4 do
        local c1 = decodeTable[string.byte(clean, i, i)] or 0
        local c2 = decodeTable[string.byte(clean, i + 1, i + 1)] or 0
        local c3 = decodeTable[string.byte(clean, i + 2, i + 2)] or 0
        local c4 = decodeTable[string.byte(clean, i + 3, i + 3)] or 0

        local n = bit.bor(bit.lshift(c1, 18), bit.lshift(c2, 12), bit.lshift(c3, 6), c4)

        local b1 = bit.band(bit.rshift(n, 16), 255)
        local b2 = bit.band(bit.rshift(n, 8), 255)
        local b3 = bit.band(n, 255)

        result[idx] = string.char(b1)
        idx = idx + 1

        if i + 2 <= l and string.sub(clean, i + 2, i + 2) ~= "=" then
            result[idx] = string.char(b2)
            idx = idx + 1
        end

        if i + 3 <= l and string.sub(clean, i + 3, i + 3) ~= "=" then
            result[idx] = string.char(b3)
            idx = idx + 1
        end
    end

    return table.concat(result)
end

return Base64
