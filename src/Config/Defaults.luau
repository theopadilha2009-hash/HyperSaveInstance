--[[
    HyperSaveInstance - Default Configuration & Presets
]]

local Defaults = {
    -- General Settings
    Mode = "Full",                         -- "Full" | "Fast" | "VisualsOnly" | "ScriptsOnly" | "Custom"
    Format = "rbxlx",                       -- "rbxlx" (Roblox XML) | "rbxl" (Roblox Binary) | "lua" (Studio Script)
    FilePath = "",                         -- Auto-generated if empty: HyperSaveInstance/<PlaceName>_<PlaceId>.<Format>
    ShowUI = true,                         -- Open HUD interface by default
    AutoStart = false,                     -- Start immediately without waiting for button click if loaded via script
    SilentMode = false,                    -- Headless / 100% Silent Mode (No UI, no notifications, no sounds, no prints)
    RandomizeGuiName = true,               -- Randomize ScreenGui name with stealth random hash
    ToggleKeybind = Enum.KeyCode.RightShift, -- Keyboard shortcut to toggle HUD visibility

    -- Anti-AFK & Stealth Protection
    AutoAntiAFK = true,                    -- Prevents idle disconnection (Error 268/273)
    StealthMode = true,                    -- Obfuscates memory references and thread identity
    SafeStreaming = true,                  -- Non-teleport streaming replication (prevents movement anti-cheat kicks)

    -- Total Raw Asset Downloader
    DownloadRawAssets = true,              -- Download raw audio (.mp3), textures (.png), 3D meshes (.mesh) to folder
    AssetDownloadWorkers = 4,              -- Safe worker count to prevent rate limits on public servers
    SafeAssetDownload = true,              -- Token-bucket throttled downloading with jitter
    PingGuard = true,                      -- Dynamic ping monitoring (auto-pauses if ping > 180ms)
    ExportAssetManifest = true,            -- Export HyperSave_Manifest_<PlaceId>.json for offline downloading
    AssetFolderName = "",                  -- Auto-generated if empty: HyperSave_Assets_<PlaceId>

    -- Smart Optimizer (Strictly Optional / Disabled by default to preserve 100% raw map integrity)
    OptimizeGeometry = false,              -- Optional deduplication of redundant structures

    -- Visual & Asset Fidelity (10/10)
    SaveTerrain = true,                    -- Save Terrain properties & decorations
    SaveTerrainVoxels = true,              -- Extract voxel occupancy & materials (SmoothTerrain)
    TerrainVoxelStep = 64,                 -- Chunk step for reading voxels safely
    SaveLighting = true,                   -- Lighting, Atmosphere, Sky, PostEffects
    SaveMaterials = true,                  -- MaterialService, MaterialVariants
    SaveSounds = true,                     -- Sounds & SoundGroups & Reverb
    SaveUnions = true,                     -- CSG UnionOperations & NegateOperations
    SaveMeshParts = true,                  -- MeshParts, SpecialMesh, Textures
    SaveSurfaceAppearance = true,          -- PBR SurfaceAppearance textures
    SaveAnimations = true,                 -- Animation instances & KeyframeSequences
    SaveAttributes = true,                 -- Modern instance:GetAttributes()
    SaveTags = true,                       -- CollectionService tags

    -- Scripts & Code Extraction (10/10)
    DecompileScripts = true,               -- Decompile LocalScripts and ModuleScripts
    DecompileTimeout = 12,                 -- Timeout in seconds per script
    DecompileMaxRetries = 2,               -- Retries on failure/timeout
    DecompileParallelWorkers = 8,          -- Concurrent workers for fast decompilation
    DecompileIgnoreCore = true,            -- Ignore CoreGui / internal scripts
    SaveServerScriptPlaceholders = true,   -- Generate RemoteSpy dispatcher stubs for server scripts
    SynthesizeServer = true,               -- Auto-generate ServerScriptService mock backend for Remotes
    AutoCaptureAnimations = true,          -- Capture Motor6D joint transforms into KeyframeSequence
    ExtractBytecodeFallback = true,        -- Extract bytecode dump if decompiler is unavailable

    -- Services & Hierarchy
    SavePlayers = false,                   -- Avoid saving temporary character avatars unless desired
    SaveNilInstances = true,               -- Extract isolated / nil instances if executor supports getnilinstances
    PreloadStreaming = true,               -- Stream around map before saving if StreamingEnabled is on
    AutoExploreStreaming = false,          -- Full map grid teleport sweep for StreamingEnabled
    StreamingPreloadRadius = 1024,         -- Preload simulation radius
    IsolateStarterPlayer = true,           -- Copy PlayerScripts/PlayerGui to StarterPlayer/StarterGui
    GenerateSafeSpawn = true,              -- Create SpawnLocation at player position to prevent falling into void
    EmulatePlayableGame = true,            -- Enable DataStore & VIP gamepass emulation for instant Studio playability

    -- Performance & Throttling
    ChunkSize = 250,                       -- Instances processed per frame/tick to prevent lag/freeze
    YieldInterval = 0.01,                  -- task.wait() interval between batches
    AdaptiveFPSGuard = true,               -- Dynamically adjust throttle delay based on framerate delta
    MaxMemoryBudgetMB = 1024,              -- Memory limit safety check
    AssetDownloadWorkers = 8,              -- Concurrent workers for asset downloader pool

    -- Logging, Reports & Validation
    VerboseLogs = true,                    -- Detailed console logs
    ValidateOutputXml = true,              -- Validate XML well-formedness before saving
    SaveSummaryReport = true,              -- Save JSON execution summary report (.json)
    PlaySoundOnComplete = true,            -- Play audio chime when save completes
    CopyToClipboardOnComplete = true,      -- Copy file path to clipboard on complete
    DiscordWebhookUrl = "",                -- Optional Discord Webhook URL for clone notifications
}

