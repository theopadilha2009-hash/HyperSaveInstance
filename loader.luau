--[[
    HyperSaveInstance - Loader

    This is the ONLY loader. `dist/Loader.luau` is a copy produced by the build
    (`npm run build`); do not edit it by hand.

    Integrity model
    ---------------
    The bundle is fetched from a pinned commit SHA, never from a moving branch.
    raw.githubusercontent serves immutable content for a commit, so whoever
    controls the repository later cannot change what this line already points
    to. That pin is the actual guarantee.

    The Adler-32 check below is NOT cryptographic and is not a defense against a
    tampered bundle; it only catches truncated or corrupted downloads, which is
    the realistic failure of a CDN fetch on a bad mobile connection.

    Both values are written by `node scripts/update_loader_pin.js` after the
    bundle is committed. Run it before publishing a release.
]]

local PINNED_COMMIT = "PLACEHOLDER_COMMIT"
-- Kept as the two 16-bit Adler halves instead of one combined 32-bit value:
-- the combined form exceeds 2^31 for most inputs and different Lua runtimes
-- disagree on how they represent that.
local EXPECTED_ADLER_A = 0
local EXPECTED_ADLER_B = 0
local EXPECTED_BYTES = 0

local REPO = "theopadilha2009-hash/HyperSaveInstance"

local function isSilent(): boolean
    local silent = false
    pcall(function()
        local genv = (getgenv and getgenv()) or _G
        if genv then
            silent = (genv.HyperSave_Silent == true)
                or (genv.SilentMode == true)
                or (genv.HyperSave_Ghost == true)
        end
    end)
    return silent
end

local function report(message: string)
    if isSilent() then return end
    warn("[HyperSaveInstance] " .. message)
end

-- Adler-32 over the whole body, read in blocks so this stays quick on a 400 KB
-- string instead of one string.byte call per character.
local function adler32(data: string): (number, number)
    local a, b = 1, 0
    local len = #data
    local i = 1
    while i <= len do
        local last = math.min(i + 255, len)
        local bytes = { string.byte(data, i, last) }
        for _, byte in ipairs(bytes) do
            a = (a + byte) % 65521
            b = (b + a) % 65521
        end
        i = last + 1
    end
    return a, b
end

local function checksumMatches(body: string): boolean
    local a, b = adler32(body)
    return a == EXPECTED_ADLER_A and b == EXPECTED_ADLER_B
end

local function fetch(url: string): string?
    local ok, body = pcall(function()
        return game:HttpGet(url, true)
    end)
    if ok and type(body) == "string" and #body > 0 then
        return body
    end
    return nil
end

local function load()
    if PINNED_COMMIT == "PLACEHOLDER_COMMIT" then
        report("Loader was published without a pinned commit. Run scripts/update_loader_pin.js.")
        return nil
    end

    -- Both hosts serve the same immutable commit; the second is only a fallback
    -- for networks that block one of them.
    local sources = {
        string.format("https://raw.githubusercontent.com/%s/%s/dist/HyperSaveInstance.luau", REPO, PINNED_COMMIT),
        string.format("https://cdn.jsdelivr.net/gh/%s@%s/dist/HyperSaveInstance.luau", REPO, PINNED_COMMIT),
    }

    for _, url in ipairs(sources) do
        local body = fetch(url)
        if body then
            if EXPECTED_BYTES > 0 and #body ~= EXPECTED_BYTES then
                report(string.format("Rejected %s: expected %d bytes, got %d.", url, EXPECTED_BYTES, #body))
            elseif EXPECTED_ADLER_B ~= 0 and not checksumMatches(body) then
                report(string.format("Rejected %s: checksum mismatch (truncated or corrupted download).", url))
            else
                local chunk, syntaxErr = loadstring(body)
                if chunk then
                    return chunk()
                end
                report("Bundle failed to compile: " .. tostring(syntaxErr))
            end
        end
    end

    report("Could not load the bundle from any source.")
    return nil
end

local ok, result = pcall(load)
if not ok then
    report("Fatal: " .. tostring(result))
    return nil
end

return result
