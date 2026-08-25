--[[
    HyperSaveInstance - Pure Luau LZ4 Compression & Decompression
    Standard Roblox binary chunks (PRMS, INST, PROP, PRNT) are compressed using LZ4.
]]

local LZ4 = {}

function LZ4.Compress(input: string): string
    local bit = bit32 or bit
    local inputLen = #input
    if inputLen == 0 then return "" end

    local hashTable = {}
    local out = {}
    local outIdx = 1

    local anchor = 1
    local i = 1

    while i <= inputLen - 4 do
        local b1 = string.byte(input, i, i)
        local b2 = string.byte(input, i + 1, i + 1)
        local b3 = string.byte(input, i + 2, i + 2)
        local b4 = string.byte(input, i + 3, i + 3)

        local hash = bit.band(bit.bxor(bit.lshift(b1, 12), bit.lshift(b2, 4), bit.rshift(b3, 4), b4) * 2654435761, 0xFFFF)
        local ref = hashTable[hash]
        hashTable[hash] = i

        if ref and (i - ref) <= 0xFFFF and string.sub(input, ref, ref + 3) == string.sub(input, i, i + 3) then
            local litLen = i - anchor
            local matchLen = 4
            while (i + matchLen <= inputLen) and (string.byte(input, i + matchLen) == string.byte(input, ref + matchLen)) do
                matchLen = matchLen + 1
            end

            local offset = i - ref
            local tokenLit = math.min(litLen, 15)
            local tokenMatch = math.min(matchLen - 4, 15)
            local token = bit.bor(bit.lshift(tokenLit, 4), tokenMatch)

            out[outIdx] = string.char(token)
            outIdx = outIdx + 1

            if litLen >= 15 then
                local extra = litLen - 15
                while extra >= 255 do
                    out[outIdx] = string.char(255)
                    outIdx = outIdx + 1
                    extra = extra - 255
                end
                out[outIdx] = string.char(extra)
                outIdx = outIdx + 1
            end

            if litLen > 0 then
                out[outIdx] = string.sub(input, anchor, i - 1)
                outIdx = outIdx + 1
            end

            out[outIdx] = string.char(bit.band(offset, 0xFF), bit.band(bit.rshift(offset, 8), 0xFF))
            outIdx = outIdx + 1

            if matchLen - 4 >= 15 then
                local extraMatch = (matchLen - 4) - 15
                while extraMatch >= 255 do
                    out[outIdx] = string.char(255)
                    outIdx = outIdx + 1
                    extraMatch = extraMatch - 255
                end
                out[outIdx] = string.char(extraMatch)
                outIdx = outIdx + 1
            end

            i = i + matchLen
            anchor = i
        else
            i = i + 1
        end
    end

    local lastLitLen = inputLen - anchor + 1
    if lastLitLen > 0 then
        local token = bit.lshift(math.min(lastLitLen, 15), 4)
        out[outIdx] = string.char(token)
        outIdx = outIdx + 1

        if lastLitLen >= 15 then
            local extra = lastLitLen - 15
            while extra >= 255 do
                out[outIdx] = string.char(255)
                outIdx = outIdx + 1
                extra = extra - 255
            end
            out[outIdx] = string.char(extra)
            outIdx = outIdx + 1
        end

        out[outIdx] = string.sub(input, anchor, inputLen)
    end

    return table.concat(out)
end

function LZ4.Decompress(compressed: string, uncompressedSize: number): string
    local bit = bit32 or bit
    local out = {}
    local outLen = 0
    local i = 1
    local cLen = #compressed

    while i <= cLen and outLen < uncompressedSize do
        local token = string.byte(compressed, i)
        i = i + 1

        local litLen = bit.rshift(token, 4)
        if litLen == 15 then
            local extra = string.byte(compressed, i)
            i = i + 1
            while extra == 255 do
                litLen = litLen + 255
                extra = string.byte(compressed, i)
                i = i + 1
            end
            litLen = litLen + extra
        end

        if litLen > 0 then
            table.insert(out, string.sub(compressed, i, i + litLen - 1))
            i = i + litLen
            outLen = outLen + litLen
        end

        if outLen >= uncompressedSize or i > cLen then break end

        local offset = bit.bor(string.byte(compressed, i), bit.lshift(string.byte(compressed, i + 1), 8))
        i = i + 2

        local matchLen = bit.band(token, 0x0F) + 4
        if matchLen == 19 then
            local extra = string.byte(compressed, i)
            i = i + 1
            while extra == 255 do
                matchLen = matchLen + 255
                extra = string.byte(compressed, i)
                i = i + 1
            end
            matchLen = matchLen + extra
        end

        local currentData = table.concat(out)
        local matchStart = #currentData - offset + 1
        local matchChunk = ""
        for m = 1, matchLen do
            local idx = matchStart + ((m - 1) % offset)
            matchChunk = matchChunk .. string.sub(currentData, idx, idx)
        end
        table.insert(out, matchChunk)
        outLen = outLen + matchLen
    end

    return table.concat(out)
end

return LZ4