-- Preset configurations
local Presets = {
    Full = {
        DownloadRawAssets = true,
        SaveTerrain = true,
        SaveTerrainVoxels = true,
        SaveLighting = true,
        SaveMaterials = true,
        SaveSounds = true,
        SaveUnions = true,
        SaveMeshParts = true,
        SaveSurfaceAppearance = true,
        SaveAnimations = true,
        SaveAttributes = true,
        SaveTags = true,
        DecompileScripts = true,
        SaveServerScriptPlaceholders = true,
        SaveNilInstances = true,
        OptimizeGeometry = false,
    },
    Fast = {
        DownloadRawAssets = false,
        SaveTerrain = true,
        SaveTerrainVoxels = false,
        SaveLighting = true,
        SaveMaterials = true,
        SaveSounds = true,
        SaveUnions = true,
        SaveMeshParts = true,
        SaveSurfaceAppearance = true,
        SaveAnimations = true,
        SaveAttributes = true,
        SaveTags = true,
        DecompileScripts = false,
        SaveServerScriptPlaceholders = true,
        SaveNilInstances = false,
        OptimizeGeometry = false,
    },
    VisualsOnly = {
        DownloadRawAssets = true,
        SaveTerrain = true,
        SaveTerrainVoxels = true,
        SaveLighting = true,
        SaveMaterials = true,
        SaveSounds = true,
        SaveUnions = true,
        SaveMeshParts = true,
        SaveSurfaceAppearance = true,
        SaveAnimations = true,
        SaveAttributes = true,
        SaveTags = true,
        DecompileScripts = false,
        SaveServerScriptPlaceholders = false,
        SaveNilInstances = false,
        OptimizeGeometry = false,
    },
    ScriptsOnly = {
        DownloadRawAssets = false,
        SaveTerrain = false,
        SaveTerrainVoxels = false,
        SaveLighting = false,
        SaveMaterials = false,
        SaveSounds = false,
        SaveUnions = false,
        SaveMeshParts = false,
        SaveSurfaceAppearance = false,
        SaveAnimations = false,
        SaveAttributes = true,
        SaveTags = true,
        DecompileScripts = true,
        SaveServerScriptPlaceholders = true,
        SaveNilInstances = true,
        OptimizeGeometry = false,
    },
    Ghost = {
        SilentMode = true,
        ShowUI = false,
        VerboseLogs = false,
        PlaySoundOnComplete = false,
        RandomizeGuiName = true,
        StealthMode = true,
        SafeStreaming = true,
        AutoExploreStreaming = false,
        DownloadRawAssets = false,
        SaveTerrain = true,
        SaveTerrainVoxels = false,
        SaveLighting = true,
        SaveMaterials = true,
        SaveSounds = true,
        SaveUnions = true,
        SaveMeshParts = true,
        SaveSurfaceAppearance = true,
        SaveAnimations = true,
        SaveAttributes = true,
        SaveTags = true,
        DecompileScripts = true,
        SaveServerScriptPlaceholders = true,
        SaveNilInstances = false,
        OptimizeGeometry = false,
    },
    OnlyMap = {
        DownloadRawAssets = false,
        SaveTerrain = true,
        SaveTerrainVoxels = true,
        SaveLighting = true,
        SaveMaterials = true,
        SaveSounds = false,
        SaveUnions = true,
        SaveMeshParts = true,
        SaveSurfaceAppearance = true,
        SaveAnimations = false,
        SaveAttributes = true,
        SaveTags = true,
        DecompileScripts = false,
        SaveServerScriptPlaceholders = false,
        SaveNilInstances = false,
        OptimizeGeometry = false,
    },
    UIOnly = {
        DownloadRawAssets = false,
        SaveTerrain = false,
        SaveTerrainVoxels = false,
        SaveLighting = false,
        SaveMaterials = false,
        SaveSounds = false,
        SaveUnions = false,
        SaveMeshParts = false,
        SaveSurfaceAppearance = false,
        SaveAnimations = false,
        SaveAttributes = true,
        SaveTags = true,
        DecompileScripts = true,
        SaveServerScriptPlaceholders = false,
        SaveNilInstances = false,
        OptimizeGeometry = false,
    },
    BeeSwarm = {
        DownloadRawAssets = true,
        SaveTerrain = true,
        SaveTerrainVoxels = true,
        SaveLighting = true,
        SaveMaterials = true,
        SaveSounds = true,
        SaveUnions = true,
        SaveMeshParts = true,
        SaveSurfaceAppearance = true,
        SaveAnimations = true,
        SaveAttributes = true,
        SaveTags = true,
        DecompileScripts = true,
        SaveServerScriptPlaceholders = true,
        SaveNilInstances = false,
        SafeStreaming = true,
        AutoExploreStreaming = false,
        IgnoreList = {
            "Collectibles",
            "Popups",
            "FieldEffects",
            "PlayerBees",
            "Debris",
        },
        OptimizeGeometry = false,
    },
    BloxFruits = {
        DownloadRawAssets = true,
        SaveTerrain = true,
        SaveTerrainVoxels = true,
        SaveLighting = true,
        SaveMaterials = true,
        SaveSounds = true,
        SaveUnions = true,
        SaveMeshParts = true,
        SaveSurfaceAppearance = true,
        SaveAnimations = true,
        SaveAttributes = true,
        SaveTags = true,
        DecompileScripts = true,
        SaveServerScriptPlaceholders = true,
        SaveNilInstances = false,
        SafeStreaming = true,
        AutoExploreStreaming = false,
        IgnoreList = {
            "CombatVFX",
            "Slashes",
            "Debris",
            "TempHitboxes",
            "WaterRipples",
            "DamageIndicators",
            "Effects",
            "TemporaryParticles",
        },
        OptimizeGeometry = false,
    },
    PetSimulator99 = {
        DownloadRawAssets = true,
        SaveTerrain = true,
        SaveTerrainVoxels = true,
        SaveLighting = true,
        SaveMaterials = true,
        SaveSounds = true,
        SaveUnions = true,
        SaveMeshParts = true,
        SaveSurfaceAppearance = true,
        SaveAnimations = true,
        SaveAttributes = true,
        SaveTags = true,
        DecompileScripts = true,
        SaveServerScriptPlaceholders = true,
        SaveNilInstances = false,
        SafeStreaming = true,
        AutoExploreStreaming = false,
        IgnoreList = {
            "CoinDebris",
            "DropCoins",
            "BreakableEffects",
            "DamagePopups",
            "TempVFX",
            "BeamEffects",
            "ActivePets",
        },
        OptimizeGeometry = false,
    },
    Arsenal = {
        DownloadRawAssets = true,
        SaveTerrain = true,
        SaveTerrainVoxels = true,
        SaveLighting = true,
        SaveMaterials = true,
        SaveSounds = true,
        SaveUnions = true,
        SaveMeshParts = true,
        SaveSurfaceAppearance = true,
        SaveAnimations = true,
        SaveAttributes = true,
        SaveTags = true,
        DecompileScripts = true,
        SaveServerScriptPlaceholders = true,
        SaveNilInstances = false,
        SafeStreaming = true,
        AutoExploreStreaming = false,
        IgnoreList = {
            "BulletHoles",
            "Tracers",
            "Ragdolls",
            "Debris",
            "BloodEffects",
            "MuzzleFlashes",
            "Viewmodel",
        },
        OptimizeGeometry = false,
    },
    Doors = {
        DownloadRawAssets = true,
        SaveTerrain = true,
        SaveTerrainVoxels = true,
        SaveLighting = true,
        SaveMaterials = true,
        SaveSounds = true,
        SaveUnions = true,
        SaveMeshParts = true,
        SaveSurfaceAppearance = true,
        SaveAnimations = true,
        SaveAttributes = true,
        SaveTags = true,
        DecompileScripts = true,
        SaveServerScriptPlaceholders = true,
        SaveNilInstances = false,
        SafeStreaming = true,
        AutoExploreStreaming = false,
        IgnoreList = {
            "JumpscareDebris",
            "TempLights",
            "FootstepParticles",
            "GlitchEffects",
        },
        OptimizeGeometry = false,
    },
    TowerDefense = {
        DownloadRawAssets = true,
        SaveTerrain = true,
        SaveTerrainVoxels = true,
        SaveLighting = true,
        SaveMaterials = true,
        SaveSounds = true,
        SaveUnions = true,
        SaveMeshParts = true,
        SaveSurfaceAppearance = true,
        SaveAnimations = true,
        SaveAttributes = true,
        SaveTags = true,
        DecompileScripts = true,
        SaveServerScriptPlaceholders = true,
        SaveNilInstances = false,
        SafeStreaming = true,
        AutoExploreStreaming = false,
        IgnoreList = {
            "MobSpawns",
            "Projectiles",
            "ExplosionDebris",
            "HealthBars",
            "TowerRadiusRings",
        },
        OptimizeGeometry = false,
    }
}

Defaults.Presets = Presets

function Defaults.ApplyPreset(config: table, presetName: string)
    local preset = Presets[presetName]
    if preset then
        for k, v in pairs(preset) do
            config[k] = v
        end
        config.Mode = presetName
    end
    return config
end

return Defaults
