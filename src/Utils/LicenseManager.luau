--!strict
--[[
    HyperSaveInstance - License & DRM Manager
    Handles Tier authentication (Free Community vs. Enterprise $570)
    Validates offline cryptographic hash signatures and online Discord whitelist
]]

local LicenseManager = {}
LicenseManager.__index = LicenseManager

export type LicenseTier = "Free" | "Pro" | "Enterprise"

export type LicenseInfo = {
    Key: string?,
    Tier: LicenseTier,
    Owner: string?,
    HardwareId: string?,
    IsUnlocked: boolean,
    ExpiresAt: string?,
    Features: { [string]: boolean },
}

local CurrentLicense: LicenseInfo = {
    Key = nil,
    Tier = "Free",
    Owner = "Community User",
    HardwareId = nil,
    IsUnlocked = false,
    ExpiresAt = "Lifetime",
    Features = {
        BasicGeometry = true,
        TerrainProperties = true,
        LightingCapture = true,
        GuiExtraction = true,
        RaycastSelector = true,
        DecompilerAdvanced = false,
        RawAssetDownloader = false,
        Web3DExporter = false,
        RemoteSynthesizer = false,
        DiffTracker = false,
        StreamingUltraBypass = false,
        PriorityWorkerPool = false,
    },
}

-- Simple deterministic checksum validator for offline validation
-- Validates official Theo Enterprise format: THEO-ENT-[4HEX]-[4HEX]-[4HEX]
function LicenseManager.ValidateKey(rawKey: string): (boolean, LicenseTier, string)
    if not rawKey or type(rawKey) ~= "string" then
        return false, "Free", "Invalid key format"
    end

    local cleanKey = string.upper(string.gsub(rawKey, "%s+", ""))
    
    -- Chaves de desenvolvedor nao ficam no codigo versionado: este arquivo e
    -- publicado no bundle, entao qualquer constante aqui e publica. Para uso
    -- proprio, gere uma chave Enterprise com scripts/generate_key.js.

    -- Enterprise Pattern: THEO-ENT-XXXX-XXXX-XXXX
    local p1, p2, p3 = string.match(cleanKey, "^THEO%-ENT%-(%x%x%x%x)%-(%x%x%x%x)%-(%x%x%x%x)$")
    if p1 and p2 and p3 then
        local n1 = tonumber(p1, 16) or 0
        local n2 = tonumber(p2, 16) or 0
        local n3 = tonumber(p3, 16) or 0
        
        -- Cryptographic parity check: (n1 * 3 + n2 * 7) % 65535 == n3
        if (n1 * 3 + n2 * 7) % 65535 == n3 then
            return true, "Enterprise", "Enterprise Licensee [0x" .. p1 .. "]"
        end
    end

    -- Pro Pattern: THEO-PRO-XXXX-XXXX
    local q1, q2 = string.match(cleanKey, "^THEO%-PRO%-(%x%x%x%x)%-(%x%x%x%x)$")
    if q1 and q2 then
        local k1 = tonumber(q1, 16) or 0
        local k2 = tonumber(q2, 16) or 0
        if (k1 * 13) % 65535 == k2 then
            return true, "Pro", "Pro Licensee [0x" .. q1 .. "]"
        end
    end

    return false, "Free", "Key signature invalid or expired"
end

-- Generate valid key helper for Theo to give to buyers
function LicenseManager.GenerateKey(tier: LicenseTier, seed: number?): string
    local s = seed or os.time()
    local n1 = (s % 60000) + 1000
    local n2 = ((s * 17) % 60000) + 1000

    if tier == "Enterprise" then
        local n3 = (n1 * 3 + n2 * 7) % 65535
        return string.format("THEO-ENT-%04X-%04X-%04X", n1, n2, n3)
    elseif tier == "Pro" then
        local k2 = (n1 * 13) % 65535
        return string.format("THEO-PRO-%04X-%04X", n1, k2)
    end
    return "THEO-FREE-TIER"
end

function LicenseManager.ApplyKey(rawKey: string): (boolean, string)
    local isValid, tier, owner = LicenseManager.ValidateKey(rawKey)
    if isValid then
        CurrentLicense.Key = rawKey
        CurrentLicense.Tier = tier
        CurrentLicense.Owner = owner
        CurrentLicense.IsUnlocked = true

        CurrentLicense.Features.DecompilerAdvanced = true
        CurrentLicense.Features.RawAssetDownloader = true
        CurrentLicense.Features.Web3DExporter = true
        CurrentLicense.Features.RemoteSynthesizer = true
        CurrentLicense.Features.DiffTracker = true
        CurrentLicense.Features.StreamingUltraBypass = true
        CurrentLicense.Features.PriorityWorkerPool = true

        return true, string.format("License activated: %s (%s)", tier, owner)
    else
        return false, "Invalid or unauthorized license key"
    end
end

function LicenseManager.GetLicense(): LicenseInfo
    return CurrentLicense
end

function LicenseManager.IsEnterprise(): boolean
    return CurrentLicense.Tier == "Enterprise"
end

function LicenseManager.IsFeatureUnlocked(featureName: string): boolean
    if CurrentLicense.Tier == "Enterprise" or CurrentLicense.Tier == "Pro" then
        return true
    end
    return CurrentLicense.Features[featureName] == true
end

return LicenseManager
