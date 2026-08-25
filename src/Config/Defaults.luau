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

    -- Total Raw Asset Downloader
    DownloadRawAssets = true,              -- Download raw audio (.mp3), textures (.png), 3D meshes (.mesh) to folder
    AssetDownloadWorkers = 6,              -- Parallel threads for raw asset downloading
    AssetFolderName = "",                  -- Auto-generated if empty: HyperSave_Assets_<PlaceId>

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
    ExtractBytecodeFallback = true,        -- Extract bytecode dump if decompiler is unavailable

    -- Services & Hierarchy
    SavePlayers = false,                   -- Avoid saving temporary character avatars unless desired
    SaveNilInstances = true,               -- Extract isolated / nil instances if executor supports getnilinstances
    PreloadStreaming = true,               -- Stream around map before saving if StreamingEnabled is on
    StreamingPreloadRadius = 1024,         -- Preload simulation radius
    IsolateStarterPlayer = true,           -- Copy PlayerScripts/PlayerGui to StarterPlayer/StarterGui

    -- Performance & Throttling
    ChunkSize = 250,                       -- Instances processed per frame/tick to prevent lag/freeze
    YieldInterval = 0.01,                  -- task.wait() interval between batches
    MaxMemoryBudgetMB = 1024,              -- Memory limit safety check

    -- Logging & Notifications
    VerboseLogs = true,                    -- Detailed console logs
    PlaySoundOnComplete = true,            -- Play audio chime when save completes
    CopyToClipboardOnComplete = true,      -- Copy file path to clipboard on complete
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
    }
}

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
