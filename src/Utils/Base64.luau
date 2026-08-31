--[[
    HyperSaveInstance - High-Performance Base64 Encoder / Decoder
    Works across Lua 5.1, LuaJIT, Luau, and environments without native bit32.
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

local function getBitOp()
    local bObj = bit32 or (getfenv and getfenv().bit32) or (getfenv and getfenv().bit) or (_G and (_G.bit32 or _G.bit))
    return bObj
end

function Base64.Encode(data: string): string
    if not data or #data == 0 then return "" end
    local bit = getBitOp()
    local l = #data
    local result = {}
    local idx = 1

    if bit and bit.bor and bit.lshift and bit.rshift and bit.band then
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
    else
        -- Pure arithmetic fallback without bit32 dependency
        for i = 1, l, 3 do
            local b1 = string.byte(data, i, i) or 0
            local b2 = string.byte(data, i + 1, i + 1) or 0
            local b3 = string.byte(data, i + 2, i + 2) or 0

            local n = b1 * 65536 + b2 * 256 + b3

            local c1 = encodeTable[math.floor(n / 262144) % 64]
            local c2 = encodeTable[math.floor(n / 4096) % 64]
            local c3 = encodeTable[math.floor(n / 64) % 64]
            local c4 = encodeTable[n % 64]

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
    end

    return table.concat(result)
end

function Base64.Decode(data: string): string
    if not data or #data == 0 then return "" end
    local bit = getBitOp()
    local clean = string.gsub(data, "%s+", "")
    local l = #clean
    if l % 4 ~= 0 then return "" end

    local result = {}
    local idx = 1

    if bit and bit.bor and bit.lshift and bit.rshift and bit.band then
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
    else
        -- Pure arithmetic fallback
        for i = 1, l, 4 do
            local c1 = decodeTable[string.byte(clean, i, i)] or 0
            local c2 = decodeTable[string.byte(clean, i + 1, i + 1)] or 0
            local c3 = decodeTable[string.byte(clean, i + 2, i + 2)] or 0
            local c4 = decodeTable[string.byte(clean, i + 3, i + 3)] or 0

            local n = c1 * 262144 + c2 * 4096 + c3 * 64 + c4

            local b1 = math.floor(n / 65536) % 256
            local b2 = math.floor(n / 256) % 256
            local b3 = n % 256

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
    end

    return table.concat(result)
end

return Base64
