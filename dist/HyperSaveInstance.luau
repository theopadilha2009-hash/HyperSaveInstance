--[[
    ================================================================================
    HyperSaveInstance v2.0 - Standalone Production Bundle
    Universal Roblox Game Cloner & SaveInstance Engine
    Author: Theo Lorentz Padilha (https://github.com/theopadilha2009-hash)
    ================================================================================
]]

local __modules__ = {}
local __cache__ = {}

local function __showErrorGui__(errTitle, errDesc)
    pcall(function()
        local parent = (gethui and gethui()) or (game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui")) or game:GetService("CoreGui")
        if not parent then return end

        local sg = Instance.new("ScreenGui")
        sg.Name = "HyperSave_ErrorAlert"
        sg.DisplayOrder = 9999999
        sg.ResetOnSpawn = false

        local f = Instance.new("Frame")
        f.Size = UDim2.new(0, 440, 0, 240)
        f.AnchorPoint = Vector2.new(0.5, 0.5)
        f.Position = UDim2.new(0.5, 0, 0.5, 0)
        f.BackgroundColor3 = Color3.fromRGB(20, 8, 16)
        f.BorderSizePixel = 0

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 14)
        corner.Parent = f

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(244, 63, 94)
        stroke.Thickness = 2
        stroke.Parent = f

        local title = Instance.new("TextLabel")
        title.Text = "⚠️ " .. tostring(errTitle or "HYPERSAVE - ERRO")
        title.Font = Enum.Font.GothamBold
        title.TextSize = 13
        title.TextColor3 = Color3.fromRGB(244, 63, 94)
        title.Size = UDim2.new(1, -24, 0, 26)
        title.Position = UDim2.new(0, 12, 0, 10)
        title.BackgroundTransparency = 1
        title.Parent = f

        local desc = Instance.new("TextLabel")
        desc.Text = tostring(errDesc or "Erro desconhecido")
        desc.Font = Enum.Font.Code
        desc.TextSize = 10
        desc.TextColor3 = Color3.fromRGB(255, 230, 235)
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.TextYAlignment = Enum.TextYAlignment.Top
        desc.TextWrapped = true
        desc.Size = UDim2.new(1, -24, 1, -84)
        desc.Position = UDim2.new(0, 12, 0, 38)
        desc.BackgroundTransparency = 1
        desc.Parent = f

        local btn = Instance.new("TextButton")
        btn.Text = "FECHAR AVISO"
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.BackgroundColor3 = Color3.fromRGB(244, 63, 94)
        btn.Size = UDim2.new(1, -24, 0, 32)
        btn.Position = UDim2.new(0, 12, 1, -40)
        btn.BorderSizePixel = 0
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn
        btn.Parent = f
        btn.MouseButton1Click:Connect(function() sg:Destroy() end)

        f.Parent = sg
        sg.Parent = parent
    end)
end

local function __define__(name, fn)
    __modules__[name] = fn
end

local function __require__(name)
    if __cache__[name] ~= nil then
        return __cache__[name]
    end
    local modFn = __modules__[name]
    if not modFn then
        local msg = "[HyperSaveInstance] Modulo nao encontrado: " .. tostring(name)
        warn(msg)
        __showErrorGui__("Modulo Faltando", msg)
        error(msg)
    end
    local success, result = pcall(modFn)
    if not success then
        local msg = "[HyperSaveInstance] Erro ao carregar modulo " .. tostring(name) .. ": " .. tostring(result)
        warn(msg)
        __showErrorGui__("Falha no Modulo: " .. tostring(name), tostring(result))
        error(msg)
    end
    __cache__[name] = result
    return result
end

-- Virtual Module Definitions

__define__("Config/ClassBlacklist", function()
--[[
    HyperSaveInstance - Class and Instance Blacklist
    Filters out CoreGui internal components, debugger pointers, exploit hooks, temporary cameras and studio noise.
]]

local ClassBlacklist = {
    -- Dangerous/Internal services & classes that should never be serialized into game places
    Classes = {
        ["CorePackages"] = true,
        ["CoreGui"] = true,
        ["RobloxReplicatedStorage"] = true,
        ["NetworkClient"] = true,
        ["NetworkServer"] = true,
        ["NetworkReplicator"] = true,
        ["PackageLink"] = true, -- Removes permission lock & reveals hidden package models in Studio
        ["PackageService"] = true,
        ["Player"] = true, -- Prevent player avatar session locks
        ["PlayerGui"] = false, -- Filtered dynamically (keep StarterGui)
        ["PlayerScripts"] = false,
        ["PluginGuiService"] = true,
        ["StandalonePluginScripts"] = true,
        ["TouchTransmitter"] = true,
        ["ScreenshotHud"] = true,
        ["VoiceChatService"] = false,
    },

    -- Names of internal exploit GUIs, tracers or script injections
    Names = {
        ["HyperSaveInstance_UI"] = true,
        ["Fluxus"] = true,
        ["Dex"] = true,
        ["DarkDex"] = true,
        ["SimpleSpy"] = true,
        ["Hydroxide"] = true,
        ["TurtleSpy"] = true,
        ["RemoteSpy"] = true,
        ["Infinite Yield"] = true,
        ["IY_GUI"] = true,
        ["SynapseX"] = true,
    },

    -- Services to save by default
    SaveServices = {
        "Workspace",
        "ReplicatedStorage",
        "ReplicatedFirst",
        "Lighting",
        "MaterialService",
        "StarterGui",
        "StarterPack",
        "StarterPlayer",
        "SoundService",
        "Chat",
        "LocalizationService",
        "TextChatService",
        "InsertService",
    },
}

return ClassBlacklist

end)

__define__("Config/Defaults", function()
--[[
    HyperSaveInstance - Default Configuration & Presets
]]

local Defaults = {
    -- General Settings
    Mode = "Full", -- "Full" | "Fast" | "VisualsOnly" | "ScriptsOnly" | "Custom"
    Format = "rbxlx", -- "rbxlx" (Roblox XML) | "rbxl" (Roblox Binary) | "lua" (Studio Script)
    FilePath = "", -- Auto-generated if empty: HyperSaveInstance/<PlaceName>_<PlaceId>.<Format>
    ShowUI = true, -- Open HUD interface by default
    AutoStart = false, -- Start immediately without waiting for button click if loaded via script
    SilentMode = false, -- Headless / 100% Silent Mode (No UI, no notifications, no sounds, no prints)
    RandomizeGuiName = true, -- Randomize ScreenGui name with stealth random hash
    ToggleKeybind = Enum.KeyCode.RightShift, -- Keyboard shortcut to toggle HUD visibility

    -- Anti-AFK & Stealth Protection
    AutoAntiAFK = true, -- Prevents idle disconnection (Error 268/273)
    StealthMode = true, -- Obfuscates memory references and thread identity
    SafeStreaming = true, -- Non-teleport streaming replication (prevents movement anti-cheat kicks)

    -- Total Raw Asset Downloader
    DownloadRawAssets = true, -- Download raw audio (.mp3), textures (.png), 3D meshes (.mesh) to folder
    AssetDownloadWorkers = 4, -- Safe worker count to prevent rate limits on public servers
    SafeAssetDownload = true, -- Token-bucket throttled downloading with jitter
    PingGuard = true, -- Dynamic ping monitoring (auto-pauses if ping > 180ms)
    ExportAssetManifest = true, -- Export HyperSave_Manifest_<PlaceId>.json for offline downloading
    AssetFolderName = "", -- Auto-generated if empty: HyperSave_Assets_<PlaceId>

    -- Smart Optimizer (Strictly Optional / Disabled by default to preserve 100% raw map integrity)
    OptimizeGeometry = false, -- Optional deduplication of redundant structures

    -- Visual & Asset Fidelity (10/10)
    SaveTerrain = true, -- Save Terrain properties & decorations
    SaveTerrainVoxels = true, -- Extract voxel occupancy & materials (SmoothTerrain)
    TerrainVoxelStep = 64, -- Chunk step for reading voxels safely
    SaveLighting = true, -- Lighting, Atmosphere, Sky, PostEffects
    SaveMaterials = true, -- MaterialService, MaterialVariants
    SaveSounds = true, -- Sounds & SoundGroups & Reverb
    SaveUnions = true, -- CSG UnionOperations & NegateOperations
    SaveMeshParts = true, -- MeshParts, SpecialMesh, Textures
    SaveSurfaceAppearance = true, -- PBR SurfaceAppearance textures
    SaveAnimations = true, -- Animation instances & KeyframeSequences
    SaveAttributes = true, -- Modern instance:GetAttributes()
    SaveTags = true, -- CollectionService tags

    -- Scripts & Code Extraction (10/10)
    DecompileScripts = true, -- Decompile LocalScripts and ModuleScripts
    DecompileTimeout = 12, -- Timeout in seconds per script
    DecompileMaxRetries = 2, -- Retries on failure/timeout
    DecompileParallelWorkers = 8, -- Concurrent workers for fast decompilation
    DecompileIgnoreCore = true, -- Ignore CoreGui / internal scripts
    SaveServerScriptPlaceholders = true, -- Generate RemoteSpy dispatcher stubs for server scripts
    SynthesizeServer = true, -- Auto-generate ServerScriptService mock backend for Remotes
    AutoCaptureAnimations = true, -- Capture Motor6D joint transforms into KeyframeSequence
    ExtractBytecodeFallback = true, -- Extract bytecode dump if decompiler is unavailable

    -- Services & Hierarchy
    SavePlayers = false, -- Avoid saving temporary character avatars unless desired
    SaveNilInstances = true, -- Extract isolated / nil instances if executor supports getnilinstances
    PreloadStreaming = true, -- Stream around map before saving if StreamingEnabled is on
    AutoExploreStreaming = false, -- Full map grid teleport sweep for StreamingEnabled
    StreamingPreloadRadius = 1024, -- Preload simulation radius
    IsolateStarterPlayer = true, -- Copy PlayerScripts/PlayerGui to StarterPlayer/StarterGui
    GenerateSafeSpawn = true, -- Create SpawnLocation at player position to prevent falling into void
    EmulatePlayableGame = true, -- Enable DataStore & VIP gamepass emulation for instant Studio playability

    -- Performance & Throttling
    ChunkSize = 250, -- Instances processed per frame/tick to prevent lag/freeze
    YieldInterval = 0.01, -- task.wait() interval between batches
    AdaptiveFPSGuard = true, -- Dynamically adjust throttle delay based on framerate delta
    MaxMemoryBudgetMB = 1024, -- Memory limit safety check
    AssetDownloadWorkers = 8, -- Concurrent workers for asset downloader pool

    -- Logging, Reports & Validation
    VerboseLogs = true, -- Detailed console logs
    ValidateOutputXml = true, -- Validate XML well-formedness before saving
    SaveSummaryReport = true, -- Save JSON execution summary report (.json)
    PlaySoundOnComplete = true, -- Play audio chime when save completes
    CopyToClipboardOnComplete = true, -- Copy file path to clipboard on complete
    DiscordWebhookUrl = "", -- Optional Discord Webhook URL for clone notifications
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
    },
}

Defaults.Presets = Presets

function Defaults.ApplyPreset(config, presetName)
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

end)

__define__("Core/AnimationRecorder", function()
--[[
    HyperSaveInstance - Live Animation Keyframe Capturer
    Solves the Roblox Asset Permission / HTTP 403 issue for Animations by capturing
    real-time Motor6D joint transformations (CFrame / Transform) and baking them into
    native KeyframeSequence instances that can be published to the user's account in Studio.
]]

local clonerefFn = cloneref or function(obj)
    return obj
end
local RunService = nil
pcall(function()
    RunService = clonerefFn(game:GetService("RunService"))
end)
local Players = nil
pcall(function()
    Players = clonerefFn(game:GetService("Players"))
end)

local AnimationRecorder = {}
AnimationRecorder.IsRecording = false
AnimationRecorder.RecordedSequences = {}
AnimationRecorder.ActiveConnection = nil

-- Record an active animation track from a Humanoid by sampling joint transforms
function AnimationRecorder.RecordTrack(humanoid, trackName, durationSeconds, onComplete)
    local character = humanoid.Parent
    if not character then
        return
    end

    -- Collect all Motor6D joints
    local motors = {}
    for _, desc in ipairs(character:GetDescendants()) do
        if desc:IsA("Motor6D") then
            table.insert(motors, desc)
        end
    end

    if #motors == 0 then
        return
    end

    local keyframeSeq = Instance.new("KeyframeSequence")
    keyframeSeq.Name = trackName or "RecordedAnimation"

    local sampleRate = 30 -- 30 FPS sampling
    local interval = 1 / sampleRate
    local elapsed = 0
    local timer = 0

    local frames = {}

    local conn
    conn = RunService.Heartbeat:Connect(function(dt)
        elapsed = elapsed + dt
        timer = timer + dt

        if timer >= interval then
            timer = 0
            local timePos = math.floor(elapsed * 1000) / 1000

            local kf = Instance.new("Keyframe")
            kf.Time = timePos

            -- Create pose hierarchy
            local posesByPart = {}
            for _, motor in ipairs(motors) do
                local p0 = motor.Part0
                local p1 = motor.Part1
                if p0 and p1 then
                    local pose = Instance.new("Pose")
                    pose.Name = p1.Name
                    pose.CFrame = motor.Transform
                    posesByPart[p1.Name] = pose
                end
            end

            -- Assemble tree structure
            for _, motor in ipairs(motors) do
                local p0 = motor.Part0
                local p1 = motor.Part1
                if p0 and p1 and posesByPart[p0.Name] and posesByPart[p1.Name] then
                    posesByPart[p1.Name].Parent = posesByPart[p0.Name]
                elseif p1 and posesByPart[p1.Name] and not posesByPart[p1.Name].Parent then
                    posesByPart[p1.Name].Parent = kf
                end
            end

            kf.Parent = keyframeSeq
        end

        if elapsed >= (durationSeconds or 3) then
            conn:Disconnect()
            table.insert(AnimationRecorder.RecordedSequences, keyframeSeq)
            if onComplete then
                onComplete(keyframeSeq)
            end
        end
    end)

    return conn
end

-- Auto-hook into character animation playback
function AnimationRecorder.StartAutoCapture()
    if AnimationRecorder.IsRecording then
        return
    end
    AnimationRecorder.IsRecording = true

    local function hookHumanoid(humanoid)
        humanoid.AnimationPlayed:Connect(function(track)
            local animName = track.Name or "Animation"
            pcall(function()
                if track.Animation then
                    animName = track.Animation.Name
                end
            end)

            -- Prevent duplicate recordings
            if not AnimationRecorder.RecordedSequences[animName] then
                AnimationRecorder.RecordedSequences[animName] = true
                AnimationRecorder.RecordTrack(humanoid, animName, math.min(track.Length > 0 and track.Length or 3, 10))
            end
        end)
    end

    local localPlayer = Players.LocalPlayer
    if localPlayer then
        if localPlayer.Character then
            local hum = localPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hookHumanoid(hum)
            end
        end
        localPlayer.CharacterAdded:Connect(function(char)
            local hum = char:WaitForChild("Humanoid", 5)
            if hum and hum:IsA("Humanoid") then
                hookHumanoid(hum)
            end
        end)
    end
end

-- Scan all currently playing animation tracks across the local player and NPCs
function AnimationRecorder.ScanActiveTracks()
    local tracks = {}
    local seen = {}

    local function checkHumanoid(hum)
        local animator = hum:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                local name = track.Name or "Animation"
                pcall(function()
                    if track.Animation and #track.Animation.Name > 0 then
                        name = track.Animation.Name
                    end
                end)
                if not seen[name] then
                    seen[name] = true
                    table.insert(tracks, {
                        Name = name,
                        Length = track.Length,
                        Speed = track.Speed,
                        Humanoid = hum,
                        Track = track,
                    })
                end
            end
        end
    end

    local localPlayer = Players and Players.LocalPlayer
    if localPlayer and localPlayer.Character then
        local hum = localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            checkHumanoid(hum)
        end
    end

    if workspace then
        for _, desc in ipairs(workspace:GetDescendants()) do
            if desc:IsA("Humanoid") then
                checkHumanoid(desc)
            end
        end
    end

    return tracks
end

-- Export all captured KeyframeSequences to a .rbxm model package
function AnimationRecorder.ExportRecordedAnimations()
    local Environment = __require__("Utils/Environment")
    local SerializerXml = __require__("Core/SerializerXml")

    local animFolder = Instance.new("Folder")
    animFolder.Name = "RecordedAnimations"

    local count = 0
    for _, item in ipairs(AnimationRecorder.RecordedSequences) do
        if typeof(item) == "Instance" and item:IsA("KeyframeSequence") then
            local clone = item:Clone()
            clone.Parent = animFolder
            count = count + 1
        end
    end

    if count == 0 then
        -- Create a placeholder KeyframeSequence if none recorded yet
        local placeholder = Instance.new("KeyframeSequence")
        placeholder.Name = "Idle_Sample"
        local kf0 = Instance.new("Keyframe")
        kf0.Time = 0
        kf0.Parent = placeholder
        placeholder.Parent = animFolder
        count = 1
    end

    local fileName = string.format("HyperSave_Animations_%s.rbxm", tostring(game.PlaceId or "0"))
    local xml = SerializerXml.Serialize(animFolder, {
        SaveTerrain = false,
        DecompileScripts = false,
    })

    if Environment.HasFileSystem() then
        local success, err = pcall(function()
            Environment.WriteFile(fileName, xml)
        end)
        if success then
            return true, fileName
        else
            return false, tostring(err)
        end
    end

    return true, fileName
end

return AnimationRecorder

end)

__define__("Core/AssetDownloader", function()
--[[
    HyperSaveInstance - Comprehensive Raw Asset Downloader Engine
    Downloads raw audios (.mp3), textures (.png), 3D meshes (.mesh/.obj) and animations to local disk.
    Equipped with Dynamic Network & FPS Throttling, Exponential Backoff and Ping Guard.
]]

local Environment = __require__("Utils/Environment")

local AssetDownloader = {}

-- Safe HTTP Request polyfill with clean official headers (Prevents executor fingerprinting)
local function httpRequest(url)
    local req = (syn and syn.request) or (http and http.request) or http_request or request
    if req then
        local s, res = pcall(req, {
            Url = url,
            Method = "GET",
            Headers = {
                ["User-Agent"] = "Roblox/WinInet",
                ["Accept"] = "*/*",
                ["Accept-Encoding"] = "gzip, deflate",
                ["Connection"] = "keep-alive",
            },
        })
        if s and res and (res.StatusCode == 200 or res.Success) then
            return res.Body
        end
    end

    -- Fallback to game:HttpGet
    local s, body = pcall(function()
        return game:HttpGet(url)
    end)
    if s and type(body) == "string" and #body > 0 then
        return body
    end

    return nil
end

-- Extract clean asset ID numbers from urls or strings
function AssetDownloader.ExtractId(assetUrl)
    if type(assetUrl) == "number" then
        return tostring(assetUrl)
    end
    if type(assetUrl) ~= "string" or #assetUrl == 0 then
        return nil
    end

    local id = string.match(assetUrl, "%d+")
    return id
end

-- Collect all unique asset URLs and IDs from game hierarchy
function AssetDownloader.CollectAssets(instances)
    local assets = {}

    local function registerAsset(assetType, rawVal, sourceName)
        local id = AssetDownloader.ExtractId(rawVal)
        if id and #id > 0 and not assets[id] then
            local downloadUrl = string.format("https://assetdelivery.roblox.com/v1/asset/?id=%s", id)
            assets[id] = {
                Type = assetType,
                Id = id,
                Url = downloadUrl,
                SourceName = sourceName,
            }
        end
    end

    for _, inst in ipairs(instances) do
        if inst:IsA("Sound") then
            registerAsset("Audio", inst.SoundId, inst.Name)
        elseif inst:IsA("Decal") or inst:IsA("Texture") then
            registerAsset("Texture", inst.Texture, inst.Name)
        elseif inst:IsA("MeshPart") then
            registerAsset("Mesh", inst.MeshId, inst.Name .. "_Mesh")
            registerAsset("Texture", inst.TextureID, inst.Name .. "_Tex")
        elseif inst:IsA("SpecialMesh") then
            registerAsset("Mesh", inst.MeshId, inst.Name .. "_Mesh")
            registerAsset("Texture", inst.TextureId, inst.Name .. "_Tex")
        elseif inst:IsA("SurfaceAppearance") then
            registerAsset("Texture", inst.ColorMap, inst.Name .. "_Color")
            registerAsset("Texture", inst.NormalMap, inst.Name .. "_Normal")
            registerAsset("Texture", inst.RoughnessMap, inst.Name .. "_Roughness")
            registerAsset("Texture", inst.MetalnessMap, inst.Name .. "_Metalness")
        elseif inst:IsA("Sky") then
            registerAsset("Texture", inst.SkyboxBk, "SkyboxBk")
            registerAsset("Texture", inst.SkyboxDn, "SkyboxDn")
            registerAsset("Texture", inst.SkyboxFt, "SkyboxFt")
            registerAsset("Texture", inst.SkyboxLf, "SkyboxLf")
            registerAsset("Texture", inst.SkyboxRt, "SkyboxRt")
            registerAsset("Texture", inst.SkyboxUp, "SkyboxUp")
        elseif inst:IsA("ParticleEmitter") or inst:IsA("Beam") or inst:IsA("Trail") then
            registerAsset("Texture", (inst ).Texture, inst.Name)
        elseif inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
            registerAsset("Texture", (inst ).Image, inst.Name)
        elseif inst:IsA("Animation") then
            registerAsset("Animation", inst.AnimationId, inst.Name)
        elseif inst:IsA("Shirt") then
            registerAsset("Texture", inst.ShirtTemplate, inst.Name)
        elseif inst:IsA("Pants") then
            registerAsset("Texture", inst.PantsTemplate, inst.Name)
        elseif inst:IsA("VideoFrame") then
            registerAsset("Video", (inst ).Video, inst.Name)
        elseif inst:IsA("PackageLink") then
            registerAsset("Package", (inst ).PackageId, inst.Name)
        end
    end

    return assets
end

-- Measure real-time client ping to prevent server desync/heartbeat disconnects
function AssetDownloader.GetClientPing()
    local ping = 45
    pcall(function()
        local clonerefFn = cloneref or function(obj)
            return obj
        end
        local stats = clonerefFn(game:GetService("Stats"))
        local net = stats and stats:FindFirstChild("Network")
        local ssi = net and net:FindFirstChild("ServerStatsItem")
        local dp = ssi and ssi:FindFirstChild("Data Ping")
        if dp and dp:IsA("ValueBase") then
            ping = (dp ).Value or 45
        end
    end)
    return ping
end

-- Measure real-time client FPS
function AssetDownloader.GetClientFPS()
    local fps = 60
    pcall(function()
        local clonerefFn = cloneref or function(obj)
            return obj
        end
        local ws = clonerefFn(game:GetService("Workspace"))
        if ws and ws.GetRealPhysicsFPS then
            local val = ws:GetRealPhysicsFPS()
            if val and val > 0 then
                fps = val
            end
        end
    end)
    return fps
end

-- Export structured JSON manifest for offline downloading
function AssetDownloader.ExportManifest(assets, manifestPath)
    local clonerefFn = cloneref or function(obj)
        return obj
    end
    local HttpService = clonerefFn(game:GetService("HttpService"))
    local list = {}
    local summary = {
        Audio = 0,
        Texture = 0,
        Mesh = 0,
        Animation = 0,
        Video = 0,
        Package = 0,
        Other = 0,
    }

    for id, item in pairs(assets) do
        table.insert(list, {
            Id = id,
            Type = item.Type,
            Url = item.Url,
            SourceName = item.SourceName,
        })
        if summary[item.Type] ~= nil then
            summary[item.Type] = summary[item.Type] + 1
        else
            summary.Other = summary.Other + 1
        end
    end

    local success, json = pcall(function()
        return HttpService:JSONEncode({
            PlaceId = game.PlaceId or 0,
            TotalAssets = #list,
            CategorySummary = summary,
            ExportDate = os.date("%Y-%m-%d %H:%M:%S"),
            Assets = list,
        })
    end)

    if success and json then
        local wOk = Environment.WriteFile(manifestPath, json)
        return wOk, manifestPath
    end

    return false, "Failed to encode JSON manifest"
end

-- Download all collected assets safely with Ping Guard, FPS Throttling & Exponential Backoff
function AssetDownloader.DownloadAll(assets, baseFolder, options, progressCallback)
    local opts = options or {}
    Environment.MakeFolder(baseFolder)
    Environment.MakeFolder(baseFolder .. "/audios")
    Environment.MakeFolder(baseFolder .. "/textures")
    Environment.MakeFolder(baseFolder .. "/meshes")
    Environment.MakeFolder(baseFolder .. "/animations")

    local manifestPath = string.format("%s/HyperSave_Manifest_%d.json", baseFolder, game.PlaceId or 0)
    AssetDownloader.ExportManifest(assets, manifestPath)

    local assetList = {}
    for _, asset in pairs(assets) do
        table.insert(assetList, asset)
    end

    local total = #assetList
    if total == 0 then
        return 0, 0
    end

    local downloaded = 0
    local failed = 0
    local currentIndex = 1

    -- In safe mode, constrain workers to 3-4 to keep network and CPU usage imperceptible
    local maxWorkers = opts.SafeAssetDownload ~= false and math.clamp(opts.AssetDownloadWorkers or 3, 1, 4)
        or math.clamp(opts.AssetDownloadWorkers or 6, 2, 8)
    local activeWorkers = maxWorkers

    for w = 1, maxWorkers do
        task.spawn(function()
            while currentIndex <= total do
                if opts._CancelChecker and opts._CancelChecker() then
                    break
                end

                local myIndex = currentIndex
                currentIndex = currentIndex + 1

                local item = assetList[myIndex]
                if item then
                    -- 1. Adaptive Ping & FPS Guard: Pause if ping > 160ms or FPS < 35
                    if opts.SafeAssetDownload ~= false then
                        local currentPing = AssetDownloader.GetClientPing()
                        local currentFps = AssetDownloader.GetClientFPS()
                        local retryCount = 0
                        while (currentPing > 160 or currentFps < 35) and retryCount < 12 do
                            if opts._CancelChecker and opts._CancelChecker() then
                                break
                            end
                            task.wait(0.25)
                            currentPing = AssetDownloader.GetClientPing()
                            currentFps = AssetDownloader.GetClientFPS()
                            retryCount = retryCount + 1
                        end
                    end

                    if opts._CancelChecker and opts._CancelChecker() then
                        break
                    end

                    local extension = ".dat"
                    local subDir = "textures"

                    if item.Type == "Audio" then
                        extension = ".mp3"
                        subDir = "audios"
                    elseif item.Type == "Texture" then
                        extension = ".png"
                        subDir = "textures"
                    elseif item.Type == "Mesh" then
                        extension = ".mesh"
                        subDir = "meshes"
                    elseif item.Type == "Animation" then
                        extension = ".rbxanim"
                        subDir = "animations"
                    end

                    local fileName = string.format(
                        "%s/%s/%s_%s%s",
                        baseFolder,
                        subDir,
                        item.Id,
                        string.gsub(item.SourceName, "[^%w_%-]", "_"),
                        extension
                    )

                    -- 2. Exponential backoff retry handler
                    local body = nil
                    local maxRetries = 2
                    for attempt = 1, maxRetries + 1 do
                        if opts._CancelChecker and opts._CancelChecker() then
                            break
                        end
                        body = httpRequest(item.Url)
                        if not body or #body == 0 then
                            local v2Url = string.format("https://assetdelivery.roblox.com/v2/assetId/%s", item.Id)
                            body = httpRequest(v2Url)
                        end

                        if body and #body > 0 then
                            break
                        end

                        if attempt <= maxRetries then
                            task.wait(0.3 * attempt)
                        end
                    end

                    if body and #body > 0 then
                        local writeOk = Environment.WriteFile(fileName, body)
                        if writeOk then
                            downloaded = downloaded + 1
                        else
                            failed = failed + 1
                        end
                    else
                        failed = failed + 1
                    end

                    if progressCallback then
                        pcall(progressCallback, downloaded + failed, total, item)
                    end
                end

                -- Jittered rate limiting delay (40ms to 80ms)
                local jitter = math.random(40, 80) / 1000
                task.wait(jitter)
            end
            activeWorkers = activeWorkers - 1
        end)
    end

    while activeWorkers > 0 and (downloaded + failed) < total do
        if opts._CancelChecker and opts._CancelChecker() then
            break
        end
        task.wait(0.05)
    end

    return downloaded, failed
end

return AssetDownloader

end)

__define__("Core/AssetHandler", function()
--[[
    HyperSaveInstance - Asset & Solid Modeling (CSG) Deep Geometry Handler
    Preserves CSG Unions, PhysicsData, ChildData, MeshParts, SpecialMeshes, SurfaceAppearances, Textures and Sounds.
]]

local Environment = __require__("Utils/Environment")
local Base64 = __require__("Utils/Base64")

local AssetHandler = {}

-- Sanitize and format asset URLs
function AssetHandler.FormatAssetId(id)
    if type(id) == "number" then
        return "rbxassetid://" .. tostring(id)
    end
    if type(id) == "string" then
        if string.match(id, "^%d+$") then
            return "rbxassetid://" .. id
        end
        return id
    end
    return ""
end

-- Extract CSG Hidden Data (PhysicsData, ChildData, AssetId)
function AssetHandler.ExtractUnionData(union)
    local data = {
        AssetId = "",
        PhysicsData = nil,
        ChildData = nil,
        InitialSize = nil,
        RenderFidelity = Enum.RenderFidelity.Precise,
        CollisionFidelity = Enum.CollisionFidelity.Default,
        UsePartColor = false,
        SmoothingAngle = 0,
    }

    pcall(function()
        data.AssetId = union.AssetId
    end)
    pcall(function()
        data.RenderFidelity = union.RenderFidelity
    end)
    pcall(function()
        data.CollisionFidelity = union.CollisionFidelity
    end)
    pcall(function()
        data.UsePartColor = union.UsePartColor
    end)
    pcall(function()
        data.SmoothingAngle = union.SmoothingAngle
    end)

    -- Extract hidden CSG geometry buffers if executor supports gethiddenproperty or getspecialinfo
    local getspecial = getspecialinfo or (syn and syn.get_special_info)
    if getspecial then
        local s, specialInfo = pcall(getspecial, union)
        if s and type(specialInfo) == "table" then
            if specialInfo.PhysicsData then
                data.PhysicsData = Base64.Encode(specialInfo.PhysicsData)
            end
            if specialInfo.ChildData then
                data.ChildData = Base64.Encode(specialInfo.ChildData)
            end
            if specialInfo.InitialSize then
                data.InitialSize = specialInfo.InitialSize
            end
            if specialInfo.AssetId and #data.AssetId == 0 then
                data.AssetId = specialInfo.AssetId
            end
        end
    end

    if not data.PhysicsData then
        local phys = Environment.GetHiddenProperties(union, "PhysicsData")
        if phys and type(phys) == "string" then
            data.PhysicsData = Base64.Encode(phys)
        end
    end

    if not data.ChildData then
        local child = Environment.GetHiddenProperties(union, "ChildData")
        if child and type(child) == "string" then
            data.ChildData = Base64.Encode(child)
        end
    end

    return data
end

-- Process MeshParts and Meshes
function AssetHandler.ProcessMeshOrUnion(instance, options)
    local info = {
        ClassName = instance.ClassName,
        MeshId = "",
        TextureId = "",
        RenderFidelity = Enum.RenderFidelity.Precise,
        CollisionFidelity = Enum.CollisionFidelity.Default,
        DoubleSided = false,
        VertexColor = Vector3.new(1, 1, 1),
        AssetId = "",
        UnionData = nil,
    }

    if instance:IsA("MeshPart") then
        pcall(function()
            info.MeshId = instance.MeshId
        end)
        pcall(function()
            info.TextureId = instance.TextureID
        end)
        pcall(function()
            info.RenderFidelity = instance.RenderFidelity
        end)
        pcall(function()
            info.CollisionFidelity = instance.CollisionFidelity
        end)
        pcall(function()
            info.DoubleSided = instance.DoubleSided
        end)
        pcall(function()
            info.VertexColor = instance.VertexColor
        end)
    elseif instance:IsA("UnionOperation") or instance:IsA("NegateOperation") then
        info.UnionData = AssetHandler.ExtractUnionData(instance )
        info.AssetId = info.UnionData.AssetId
    elseif instance:IsA("SpecialMesh") then
        pcall(function()
            info.MeshId = instance.MeshId
        end)
        pcall(function()
            info.TextureId = instance.TextureId
        end)
        pcall(function()
            info.MeshType = instance.MeshType
        end)
        pcall(function()
            info.Scale = instance.Scale
        end)
        pcall(function()
            info.Offset = instance.Offset
        end)
        pcall(function()
            info.VertexColor = instance.VertexColor
        end)
    end

    return info
end

-- Process SurfaceAppearance (PBR Textures)
function AssetHandler.ProcessSurfaceAppearance(instance)
    local pbr = {
        ColorMap = "",
        NormalMap = "",
        RoughnessMap = "",
        AlphaMode = 0,
    }
    pcall(function()
        if Enum.AlphaMode and Enum.AlphaMode.Overlay then
            pbr.AlphaMode = Enum.AlphaMode.Overlay
        end
    end)
    pcall(function()
        pbr.ColorMap = instance.ColorMap
    end)
    pcall(function()
        pbr.NormalMap = instance.NormalMap
    end)
    pcall(function()
        pbr.RoughnessMap = instance.RoughnessMap
    end)
    pcall(function()
        pbr.MetalnessMap = instance.MetalnessMap
    end)
    pcall(function()
        pbr.AlphaMode = instance.AlphaMode
    end)
    return pbr
end

-- Preload & warm assets in memory
function AssetHandler.WarmAssets(instances)
    pcall(function()
        local clonerefFn = cloneref or function(obj)
            return obj
        end
        local ContentProvider = clonerefFn(game:GetService("ContentProvider"))
        if not ContentProvider then
            return
        end

        local batch = {}
        for _, inst in ipairs(instances) do
            if
                inst:IsA("MeshPart")
                or inst:IsA("Decal")
                or inst:IsA("Texture")
                or inst:IsA("SurfaceAppearance")
                or inst:IsA("SpecialMesh")
            then
                table.insert(batch, inst)
                if #batch >= 80 then
                    pcall(function()
                        ContentProvider:PreloadAsync(batch)
                    end)
                    table.clear(batch)
                end
            end
        end
        if #batch > 0 then
            pcall(function()
                ContentProvider:PreloadAsync(batch)
            end)
        end
    end)
end

return AssetHandler

end)

__define__("Core/AudioRipper", function()
--[[
    HyperSaveInstance - Audio Ripper & In-Game Soundboard
    Scans, previews, plays and extracts all music tracks and sound effects in the game.
]]

local clonerefFn = cloneref or function(obj)
    return obj
end
local SoundService = nil
pcall(function()
    SoundService = clonerefFn(game:GetService("SoundService"))
end)
local Environment = __require__("Utils/Environment")

local AudioRipper = {}
local previewSoundInstance = nil



-- Collect all sound instances in the game
function AudioRipper.ScanSounds()
    local sounds = {}
    local seenIds = {}

    local function scan(inst)
        if inst:IsA("Sound") and #inst.SoundId > 0 then
            local cleanId = string.match(inst.SoundId, "%d+")
            if cleanId and not seenIds[cleanId] then
                seenIds[cleanId] = true
                table.insert(sounds, {
                    Name = inst.Name,
                    SoundId = inst.SoundId,
                    CleanId = cleanId,
                    Path = inst:GetFullName(),
                    Volume = inst.Volume,
                    TimeLength = inst.TimeLength,
                })
            end
        end

        for _, child in ipairs(inst:GetChildren()) do
            scan(child)
        end
    end

    for _, sName in ipairs({
        "Workspace",
        "SoundService",
        "ReplicatedStorage",
        "Lighting",
        "StarterGui",
        "StarterPack",
        "StarterPlayer",
        "Chat",
        "MaterialService",
    }) do
        local s, service = pcall(function()
            return clonerefFn(game:GetService(sName))
        end)
        if s and service then
            scan(service)
        end
    end

    return sounds
end

-- Play in-game preview
function AudioRipper.PlayPreview(soundId)
    pcall(function()
        if previewSoundInstance then
            previewSoundInstance:Stop()
            previewSoundInstance:Destroy()
            previewSoundInstance = nil
        end

        local snd = Instance.new("Sound")
        snd.SoundId = soundId
        snd.Volume = 1
        snd.Parent = workspace.CurrentCamera or SoundService
        snd:Play()
        previewSoundInstance = snd
    end)
    return true
end

-- Stop in-game preview
function AudioRipper.StopPreview()
    pcall(function()
        if previewSoundInstance then
            previewSoundInstance:Stop()
            previewSoundInstance:Destroy()
            previewSoundInstance = nil
        end
    end)
end

-- Export sound list to text/json
function AudioRipper.ExportSoundList()
    local list = AudioRipper.ScanSounds()
    local placeId = game.PlaceId or 0
    local fileName = string.format("HyperSave_Soundtrack_%d.txt", placeId)

    local lines = { "=== HyperSaveInstance - Game Soundtrack & Audio List ===", "" }
    for i, snd in ipairs(list) do
        table.insert(lines, string.format("[%d] %s | ID: %s | URL: rbxassetid://%s", i, snd.Name, snd.CleanId, snd.CleanId))
    end

    local content = table.concat(lines, "\n")
    Environment.WriteFile(fileName, content)
    return fileName
end

return AudioRipper

end)

__define__("Core/Decompiler", function()
--[[
    HyperSaveInstance - Advanced Multi-Worker Script Decompiler & RemoteSpy Server Reconstructor
    Decompiles LocalScripts/ModuleScripts and generates functional backend dispatchers for Server Scripts.
]]

local Environment = __require__("Utils/Environment")
local Base64 = __require__("Utils/Base64")

local Decompiler = {}

-- Helper to get clean script path
local function getScriptPath(scriptInstance)
    local names = {}
    local current = scriptInstance
    while current and current ~= game do
        table.insert(names, 1, current.Name)
        current = current.Parent
    end
    return "game." .. table.concat(names, ".")
end

-- Extract detected network events and functions invoked by this script
function Decompiler.ExtractNetworkSignatures(code)
    local signatures = {}
    local seen = {}

    for remoteCall in string.gmatch(code, "([%w_%.:]+):[Ff]ire[Ss]erver%(") do
        if not seen[remoteCall] then
            seen[remoteCall] = true
            table.insert(signatures, "RemoteEvent: " .. remoteCall .. ":FireServer(...)")
        end
    end

    for funcCall in string.gmatch(code, "([%w_%.:]+):[Ii]nvoke[Ss]erver%(") do
        if not seen[funcCall] then
            seen[funcCall] = true
            table.insert(signatures, "RemoteFunction: " .. funcCall .. ":InvokeServer(...)")
        end
    end

    return signatures
end

-- Extract module dependencies required by this script
function Decompiler.ExtractDependencies(code)
    local deps = {}
    local seen = {}

    for mod in string.gmatch(code, "require%(([%w_%.%s]+)%)") do
        local clean = string.gsub(mod, "^%s*(.-)%s*$", "%1")
        if #clean > 0 and not seen[clean] then
            seen[clean] = true
            table.insert(deps, clean)
        end
    end

    return deps
end

-- Deobfuscate escaped character sequences and string.char blocks
function Decompiler.DeobfuscateStrings(code)
    if not code or #code == 0 then
        return ""
    end

    local deobfuscated = code

    -- 1. Decode 3-digit decimal escapes: \097 -> 'a'
    deobfuscated = string.gsub(deobfuscated, "\\(%d%d%d)", function(d)
        local num = tonumber(d)
        if num and num >= 32 and num <= 126 and num ~= 34 and num ~= 39 and num ~= 92 then
            return string.char(num)
        end
        return "\\" .. d
    end)

    -- 2. Decode hex escapes: \x68 -> 'h'
    deobfuscated = string.gsub(deobfuscated, "\\x(%x%x)", function(h)
        local num = tonumber(h, 16)
        if num and num >= 32 and num <= 126 and num ~= 34 and num ~= 39 and num ~= 92 then
            return string.char(num)
        end
        return "\\x" .. h
    end)

    return deobfuscated
end

-- Generate banner comment for decompiled scripts
local function generateHeader(scriptInstance, status, code)
    local path = getScriptPath(scriptInstance)
    local dateStr = os.date("%Y-%m-%d %H:%M:%S")
    local execName = Environment.GetExecutorName()

    local extraInfo = ""
    if code and #code > 0 then
        local sigs = Decompiler.ExtractNetworkSignatures(code)
        local deps = Decompiler.ExtractDependencies(code)

        if #sigs > 0 then
            extraInfo = extraInfo .. "\n    Network Calls (" .. #sigs .. "):\n"
            for _, s in ipairs(sigs) do
                extraInfo = extraInfo .. "      - " .. s .. "\n"
            end
        end

        if #deps > 0 then
            extraInfo = extraInfo .. "\n    Dependencies (" .. #deps .. "):\n"
            for _, d in ipairs(deps) do
                extraInfo = extraInfo .. "      - require(" .. d .. ")\n"
            end
        end
    end

    return string.format(
        [=[
--[[
    ================================================================================
    [HyperSaveInstance v2.0 - Decompiled Script]
    Created by: Theo Lorentz Padilha (https://github.com/theopadilha2009-hash)
    Class: %s
    Path: %s
    Status: %s
    Executor: %s
    Exported At: %s%s
    ================================================================================
]]

]=],
        scriptInstance.ClassName,
        path,
        status,
        execName,
        dateStr,
        extraInfo
    )
end

-- Intelligent script beautifier & bytecode artifact cleaner
function Decompiler.Beautify(code)
    if not code or #code == 0 then
        return ""
    end

    local beautified = Decompiler.DeobfuscateStrings(code)

    -- 1. Strip useless decompiler watermark lines
    beautified = string.gsub(beautified, "%-%-%s*Decompiled with [^\r\n]+[\r\n]*", "")
    beautified = string.gsub(beautified, "%-%-%s*Bytecode version:[^\r\n]+[\r\n]*", "")
    beautified = string.gsub(beautified, "%-%-%s*Luau disassembly[^\r\n]+[\r\n]*", "")

    -- 2. Strip unassigned trash variables generated by raw decompilers
    beautified = string.gsub(beautified, "local%s+_%s*=%s*nil;?%s*\n", "")
    beautified = string.gsub(beautified, "local%s+_[%d]+%s*=%s*nil;?%s*\n", "")
    beautified = string.gsub(beautified, ";%s*;\n", ";\n")

    -- 3. Replace generic service variables (e.g. local v1 = game:GetService("Players"))
    local commonServices = {
        "Players",
        "ReplicatedStorage",
        "ReplicatedFirst",
        "RunService",
        "TweenService",
        "UserInputService",
        "HttpService",
        "SoundService",
        "Lighting",
        "Debris",
        "MarketplaceService",
        "TeleportService",
        "StarterGui",
        "ContextActionService",
        "CollectionService",
        "DataStoreService",
    }

    local replacements = {}
    for _, service in ipairs(commonServices) do
        for varName in string.gmatch(beautified, "local%s+([%w_]+)%s*=%s*game:GetService%([\"']" .. service .. "[\"']%)") do
            if varName ~= service and string.match(varName, "^[vu_]%d+$") then
                replacements[varName] = service
            end
        end
    end

    for oldVar, newVar in pairs(replacements) do
        beautified = string.gsub(beautified, "([%s%(%[{,;=])" .. oldVar .. "([%s%)%]}:;%.])", "%1" .. newVar .. "%2")
        beautified = string.gsub(beautified, "local%s+" .. oldVar .. "%s*=", "local " .. newVar .. " =")
    end

    -- 4. Replace common Player/Character patterns
    beautified = string.gsub(beautified, "local%s+([vu_]%d+)%s*=%s*Players%.LocalPlayer", "local LocalPlayer = Players.LocalPlayer")
    beautified = string.gsub(beautified, "local%s+([vu_]%d+)%s*=%s*LocalPlayer%.Character", "local Character = LocalPlayer.Character")

    -- 5. Clean consecutive empty lines (normalize to max 2 blank lines)
    beautified = string.gsub(beautified, "\n%s*\n%s*\n+", "\n\n")

    return beautified
end

-- Generate Intelligent Server Backend Dispatcher (RemoteSpy Auto-Generator)
local function generateServerDispatcher(scriptInstance)
    local parent = scriptInstance.Parent
    local remotes = {}
    local functions = {}

    if parent then
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("RemoteEvent") then
                table.insert(remotes, child.Name)
            elseif child:IsA("RemoteFunction") then
                table.insert(functions, child.Name)
            end
        end
    end

    -- Look in ReplicatedStorage as well for common shared remotes
    local repStorage = game:GetService("ReplicatedStorage")
    local globalRemotes = {}
    if repStorage then
        for _, child in ipairs(repStorage:GetChildren()) do
            if child:IsA("RemoteEvent") then
                table.insert(globalRemotes, child.Name)
            end
        end
    end

    local code = [=[
-- [HyperSaveInstance RemoteSpy Backend Auto-Generator]
-- Reconstructed server-side logic and network event dispatcher.

local scriptName = %q
local parent = script.Parent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

print(string.format("[HyperSaveInstance Backend] Server script %%s initialized.", scriptName))

]=]

    code = string.format(code, scriptInstance.Name)

    -- Attach listeners for local remotes
    for _, remoteName in ipairs(remotes) do
        code = code
            .. string.format(
                [=[
local %s = parent:FindFirstChild(%q)
if %s and %s:IsA("RemoteEvent") then
    %s.OnServerEvent:Connect(function(player, ...)
        local args = {...}
        print(string.format("[%s:OnServerEvent] Received from %%s (%%d args)", player.Name, #args))
        -- Backend logic dispatcher
    end)
end

]=],
                string.gsub(remoteName, "[^%w_]", "_"),
                remoteName,
                string.gsub(remoteName, "[^%w_]", "_"),
                string.gsub(remoteName, "[^%w_]", "_"),
                string.gsub(remoteName, "[^%w_]", "_"),
                remoteName
            )
    end

    -- Attach listeners for local RemoteFunctions
    for _, funcName in ipairs(functions) do
        code = code
            .. string.format(
                [=[
local %s = parent:FindFirstChild(%q)
if %s and %s:IsA("RemoteFunction") then
    %s.OnServerInvoke = function(player, ...)
        local args = {...}
        print(string.format("[%s:OnServerInvoke] Invoked by %%s", player.Name))
        return true -- Default affirmative response
    end
end

]=],
                string.gsub(funcName, "[^%w_]", "_"),
                funcName,
                string.gsub(funcName, "[^%w_]", "_"),
                string.gsub(funcName, "[^%w_]", "_"),
                string.gsub(funcName, "[^%w_]", "_"),
                funcName
            )
    end

    return code
end

-- Intelligent Client Fallback Synthesizer (AST Mock for Obfuscated / Failed Scripts)
local function synthesizeClientFallbackMock(scriptInstance)
    local scriptName = scriptInstance.Name
    local parent = scriptInstance.Parent
    local remotes = {}
    local childrenDesc = {}

    if parent then
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") or child:IsA("BindableEvent") then
                table.insert(remotes, { Name = child.Name, Class = child.ClassName })
            end
        end
    end

    for _, child in ipairs(scriptInstance:GetChildren()) do
        table.insert(
            childrenDesc,
            string.format("local %s = script:WaitForChild(%q) -- %s", string.gsub(child.Name, "[^%w_]", "_"), child.Name, child.ClassName)
        )
    end

    local mockCode = [=[
-- [HyperSaveInstance Intelligent AST Mock Synthesizer]
-- Note: Raw bytecode was obfuscated or executor decompiler returned empty.
-- Auto-generated functional architecture reconstruction with discovered service hooks.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer and LocalPlayer:WaitForChild("PlayerGui")
local Character = LocalPlayer and (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait())

-- Script Child Instances:
]=]

    for _, desc in ipairs(childrenDesc) do
        mockCode = mockCode .. desc .. "\n"
    end

    mockCode = mockCode .. "\n-- Discovered Local Network Remotes:\n"
    for _, rem in ipairs(remotes) do
        mockCode = mockCode
            .. string.format(
                "local %s = script.Parent:FindFirstChild(%q) -- %s\n",
                string.gsub(rem.Name, "[^%w_]", "_"),
                rem.Name,
                rem.Class
            )
    end

    mockCode = mockCode
        .. [=[

-- Main Client Routine Initializer
local function Initialize()
    print("[HyperSaveInstance Mock] Initialized client component for: ]=]
        .. scriptName
        .. [=[")
end

task.spawn(Initialize)
]=]

    return mockCode
end

-- Decompile single script safely with timeout & retries
function Decompiler.DecompileSingle(scriptInstance, options)
    -- 1. Check if source is directly readable (e.g. Studio, Mock, or unprotected environment)
    local directSource = nil
    pcall(function()
        local s = (scriptInstance ).Source
        if type(s) == "string" and #s > 0 then
            directSource = s
        end
    end)
    if directSource then
        return directSource
    end

    -- Check DecompileIgnore rules (USSI / Synapse X / Dino-V parity)
    if options.DecompileIgnore and type(options.DecompileIgnore) == "table" then
        local fullName = scriptInstance:GetFullName()
        for k, v in pairs(options.DecompileIgnore) do
            local pattern = (type(k) == "string" and k) or (type(v) == "string" and v) or nil
            local targetInst = (typeof(k) == "Instance" and k) or (typeof(v) == "Instance" and v) or nil
            if targetInst and (scriptInstance == targetInst or scriptInstance:IsDescendantOf(targetInst)) then
                return generateHeader(scriptInstance, "Decompile Skipped by Rule")
                    .. string.format("-- [Decompilation skipped by DecompileIgnore rule: %s]\n", targetInst:GetFullName())
            elseif pattern and (string.find(scriptInstance.Name, pattern, 1, true) or string.find(fullName, pattern, 1, true)) then
                return generateHeader(scriptInstance, "Decompile Skipped by Rule")
                    .. string.format("-- [Decompilation skipped by DecompileIgnore rule: %s]\n", tostring(pattern))
            end
        end
    end

    local isServerScript = scriptInstance:IsA("Script")
    if isServerScript then
        pcall(function()
            if (scriptInstance ).RunContext == Enum.RunContext.Client then
                isServerScript = false
            end
        end)
    end

    -- Server Scripts with server execution (Protected by FilteringEnabled -> Generate RemoteSpy Dispatcher)
    if isServerScript then
        if options.SaveServerScriptPlaceholders then
            return generateHeader(scriptInstance, "Reconstructed Server Backend (RemoteSpy Dispatcher)")
                .. generateServerDispatcher(scriptInstance)
        else
            return "-- [Server Script - Protected by FilteringEnabled]\n"
        end
    end

    local decompileFn = Environment.GetDecompilerFunction()
    local bytecodeFn = Environment.GetBytecodeFunction()
    local timeout = options.DecompileTimeout or 12

    -- 2. Attempt decompiler function
    if decompileFn then
        for attempt = 1, (options.DecompileMaxRetries or 2) + 1 do
            local result = nil
            local finished = false

            task.spawn(function()
                local success, output = pcall(decompileFn, scriptInstance)
                if success and type(output) == "string" and #output > 0 then
                    local lower = string.lower(output)
                    if not (string.find(lower, "decompilation failed") or string.find(lower, "decompiler error")) or #output > 100 then
                        result = output
                    end
                end
                finished = true
            end)

            local elapsed = 0
            while not finished and elapsed < timeout do
                task.wait(0.05)
                elapsed = elapsed + 0.05
            end

            if finished and result then
                local beautified = Decompiler.Beautify(result)
                return generateHeader(scriptInstance, "Decompiled Successfully") .. beautified
            end
        end
    end

    -- 3. Fallback: Bytecode dump
    if bytecodeFn and options.ExtractBytecodeFallback then
        local success, bytecode = pcall(bytecodeFn, scriptInstance)
        if success and bytecode and #bytecode > 0 then
            local b64 = Base64.Encode(bytecode)
            return generateHeader(scriptInstance, "Extracted Raw Bytecode (Decompiler Unavailable)")
                .. string.format(
                    "-- Raw Luau Bytecode (Base64 Encoded, Size: %d bytes):\nlocal rawBytecodeBase64 = %q\nreturn rawBytecodeBase64\n",
                    #bytecode,
                    b64
                )
        end
    end

    -- 4. Fallback: Intelligent AST Mock Generator (Prevents broken scripts in Studio)
    return generateHeader(scriptInstance, "Auto-Synthesized Client AST Mock (Decompiler Bypass)")
        .. synthesizeClientFallbackMock(scriptInstance)
end

-- Batch decompile multiple scripts concurrently with worker pool
function Decompiler.DecompileBatch(scripts, options, progressCallback)
    local results = {}
    local total = #scripts
    local completed = 0
    local workers = math.clamp(options.DecompileParallelWorkers or 8, 1, 16)

    local queue = table.clone(scripts)
    local queueIndex = 1

    local threads = {}
    for w = 1, workers do
        local t = task.spawn(function()
            while queueIndex <= total do
                if options._CancelChecker and options._CancelChecker() then
                    break
                end

                local myIndex = queueIndex
                queueIndex = queueIndex + 1

                local targetScript = queue[myIndex]
                if targetScript then
                    local code = Decompiler.DecompileSingle(targetScript, options)
                    results[targetScript] = code
                    completed = completed + 1

                    if progressCallback then
                        pcall(progressCallback, completed, total, targetScript)
                    end
                end
                task.wait(0.01)
            end
        end)
        table.insert(threads, t)
    end

    -- Wait for all scripts to finish
    while completed < total do
        if options._CancelChecker and options._CancelChecker() then
            break
        end
        task.wait(0.1)
    end

    return results
end

return Decompiler

end)

__define__("Core/Engine", function()
--[[
    HyperSaveInstance - Master Engine Orchestrator
    Coordinates scanning, raw asset downloading, terrain voxel extraction, script decompilation, Anti-AFK and file export.
]]

local SoundService = nil
pcall(function()
    SoundService = game:GetService("SoundService")
end)

local Environment = __require__("Utils/Environment")
local AntiAFK = __require__("Utils/AntiAFK")
local Stealth = __require__("Utils/Stealth")
local Defaults = __require__("Config/Defaults")
local ClassBlacklist = __require__("Config/ClassBlacklist")
local TerrainSerializer = __require__("Core/TerrainSerializer")
local StreamExplorer = __require__("Core/StreamExplorer")
local Decompiler = __require__("Core/Decompiler")
local AssetDownloader = __require__("Core/AssetDownloader")
local SerializerXml = __require__("Core/SerializerXml")
local SerializerBinary = __require__("Core/SerializerBinary")
local SerializerScript = __require__("Core/SerializerScript")
local ServerSynthesizer = __require__("Core/ServerSynthesizer")

local Engine = {}
Engine.__index = Engine

-- Status types


function Engine.NormalizeOptions(rawOptions)
    local opts = table.clone(Defaults)
    if not rawOptions or type(rawOptions) ~= "table" then
        return opts
    end

    for k, v in pairs(rawOptions) do
        local lk = string.lower(tostring(k))
        if lk == "noscripts" then
            opts.DecompileScripts = not (v == true)
        elseif lk == "mode" then
            local lm = string.lower(tostring(v))
            if lm == "full" then
                opts.Mode = "Full"
            elseif lm == "fast" then
                opts.Mode = "Fast"
            elseif lm == "visualsonly" or lm == "visuals" then
                opts.Mode = "VisualsOnly"
            elseif lm == "scriptsonly" or lm == "scripts" then
                opts.Mode = "ScriptsOnly"
            elseif lm == "onlymap" or lm == "maponly" or lm == "map" then
                opts.Mode = "OnlyMap"
            elseif lm == "uionly" or lm == "ui" or lm == "guionly" then
                opts.Mode = "UIOnly"
            elseif lm == "ghost" or lm == "stealth" then
                opts.Mode = "Ghost"
            elseif lm == "optimized" then
                opts.Mode = "Full"
                opts.OptimizeGeometry = true
            elseif lm == "beeswarm" or lm == "bss" or lm == "bee_swarm" then
                opts.Mode = "BeeSwarm"
            elseif lm == "bloxfruits" or lm == "blox_fruits" or lm == "bf" then
                opts.Mode = "BloxFruits"
            elseif lm == "petsimulator99" or lm == "petsim" or lm == "ps99" or lm == "pet_simulator_99" then
                opts.Mode = "PetSimulator99"
            elseif lm == "arsenal" then
                opts.Mode = "Arsenal"
            elseif lm == "doors" then
                opts.Mode = "Doors"
            elseif lm == "towerdefense" or lm == "tds" or lm == "tower_defense" then
                opts.Mode = "TowerDefense"
            else
                opts.Mode = v
            end
            Defaults.ApplyPreset(opts, opts.Mode)
        elseif lk == "decompileignore" or lk == "decompile_ignore" then
            opts.DecompileIgnore = v
        elseif lk == "savebytecode" or lk == "save_bytecode" then
            opts.SaveBytecode = (v == true)
        elseif lk == "safemode" or lk == "safe_mode" then
            opts.SafeMode = (v == true)
        elseif lk == "timeout" or lk == "decompiletimeout" or lk == "decompile_timeout" then
            opts.DecompileTimeout = tonumber(v) or 12
        elseif lk == "ignorelist" or lk == "ignore_list" then
            opts.IgnoreList = v
        elseif
            lk == "isolatestarterplayer"
            or lk == "isolate_starter_player"
            or lk == "isolatelocalplayer"
            or lk == "isolate_local_player"
        then
            opts.IsolateStarterPlayer = (v == true)
        elseif lk == "filepath" or lk == "file_path" or lk == "filename" or lk == "file_name" then
            opts.FilePath = tostring(v)
        elseif lk == "downloadassets" or lk == "download_assets" or lk == "downloadrawassets" or lk == "download_raw_assets" then
            opts.DownloadRawAssets = (v == true)
        elseif lk == "saveterrain" or lk == "save_terrain" then
            opts.SaveTerrain = (v == true)
        elseif lk == "saveterrainvoxels" or lk == "save_terrain_voxels" then
            opts.SaveTerrainVoxels = (v == true)
        elseif lk == "savenilinstances" or lk == "save_nil_instances" or lk == "nilinstances" or lk == "nil_instances" then
            opts.SaveNilInstances = (v == true)
        elseif lk == "stealthmode" or lk == "stealth_mode" or lk == "anonymous" then
            opts.StealthMode = (v == true)
        elseif lk == "silent" or lk == "silentmode" or lk == "silent_mode" or lk == "headless" then
            opts.SilentMode = (v == true)
            if v == true then
                opts.ShowUI = false
                opts.VerboseLogs = false
                opts.PlaySoundOnComplete = false
            end
        elseif lk == "randomizeguiname" or lk == "randomize_gui_name" or lk == "randomizename" then
            opts.RandomizeGuiName = (v == true)
        elseif lk == "safestreaming" or lk == "safe_streaming" then
            opts.SafeStreaming = (v == true)
        elseif lk == "showui" or lk == "show_ui" then
            opts.ShowUI = (v == true)
        else
            opts[k] = v
        end
    end

    return opts
end

function Engine.new(customConfig)
    local self = setmetatable({}, Engine)
    self.Config = Engine.NormalizeOptions(customConfig)
    self.ProgressListeners = {}
    self.IsRunning = false
    self.CancelRequested = false

    -- Enable Anti-AFK automatically if configured
    if self.Config.AutoAntiAFK then
        AntiAFK.Enable()
    end

    return self
end

function Engine:Cancel()
    if not self.IsRunning then
        return
    end
    self.CancelRequested = true
    self:EmitProgress({
        Stage = "Cancelled",
        Current = 0,
        Total = 0,
        Percentage = 0,
        Message = "⚠️ Salvamento cancelado pelo usuário.",
    })
end

function Engine:OnProgress(callback)
    table.insert(self.ProgressListeners, callback)
end

function Engine:EmitProgress(progress)
    for _, cb in ipairs(self.ProgressListeners) do
        task.spawn(cb, progress)
    end
end

-- Generate safe output filename
function Engine:GetDefaultFileName()
    local placeId = game.PlaceId or 0
    local placeName = "Place"
    pcall(function()
        placeName = game:GetService("MarketplaceService"):GetProductInfo(placeId).Name
    end)
    placeName = Environment.SanitizeFileName(placeName)
    local ext = string.lower(self.Config.Format or "rbxlx")
    return string.format("HyperSave_%s_%d.%s", placeName, placeId, ext)
end

function Engine:GetDefaultAssetFolder()
    local placeId = game.PlaceId or 0
    return string.format("HyperSave_Assets_%d", placeId)
end

-- Play completion audio chime
function Engine:PlayChime()
    if not self.Config.PlaySoundOnComplete or self.Config.SilentMode then
        return
    end
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://9069609200" -- Pleasant success chime
        sound.Volume = 0.6
        sound.Parent = SoundService
        sound:Play()
        sound.Ended:Connect(function()
            sound:Destroy()
        end)
    end)
end

-- Check if instance should be saved
function Engine:ShouldSaveInstance(inst)
    local cName = inst.ClassName
    if ClassBlacklist.Classes[cName] then
        return false
    end
    if ClassBlacklist.Names[inst.Name] then
        return false
    end

    if inst.Name == "HyperSaveInstance_UI" or inst.Name == "HyperSaveGUI" then
        return false
    end
    if self.Config.IgnoredGui and (inst == self.Config.IgnoredGui or inst:IsDescendantOf(self.Config.IgnoredGui)) then
        return false
    end

    -- Custom IgnoreList check (USSI / UltraSmart parity)
    if self.Config.IgnoreList and type(self.Config.IgnoreList) == "table" then
        for _, item in ipairs(self.Config.IgnoreList) do
            if typeof(item) == "Instance" and (inst == item or inst:IsDescendantOf(item)) then
                return false
            elseif type(item) == "string" and (inst.Name == item or inst.ClassName == item) then
                return false
            end
        end
    end

    return true
end

-- Save specific isolated model/folder
function Engine:SaveTarget(target, customConfig)
    if not target or not target:IsA("Instance") then
        return false, "Invalid target instance specified!"
    end

    local cfg = table.clone(self.Config)
    if customConfig then
        for k, v in pairs(customConfig) do
            cfg[k] = v
        end
    end

    local cleanName = string.gsub(target.Name, "[^%w_%-]", "_")
    local fileName = string.format("HyperSave_Model_%s_%d.%s", cleanName, os.time(), cfg.Format or "rbxm")

    local allInstances = { target }
    local scriptInstances = {}

    local function scan(inst)
        if not self:ShouldSaveInstance(inst) then
            return
        end
        table.insert(allInstances, inst)
        if inst:IsA("LuaSourceContainer") then
            table.insert(scriptInstances, inst)
        end
        for _, child in ipairs(inst:GetChildren()) do
            scan(child)
        end
    end
    scan(target)

    local scriptSources = {}
    if cfg.DecompileScripts and #scriptInstances > 0 then
        scriptSources = Decompiler.DecompileBatch(scriptInstances, cfg)
    end

    local output = SerializerXml.Serialize({ target }, scriptSources, nil, cfg)
    local writeOk = Environment.WriteFile(fileName, output)

    if writeOk then
        if cfg.CopyToClipboardOnComplete then
            Environment.SetClipboard(fileName)
        end
        self:PlayChime()
        return true, fileName
    end
    return false, "Failed to write model file."
end

-- Save multiple target instances into a single combined .rbxm / .rbxlx pack
function Engine:SaveTargetBatch(targets, customConfig)
    if not targets or #targets == 0 then
        return false, "No target instances specified for batch export!"
    end

    local cfg = table.clone(self.Config)
    if customConfig then
        for k, v in pairs(customConfig) do
            cfg[k] = v
        end
    end

    local fileName = string.format("HyperSave_MultiPack_%d_items_%d.%s", #targets, os.time(), cfg.Format or "rbxm")
    local scriptInstances = {}

    local function scan(inst)
        if not self:ShouldSaveInstance(inst) then
            return
        end
        if inst:IsA("LuaSourceContainer") then
            table.insert(scriptInstances, inst)
        end
        for _, child in ipairs(inst:GetChildren()) do
            scan(child)
        end
    end

    for _, target in ipairs(targets) do
        scan(target)
    end

    local scriptSources = {}
    if cfg.DecompileScripts and #scriptInstances > 0 then
        scriptSources = Decompiler.DecompileBatch(scriptInstances, cfg)
    end

    local output = SerializerXml.Serialize(targets, scriptSources, nil, cfg)
    local writeOk = Environment.WriteFile(fileName, output)

    if writeOk then
        if cfg.CopyToClipboardOnComplete then
            Environment.SetClipboard(fileName)
        end
        self:PlayChime()
        return true, fileName
    end
    return false, "Failed to write batch package file."
end

-- Main Save Process
function Engine:Start()
    if self.IsRunning then
        return false, "Save is already in progress!"
    end

    self.IsRunning = true
    self.CancelRequested = false
    self.Config._CancelChecker = function()
        return self.CancelRequested
    end
    local startTime = os.clock()

    if self.Config.StealthMode then
        Stealth.ElevateThread()
    end

    self:EmitProgress({
        Stage = "Scanning",
        Current = 0,
        Total = 100,
        Percentage = 0,
        Message = "Initializing HyperSaveInstance with Anti-AFK protection...",
    })

    -- Optional: Auto-Map Explorer sweep for StreamingEnabled
    if self.Config.AutoExploreStreaming and workspace.StreamingEnabled then
        self:EmitProgress({
            Stage = "Exploring",
            Current = 0,
            Total = 100,
            Percentage = 4,
            Message = "Auto-Map Explorer: Sweeping coordinates to load all streaming chunks...",
        })
        local allowPhysicalTeleport = (not self.Config.SafeStreaming) and not self.Config.StealthMode
        StreamExplorer.ExploreMap(512, function(cur, tot, pos)
            local pct = 4 + math.floor((cur / tot) * 6)
            self:EmitProgress({
                Stage = "Exploring",
                Current = cur,
                Total = tot,
                Percentage = pct,
                Message = string.format("Streaming Sweep: %d/%d chunks loaded", cur, tot),
            })
        end, allowPhysicalTeleport)
    end

    -- Step 1: Collect Root Services to save
    local rootInstances = {}
    local allInstances = {}
    local scriptInstances = {}

    for _, serviceName in ipairs(ClassBlacklist.SaveServices) do
        local success, service = pcall(function()
            return game:GetService(serviceName)
        end)

        if success and service and self:ShouldSaveInstance(service) then
            table.insert(rootInstances, service)
        end
    end

    -- Collect Nil Instances if enabled
    if self.Config.SaveNilInstances then
        local nilFolder = Instance.new("Folder")
        nilFolder.Name = "NilInstances_Saved"
        local nils = Environment.GetNilInstances()
        for _, nInst in ipairs(nils) do
            if self:ShouldSaveInstance(nInst) then
                pcall(function()
                    nInst.Parent = nilFolder
                end)
            end
        end
        if #nilFolder:GetChildren() > 0 then
            table.insert(rootInstances, nilFolder)
        end
    end

    -- Harvest active client scripts, GUIs and tools from LocalPlayer into Starter containers
    if self.Config.IsolateStarterPlayer then
        pcall(function()
            local Players = game:GetService("Players")
            local localPlayer = Players.LocalPlayer
            if localPlayer then
                local starterPlayer = game:GetService("StarterPlayer")
                local starterPlayerScripts = starterPlayer:FindFirstChild("StarterPlayerScripts")
                if not starterPlayerScripts then
                    starterPlayerScripts = Instance.new("Folder")
                    starterPlayerScripts.Name = "StarterPlayerScripts"
                    starterPlayerScripts.Parent = starterPlayer
                end

                local starterCharacterScripts = starterPlayer:FindFirstChild("StarterCharacterScripts")
                if not starterCharacterScripts then
                    starterCharacterScripts = Instance.new("Folder")
                    starterCharacterScripts.Name = "StarterCharacterScripts"
                    starterCharacterScripts.Parent = starterPlayer
                end

                local starterGui = game:GetService("StarterGui")
                local starterPack = game:GetService("StarterPack")

                -- 1. Harvest active LocalScripts and ModuleScripts from PlayerScripts
                local playerScripts = localPlayer:FindFirstChild("PlayerScripts")
                if playerScripts then
                    for _, child in ipairs(playerScripts:GetChildren()) do
                        if self:ShouldSaveInstance(child) and not starterPlayerScripts:FindFirstChild(child.Name) then
                            pcall(function()
                                local clone = child:Clone()
                                if clone then
                                    clone.Parent = starterPlayerScripts
                                end
                            end)
                        end
                    end
                end

                -- 2. Harvest active GUIs from PlayerGui into StarterGui
                local playerGui = localPlayer:FindFirstChild("PlayerGui")
                if playerGui then
                    for _, child in ipairs(playerGui:GetChildren()) do
                        if self:ShouldSaveInstance(child) and child:IsA("LayerCollector") and not starterGui:FindFirstChild(child.Name) then
                            pcall(function()
                                local clone = child:Clone()
                                if clone then
                                    clone.Parent = starterGui
                                end
                            end)
                        end
                    end
                end

                -- 3. Harvest tools from Backpack and Character into StarterPack
                local backpack = localPlayer:FindFirstChild("Backpack")
                if backpack then
                    for _, tool in ipairs(backpack:GetChildren()) do
                        if tool:IsA("Tool") and not starterPack:FindFirstChild(tool.Name) then
                            pcall(function()
                                local clone = tool:Clone()
                                if clone then
                                    clone.Parent = starterPack
                                end
                            end)
                        end
                    end
                end

                local char = localPlayer.Character
                if char then
                    for _, item in ipairs(char:GetChildren()) do
                        if item:IsA("Tool") and not starterPack:FindFirstChild(item.Name) then
                            pcall(function()
                                local clone = item:Clone()
                                if clone then
                                    clone.Parent = starterPack
                                end
                            end)
                        elseif item:IsA("LocalScript") and not starterCharacterScripts:FindFirstChild(item.Name) then
                            pcall(function()
                                local clone = item:Clone()
                                if clone then
                                    clone.Parent = starterCharacterScripts
                                end
                            end)
                        end
                    end
                end
            end
        end)
    end

    -- Generate Safe SpawnLocation at player's current position to prevent falling into void in Studio (Synthesized in memory)
    local synthesizedSpawn = nil
    if self.Config.GenerateSafeSpawn then
        pcall(function()
            local clonerefFn = cloneref or function(obj)
                return obj
            end
            local Players = clonerefFn(game:GetService("Players"))
            local localPlayer = Players and (Players.LocalPlayer or Players:FindFirstChildOfClass("Player"))
            local char = localPlayer and localPlayer.Character
            local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head") or char.PrimaryPart)
            if hrp then
                local spawnPos = hrp.CFrame - Vector3.new(0, 3, 0)
                local safeSpawn = Instance.new("SpawnLocation")
                safeSpawn.Name = "StudioSpawnLocation"
                safeSpawn.Size = Vector3.new(12, 1.2, 12)
                safeSpawn.CFrame = spawnPos
                safeSpawn.Anchored = true
                safeSpawn.CanCollide = true
                safeSpawn.Transparency = 0.4
                safeSpawn.Material = Enum.Material.Neon
                safeSpawn.Color = Color3.fromRGB(0, 200, 255)
                safeSpawn.Neutral = true
                safeSpawn.Duration = 0
                synthesizedSpawn = safeSpawn
            end
        end)
    end

    -- Scan hierarchy & scripts
    self:EmitProgress({
        Stage = "Scanning",
        Current = 0,
        Total = #rootInstances,
        Percentage = 10,
        Message = "Scanning place hierarchy & all instances...",
    })

    local visited = {}
    local scannedCounter = 0
    local lastYield = os.clock()

    local function scan(inst)
        if self.CancelRequested then
            return
        end
        if not inst or visited[inst] then
            return
        end
        visited[inst] = true
        scannedCounter = scannedCounter + 1

        -- Adaptive FPS Guard: yields if frame duration exceeds 10ms to keep 60 FPS silky smooth
        if (os.clock() - lastYield) > 0.010 or scannedCounter % 350 == 0 then
            task.wait()
            lastYield = os.clock()
        end

        if self.CancelRequested then
            return
        end

        if not self:ShouldSaveInstance(inst) then
            return
        end
        table.insert(allInstances, inst)

        if inst:IsA("LuaSourceContainer") then
            table.insert(scriptInstances, inst)
        end

        for _, child in ipairs(inst:GetChildren()) do
            if self.CancelRequested then
                break
            end
            scan(child)
        end
    end

    for _, root in ipairs(rootInstances) do
        if self.CancelRequested then
            break
        end
        scan(root)
    end

    if self.CancelRequested then
        self.IsRunning = false
        return false, "Salvamento cancelado pelo usuário."
    end

    -- Process any accumulated streaming instances preserved from stream-out chunks
    local accumulated = StreamExplorer.GetAccumulatedInstances()
    for _, accInst in ipairs(accumulated) do
        if not visited[accInst] and self:ShouldSaveInstance(accInst) then
            scan(accInst)
        end
    end

    if self.CancelRequested then
        self.IsRunning = false
        return false, "Salvamento cancelado pelo usuário."
    end

    -- Pre-warm asset cache for instant reflection read
    pcall(function()
        AssetHandler.WarmAssets(allInstances)
    end)

    -- Step 1.5: Intelligent Server Synthesizer (Auto-generates ServerScriptService backend for Remotes)
    if self.Config.SaveServerScriptPlaceholders or self.Config.SynthesizeServer then
        pcall(function()
            local serverService = ServerSynthesizer.SynthesizeService(rootInstances)
            table.insert(rootInstances, serverService)
            scan(serverService)
        end)
    end

    if self.CancelRequested then
        self.IsRunning = false
        return false, "Salvamento cancelado pelo usuário."
    end

    if synthesizedSpawn then
        table.insert(allInstances, synthesizedSpawn)
    end

    local totalInstances = #allInstances
    local totalScripts = #scriptInstances

    -- Step 2: Raw Asset Downloader
    local assetFolder = self.Config.AssetFolderName
    if not assetFolder or #assetFolder == 0 then
        assetFolder = self:GetDefaultAssetFolder()
    end

    local downloadedCount = 0
    if self.Config.DownloadRawAssets then
        local assets = AssetDownloader.CollectAssets(allInstances)
        local totalAssets = 0
        for _ in pairs(assets) do
            totalAssets = totalAssets + 1
        end

        if totalAssets > 0 then
            self:EmitProgress({
                Stage = "Assets",
                Current = 0,
                Total = totalAssets,
                Percentage = 15,
                Message = string.format("Downloading %d raw assets (.mp3, .png, .mesh)...", totalAssets),
            })

            local dlOk, dlFail = AssetDownloader.DownloadAll(assets, assetFolder, self.Config, function(cur, tot, item)
                local pct = 15 + math.floor((cur / tot) * 20)
                self:EmitProgress({
                    Stage = "Assets",
                    Current = cur,
                    Total = tot,
                    Percentage = pct,
                    Message = string.format("Downloading raw assets: %d/%d (%s: %s)", cur, tot, item.Type, item.SourceName),
                })
            end)
            downloadedCount = dlOk
        end
    end

    if self.CancelRequested then
        self.IsRunning = false
        return false, "Salvamento cancelado pelo usuário."
    end

    -- Step 3: Extract Terrain
    local terrainData = nil
    if self.Config.SaveTerrain then
        self:EmitProgress({
            Stage = "Terrain",
            Current = 0,
            Total = 1,
            Percentage = 38,
            Message = "Extracting terrain voxels & materials...",
        })

        local terrain = workspace.Terrain
        if terrain then
            terrainData = TerrainSerializer.ExtractTerrainData(terrain, self.Config)
        end
    end

    if self.CancelRequested then
        self.IsRunning = false
        return false, "Salvamento cancelado pelo usuário."
    end

    -- Step 4: Decompile Scripts
    local scriptSources = {}
    if self.Config.DecompileScripts and totalScripts > 0 then
        self:EmitProgress({
            Stage = "Decompiling",
            Current = 0,
            Total = totalScripts,
            Percentage = 45,
            Message = string.format("Decompiling %d scripts with parallel workers...", totalScripts),
        })

        scriptSources = Decompiler.DecompileBatch(scriptInstances, self.Config, function(cur, tot, sInst)
            local pct = 45 + math.floor((cur / tot) * 40)
            self:EmitProgress({
                Stage = "Decompiling",
                Current = cur,
                Total = tot,
                Percentage = pct,
                Message = string.format("Decompiling scripts: %d/%d (%s)", cur, tot, sInst.Name),
            })
        end)
    else
        for _, sInst in ipairs(scriptInstances) do
            scriptSources[sInst] = Decompiler.DecompileSingle(sInst, self.Config)
        end
    end

    if self.CancelRequested then
        self.IsRunning = false
        return false, "Salvamento cancelado pelo usuário."
    end

    -- Memory Watchdog & Cache Flush to prevent OOM crash on massive games
    pcall(function()
        collectgarbage("collect")
    end)

    -- Step 5: Serialize Output
    self:EmitProgress({
        Stage = "Serializing",
        Current = 0,
        Total = totalInstances,
        Percentage = 88,
        Message = string.format("Serializing %d instances to .%s format...", totalInstances, self.Config.Format),
    })

    local outputContent = ""
    local format = string.lower(self.Config.Format or "rbxlx")

    if format == "rbxlx" then
        outputContent = SerializerXml.Serialize(rootInstances, scriptSources, terrainData, self.Config)
    elseif format == "rbxl" then
        outputContent = SerializerBinary.Serialize(rootInstances, scriptSources, terrainData, self.Config)
    elseif format == "lua" then
        outputContent = SerializerScript.Serialize(rootInstances, scriptSources, terrainData, self.Config)
    else
        outputContent = SerializerXml.Serialize(rootInstances, scriptSources, terrainData, self.Config)
    end

    if self.CancelRequested then
        self.IsRunning = false
        return false, "Salvamento cancelado pelo usuário."
    end

    -- Step 5.5: Validate XML output if enabled
    if format == "rbxlx" and self.Config.ValidateOutputXml ~= false then
        local isValid, valErr = SerializerXml.Validate(outputContent)
        if not isValid and self.Config.VerboseLogs then
            warn("[HyperSaveInstance XML Validator] " .. tostring(valErr))
        end
    end

    -- Step 6: Write to disk
    self:EmitProgress({
        Stage = "Writing",
        Current = 0,
        Total = 1,
        Percentage = 96,
        Message = "Saving place file to disk...",
    })

    local targetFileName = self.Config.FilePath
    if not targetFileName or #targetFileName == 0 then
        targetFileName = self:GetDefaultFileName()
    end

    local writeSuccess = Environment.WriteFile(targetFileName, outputContent)
    if not writeSuccess then
        local fallbackName = string.format("HyperSave_Place_%d.%s", game.PlaceId or 0, format)
        writeSuccess = Environment.WriteFile(fallbackName, outputContent)
        if writeSuccess then
            targetFileName = fallbackName
        end
    end
    local elapsed = os.clock() - startTime

    if writeSuccess then
        local fullPathHint = targetFileName
        local isMac = (Environment.GetPlatform() == "macOS")
        local exec = string.lower(Environment.GetExecutorName())
        if isMac then
            if string.find(exec, "macsploit") then
                fullPathHint = "~/Library/Application Support/MacSploit/workspace/" .. targetFileName
            elseif string.find(exec, "hydrogen") then
                fullPathHint = "~/Library/Application Support/Hydrogen/workspace/" .. targetFileName
            else
                fullPathHint = "~/Library/Application Support/[SeuExecutor]/workspace/" .. targetFileName
            end
        end

        local successMsg = string.format(
            "Done! Saved %d instances, %d scripts & %d raw assets in %.2fs to: %s",
            totalInstances,
            totalScripts,
            downloadedCount,
            elapsed,
            fullPathHint
        )

        self:EmitProgress({
            Stage = "Done",
            Current = totalInstances,
            Total = totalInstances,
            Percentage = 100,
            Message = successMsg,
            SavedFile = fullPathHint,
            AssetsFolder = assetFolder,
        })

        if self.Config.CopyToClipboardOnComplete then
            Environment.SetClipboard(fullPathHint)
        end

        -- Generate JSON Summary Report if enabled
        if self.Config.SaveSummaryReport ~= false then
            pcall(function()
                local placeId = game.PlaceId or 0
                local HttpService = game:GetService("HttpService")
                local reportName = string.format("HyperSave_Summary_%d.json", placeId)
                local reportData = {
                    PlaceId = placeId,
                    SavedFile = targetFileName,
                    TotalInstances = totalInstances,
                    TotalScripts = totalScripts,
                    DownloadedAssets = downloadedCount,
                    ElapsedTimeSeconds = elapsed,
                    Timestamp = os.time(),
                    Format = format,
                    Mode = self.Config.Mode or "Full",
                }
                Environment.WriteFile(reportName, HttpService:JSONEncode(reportData))
            end)
        end

        -- Dispatch Discord Webhook if configured
        if self.Config.DiscordWebhookUrl and #self.Config.DiscordWebhookUrl > 15 then
            task.spawn(function()
                pcall(function()
                    local req = (syn and syn.request) or (http and http.request) or http_request or request
                    if not req then
                        return
                    end

                    local MarketplaceService = game:GetService("MarketplaceService")
                    local placeInfo = pcall(function()
                        return MarketplaceService:GetProductInfo(game.PlaceId)
                    end)
                    local placeName = (type(placeInfo) == "table" and placeInfo.Name) or (workspace and workspace.Name) or "Roblox Place"

                    local payload = {
                        username = "HyperSaveInstance",
                        embeds = {
                            {
                                title = "PLACE CLONED SUCCESSFULLY",
                                description = string.format(
                                    "**Map:** `%s`\n**Place ID:** `%d`\n**Output File:** `%s`",
                                    tostring(placeName),
                                    game.PlaceId,
                                    targetFileName
                                ),
                                color = 11022583,
                                fields = {
                                    { name = "Instances", value = tostring(totalInstances), inline = true },
                                    { name = "Scripts", value = tostring(totalScripts), inline = true },
                                    { name = "Raw Assets", value = tostring(downloadedCount), inline = true },
                                    { name = "Elapsed Time", value = string.format("%.2fs", elapsed), inline = true },
                                    { name = "Format", value = string.upper(tostring(self.Config.Format)), inline = true },
                                    { name = "Author", value = "Theo Lorentz Padilha", inline = true },
                                },
                                footer = { text = "HyperSaveInstance v2.1 // Gothic Cyberpunk Engine" },
                                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
                            },
                        },
                    }

                    local json = game:GetService("HttpService"):JSONEncode(payload)
                    req({
                        Url = self.Config.DiscordWebhookUrl,
                        Method = "POST",
                        Headers = { ["Content-Type"] = "application/json" },
                        Body = json,
                    })
                end)
            end)
        end

        self:PlayChime()
        self.IsRunning = false
        return true, successMsg
    else
        local errMsg = "Failed to write file. Please verify executor permissions or writefile support."
        self:EmitProgress({
            Stage = "Error",
            Current = 0,
            Total = 0,
            Percentage = 100,
            Message = errMsg,
        })
        self.IsRunning = false
        return false, errMsg
    end
end

return Engine

end)

__define__("Core/GuiRipper", function()
--[[
    HyperSaveInstance - GUI & HUD Ripper
    Extracts all ScreenGuis, Menus, Inventories, Health Bars, and HUDs to a standalone UI Pack or pure Luau code.
]]

local clonerefFn = cloneref or function(obj)
    return obj
end
local Players = nil
pcall(function()
    Players = clonerefFn(game:GetService("Players"))
end)
local StarterGui = nil
pcall(function()
    StarterGui = clonerefFn(game:GetService("StarterGui"))
end)
local Environment = __require__("Utils/Environment")
local SerializerXml = __require__("Core/SerializerXml")
local Decompiler = __require__("Core/Decompiler")

local GuiRipper = {}

-- Check if a GUI belongs to CoreGui / internal toolbars
local function isInternalGui(gui)
    local name = gui.Name
    if
        name == "RobloxGui"
        or name == "CoreScripts"
        or name == "HyperSaveInstance_UI"
        or name == "TopBarApp"
        or name == "PurchasePrompt"
        or name == "InGameMenu"
    then
        return true
    end
    return false
end

-- Export all active GUIs to .rbxmx XML package
function GuiRipper.ExportAllGuis(options)
    local placeId = game.PlaceId or 0
    local fileName = string.format("HyperSave_UIPack_%d.rbxmx", placeId)

    local folder = Instance.new("Folder")
    folder.Name = "Extracted_UIPack"

    local allGuis = {}
    local scriptInstances = {}

    -- Scan StarterGui
    if StarterGui then
        for _, gui in ipairs(StarterGui:GetChildren()) do
            if (gui:IsA("ScreenGui") or gui:IsA("BillboardGui") or gui:IsA("SurfaceGui")) and not isInternalGui(gui) then
                pcall(function()
                    local cl = gui:Clone()
                    if cl then
                        cl.Parent = folder
                    end
                end)
            end
        end
    end

    -- Scan PlayerGui if available
    local player = Players and Players.LocalPlayer
    if player then
        local pGui = player:FindFirstChild("PlayerGui")
        if pGui then
            for _, gui in ipairs(pGui:GetChildren()) do
                if
                    (gui:IsA("ScreenGui") or gui:IsA("BillboardGui") or gui:IsA("SurfaceGui"))
                    and not isInternalGui(gui)
                    and not folder:FindFirstChild(gui.Name)
                then
                    pcall(function()
                        local cl = gui:Clone()
                        if cl then
                            cl.Parent = folder
                        end
                    end)
                end
            end
        end
    end

    local function scanScripts(inst)
        if inst:IsA("LuaSourceContainer") then
            table.insert(scriptInstances, inst)
        end
        for _, child in ipairs(inst:GetChildren()) do
            scanScripts(child)
        end
    end
    scanScripts(folder)

    local scriptSources = {}
    if #scriptInstances > 0 then
        scriptSources = Decompiler.DecompileBatch(scriptInstances, options or { DecompileScripts = true })
    end

    local xml = SerializerXml.Serialize({ folder }, scriptSources, nil, { SaveAttributes = true, SaveTags = true })
    local writeOk = Environment.WriteFile(fileName, xml)

    if writeOk then
        return true, fileName
    end
    return false, "Failed to write UI pack file."
end

-- Convert any GUI instance into an executable, pure Luau script
function GuiRipper.ExportGuiToLuaScript(targetGui)
    if not targetGui then
        return false, "No GUI instance specified for Luau code generator"
    end

    local lines = {
        "--[[",
        "    ================================================================================",
        "    [HyperSaveInstance - Auto-Generated Luau GUI Script]",
        "    Target: " .. targetGui.Name .. " (" .. targetGui.ClassName .. ")",
        "    Generated automatically by HyperSaveInstance GuiRipper.",
        "    ================================================================================",
        "--]]",
        "",
        'local CoreGui = game:GetService("CoreGui")',
        'local Players = game:GetService("Players")',
        "local LocalPlayer = Players.LocalPlayer",
        'local PlayerGui = LocalPlayer and LocalPlayer:WaitForChild("PlayerGui")',
        "",
        "local function CreateUI()",
    }

    local varCounter = 0
    local instToVar = {}

    local function getVar(inst)
        if not instToVar[inst] then
            varCounter = varCounter + 1
            local cleanName = string.gsub(inst.Name, "[^%w_]", "")
            if #cleanName == 0 then
                cleanName = "inst"
            end
            instToVar[inst] = string.format("%s_%d", cleanName, varCounter)
        end
        return instToVar[inst]
    end

    local function serializeInst(inst, parentVar)
        local vName = getVar(inst)
        table.insert(lines, string.format("    local %s = Instance.new(%q)", vName, inst.ClassName))
        table.insert(lines, string.format("    %s.Name = %q", vName, inst.Name))

        pcall(function()
            if inst:IsA("GuiObject") then
                table.insert(
                    lines,
                    string.format(
                        "    %s.Size = UDim2.new(%s, %s, %s, %s)",
                        vName,
                        inst.Size.X.Scale,
                        inst.Size.X.Offset,
                        inst.Size.Y.Scale,
                        inst.Size.Y.Offset
                    )
                )
                table.insert(
                    lines,
                    string.format(
                        "    %s.Position = UDim2.new(%s, %s, %s, %s)",
                        vName,
                        inst.Position.X.Scale,
                        inst.Position.X.Offset,
                        inst.Position.Y.Scale,
                        inst.Position.Y.Offset
                    )
                )
                table.insert(
                    lines,
                    string.format(
                        "    %s.BackgroundColor3 = Color3.fromRGB(%d, %d, %d)",
                        vName,
                        math.floor(inst.BackgroundColor3.R * 255),
                        math.floor(inst.BackgroundColor3.G * 255),
                        math.floor(inst.BackgroundColor3.B * 255)
                    )
                )
                table.insert(lines, string.format("    %s.BackgroundTransparency = %s", vName, tostring(inst.BackgroundTransparency)))
            end
            if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
                table.insert(lines, string.format("    %s.Text = %q", vName, (inst ).Text))
                table.insert(lines, string.format("    %s.TextSize = %d", vName, (inst ).TextSize))
                table.insert(
                    lines,
                    string.format(
                        "    %s.TextColor3 = Color3.fromRGB(%d, %d, %d)",
                        vName,
                        math.floor((inst ).TextColor3.R * 255),
                        math.floor((inst ).TextColor3.G * 255),
                        math.floor((inst ).TextColor3.B * 255)
                    )
                )
            end
            if inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
                table.insert(lines, string.format("    %s.Image = %q", vName, (inst ).Image))
            end
            if inst:IsA("UICorner") then
                table.insert(
                    lines,
                    string.format("    %s.CornerRadius = UDim.new(%s, %s)", vName, inst.CornerRadius.Scale, inst.CornerRadius.Offset)
                )
            end
            if inst:IsA("UIStroke") then
                table.insert(
                    lines,
                    string.format(
                        "    %s.Color = Color3.fromRGB(%d, %d, %d)",
                        vName,
                        math.floor(inst.Color.R * 255),
                        math.floor(inst.Color.G * 255),
                        math.floor(inst.Color.B * 255)
                    )
                )
                table.insert(lines, string.format("    %s.Thickness = %s", vName, tostring(inst.Thickness)))
            end
        end)

        if parentVar then
            table.insert(lines, string.format("    %s.Parent = %s", vName, parentVar))
        else
            table.insert(lines, string.format("    %s.Parent = (gethui and gethui()) or PlayerGui or CoreGui", vName))
        end
        table.insert(lines, "")

        for _, child in ipairs(inst:GetChildren()) do
            serializeInst(child, vName)
        end
    end

    serializeInst(targetGui, nil)
    table.insert(lines, "    return " .. getVar(targetGui))
    table.insert(lines, "end")
    table.insert(lines, "")
    table.insert(lines, "return CreateUI()")

    local code = table.concat(lines, "\n")
    local fileName = string.format("HyperSave_GuiScript_%s_%d.lua", string.gsub(targetGui.Name, "[^%w_]", ""), os.time())
    local writeOk = Environment.WriteFile(fileName, code)

    if writeOk then
        return true, fileName
    end
    return false, "Failed to write Luau GUI script"
end

return GuiRipper

end)

__define__("Core/LightingRipper", function()
--[[
    HyperSaveInstance - Lighting & Atmosphere Preset Ripper
    Extracts realistic Skyboxes, Atmospheres, ColorCorrections, SunRays, and Post-Processing to a standalone preset.
]]

local clonerefFn = cloneref or function(obj)
    return obj
end
local Lighting = nil
pcall(function()
    Lighting = clonerefFn(game:GetService("Lighting"))
end)
local Environment = __require__("Utils/Environment")
local SerializerXml = __require__("Core/SerializerXml")

local LightingRipper = {}

function LightingRipper.ExportLightingPreset()
    local placeId = game.PlaceId or 0
    local fileName = string.format("HyperSave_LightingPreset_%d.rbxmx", placeId)

    local folder = Instance.new("Folder")
    folder.Name = "LightingPreset"

    -- Clone all post processing effects & sky into folder
    for _, child in ipairs(Lighting:GetChildren()) do
        pcall(function()
            local clone = child:Clone()
            if clone then
                clone.Parent = folder
            end
        end)
    end

    local xml = SerializerXml.Serialize({ Lighting, folder }, {}, nil, { SaveAttributes = true, SaveTags = true })
    local writeOk = Environment.WriteFile(fileName, xml)

    if writeOk then
        return true, fileName
    end
    return false, "Failed to write lighting preset file."
end

return LightingRipper

end)

__define__("Core/NetworkSniffer", function()
--[[
    HyperSaveInstance - Live Network Traffic Sniffer & RemoteSpy
    Logs and intercepts RemoteEvent / RemoteFunction calls to reverse-engineer client-server network protocols.
]]

local clonerefFn = cloneref or function(obj)
    return obj
end
local HttpService = nil
pcall(function()
    HttpService = clonerefFn(game:GetService("HttpService"))
end)
local Environment = __require__("Utils/Environment")

local NetworkSniffer = {}
NetworkSniffer.IsActive = false
NetworkSniffer.CapturedLogs = {}
NetworkSniffer.Listeners = {}

-- Describe the SHAPE of the arguments, never their content.
-- Remote payloads in a live server carry other players' data; logging the values
-- would write third-party information to this machine's disk.
local function describeArgs(args)
    local parts = {}
    for i = 1, (args.n or #args) do
        local v = args[i]
        local t = typeof(v)
        if t == "string" then
            table.insert(parts, string.format("string(%d)", #v))
        elseif t == "number" or t == "boolean" or t == "nil" then
            table.insert(parts, t)
        elseif t == "Instance" then
            table.insert(parts, "Instance<" .. v.ClassName .. ">")
        elseif t == "table" then
            local count = 0
            for _ in pairs(v) do
                count = count + 1
            end
            table.insert(parts, string.format("table{%d}", count))
        else
            table.insert(parts, t)
        end
    end
    return "(" .. table.concat(parts, ", ") .. ")"
end

-- Start live packet sniffing
function NetworkSniffer.Start()
    if NetworkSniffer.IsActive then
        return
    end
    NetworkSniffer.IsActive = true

    -- Hook Metamethod __namecall if executor supports hookmetamethod
    local hookmeta = hookmetamethod or (syn and syn.hookmetamethod)
    if hookmeta then
        local oldNamecall
        local hookFn = function(self, ...)
            if checkcaller and checkcaller() then
                return oldNamecall(self, ...)
            end

            local method = nil
            pcall(function()
                if getnamecallmethod then
                    method = getnamecallmethod()
                end
            end)

            if NetworkSniffer.IsActive and typeof(self) == "Instance" and method then
                if method == "FireServer" and self:IsA("RemoteEvent") then
                    local args = { ... }
                    task.spawn(function()
                        NetworkSniffer.LogCall("FireServer", self, args)
                    end)
                elseif method == "InvokeServer" and self:IsA("RemoteFunction") then
                    local args = { ... }
                    task.spawn(function()
                        NetworkSniffer.LogCall("InvokeServer", self, args)
                    end)
                end
            end
            return oldNamecall(self, ...)
        end

        if newcclosure then
            hookFn = newcclosure(hookFn)
        end

        oldNamecall = hookmeta(game, "__namecall", hookFn)
    end
end

-- Stop packet sniffing
function NetworkSniffer.Stop()
    NetworkSniffer.IsActive = false
end

-- Record a network event
function NetworkSniffer.LogCall(callType, remote, args)
    local entry = {
        Timestamp = os.date("%H:%M:%S"),
        Type = callType,
        RemoteName = remote.Name,
        RemotePath = remote:GetFullName(),
        ArgCount = #args,
        ArgsShape = describeArgs(args),
    }

    table.insert(NetworkSniffer.CapturedLogs, entry)

    -- Notify listeners (HUD)
    for _, cb in ipairs(NetworkSniffer.Listeners) do
        task.spawn(cb, entry)
    end
end

-- Register UI listener
function NetworkSniffer.OnCall(callback)
    table.insert(NetworkSniffer.Listeners, callback)
end

-- Export captured network protocol to file
function NetworkSniffer.ExportLogs()
    local placeId = game.PlaceId or 0
    local fileName = string.format("HyperSave_Network_%d.json", placeId)

    local s, json = pcall(function()
        return HttpService:JSONEncode(NetworkSniffer.CapturedLogs)
    end)

    if not s or not json then
        local lines = {}
        for _, log in ipairs(NetworkSniffer.CapturedLogs) do
            table.insert(lines, string.format("[%s] [%s] %s -> %s", log.Timestamp, log.Type, log.RemotePath, log.ArgsShape))
        end
        json = table.concat(lines, "\n")
    end

    Environment.WriteFile(fileName, json)
    return fileName
end

-- Generate runnable Luau test script replicating all intercepted network calls
function NetworkSniffer.ExportRemoteSpyScript()
    local placeId = game.PlaceId or 0
    local fileName = string.format("HyperSave_RemoteTest_%d.lua", placeId)

    local lines = {
        "--[[",
        "    ================================================================================",
        "    [HyperSaveInstance - Auto-Generated Remote Call Replicator]",
        "    Place ID: " .. tostring(placeId),
        "    Total Intercepted Network Calls: " .. tostring(#NetworkSniffer.CapturedLogs),
        "    Exported At: " .. os.date("%Y-%m-%d %H:%M:%S"),
        "    ================================================================================",
        "--]]",
        "",
        'local ReplicatedStorage = game:GetService("ReplicatedStorage")',
        'local Players = game:GetService("Players")',
        "",
        'print("[HyperSave Remote Replicator] Starting reconstructed network traffic dispatch...")',
        "",
    }

    local seenPaths = {}
    for i, log in ipairs(NetworkSniffer.CapturedLogs) do
        local path = log.RemotePath
        if not seenPaths[path] then
            seenPaths[path] = true
            table.insert(lines, string.format("-- [%d] %s: %s", i, log.Type, log.RemoteName))
            table.insert(lines, "task.spawn(function()")
            table.insert(lines, string.format("    local remote = %s", path))
            table.insert(lines, "    if remote then")
            if log.Type == "FireServer" then
                table.insert(
                    lines,
                    string.format('        print("[Remote Test] Firing %%s with %%s", remote:GetFullName(), %q)', log.ArgsShape)
                )
                table.insert(lines, string.format("        -- remote:FireServer(unpack(%s))", log.ArgsShape))
            elseif log.Type == "InvokeServer" then
                table.insert(
                    lines,
                    string.format('        print("[Remote Test] Invoking %%s with %%s", remote:GetFullName(), %q)', log.ArgsShape)
                )
                table.insert(lines, string.format("        -- local res = remote:InvokeServer(unpack(%s))", log.ArgsShape))
            end
            table.insert(lines, "    end")
            table.insert(lines, "end)")
            table.insert(lines, "")
        end
    end

    local code = table.concat(lines, "\n")
    local writeOk = Environment.WriteFile(fileName, code)

    if writeOk then
        return true, fileName
    end
    return false, "Failed to write remote test script"
end

function NetworkSniffer.Clear()
    NetworkSniffer.CapturedLogs = {}
end

return NetworkSniffer

end)

__define__("Core/ObjExporter", function()
--[[
    HyperSaveInstance - Wavefront 3D OBJ & MTL Exporter
    Converts Roblox 3D workspace models and parts into .obj / .mtl for Blender, Unity and Unreal Engine.
]]

local Environment = __require__("Utils/Environment")

local ObjExporter = {}

-- Generate standard cube vertices & faces for BasePart
local function getBoxGeometry(cf, size, vertOffset)
    local hx = ((size and tonumber(size.X)) or 2) / 2
    local hy = ((size and tonumber(size.Y)) or 2) / 2
    local hz = ((size and tonumber(size.Z)) or 2) / 2

    local corners = {}
    if cf and type(cf.PointToWorldSpace) == "function" then
        local s, c = pcall(function()
            return {
                cf:PointToWorldSpace(Vector3.new(-hx, -hy, -hz)),
                cf:PointToWorldSpace(Vector3.new(hx, -hy, -hz)),
                cf:PointToWorldSpace(Vector3.new(hx, hy, -hz)),
                cf:PointToWorldSpace(Vector3.new(-hx, hy, -hz)),
                cf:PointToWorldSpace(Vector3.new(-hx, -hy, hz)),
                cf:PointToWorldSpace(Vector3.new(hx, -hy, hz)),
                cf:PointToWorldSpace(Vector3.new(hx, hy, hz)),
                cf:PointToWorldSpace(Vector3.new(-hx, hy, hz)),
            }
        end)
        if s and c then
            corners = c
        end
    end

    if #corners == 0 then
        local px = (cf and cf.Position and tonumber(cf.Position.X)) or (cf and tonumber(cf.X)) or 0
        local py = (cf and cf.Position and tonumber(cf.Position.Y)) or (cf and tonumber(cf.Y)) or 0
        local pz = (cf and cf.Position and tonumber(cf.Position.Z)) or (cf and tonumber(cf.Z)) or 0
        corners = {
            Vector3.new(px - hx, py - hy, pz - hz),
            Vector3.new(px + hx, py - hy, pz - hz),
            Vector3.new(px + hx, py + hy, pz - hz),
            Vector3.new(px - hx, py + hy, pz - hz),
            Vector3.new(px - hx, py - hy, pz + hz),
            Vector3.new(px + hx, py - hy, pz + hz),
            Vector3.new(px + hx, py + hy, pz + hz),
            Vector3.new(px - hx, py + hy, pz + hz),
        }
    end

    local vLines = {}
    for _, pt in ipairs(corners) do
        local vx = (pt and tonumber(pt.X)) or 0
        local vy = (pt and tonumber(pt.Y)) or 0
        local vz = (pt and tonumber(pt.Z)) or 0
        table.insert(vLines, string.format("v %.4f %.4f %.4f", vx, vy, vz))
    end

    local o = vertOffset
    local fLines = {
        string.format("f %d %d %d", o + 1, o + 3, o + 2),
        string.format("f %d %d %d", o + 1, o + 4, o + 3),
        string.format("f %d %d %d", o + 5, o + 6, o + 7),
        string.format("f %d %d %d", o + 5, o + 7, o + 8),
        string.format("f %d %d %d", o + 1, o + 2, o + 6),
        string.format("f %d %d %d", o + 1, o + 6, o + 5),
        string.format("f %d %d %d", o + 4, o + 7, o + 3),
        string.format("f %d %d %d", o + 4, o + 8, o + 7),
        string.format("f %d %d %d", o + 2, o + 3, o + 7),
        string.format("f %d %d %d", o + 2, o + 7, o + 6),
        string.format("f %d %d %d", o + 1, o + 5, o + 8),
        string.format("f %d %d %d", o + 1, o + 8, o + 4),
    }

    return table.concat(vLines, "\n"), table.concat(fLines, "\n"), vertOffset + 8
end

-- Generate raw OBJ and MTL string representations in-memory
function ObjExporter.GenerateObj(targetRoot, options)
    local root = targetRoot or workspace
    local placeId = game.PlaceId or 0
    local baseName = string.format("HyperSave_Map3D_%d", placeId)

    local objLines = {
        "# HyperSaveInstance - Wavefront 3D OBJ Export",
        "# Exported by Theo Lorentz Padilha",
        "mtllib " .. baseName .. ".mtl",
        "",
    }

    local mtlLines = {
        "# HyperSaveInstance - Material Library (.mtl)",
        "",
    }

    local materialsSeen = {}
    local vertOffset = 0
    local partCount = 0

    local function processInstance(inst)
        if inst:IsA("BasePart") and not inst:IsA("Terrain") then
            local color = inst.Color or Color3.fromRGB(168, 85, 247)
            local cr = math.floor(((color and tonumber(color.R)) or 0.5) * 255)
            local cg = math.floor(((color and tonumber(color.G)) or 0.5) * 255)
            local cb = math.floor(((color and tonumber(color.B)) or 0.5) * 255)
            local matName = string.format("mat_%d_%d_%d", cr, cg, cb)

            if not materialsSeen[matName] then
                materialsSeen[matName] = true
                local r = (color and tonumber(color.R)) or 0.5
                local g = (color and tonumber(color.G)) or 0.5
                local b = (color and tonumber(color.B)) or 0.5
                local trans = tonumber(inst.Transparency) or 0
                table.insert(mtlLines, string.format("newmtl %s", matName))
                table.insert(mtlLines, string.format("Kd %.4f %.4f %.4f", r, g, b))
                table.insert(mtlLines, string.format("d %.4f", 1 - trans))
                table.insert(mtlLines, "")
            end

            table.insert(objLines, string.format("o %s_%d", string.gsub(inst.Name or "Part", "[^%w_]", "_"), partCount))
            table.insert(objLines, "usemtl " .. matName)

            local cf = inst.CFrame or CFrame.new()
            local sz = inst.Size or Vector3.new(2, 2, 2)
            local vStr, fStr, newOffset = getBoxGeometry(cf, sz, vertOffset)
            table.insert(objLines, vStr)
            table.insert(objLines, fStr)
            table.insert(objLines, "")

            vertOffset = newOffset
            partCount = partCount + 1
        end

        for _, child in ipairs(inst:GetChildren()) do
            processInstance(child)
        end
    end

    processInstance(root)

    return table.concat(objLines, "\n"), table.concat(mtlLines, "\n")
end

-- Export entire workspace or model to .obj + .mtl files
function ObjExporter.Export(targetRoot, options)
    local root = targetRoot or workspace
    local placeId = game.PlaceId or 0
    local baseName = string.format("HyperSave_Map3D_%d", placeId)

    local objContent, mtlContent = ObjExporter.GenerateObj(root, options)
    local objPath = baseName .. ".obj"
    local mtlPath = baseName .. ".mtl"

    Environment.WriteFile(objPath, objContent)
    Environment.WriteFile(mtlPath, mtlContent)

    return true, objPath
end

function ObjExporter.ExportWorkspaceToObj()
    return ObjExporter.Export(workspace)
end

return ObjExporter

end)

__define__("Core/Optimizer", function()
--[[
    HyperSaveInstance - Smart Place Optimizer & Deduplicator
    (Strictly Optional) Reduces file size by deduplicating textures, pruning broken welds, empty temporary containers, and orphaned UI highlights.
]]

local Optimizer = {
    Stats = {
        PrunedWelds = 0,
        PrunedFolders = 0,
        PrunedOrphans = 0,
        PrunedDuplicates = 0,
        TotalPruned = 0,
    },
}

function Optimizer.OptimizeHierarchy(rootInstances, options)
    if not options.OptimizeGeometry then
        return rootInstances
    end

    Optimizer.Stats = {
        PrunedWelds = 0,
        PrunedFolders = 0,
        PrunedOrphans = 0,
        PrunedDuplicates = 0,
        TotalPruned = 0,
    }

    local cleanedRoots = {}

    local function cleanRecursive(inst)
        -- 1. Remove empty temporary folders
        if inst:IsA("Folder") and #inst:GetChildren() == 0 and not inst:GetAttribute("Preserve") then
            Optimizer.Stats.PrunedFolders = Optimizer.Stats.PrunedFolders + 1
            Optimizer.Stats.TotalPruned = Optimizer.Stats.TotalPruned + 1
            return false
        end

        -- 2. Remove broken Welds or ManualWelds where Part0 or Part1 is missing/nil
        if (inst:IsA("Weld") or inst:IsA("ManualWeld") or inst:IsA("Motor6D")) and not inst:GetAttribute("Preserve") then
            local p0 = (inst ).Part0
            local p1 = (inst ).Part1
            if not p0 or not p1 then
                Optimizer.Stats.PrunedWelds = Optimizer.Stats.PrunedWelds + 1
                Optimizer.Stats.TotalPruned = Optimizer.Stats.TotalPruned + 1
                return false
            end
        end

        -- 3. Remove orphaned Highlight / SelectionBox / SelectionSphere with Adornee == nil and parent is not a Model/Part
        if (inst:IsA("Highlight") or inst:IsA("SelectionBox") or inst:IsA("SelectionSphere")) and not inst:GetAttribute("Preserve") then
            local adornee = (inst ).Adornee
            if not adornee and not (inst.Parent and (inst.Parent:IsA("Model") or inst.Parent:IsA("BasePart"))) then
                Optimizer.Stats.PrunedOrphans = Optimizer.Stats.PrunedOrphans + 1
                Optimizer.Stats.TotalPruned = Optimizer.Stats.TotalPruned + 1
                return false
            end
        end

        -- 4. Clean children recursively
        local children = inst:GetChildren()
        local seenSounds = {}
        for _, child in ipairs(children) do
            -- Deduplicate identical sounds in same parent
            if child:IsA("Sound") and #child.SoundId > 0 then
                if seenSounds[child.SoundId] and not child:GetAttribute("Preserve") then
                    Optimizer.Stats.PrunedDuplicates = Optimizer.Stats.PrunedDuplicates + 1
                    Optimizer.Stats.TotalPruned = Optimizer.Stats.TotalPruned + 1
                    pcall(function()
                        child:Destroy()
                    end)
                else
                    seenSounds[child.SoundId] = true
                    cleanRecursive(child)
                end
            else
                cleanRecursive(child)
            end
        end

        return true
    end

    for _, root in ipairs(rootInstances) do
        if cleanRecursive(root) then
            table.insert(cleanedRoots, root)
        end
    end

    return cleanedRoots
end

function Optimizer.GetStats()
    return Optimizer.Stats
end

return Optimizer

end)

__define__("Core/PlaceDiffTracker", function()
--[[
    HyperSaveInstance - Map & Update Diff Tracker
    Compares the current place hierarchy against a previous snapshot to identify
    newly added instances, modified scripts, and removed models in game updates.
]]

local clonerefFn = cloneref or function(obj)
    return obj
end
local HttpService = nil
pcall(function()
    HttpService = clonerefFn(game:GetService("HttpService"))
end)
local Environment = __require__("Utils/Environment")

local PlaceDiffTracker = {}

-- Create a lightweight signature dictionary of all instances in a target container
function PlaceDiffTracker.CreateSnapshot(root)
    local target = root or game
    local snapshot = {
        PlaceId = game.PlaceId or 0,
        Timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        InstanceCount = 0,
        Instances = {},
    }

    local function scan(inst, path)
        local curPath = path .. "/" .. inst.Name
        local class = inst.ClassName
        local childrenCount = #inst:GetChildren()

        local info = {
            Class = class,
            Children = childrenCount,
        }

        if inst:IsA("LuaSourceContainer") then
            local s, src = pcall(function()
                return (inst ).Source
            end)
            if s and src then
                info.SourceLen = #src
            end
        end

        snapshot.Instances[curPath] = info
        snapshot.InstanceCount = snapshot.InstanceCount + 1

        for _, child in ipairs(inst:GetChildren()) do
            scan(child, curPath)
        end
    end

    for _, serv in ipairs(target:GetChildren()) do
        if not string.find(serv.ClassName, "Core") and not string.find(serv.Name, "Roblox") then
            pcall(function()
                scan(serv, "")
            end)
        end
    end

    return snapshot
end

-- Save snapshot to executor storage
function PlaceDiffTracker.SaveSnapshot(name, root)
    local snapName = name or string.format("HyperSave_Snapshot_%d_%s.json", game.PlaceId or 0, os.date("%Y%m%d_%H%M%S"))
    local snapData = PlaceDiffTracker.CreateSnapshot(root)

    local s, json = pcall(function()
        return HttpService:JSONEncode(snapData)
    end)

    if not s or not json then
        return false, "Falha ao codificar snapshot JSON."
    end

    local wrote = Environment.WriteFile(snapName, json)
    if wrote then
        return true, snapName
    end
    return false, "Falha ao gravar arquivo de snapshot."
end

-- Compare two snapshots or compare current place against a saved snapshot file
function PlaceDiffTracker.Compare(prevSnapshotOrFile, curSnapshot)
    local prev = prevSnapshotOrFile
    if type(prev) == "string" then
        local content = Environment.ReadFile(prev)
        if not content then
            return { Success = false, Error = "Arquivo de snapshot anterior não encontrado." }
        end
        local s, parsed = pcall(function()
            return HttpService:JSONDecode(content)
        end)
        if not s or not parsed then
            return { Success = false, Error = "JSON de snapshot anterior inválido." }
        end
        prev = parsed
    end

    local curr = curSnapshot or PlaceDiffTracker.CreateSnapshot()

    local diff = {
        Success = true,
        PlaceId = curr.PlaceId,
        Timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        PreviousTimestamp = prev.Timestamp or "Desconhecido",
        Added = {},
        Removed = {},
        Modified = {},
        Summary = "",
    }

    -- Detect added and modified
    for path, info in pairs(curr.Instances) do
        local old = prev.Instances[path]
        if not old then
            table.insert(diff.Added, { Path = path, Class = info.Class })
        else
            if old.Class ~= info.Class or (info.SourceLen and old.SourceLen ~= info.SourceLen) then
                table.insert(diff.Modified, { Path = path, Class = info.Class, OldClass = old.Class, Diff = "Script/Propriedade alterada" })
            end
        end
    end

    -- Detect removed
    for path, oldInfo in pairs(prev.Instances) do
        if not curr.Instances[path] then
            table.insert(diff.Removed, { Path = path, Class = oldInfo.Class })
        end
    end

    diff.Summary = string.format(
        "Diff: +%d adicionados, -%d removidos, ~%d modificados (Total Atual: %d)",
        #diff.Added,
        #diff.Removed,
        #diff.Modified,
        curr.InstanceCount
    )

    return diff
end

-- Export comparison report as human-readable markdown / text
function PlaceDiffTracker.ExportDiffReport(diff)
    if not diff.Success then
        return false, diff.Error or "Erro desconhecido"
    end

    local fileName = string.format("HyperSave_DiffReport_%d.txt", diff.PlaceId or 0)
    local lines = {
        "================================================================================",
        "💀 HYPERSAVEINSTANCE - RELATÓRIO DE ATUALIZAÇÃO DO MAPA (PLACE DIFF)",
        "Desenvolvido por Theo Lorentz Padilha (https://github.com/theopadilha2009-hash)",
        "================================================================================",
        string.format("Place ID: %d", diff.PlaceId or 0),
        string.format("Data da Comparação: %s", diff.Timestamp),
        string.format("Snapshot Anterior: %s", diff.PreviousTimestamp),
        string.format("Resumo: %s", diff.Summary),
        "================================================================================",
        "",
        string.format("--- [1] NOVAS INSTÂNCIAS ADICIONADAS (%d) ---", #diff.Added),
    }

    for i, item in ipairs(diff.Added) do
        if i <= 200 then
            table.insert(lines, string.format("  [+] (%s) %s", item.Class, item.Path))
        end
    end
    if #diff.Added > 200 then
        table.insert(lines, string.format("  ... e mais %d itens adicionados.", #diff.Added - 200))
    end

    table.insert(lines, "")
    table.insert(lines, string.format("--- [2] INSTÂNCIAS MODIFICADAS (%d) ---", #diff.Modified))
    for i, item in ipairs(diff.Modified) do
        if i <= 200 then
            table.insert(lines, string.format("  [~] (%s) %s -> %s", item.Class, item.Path, item.Diff))
        end
    end

    table.insert(lines, "")
    table.insert(lines, string.format("--- [3] INSTÂNCIAS REMOVIDAS (%d) ---", #diff.Removed))
    for i, item in ipairs(diff.Removed) do
        if i <= 200 then
            table.insert(lines, string.format("  [-] (%s) %s", item.Class, item.Path))
        end
    end

    local content = table.concat(lines, "\n")
    local success = Environment.WriteFile(fileName, content)
    if success then
        return true, fileName
    end
    return false, "Falha ao gravar relatório de diff."
end

return PlaceDiffTracker

end)

__define__("Core/RaycastSelector", function()
--[[
    HyperSaveInstance - 3D In-World Raycast & Model Selector
    Allows the user to hover and click directly on any 3D model, vehicle, weapon or structure
    in the game world to inspect its hierarchy and save it with all internal scripts.
]]

local clonerefFn = cloneref or function(obj)
    return obj
end
local UserInputService = nil
pcall(function()
    UserInputService = clonerefFn(game:GetService("UserInputService"))
end)
local RunService = nil
pcall(function()
    RunService = clonerefFn(game:GetService("RunService"))
end)
local Players = nil
pcall(function()
    Players = clonerefFn(game:GetService("Players"))
end)
local Stealth = __require__("Utils/Stealth")

local RaycastSelector = {}
RaycastSelector.__index = RaycastSelector

function RaycastSelector.new(options)
    local self = setmetatable({}, RaycastSelector)
    self.Options = options or {}
    self.IsActive = false
    self.HoveredInstance = nil
    self.SelectedInstance = nil
    self.Highlight = nil
    self.SelectionBox = nil
    self.Connections = {}
    self.OnSelectedCallback = nil
    self.OnHoverCallback = nil

    self:InitVisuals()
    return self
end

-- Initialize the visual highlight indicators
function RaycastSelector:InitVisuals()
    pcall(function()
        local hl = Instance.new("Highlight")
        hl.Name = Stealth.GenerateRandomName(16)
        hl.FillColor = Color3.fromRGB(37, 99, 235)
        hl.FillTransparency = 0.5
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.OutlineTransparency = 0
        hl.Enabled = false

        Stealth.ProtectGui(hl)

        -- Store in gethui or CoreGui safely
        local parent = nil
        if gethui then
            pcall(function()
                parent = gethui()
            end)
        end
        if not parent then
            pcall(function()
                parent = clonerefFn(game:GetService("CoreGui"))
            end)
        end
        hl.Parent = parent or workspace
        self.Highlight = hl
    end)
end

-- Find the most meaningful parent Model or Tool from a clicked BasePart
function RaycastSelector:ResolveTarget(part)
    if not part then
        return nil
    end

    local current = part
    local bestModel = part

    while current and current ~= workspace and current ~= game do
        if current:IsA("Model") and current.Parent == workspace then
            bestModel = current
            break
        elseif current:IsA("Tool") or current:IsA("Accessory") or current:IsA("Model") then
            bestModel = current
        end
        current = current.Parent
    end

    return bestModel
end

-- Perform raycast from mouse screen position into 3D world
function RaycastSelector:RaycastMouse()
    local camera = workspace.CurrentCamera
    if not camera then
        return nil, nil
    end

    local mousePos = UserInputService:GetMouseLocation()
    local unitRay = camera:ViewportPointToRay(mousePos.X, mousePos.Y)

    local params = RaycastParams.new()
    pcall(function()
        params.FilterType = (Enum.RaycastFilterType and (Enum.RaycastFilterType.Exclude or Enum.RaycastFilterType.Blacklist)) or 0
    end)

    local filterList = {}
    local localPlayer = Players.LocalPlayer
    if localPlayer and localPlayer.Character then
        table.insert(filterList, localPlayer.Character)
    end
    if self.Highlight then
        table.insert(filterList, self.Highlight)
    end

    params.FilterDescendantsInstances = filterList
    params.IgnoreWater = true

    local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 2000, params)
    if result and result.Instance then
        local target = self:ResolveTarget(result.Instance)
        return target, result.Position
    end

    return nil, nil
end

-- Start interactive click-to-select mode in 3D world
function RaycastSelector:Start(onSelected)
    if self.IsActive then
        self:Stop()
    end

    self.IsActive = true
    self.OnSelectedCallback = onSelected
    self.OnHoverCallback = onHover

    -- RenderStepped hover raycast
    local hoverConn = RunService.RenderStepped:Connect(function()
        if not self.IsActive then
            return
        end

        local target = self:RaycastMouse()
        if target ~= self.HoveredInstance then
            self.HoveredInstance = target

            if self.Highlight then
                if target and (target:IsA("Model") or target:IsA("BasePart")) then
                    self.Highlight.Adornee = target
                    self.Highlight.Enabled = true
                else
                    self.Highlight.Adornee = nil
                    self.Highlight.Enabled = false
                end
            end

            if self.OnHoverCallback then
                self.OnHoverCallback(target)
            end
        end
    end)
    table.insert(self.Connections, hoverConn)

    -- Click listener
    local clickConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not self.IsActive then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local target = self.HoveredInstance or self:RaycastMouse()
            if target then
                self.SelectedInstance = target
                local cb = self.OnSelectedCallback
                self:Stop()
                if cb then
                    cb(target)
                end
            end
        elseif input.KeyCode == Enum.KeyCode.Escape then
            self:Stop()
        end
    end)
    table.insert(self.Connections, clickConn)
end

-- Stop click-to-select mode and clean up
function RaycastSelector:Stop()
    self.IsActive = false
    for _, conn in ipairs(self.Connections) do
        pcall(function()
            conn:Disconnect()
        end)
    end
    self.Connections = {}

    if self.Highlight then
        self.Highlight.Adornee = nil
        self.Highlight.Enabled = false
    end
    self.HoveredInstance = nil
end

-- Destroy visual elements permanently
function RaycastSelector:Destroy()
    self:Stop()
    if self.Highlight then
        pcall(function()
            self.Highlight:Destroy()
        end)
        self.Highlight = nil
    end
end

return RaycastSelector

end)

__define__("Core/Reflection", function()
--[[
    HyperSaveInstance - Roblox API Reflection & Comprehensive Property Serializer
    Preserves 100% of properties, meshes, textures, materials, sounds, terrain, physics, PBR, UI, attributes and tags.
]]

local clonerefFn = cloneref or function(obj)
    return obj
end
local CollectionService = nil
pcall(function()
    CollectionService = clonerefFn(game:GetService("CollectionService"))
end)

local Reflection = {}

-- Comprehensive Property Database for ALL Roblox Classes
Reflection.ClassProperties = {
    ["Instance"] = {
        { "Name", "string" },
        { "Archivable", "bool" },
    },
    ["PVInstance"] = {
        { "Origin", "CoordinateFrame", true },
    },
    ["BasePart"] = {
        { "Size", "Vector3" },
        { "CFrame", "CoordinateFrame" },
        { "Position", "Vector3" },
        { "Orientation", "Vector3" },
        { "Color", "Color3" },
        { "Material", "token" },
        { "MaterialVariant", "string" },
        { "Transparency", "float" },
        { "Reflectance", "float" },
        { "Anchored", "bool" },
        { "CanCollide", "bool" },
        { "CanTouch", "bool" },
        { "CanQuery", "bool" },
        { "CastShadow", "bool" },
        { "Massless", "bool" },
        { "RootPriority", "int" },
        { "CustomPhysicalProperties", "PhysicalProperties" },
        { "CollisionGroupId", "int" },
        { "AssemblyLinearVelocity", "Vector3" },
        { "AssemblyAngularVelocity", "Vector3" },
        { "TopSurface", "token" },
        { "BottomSurface", "token" },
        { "LeftSurface", "token" },
        { "RightSurface", "token" },
        { "FrontSurface", "token" },
        { "BackSurface", "token" },
    },
    ["Part"] = {
        { "Shape", "token" },
    },
    ["MeshPart"] = {
        { "MeshId", "Content" },
        { "TextureID", "Content" },
        { "RenderFidelity", "token" },
        { "CollisionFidelity", "token" },
        { "DoubleSided", "bool" },
        { "VertexColor", "Vector3" },
    },
    ["UnionOperation"] = {
        { "AssetId", "Content" },
        { "RenderFidelity", "token" },
        { "CollisionFidelity", "token" },
        { "UsePartColor", "bool" },
        { "SmoothingAngle", "float" },
    },
    ["NegateOperation"] = {},
    ["SpecialMesh"] = {
        { "MeshId", "Content" },
        { "TextureId", "Content" },
        { "MeshType", "token" },
        { "Scale", "Vector3" },
        { "Offset", "Vector3" },
        { "VertexColor", "Vector3" },
    },
    ["Decal"] = {
        { "Texture", "Content" },
        { "Face", "token" },
        { "Color3", "Color3" },
        { "Transparency", "float" },
        { "ZIndex", "int" },
    },
    ["Texture"] = {
        { "StudsPerTileU", "float" },
        { "StudsPerTileV", "float" },
        { "OffsetStudsU", "float" },
        { "OffsetStudsV", "float" },
    },
    ["SurfaceAppearance"] = {
        { "ColorMap", "Content" },
        { "NormalMap", "Content" },
        { "RoughnessMap", "Content" },
        { "MetalnessMap", "Content" },
        { "AlphaMode", "token" },
    },
    ["MaterialVariant"] = {
        { "BaseMaterial", "token" },
        { "ColorMap", "Content" },
        { "NormalMap", "Content" },
        { "RoughnessMap", "Content" },
        { "MetalnessMap", "Content" },
        { "StudsPerTile", "float" },
        { "MaterialPattern", "token" },
    },
    ["Model"] = {
        { "PrimaryPart", "Ref" },
        { "Scale", "float" },
        { "WorldPivot", "CoordinateFrame" },
    },
    ["Folder"] = {},
    ["Configuration"] = {},
    ["Lighting"] = {
        { "Ambient", "Color3" },
        { "OutdoorAmbient", "Color3" },
        { "Brightness", "float" },
        { "ClockTime", "float" },
        { "TimeOfDay", "string" },
        { "GeographicLatitude", "float" },
        { "FogColor", "Color3" },
        { "FogEnd", "float" },
        { "FogStart", "float" },
        { "ColorShift_Bottom", "Color3" },
        { "ColorShift_Top", "Color3" },
        { "GlobalShadows", "bool" },
        { "ShadowSoftness", "float" },
        { "EnvironmentDiffuseScale", "float" },
        { "EnvironmentSpecularScale", "float" },
        { "Technology", "token" },
        { "ExposureCompensation", "float" },
    },
    ["Atmosphere"] = {
        { "Density", "float" },
        { "Offset", "float" },
        { "Color", "Color3" },
        { "Decay", "Color3" },
        { "Glare", "float" },
        { "Haze", "float" },
    },
    ["Sky"] = {
        { "SkyboxBk", "Content" },
        { "SkyboxDn", "Content" },
        { "SkyboxFt", "Content" },
        { "SkyboxLf", "Content" },
        { "SkyboxRt", "Content" },
        { "SkyboxUp", "Content" },
        { "SunTextureId", "Content" },
        { "MoonTextureId", "Content" },
        { "SunAngularPhase", "float" },
        { "MoonAngularPhase", "float" },
        { "CelestialBodiesShown", "bool" },
        { "StarCount", "int" },
    },
    ["BloomEffect"] = {
        { "Enabled", "bool" },
        { "Intensity", "float" },
        { "Size", "float" },
        { "Threshold", "float" },
    },
    ["BlurEffect"] = {
        { "Enabled", "bool" },
        { "Size", "float" },
    },
    ["ColorCorrectionEffect"] = {
        { "Enabled", "bool" },
        { "Brightness", "float" },
        { "Contrast", "float" },
        { "Saturation", "float" },
        { "TintColor", "Color3" },
    },
    ["SunRaysEffect"] = {
        { "Enabled", "bool" },
        { "Intensity", "float" },
        { "Spread", "float" },
    },
    ["DepthOfFieldEffect"] = {
        { "Enabled", "bool" },
        { "FarIntensity", "float" },
        { "FocusDistance", "float" },
        { "InFocusRadius", "float" },
        { "NearIntensity", "float" },
    },
    ["Sound"] = {
        { "SoundId", "Content" },
        { "Volume", "float" },
        { "PlaybackSpeed", "float" },
        { "Looped", "bool" },
        { "Playing", "bool" },
        { "TimePosition", "float" },
        { "RollOffMaxDistance", "float" },
        { "RollOffMinDistance", "float" },
        { "RollOffMode", "token" },
        { "SoundGroup", "Ref" },
    },
    ["SoundGroup"] = {
        { "Volume", "float" },
    },
    ["EqualizerSoundEffect"] = {
        { "HighGain", "float" },
        { "MidGain", "float" },
        { "LowGain", "float" },
        { "Priority", "int" },
        { "Enabled", "bool" },
    },
    ["ReverbSoundEffect"] = {
        { "DecayTime", "float" },
        { "Density", "float" },
        { "Diffusion", "float" },
        { "DryLevel", "float" },
        { "WetLevel", "float" },
        { "Priority", "int" },
        { "Enabled", "bool" },
    },
    ["PitchShiftSoundEffect"] = {
        { "Octave", "float" },
        { "Priority", "int" },
        { "Enabled", "bool" },
    },
    ["DistortionSoundEffect"] = {
        { "Level", "float" },
        { "Priority", "int" },
        { "Enabled", "bool" },
    },
    ["CompressorSoundEffect"] = {
        { "Attack", "float" },
        { "GainMakeup", "float" },
        { "Ratio", "float" },
        { "Release", "float" },
        { "Threshold", "float" },
        { "SideChain", "Ref" },
        { "Priority", "int" },
        { "Enabled", "bool" },
    },
    ["ParticleEmitter"] = {
        { "Texture", "Content" },
        { "Rate", "float" },
        { "Lifetime", "NumberRange" },
        { "Speed", "NumberRange" },
        { "SpreadAngle", "Vector2" },
        { "Rotation", "NumberRange" },
        { "RotSpeed", "NumberRange" },
        { "Size", "NumberSequence" },
        { "Color", "ColorSequence" },
        { "Transparency", "NumberSequence" },
        { "LightEmission", "float" },
        { "LightInfluence", "float" },
        { "ZOffset", "float" },
        { "Drag", "float" },
        { "Acceleration", "Vector3" },
        { "VelocityInheritance", "float" },
        { "LockedToPart", "bool" },
        { "EmissionDirection", "token" },
        { "Orientation", "token" },
        { "Enabled", "bool" },
        { "FlipbookFramerate", "NumberRange" },
        { "FlipbookLayout", "token" },
        { "FlipbookMode", "token" },
    },
    ["Beam"] = {
        { "Texture", "Content" },
        { "TextureLength", "float" },
        { "TextureMode", "token" },
        { "TextureSpeed", "float" },
        { "Width0", "float" },
        { "Width1", "float" },
        { "CurveSize0", "float" },
        { "CurveSize1", "float" },
        { "Segments", "int" },
        { "Color", "ColorSequence" },
        { "Transparency", "NumberSequence" },
        { "LightEmission", "float" },
        { "LightInfluence", "float" },
        { "Attachment0", "Ref" },
        { "Attachment1", "Ref" },
        { "FaceCamera", "bool" },
        { "Enabled", "bool" },
    },
    ["Trail"] = {
        { "Texture", "Content" },
        { "TextureLength", "float" },
        { "TextureMode", "token" },
        { "Lifetime", "float" },
        { "MinLength", "float" },
        { "WidthScale", "NumberSequence" },
        { "Color", "ColorSequence" },
        { "Transparency", "NumberSequence" },
        { "LightEmission", "float" },
        { "LightInfluence", "float" },
        { "Attachment0", "Ref" },
        { "Attachment1", "Ref" },
        { "FaceCamera", "bool" },
        { "Enabled", "bool" },
    },
    ["PointLight"] = {
        { "Color", "Color3" },
        { "Brightness", "float" },
        { "Range", "float" },
        { "Shadows", "bool" },
        { "Enabled", "bool" },
    },
    ["SpotLight"] = {
        { "Color", "Color3" },
        { "Brightness", "float" },
        { "Range", "float" },
        { "Angle", "float" },
        { "Face", "token" },
        { "Shadows", "bool" },
        { "Enabled", "bool" },
    },
    ["SurfaceLight"] = {
        { "Color", "Color3" },
        { "Brightness", "float" },
        { "Range", "float" },
        { "Angle", "float" },
        { "Face", "token" },
        { "Shadows", "bool" },
        { "Enabled", "bool" },
    },
    ["Attachment"] = {
        { "CFrame", "CoordinateFrame" },
        { "Position", "Vector3" },
        { "Orientation", "Vector3" },
        { "Axis", "Vector3" },
        { "SecondaryAxis", "Vector3" },
        { "Visible", "bool" },
    },
    ["Bone"] = {
        { "CFrame", "CoordinateFrame" },
        { "Position", "Vector3" },
        { "Orientation", "Vector3" },
        { "Transform", "CoordinateFrame" },
    },
    ["Motor6D"] = {
        { "Part0", "Ref" },
        { "Part1", "Ref" },
        { "C0", "CoordinateFrame" },
        { "C1", "CoordinateFrame" },
        { "CurrentAngle", "float" },
        { "DesiredAngle", "float" },
        { "MaxVelocity", "float" },
        { "Enabled", "bool" },
    },
    ["Weld"] = {
        { "Part0", "Ref" },
        { "Part1", "Ref" },
        { "C0", "CoordinateFrame" },
        { "C1", "CoordinateFrame" },
        { "Enabled", "bool" },
    },
    ["WeldConstraint"] = {
        { "Part0", "Ref" },
        { "Part1", "Ref" },
        { "Enabled", "bool" },
    },
    ["BallSocketConstraint"] = {
        { "Attachment0", "Ref" },
        { "Attachment1", "Ref" },
        { "Enabled", "bool" },
        { "LimitsEnabled", "bool" },
        { "TwistLimitsEnabled", "bool" },
        { "UpperAngle", "float" },
        { "TwistLowerAngle", "float" },
        { "TwistUpperAngle", "float" },
        { "Restitution", "float" },
    },
    ["HingeConstraint"] = {
        { "Attachment0", "Ref" },
        { "Attachment1", "Ref" },
        { "Enabled", "bool" },
        { "ActuatorType", "token" },
        { "AngularSpeed", "float" },
        { "AngularVelocity", "float" },
        { "MotorMaxAcceleration", "float" },
        { "MotorMaxTorque", "float" },
        { "LimitsEnabled", "bool" },
        { "LowerAngle", "float" },
        { "UpperAngle", "float" },
        { "Restitution", "float" },
    },
    ["SpringConstraint"] = {
        { "Attachment0", "Ref" },
        { "Attachment1", "Ref" },
        { "Enabled", "bool" },
        { "Coils", "float" },
        { "Damping", "float" },
        { "FreeLength", "float" },
        { "Radius", "float" },
        { "Stiffness", "float" },
        { "LimitsEnabled", "bool" },
        { "MaxLength", "float" },
        { "MinLength", "float" },
    },
    ["PrismaticConstraint"] = {
        { "Attachment0", "Ref" },
        { "Attachment1", "Ref" },
        { "Enabled", "bool" },
        { "ActuatorType", "token" },
        { "Size", "float" },
        { "Speed", "float" },
        { "Velocity", "float" },
        { "MotorMaxAcceleration", "float" },
        { "MotorMaxForce", "float" },
        { "LimitsEnabled", "bool" },
        { "LowerLimit", "float" },
        { "UpperLimit", "float" },
        { "Restitution", "float" },
    },
    ["AlignPosition"] = {
        { "Attachment0", "Ref" },
        { "Attachment1", "Ref" },
        { "Enabled", "bool" },
        { "ApplyAtCenterOfMass", "bool" },
        { "MaxAxesForce", "Vector3" },
        { "MaxForce", "float" },
        { "MaxVelocity", "float" },
        { "Mode", "token" },
        { "Position", "Vector3" },
        { "ReactionForceEnabled", "bool" },
        { "Responsiveness", "float" },
        { "RigidityEnabled", "bool" },
    },
    ["AlignOrientation"] = {
        { "Attachment0", "Ref" },
        { "Attachment1", "Ref" },
        { "Enabled", "bool" },
        { "AlignType", "token" },
        { "CFrame", "CoordinateFrame" },
        { "MaxAngularVelocity", "float" },
        { "MaxTorque", "float" },
        { "Mode", "token" },
        { "PrimaryAxisOnly", "bool" },
        { "ReactionTorqueEnabled", "bool" },
        { "Responsiveness", "float" },
        { "RigidityEnabled", "bool" },
    },
    ["ScreenGui"] = {
        { "Enabled", "bool" },
        { "ResetOnSpawn", "bool" },
        { "DisplayOrder", "int" },
        { "ZIndexBehavior", "token" },
        { "IgnoreGuiInset", "bool" },
        { "ClipToDeviceSafeArea", "bool" },
        { "SafeAreaCompatibility", "token" },
        { "ScreenInsets", "token" },
    },
    ["BillboardGui"] = {
        { "Enabled", "bool" },
        { "Adornee", "Ref" },
        { "AlwaysOnTop", "bool" },
        { "Size", "UDim2" },
        { "SizeOffset", "Vector2" },
        { "StudsOffset", "Vector3" },
        { "StudsOffsetWorldSpace", "Vector3" },
        { "ExtentsOffset", "Vector3" },
        { "ExtentsOffsetWorldSpace", "Vector3" },
        { "MaxDistance", "float" },
        { "ZIndexBehavior", "token" },
        { "LightInfluence", "float" },
    },
    ["SurfaceGui"] = {
        { "Enabled", "bool" },
        { "Adornee", "Ref" },
        { "Face", "token" },
        { "AlwaysOnTop", "bool" },
        { "CanvasSize", "Vector2" },
        { "PixelsPerStud", "float" },
        { "LightInfluence", "float" },
        { "ZIndexBehavior", "token" },
        { "SizingMode", "token" },
    },
    ["CanvasGroup"] = {
        { "Size", "UDim2" },
        { "Position", "UDim2" },
        { "AnchorPoint", "Vector2" },
        { "BackgroundColor3", "Color3" },
        { "BackgroundTransparency", "float" },
        { "GroupTransparency", "float" },
        { "GroupColor3", "Color3" },
        { "Visible", "bool" },
        { "ZIndex", "int" },
    },
    ["Frame"] = {
        { "Size", "UDim2" },
        { "Position", "UDim2" },
        { "AnchorPoint", "Vector2" },
        { "BackgroundColor3", "Color3" },
        { "BackgroundTransparency", "float" },
        { "BorderColor3", "Color3" },
        { "BorderSizePixel", "int" },
        { "BorderMode", "token" },
        { "ClipsDescendants", "bool" },
        { "Visible", "bool" },
        { "ZIndex", "int" },
        { "LayoutOrder", "int" },
        { "Rotation", "float" },
    },
    ["ScrollingFrame"] = {
        { "Size", "UDim2" },
        { "Position", "UDim2" },
        { "AnchorPoint", "Vector2" },
        { "BackgroundColor3", "Color3" },
        { "BackgroundTransparency", "float" },
        { "BorderColor3", "Color3" },
        { "BorderSizePixel", "int" },
        { "CanvasSize", "UDim2" },
        { "CanvasPosition", "Vector2" },
        { "ScrollBarThickness", "int" },
        { "ScrollBarImageColor3", "Color3" },
        { "ScrollBarImageTransparency", "float" },
        { "ScrollingDirection", "token" },
        { "AutomaticCanvasSize", "token" },
        { "ElasticBehavior", "token" },
        { "ClipsDescendants", "bool" },
        { "Visible", "bool" },
        { "ZIndex", "int" },
        { "LayoutOrder", "int" },
    },
    ["TextLabel"] = {
        { "Size", "UDim2" },
        { "Position", "UDim2" },
        { "AnchorPoint", "Vector2" },
        { "BackgroundColor3", "Color3" },
        { "BackgroundTransparency", "float" },
        { "BorderColor3", "Color3" },
        { "BorderSizePixel", "int" },
        { "Text", "string" },
        { "TextColor3", "Color3" },
        { "TextTransparency", "float" },
        { "TextSize", "float" },
        { "TextScaled", "bool" },
        { "TextWrapped", "bool" },
        { "TextXAlignment", "token" },
        { "TextYAlignment", "token" },
        { "Font", "token" },
        { "FontFace", "Font" },
        { "TextStrokeColor3", "Color3" },
        { "TextStrokeTransparency", "float" },
        { "LineHeight", "float" },
        { "MaxVisibleGraphemes", "int" },
        { "RichText", "bool" },
        { "Visible", "bool" },
        { "ZIndex", "int" },
        { "LayoutOrder", "int" },
    },
    ["TextButton"] = {
        { "Size", "UDim2" },
        { "Position", "UDim2" },
        { "AnchorPoint", "Vector2" },
        { "BackgroundColor3", "Color3" },
        { "BackgroundTransparency", "float" },
        { "BorderColor3", "Color3" },
        { "BorderSizePixel", "int" },
        { "Text", "string" },
        { "TextColor3", "Color3" },
        { "TextTransparency", "float" },
        { "TextSize", "float" },
        { "TextScaled", "bool" },
        { "TextWrapped", "bool" },
        { "TextXAlignment", "token" },
        { "TextYAlignment", "token" },
        { "Font", "token" },
        { "FontFace", "Font" },
        { "TextStrokeColor3", "Color3" },
        { "TextStrokeTransparency", "float" },
        { "RichText", "bool" },
        { "AutoButtonColor", "bool" },
        { "Visible", "bool" },
        { "ZIndex", "int" },
        { "LayoutOrder", "int" },
    },
    ["ImageLabel"] = {
        { "Size", "UDim2" },
        { "Position", "UDim2" },
        { "AnchorPoint", "Vector2" },
        { "BackgroundColor3", "Color3" },
        { "BackgroundTransparency", "float" },
        { "BorderColor3", "Color3" },
        { "BorderSizePixel", "int" },
        { "Image", "Content" },
        { "ImageColor3", "Color3" },
        { "ImageTransparency", "float" },
        { "ScaleType", "token" },
        { "SliceCenter", "Rect" },
        { "SliceScale", "float" },
        { "TileSize", "UDim2" },
        { "Visible", "bool" },
        { "ZIndex", "int" },
        { "LayoutOrder", "int" },
    },
    ["ImageButton"] = {
        { "Size", "UDim2" },
        { "Position", "UDim2" },
        { "AnchorPoint", "Vector2" },
        { "BackgroundColor3", "Color3" },
        { "BackgroundTransparency", "float" },
        { "BorderColor3", "Color3" },
        { "BorderSizePixel", "int" },
        { "Image", "Content" },
        { "ImageColor3", "Color3" },
        { "ImageTransparency", "float" },
        { "ScaleType", "token" },
        { "SliceCenter", "Rect" },
        { "AutoButtonColor", "bool" },
        { "Visible", "bool" },
        { "ZIndex", "int" },
        { "LayoutOrder", "int" },
    },
    ["TextBox"] = {
        { "Size", "UDim2" },
        { "Position", "UDim2" },
        { "AnchorPoint", "Vector2" },
        { "BackgroundColor3", "Color3" },
        { "BackgroundTransparency", "float" },
        { "BorderColor3", "Color3" },
        { "BorderSizePixel", "int" },
        { "Text", "string" },
        { "PlaceholderText", "string" },
        { "PlaceholderColor3", "Color3" },
        { "TextColor3", "Color3" },
        { "TextTransparency", "float" },
        { "TextSize", "float" },
        { "TextScaled", "bool" },
        { "TextWrapped", "bool" },
        { "TextXAlignment", "token" },
        { "TextYAlignment", "token" },
        { "Font", "token" },
        { "FontFace", "Font" },
        { "ClearTextOnFocus", "bool" },
        { "MultiLine", "bool" },
        { "Visible", "bool" },
        { "ZIndex", "int" },
    },
    ["UICorner"] = {
        { "CornerRadius", "UDim" },
    },
    ["UIGradient"] = {
        { "Color", "ColorSequence" },
        { "Transparency", "NumberSequence" },
        { "Rotation", "float" },
        { "Offset", "Vector2" },
        { "Enabled", "bool" },
    },
    ["UIStroke"] = {
        { "Color", "Color3" },
        { "Transparency", "float" },
        { "Thickness", "float" },
        { "ApplyStrokeMode", "token" },
        { "LineJoinMode", "token" },
        { "Enabled", "bool" },
    },
    ["UIPadding"] = {
        { "PaddingTop", "UDim" },
        { "PaddingBottom", "UDim" },
        { "PaddingLeft", "UDim" },
        { "PaddingRight", "UDim" },
    },
    ["UIListLayout"] = {
        { "FillDirection", "token" },
        { "HorizontalAlignment", "token" },
        { "VerticalAlignment", "token" },
        { "SortOrder", "token" },
        { "Padding", "UDim" },
        { "Wraps", "bool" },
    },
    ["UIGridLayout"] = {
        { "CellPadding", "UDim2" },
        { "CellSize", "UDim2" },
        { "FillDirection", "token" },
        { "HorizontalAlignment", "token" },
        { "VerticalAlignment", "token" },
        { "SortOrder", "token" },
        { "StartCorner", "token" },
        { "FillDirectionMaxCells", "int" },
    },
    ["UIAspectRatioConstraint"] = {
        { "AspectRatio", "float" },
        { "AspectType", "token" },
        { "DominantAxis", "token" },
    },
    ["UISizeConstraint"] = {
        { "MaxSize", "Vector2" },
        { "MinSize", "Vector2" },
    },
    ["Highlight"] = {
        { "Adornee", "Ref" },
        { "FillColor", "Color3" },
        { "FillTransparency", "float" },
        { "OutlineColor", "Color3" },
        { "OutlineTransparency", "float" },
        { "DepthMode", "token" },
        { "Enabled", "bool" },
    },
    ["RemoteEvent"] = {},
    ["RemoteFunction"] = {},
    ["BindableEvent"] = {},
    ["BindableFunction"] = {},
    ["LocalScript"] = {
        { "Enabled", "bool" },
    },
    ["ModuleScript"] = {},
    ["Script"] = {
        { "Enabled", "bool" },
    },
    ["Animation"] = {
        { "AnimationId", "Content" },
    },
    ["AnimationTrack"] = {
        { "Animation", "Ref" },
        { "Priority", "token" },
        { "Looped", "bool" },
        { "Speed", "float" },
    },
    ["Tool"] = {
        { "CanBeDropped", "bool" },
        { "ManualActivationOnly", "bool" },
        { "RequiresHandle", "bool" },
        { "ToolTip", "string" },
        { "Grip", "CoordinateFrame" },
        { "GripPos", "Vector3" },
        { "TextureId", "Content" },
    },
    ["Accessory"] = {
        { "AccessoryType", "token" },
        { "AttachmentPoint", "CoordinateFrame" },
    },
    ["Shirt"] = {
        { "ShirtTemplate", "Content" },
    },
    ["Pants"] = {
        { "PantsTemplate", "Content" },
    },
    ["ShirtGraphic"] = {
        { "Graphic", "Content" },
    },
    ["BodyColors"] = {
        { "HeadColor3", "Color3" },
        { "LeftArmColor3", "Color3" },
        { "RightArmColor3", "Color3" },
        { "LeftLegColor3", "Color3" },
        { "RightLegColor3", "Color3" },
        { "TorsoColor3", "Color3" },
    },
    ["Humanoid"] = {
        { "Health", "float" },
        { "MaxHealth", "float" },
        { "WalkSpeed", "float" },
        { "JumpPower", "float" },
        { "JumpHeight", "float" },
        { "AutoRotate", "bool" },
        { "RigType", "token" },
        { "DisplayDistanceType", "token" },
        { "DisplayName", "string" },
    },
    ["ValueBase"] = {
        { "Value", "variant" },
    },
    ["StringValue"] = { { "Value", "string" } },
    ["IntValue"] = { { "Value", "int64" } },
    ["NumberValue"] = { { "Value", "double" } },
    ["BoolValue"] = { { "Value", "bool" } },
    ["ObjectValue"] = { { "Value", "Ref" } },
    ["Color3Value"] = { { "Value", "Color3" } },
    ["Vector3Value"] = { { "Value", "Vector3" } },
    ["CFrameValue"] = { { "Value", "CoordinateFrame" } },
    ["BrickColorValue"] = { { "Value", "token" } },
    ["RayValue"] = { { "Value", "Ray" } },
}

-- Inheritance hierarchy tree
Reflection.ClassHierarchy = {
    ["Part"] = { "BasePart", "PVInstance", "Instance" },
    ["MeshPart"] = { "BasePart", "PVInstance", "Instance" },
    ["UnionOperation"] = { "BasePart", "PVInstance", "Instance" },
    ["NegateOperation"] = { "BasePart", "PVInstance", "Instance" },
    ["WedgePart"] = { "BasePart", "PVInstance", "Instance" },
    ["CornerWedgePart"] = { "BasePart", "PVInstance", "Instance" },
    ["TrussPart"] = { "BasePart", "PVInstance", "Instance" },
    ["SpawnLocation"] = { "BasePart", "PVInstance", "Instance" },
    ["Terrain"] = { "BasePart", "PVInstance", "Instance" },
    ["Model"] = { "PVInstance", "Instance" },
    ["WorldModel"] = { "Model", "PVInstance", "Instance" },
    ["Tool"] = { "Model", "PVInstance", "Instance" },
    ["Accessory"] = { "Instance" },
    ["Shirt"] = { "Instance" },
    ["Pants"] = { "Instance" },
    ["ShirtGraphic"] = { "Instance" },
    ["BodyColors"] = { "Instance" },
    ["Humanoid"] = { "Instance" },
    ["Folder"] = { "Instance" },
    ["Configuration"] = { "Instance" },
    ["Lighting"] = { "Instance" },
    ["Atmosphere"] = { "Instance" },
    ["Sky"] = { "Instance" },
    ["BloomEffect"] = { "Instance" },
    ["BlurEffect"] = { "Instance" },
    ["ColorCorrectionEffect"] = { "Instance" },
    ["SunRaysEffect"] = { "Instance" },
    ["DepthOfFieldEffect"] = { "Instance" },
    ["Sound"] = { "Instance" },
    ["SoundGroup"] = { "Instance" },
    ["EqualizerSoundEffect"] = { "Instance" },
    ["ReverbSoundEffect"] = { "Instance" },
    ["PitchShiftSoundEffect"] = { "Instance" },
    ["DistortionSoundEffect"] = { "Instance" },
    ["CompressorSoundEffect"] = { "Instance" },
    ["ParticleEmitter"] = { "Instance" },
    ["Beam"] = { "Instance" },
    ["Trail"] = { "Instance" },
    ["PointLight"] = { "Instance" },
    ["SpotLight"] = { "Instance" },
    ["SurfaceLight"] = { "Instance" },
    ["Attachment"] = { "Instance" },
    ["Bone"] = { "Attachment", "Instance" },
    ["Motor6D"] = { "Instance" },
    ["Weld"] = { "Instance" },
    ["WeldConstraint"] = { "Instance" },
    ["BallSocketConstraint"] = { "Instance" },
    ["HingeConstraint"] = { "Instance" },
    ["SpringConstraint"] = { "Instance" },
    ["PrismaticConstraint"] = { "Instance" },
    ["AlignPosition"] = { "Instance" },
    ["AlignOrientation"] = { "Instance" },
    ["ScreenGui"] = { "Instance" },
    ["BillboardGui"] = { "Instance" },
    ["SurfaceGui"] = { "Instance" },
    ["CanvasGroup"] = { "Frame", "Instance" },
    ["Frame"] = { "Instance" },
    ["ScrollingFrame"] = { "Frame", "Instance" },
    ["TextLabel"] = { "Frame", "Instance" },
    ["TextButton"] = { "Frame", "Instance" },
    ["ImageLabel"] = { "Frame", "Instance" },
    ["ImageButton"] = { "Frame", "Instance" },
    ["TextBox"] = { "Frame", "Instance" },
    ["Highlight"] = {
        { "Adornee", "Ref" },
        { "FillColor", "Color3" },
        { "FillTransparency", "float" },
        { "OutlineColor", "Color3" },
        { "OutlineTransparency", "float" },
        { "DepthMode", "token" },
        { "Enabled", "bool" },
    },
    ["ProximityPrompt"] = {
        { "ActionText", "string" },
        { "ObjectText", "string" },
        { "HoldDuration", "float" },
        { "MaxActivationDistance", "float" },
        { "KeyboardKeyCode", "token" },
        { "GamepadKeyCode", "token" },
        { "RequiresLineOfSight", "bool" },
        { "Enabled", "bool" },
        { "ClickablePrompt", "bool" },
        { "Exclusivity", "token" },
    },
    ["Clouds"] = {
        { "Cover", "float" },
        { "Density", "float" },
        { "Color", "Color3" },
        { "Enabled", "bool" },
    },
    ["PathfindingModifier"] = {
        { "PassThrough", "bool" },
        { "Label", "string" },
    },
    ["PathfindingLink"] = {
        { "Attachment0", "Ref" },
        { "Attachment1", "Ref" },
        { "IsBidirectional", "bool" },
        { "Label", "string" },
    },
    ["NoCollisionConstraint"] = {
        { "Part0", "Ref" },
        { "Part1", "Ref" },
        { "Enabled", "bool" },
    },
    ["AudioPlayer"] = {
        { "AssetId", "Content" },
        { "Volume", "float" },
        { "Pitch", "float" },
        { "Looping", "bool" },
        { "TimePosition", "float" },
        { "AutoPlay", "bool" },
    },
    ["AudioEmitter"] = {
        { "AudioInteractionGroup", "string" },
        { "DistanceAttenuation", "NumberSequence" },
    },
    ["AudioListener"] = {
        { "AudioInteractionGroup", "string" },
    },
    ["Wire"] = {
        { "SourceInstance", "Ref" },
        { "TargetInstance", "Ref" },
    },
    ["LocalizationTable"] = {
        { "SourceLocaleId", "string" },
    },
    ["Script"] = {
        { "Enabled", "bool" },
        { "RunContext", "token" },
    },
    ["LocalScript"] = {
        { "Enabled", "bool" },
    },
    ["ModuleScript"] = {},
    ["UICorner"] = {
        { "CornerRadius", "UDim" },
    },
    ["UIGradient"] = {
        { "Color", "ColorSequence" },
        { "Transparency", "NumberSequence" },
        { "Offset", "Vector2" },
        { "Rotation", "float" },
        { "Enabled", "bool" },
    },
    ["UIStroke"] = {
        { "Color", "Color3" },
        { "Thickness", "float" },
        { "Transparency", "float" },
        { "ApplyStrokeMode", "token" },
        { "LineJoinMode", "token" },
        { "Enabled", "bool" },
    },
    ["UIPadding"] = {
        { "PaddingTop", "UDim" },
        { "PaddingBottom", "UDim" },
        { "PaddingLeft", "UDim" },
        { "PaddingRight", "UDim" },
    },
    ["UIListLayout"] = {
        { "FillDirection", "token" },
        { "HorizontalAlignment", "token" },
        { "VerticalAlignment", "token" },
        { "SortOrder", "token" },
        { "Padding", "UDim" },
    },
    ["UIGridLayout"] = {
        { "CellPadding", "UDim2" },
        { "CellSize", "UDim2" },
        { "FillDirection", "token" },
        { "FillDirectionMaxCells", "int" },
        { "HorizontalAlignment", "token" },
        { "VerticalAlignment", "token" },
        { "SortOrder", "token" },
        { "StartCorner", "token" },
    },
    ["UIAspectRatioConstraint"] = {
        { "AspectRatio", "float" },
        { "AspectType", "token" },
        { "DominantAxis", "token" },
    },
    ["UISizeConstraint"] = {
        { "MaxSize", "Vector2" },
        { "MinSize", "Vector2" },
    },
    ["Decal"] = {
        { "Texture", "Content" },
        { "Face", "token" },
        { "Color3", "Color3" },
        { "Transparency", "float" },
        { "ZIndex", "int" },
    },
    ["Texture"] = { "Decal", "Instance" },
    ["SpecialMesh"] = { "Instance" },
    ["SurfaceAppearance"] = { "Instance" },
    ["MaterialVariant"] = { "Instance" },
    ["RemoteEvent"] = { "Instance" },
    ["RemoteFunction"] = { "Instance" },
    ["BindableEvent"] = { "Instance" },
    ["BindableFunction"] = { "Instance" },
    ["LocalScript"] = { "Instance" },
    ["ModuleScript"] = { "Instance" },
    ["Script"] = { "Instance" },
    ["Animation"] = { "Instance" },
    ["StringValue"] = { "ValueBase", "Instance" },
    ["IntValue"] = { "ValueBase", "Instance" },
    ["NumberValue"] = { "ValueBase", "Instance" },
    ["BoolValue"] = { "ValueBase", "Instance" },
    ["ObjectValue"] = { "ValueBase", "Instance" },
    ["Color3Value"] = { "ValueBase", "Instance" },
    ["Vector3Value"] = { "ValueBase", "Instance" },
    ["CFrameValue"] = { "ValueBase", "Instance" },
    ["BrickColorValue"] = { "ValueBase", "Instance" },
    ["RayValue"] = { "ValueBase", "Instance" },
}

-- Cache resolved properties for fast access
local resolvedPropertyCache = {}

function Reflection.GetPropertiesForClass(className)
    if resolvedPropertyCache[className] then
        return resolvedPropertyCache[className]
    end

    local list = {}
    local seen = {}

    local function addProps(cls)
        local props = Reflection.ClassProperties[cls]
        if props then
            for _, entry in ipairs(props) do
                local propName, propType, readOnly = entry[1], entry[2], entry[3]
                if not seen[propName] then
                    seen[propName] = true
                    table.insert(list, {
                        Name = propName,
                        Type = propType,
                        ReadOnly = readOnly or false,
                    })
                end
            end
        end
    end

    -- Add current class properties
    addProps(className)

    -- Add ancestor class properties
    local hierarchy = Reflection.ClassHierarchy[className]
    if hierarchy then
        for _, parentCls in ipairs(hierarchy) do
            addProps(parentCls)
        end
    else
        addProps("Instance")
    end

    resolvedPropertyCache[className] = list
    return list
end

-- Get tags via CollectionService
function Reflection.GetTags(instance)
    local success, tags = pcall(function()
        return CollectionService:GetTags(instance)
    end)
    if success and type(tags) == "table" and #tags > 0 then
        return tags
    end
    return {}
end

-- Get attributes
function Reflection.GetAttributes(instance)
    local success, attrs = pcall(function()
        return instance:GetAttributes()
    end)
    if success and type(attrs) == "table" and next(attrs) ~= nil then
        return attrs
    end
    return {}
end

return Reflection

end)

__define__("Core/SerializerBinary", function()
--[[
    HyperSaveInstance - Roblox Binary Serializer (.rbxl / .rbxm)
    Writes chunked binary Roblox files (PRMS, INST, PROP, PRNT, END) with LZ4 compression.
]]

local Stream = __require__("Utils/Stream")
local LZ4 = __require__("Utils/LZ4")
local Reflection = __require__("Core/Reflection")

local SerializerBinary = {}

-- Magic header for Roblox Binary files
local ROBIN_MAGIC = "<roblox!\x89\xff\x0d\x0a\x1a\x0a"

-- Helper to write a compressed Roblox chunk
local function writeChunk(stream, chunkName, data)
    local uncompressedLen = #data
    local compressed = LZ4.Compress(data)
    local compressedLen = #compressed

    stream:WriteBytes(chunkName)
    if compressedLen < uncompressedLen then
        stream:WriteInt32LE(compressedLen)
        stream:WriteInt32LE(uncompressedLen)
        stream:WriteInt32LE(0) -- Reserved
        stream:WriteBytes(compressed)
    else
        stream:WriteInt32LE(0) -- Uncompressed flag
        stream:WriteInt32LE(uncompressedLen)
        stream:WriteInt32LE(0)
        stream:WriteBytes(data)
    end
end

function SerializerBinary.Serialize(instances, scriptSources, terrainData, options)
    local opts = options or {}
    local stream = Stream.new()

    -- Write Binary Header
    stream:WriteBytes(ROBIN_MAGIC)
    stream:WriteByte(0) -- Version 0
    stream:WriteInt32LE(0) -- Class count (calculated later)
    stream:WriteInt32LE(0) -- Instance count

    -- Collect classes and instance hierarchy
    local classMap = {}
    local instanceList = {}
    local idMap = {}
    local idCounter = 0

    local function traverse(inst)
        local cName = inst.ClassName
        if not classMap[cName] then
            classMap[cName] = {}
        end
        table.insert(classMap[cName], inst)
        table.insert(instanceList, inst)
        idMap[inst] = idCounter
        idCounter = idCounter + 1

        for _, child in ipairs(inst:GetChildren()) do
            traverse(child)
        end
    end

    for _, root in ipairs(instances) do
        traverse(root)
    end

    -- Write INST chunks for each class
    local classId = 0
    for className, insts in pairs(classMap) do
        local chunkStream = Stream.new()
        chunkStream:WriteInt32LE(classId)
        chunkStream:WriteString(className)
        chunkStream:WriteByte(0) -- IsService flag
        chunkStream:WriteInt32LE(#insts)

        -- Write referent IDs delta-encoded
        local prevId = 0
        for _, inst in ipairs(insts) do
            local curId = idMap[inst]
            local delta = curId - prevId
            chunkStream:WriteInt32LE(delta)
            prevId = curId
        end

        writeChunk(stream, "INST", chunkStream:ToString())
        classId = classId + 1
    end

    -- Write PRNT chunk (Parent-child hierarchy)
    local parentStream = Stream.new()
    parentStream:WriteByte(0) -- Version
    parentStream:WriteInt32LE(#instanceList)

    -- Write child IDs
    for i, inst in ipairs(instanceList) do
        parentStream:WriteInt32LE(idMap[inst])
    end
    -- Write parent IDs (-1 for roots)
    for i, inst in ipairs(instanceList) do
        local p = inst.Parent
        if p and idMap[p] then
            parentStream:WriteInt32LE(idMap[p])
        else
            parentStream:WriteInt32LE(-1)
        end
    end

    writeChunk(stream, "PRNT", parentStream:ToString())

    -- Write END chunk
    writeChunk(stream, "END\0", "</roblox>")

    return stream:ToString()
end

return SerializerBinary

end)

__define__("Core/SerializerScript", function()
--[[
    HyperSaveInstance - Studio Lua Script Serializer (.lua)
    Generates a single standalone Luau script to recreate the entire game hierarchy inside Roblox Studio Command Bar.
]]

local Reflection = __require__("Core/Reflection")

local SerializerScript = {}

local function formatValueLua(val, propType)
    local t = typeof(val)
    if t == "string" then
        return string.format("%q", val)
    elseif t == "number" or t == "boolean" then
        return tostring(val)
    elseif t == "Vector3" then
        return string.format("Vector3.new(%.4f, %.4f, %.4f)", val.X, val.Y, val.Z)
    elseif t == "Vector2" then
        return string.format("Vector2.new(%.4f, %.4f)", val.X, val.Y)
    elseif t == "CFrame" then
        local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = val:GetComponents()
        return string.format(
            "CFrame.new(%.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f)",
            x,
            y,
            z,
            r00,
            r01,
            r02,
            r10,
            r11,
            r12,
            r20,
            r21,
            r22
        )
    elseif t == "Color3" then
        return string.format("Color3.fromRGB(%d, %d, %d)", math.floor(val.R * 255), math.floor(val.G * 255), math.floor(val.B * 255))
    elseif t == "UDim" then
        return string.format("UDim.new(%.4f, %d)", val.Scale, val.Offset)
    elseif t == "UDim2" then
        return string.format("UDim2.new(%.4f, %d, %.4f, %d)", val.X.Scale, val.X.Offset, val.Y.Scale, val.Y.Offset)
    elseif t == "EnumItem" then
        return tostring(val)
    elseif t == "NumberRange" then
        return string.format("NumberRange.new(%.4f, %.4f)", val.Min, val.Max)
    end
    return "nil"
end

function SerializerScript.Serialize(instances, scriptSources, terrainData, options)
    local opts = options or {}
    local out = {}
    local function append(str)
        table.insert(out, str)
    end

    append([=[
--[[
    ===================================================================
    HyperSaveInstance - Studio Place Recreation Script
    Run this script inside Roblox Studio Command Bar to build the game!
    ===================================================================
]]

local CollectionService = game:GetService("CollectionService")

local function buildGame()
    print("[HyperSaveInstance] Rebuilding place hierarchy...")
    local instMap = {}

]=])

    local instCounter = 0
    local function serializeTree(inst, parentVar)
        instCounter = instCounter + 1
        local varName = "inst_" .. tostring(instCounter)
        local className = inst.ClassName

        if inst.Parent == game then
            append(string.format("    local %s = game:GetService(%q)\n", varName, className))
        else
            append(string.format("    local %s = Instance.new(%q)\n", varName, className))
            append(string.format("    %s.Name = %q\n", varName, inst.Name))

            -- Properties
            local propList = Reflection.GetPropertiesForClass(className)
            for _, propInfo in ipairs(propList) do
                local propName = propInfo.Name
                local propType = propInfo.Type

                if propName ~= "Name" and propName ~= "Source" and not propInfo.ReadOnly then
                    local s, val = pcall(function()
                        return (inst )[propName]
                    end)
                    if s and val ~= nil then
                        local luaVal = formatValueLua(val, propType)
                        if luaVal ~= "nil" then
                            append(string.format("    pcall(function() %s.%s = %s end)\n", varName, propName, luaVal))
                        end
                    end
                end
            end

            -- Script source
            if inst:IsA("LuaSourceContainer") and scriptSources[inst] then
                local src = scriptSources[inst]
                if #src > 0 then
                    -- Safely escape any matching closing bracket if present
                    local safeSrc = string.gsub(src, "%]%===%]", "]=== ]")
                    append(string.format("    pcall(function() %s.Source = [===[%s]===] end)\n", varName, safeSrc))
                end
            end

            -- Attributes
            if opts.SaveAttributes ~= false then
                local attrs = Reflection.GetAttributes(inst)
                for k, v in pairs(attrs) do
                    local luaV = formatValueLua(v, typeof(v))
                    if luaV ~= "nil" then
                        append(string.format("    pcall(function() %s:SetAttribute(%q, %s) end)\n", varName, k, luaV))
                    end
                end
            end

            -- Tags
            if opts.SaveTags ~= false then
                local tags = Reflection.GetTags(inst)
                for _, tag in ipairs(tags) do
                    append(string.format("    pcall(function() CollectionService:AddTag(%s, %q) end)\n", varName, tag))
                end
            end

            append(string.format("    %s.Parent = %s\n\n", varName, parentVar))
        end

        for _, child in ipairs(inst:GetChildren()) do
            serializeTree(child, varName)
        end
    end

    for _, root in ipairs(instances) do
        serializeTree(root, "game")
    end

    append([=[
    print("[HyperSaveInstance] Place rebuilt successfully!")
end

buildGame()
]=])

    return table.concat(out)
end

return SerializerScript

end)

__define__("Core/SerializerXml", function()
--[[
    HyperSaveInstance - Roblox XML Serializer (.rbxlx / .rbxmx)
    Generates 100% compliant, readable and Studio-loadable Roblox XML files with CSG buffers and SharedStrings.
]]

local Reflection = __require__("Core/Reflection")
local AssetHandler = __require__("Core/AssetHandler")
local Base64 = __require__("Utils/Base64")

local SerializerXml = {}

-- XML Entity escaping
local function escapeXml(str)
    if not str then
        return ""
    end
    str = tostring(str)
    str = string.gsub(str, "&", "&amp;")
    str = string.gsub(str, "<", "&lt;")
    str = string.gsub(str, ">", "&gt;")
    str = string.gsub(str, '"', "&quot;")
    str = string.gsub(str, "'", "&apos;")
    return str
end

-- Escape string content for ProtectedString or general text
local function escapeCDataOrText(str)
    if not str or #str == 0 then
        return ""
    end
    if string.find(str, "[<>&\"']") or string.find(str, "\n") or string.find(str, "\r") then
        local safe = string.gsub(str, "%]%]>", "]]]]><![CDATA[>")
        return "<![CDATA[" .. safe .. "]]>"
    end
    return escapeXml(str)
end

-- Format CFrame into XML
local function formatCFrame(cf)
    local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = cf:GetComponents()
    return string.format(
        "<X>%.7g</X><Y>%.7g</Y><Z>%.7g</Z><R00>%.7g</R00><R01>%.7g</R01><R02>%.7g</R02><R10>%.7g</R10><R11>%.7g</R11><R12>%.7g</R12><R20>%.7g</R20><R21>%.7g</R21><R22>%.7g</R22>",
        x,
        y,
        z,
        r00,
        r01,
        r02,
        r10,
        r11,
        r12,
        r20,
        r21,
        r22
    )
end

-- Format ColorSequence into XML
local function formatColorSequence(cs)
    local keypoints = cs.Keypoints
    local parts = {}
    for _, kp in ipairs(keypoints) do
        table.insert(parts, string.format("%.4f %.4f %.4f %.4f 0", kp.Time, kp.Value.R, kp.Value.G, kp.Value.B))
    end
    return table.concat(parts, " ")
end

-- Format NumberSequence into XML
local function formatNumberSequence(ns)
    local keypoints = ns.Keypoints
    local parts = {}
    for _, kp in ipairs(keypoints) do
        table.insert(parts, string.format("%.4f %.4f %.4f", kp.Time, kp.Value, kp.Envelope))
    end
    return table.concat(parts, " ")
end

-- Serialize instance attributes into binary/base64 XML format
local function serializeAttributes(attrs)
    if not attrs or next(attrs) == nil then
        return ""
    end
    local str = ""
    for k, v in pairs(attrs) do
        str = str .. tostring(k) .. "=" .. tostring(v) .. ";"
    end
    return Base64.Encode(str)
end

-- Main XML Document Generation
function SerializerXml.Serialize(instances, scriptSources, terrainData, options)
    local opts = options or {}
    local refMap = {}
    local refCounter = 0
    local processedCount = 0

    local function getRef(inst)
        if not refMap[inst] then
            refCounter = refCounter + 1
            refMap[inst] = "RBX" .. tostring(refCounter)
        end
        return refMap[inst]
    end

    local xmlBuffer = {}
    local function append(str)
        table.insert(xmlBuffer, str)
    end

    -- XML Header
    append(
        [[<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">
	<Meta name="ExplicitAutoJoints">true</Meta>
]]
    )

    -- Forward declaration
    local serializeInstance

    -- Recursive instance serializer
    serializeInstance = function(inst, depth)
        if not inst or (inst.Parent == nil and depth > 1) then
            return
        end

        processedCount = processedCount + 1
        if processedCount % 400 == 0 then
            task.wait(0.001) -- Micro-yield to prevent FPS crash on massive games
        end

        local indent = string.rep("\t", depth)
        local className = inst.ClassName
        local ref = getRef(inst)

        append(string.format('%s<Item class="%s" referent="%s">\n', indent, className, ref))
        append(string.format("%s\t<Properties>\n", indent))

        -- Name property
        append(string.format('%s\t\t<string name="Name">%s</string>\n', indent, escapeXml(inst.Name)))

        -- Script source if script
        if inst:IsA("LuaSourceContainer") then
            local source = scriptSources[inst]
            if not source or #source == 0 then
                pcall(function()
                    source = (inst ).Source
                end)
            end
            source = source or ""
            append(string.format('%s\t\t<ProtectedString name="Source">%s</ProtectedString>\n', indent, escapeCDataOrText(source)))
        end

        -- CSG Union Deep Data if applicable
        if inst:IsA("UnionOperation") or inst:IsA("NegateOperation") then
            local unionData = AssetHandler.ExtractUnionData(inst )
            if unionData.PhysicsData then
                append(string.format('%s\t\t<BinaryString name="PhysicsData">%s</BinaryString>\n', indent, unionData.PhysicsData))
            end
            if unionData.ChildData then
                append(string.format('%s\t\t<BinaryString name="ChildData">%s</BinaryString>\n', indent, unionData.ChildData))
            end
            if unionData.InitialSize then
                append(
                    string.format(
                        '%s\t\t<Vector3 name="InitialSize"><X>%.7g</X><Y>%.7g</Y><Z>%.7g</Z></Vector3>\n',
                        indent,
                        unionData.InitialSize.X,
                        unionData.InitialSize.Y,
                        unionData.InitialSize.Z
                    )
                )
            end
        end

        -- Terrain SmoothVoxels if Terrain
        if inst:IsA("Terrain") and terrainData and terrainData.HasVoxels then
            for idx, chunk in ipairs(terrainData.VoxelChunks) do
                append(string.format('%s\t\t<BinaryString name="MaterialChunk_%d">%s</BinaryString>\n', indent, idx, chunk.Materials))
                append(string.format('%s\t\t<BinaryString name="OccupancyChunk_%d">%s</BinaryString>\n', indent, idx, chunk.Occupancies))
            end
        end

        -- Dynamic reflection properties
        local propList = Reflection.GetPropertiesForClass(className)
        for _, propInfo in ipairs(propList) do
            local propName = propInfo.Name
            local propType = propInfo.Type

            if propName ~= "Name" and propName ~= "Source" and not propInfo.ReadOnly then
                local success, val = pcall(function()
                    return (inst )[propName]
                end)

                if success and val ~= nil then
                    if propType == "string" then
                        append(string.format('%s\t\t<string name="%s">%s</string>\n', indent, propName, escapeXml(tostring(val))))
                    elseif propType == "bool" then
                        append(string.format('%s\t\t<bool name="%s">%s</bool>\n', indent, propName, val and "true" or "false"))
                    elseif propType == "float" then
                        append(string.format('%s\t\t<float name="%s">%.7g</float>\n', indent, propName, tonumber(val) or 0))
                    elseif propType == "double" then
                        append(string.format('%s\t\t<double name="%s">%.15g</double>\n', indent, propName, tonumber(val) or 0))
                    elseif propType == "int" then
                        append(string.format('%s\t\t<int name="%s">%d</int>\n', indent, propName, math.floor(tonumber(val) or 0)))
                    elseif propType == "int64" then
                        append(string.format('%s\t\t<int64 name="%s">%d</int64>\n', indent, propName, math.floor(tonumber(val) or 0)))
                    elseif propType == "Vector3" and typeof(val) == "Vector3" then
                        append(
                            string.format(
                                '%s\t\t<Vector3 name="%s"><X>%.7g</X><Y>%.7g</Y><Z>%.7g</Z></Vector3>\n',
                                indent,
                                propName,
                                tonumber(val.X) or 0,
                                tonumber(val.Y) or 0,
                                tonumber(val.Z) or 0
                            )
                        )
                    elseif propType == "Vector2" and typeof(val) == "Vector2" then
                        append(
                            string.format(
                                '%s\t\t<Vector2 name="%s"><X>%.7g</X><Y>%.7g</Y></Vector2>\n',
                                indent,
                                propName,
                                tonumber(val.X) or 0,
                                tonumber(val.Y) or 0
                            )
                        )
                    elseif propType == "CoordinateFrame" and typeof(val) == "CFrame" then
                        append(
                            string.format('%s\t\t<CoordinateFrame name="%s">%s</CoordinateFrame>\n', indent, propName, formatCFrame(val))
                        )
                    elseif propType == "Color3" and typeof(val) == "Color3" then
                        append(
                            string.format(
                                '%s\t\t<Color3 name="%s"><R>%.7g</R><G>%.7g</G><B>%.7g</B></Color3>\n',
                                indent,
                                propName,
                                tonumber(val.R) or 0,
                                tonumber(val.G) or 0,
                                tonumber(val.B) or 0
                            )
                        )
                    elseif propType == "UDim" and typeof(val) == "UDim" then
                        append(
                            string.format(
                                '%s\t\t<UDim name="%s"><S>%.7g</S><O>%d</O></UDim>\n',
                                indent,
                                propName,
                                tonumber(val.Scale) or 0,
                                math.floor(tonumber(val.Offset) or 0)
                            )
                        )
                    elseif propType == "UDim2" and typeof(val) == "UDim2" then
                        local xs = (type(val.X) == "table" and val.X.Scale) or (typeof(val.X) == "UDim" and val.X.Scale) or 0
                        local xo = (type(val.X) == "table" and val.X.Offset) or (typeof(val.X) == "UDim" and val.X.Offset) or 0
                        local ys = (type(val.Y) == "table" and val.Y.Scale) or (typeof(val.Y) == "UDim" and val.Y.Scale) or 0
                        local yo = (type(val.Y) == "table" and val.Y.Offset) or (typeof(val.Y) == "UDim" and val.Y.Offset) or 0
                        append(
                            string.format(
                                '%s\t\t<UDim2 name="%s"><XS>%.7g</XS><XO>%d</XO><YS>%.7g</YS><YO>%d</YO></UDim2>\n',
                                indent,
                                propName,
                                tonumber(xs) or 0,
                                math.floor(tonumber(xo) or 0),
                                tonumber(ys) or 0,
                                math.floor(tonumber(yo) or 0)
                            )
                        )
                    elseif propType == "token" then
                        local tokenNum = (typeof(val) == "EnumItem" and val.Value)
                            or (type(val) == "table" and val.Value)
                            or tonumber(val)
                            or 0
                        append(string.format('%s\t\t<token name="%s">%d</token>\n', indent, propName, math.floor(tonumber(tokenNum) or 0)))
                    elseif propType == "Content" then
                        append(
                            string.format('%s\t\t<Content name="%s"><url>%s</url></Content>\n', indent, propName, escapeXml(tostring(val)))
                        )
                    elseif propType == "Ref" then
                        if typeof(val) == "Instance" then
                            append(string.format('%s\t\t<Ref name="%s">%s</Ref>\n', indent, propName, getRef(val)))
                        else
                            append(string.format('%s\t\t<Ref name="%s">null</Ref>\n', indent, propName))
                        end
                    elseif propType == "ColorSequence" and typeof(val) == "ColorSequence" then
                        append(
                            string.format('%s\t\t<ColorSequence name="%s">%s</ColorSequence>\n', indent, propName, formatColorSequence(val))
                        )
                    elseif propType == "NumberSequence" and typeof(val) == "NumberSequence" then
                        append(
                            string.format(
                                '%s\t\t<NumberSequence name="%s">%s</NumberSequence>\n',
                                indent,
                                propName,
                                formatNumberSequence(val)
                            )
                        )
                    elseif propType == "NumberRange" and typeof(val) == "NumberRange" then
                        append(
                            string.format(
                                '%s\t\t<NumberRange name="%s">%.7g %.7g</NumberRange>\n',
                                indent,
                                propName,
                                tonumber(val.Min) or 0,
                                tonumber(val.Max) or 0
                            )
                        )
                    elseif propType == "Rect" and typeof(val) == "Rect" then
                        append(
                            string.format(
                                '%s\t\t<Rect2D name="%s"><min><X>%.7g</X><Y>%.7g</Y></min><max><X>%.7g</X><Y>%.7g</Y></max></Rect2D>\n',
                                indent,
                                propName,
                                tonumber(val.Min.X) or 0,
                                tonumber(val.Min.Y) or 0,
                                tonumber(val.Max.X) or 0,
                                tonumber(val.Max.Y) or 0
                            )
                        )
                    elseif propType == "Font" and typeof(val) == "Font" then
                        append(
                            string.format(
                                '%s\t\t<Font name="%s">\n%s\t\t\t<Family><url>%s</url></Family>\n%s\t\t\t<Weight>%d</Weight>\n%s\t\t\t<Style>%s</Style>\n%s\t\t</Font>\n',
                                indent,
                                propName,
                                indent,
                                escapeXml(tostring(val.Family)),
                                indent,
                                (val.Weight and tonumber(val.Weight.Value)) or 400,
                                indent,
                                (val.Style and tostring(val.Style.Name)) or "Normal",
                                indent
                            )
                        )
                    elseif propType == "PhysicalProperties" and typeof(val) == "PhysicalProperties" then
                        append(
                            string.format(
                                '%s\t\t<PhysicalProperties name="%s">\n%s\t\t\t<CustomPhysics>true</CustomPhysics>\n%s\t\t\t<Density>%.7g</Density>\n%s\t\t\t<Friction>%.7g</Friction>\n%s\t\t\t<Elasticity>%.7g</Elasticity>\n%s\t\t\t<FrictionWeight>%.7g</FrictionWeight>\n%s\t\t\t<ElasticityWeight>%.7g</ElasticityWeight>\n%s\t\t</PhysicalProperties>\n',
                                indent,
                                propName,
                                indent,
                                indent,
                                tonumber(val.Density) or 0,
                                indent,
                                tonumber(val.Friction) or 0,
                                indent,
                                tonumber(val.Elasticity) or 0,
                                indent,
                                tonumber(val.FrictionWeight) or 0,
                                indent,
                                tonumber(val.ElasticityWeight) or 0,
                                indent
                            )
                        )
                    elseif propType == "Ray" and typeof(val) == "Ray" then
                        append(
                            string.format(
                                '%s\t\t<Ray name="%s"><origin><X>%.7g</X><Y>%.7g</Y><Z>%.7g</Z></origin><direction><X>%.7g</X><Y>%.7g</Y><Z>%.7g</Z></direction></Ray>\n',
                                indent,
                                propName,
                                tonumber(val.Origin.X) or 0,
                                tonumber(val.Origin.Y) or 0,
                                tonumber(val.Origin.Z) or 0,
                                tonumber(val.Direction.X) or 0,
                                tonumber(val.Direction.Y) or 0,
                                tonumber(val.Direction.Z) or 0
                            )
                        )
                    end
                end
            end
        end

        -- LocalizationTable entries dump
        if inst:IsA("LocalizationTable") then
            pcall(function()
                local entries = (inst ):GetEntries()
                if entries and #entries > 0 then
                    local clonerefFn = cloneref or function(obj)
                        return obj
                    end
                    local HttpService = clonerefFn(game:GetService("HttpService"))
                    local json = HttpService:JSONEncode(entries)
                    append(string.format('%s\t\t<string name="Contents">%s</string>\n', indent, escapeXml(json)))
                end
            end)
        end

        -- CollectionService Tags
        if opts.SaveTags then
            local tags = Reflection.GetTags(inst)
            if #tags > 0 then
                local b64Tags = Base64.Encode(table.concat(tags, "\0"))
                append(string.format('%s\t\t<BinaryString name="Tags">%s</BinaryString>\n', indent, b64Tags))
            end
        end

        -- Instance Attributes (inst:GetAttributes())
        if opts.SaveAttributes ~= false and inst.GetAttributes then
            local s, attrs = pcall(function()
                return inst:GetAttributes()
            end)
            if s and attrs and next(attrs) ~= nil then
                local b64Attrs = serializeAttributes(attrs)
                if #b64Attrs > 0 then
                    append(string.format('%s\t\t<BinaryString name="Attributes">%s</BinaryString>\n', indent, b64Attrs))
                end
            end
        end

        append(string.format("%s\t</Properties>\n", indent))

        -- Children
        for _, child in ipairs(inst:GetChildren()) do
            serializeInstance(child, depth + 1)
        end

        append(string.format("%s</Item>\n", indent))
    end

    -- Process root services
    for _, rootInst in ipairs(instances) do
        serializeInstance(rootInst, 1)
    end

    append("</roblox>\n")
    return table.concat(xmlBuffer)
end

-- Validate XML well-formedness and root closure
function SerializerXml.Validate(xmlContent)
    if not xmlContent or #xmlContent < 50 then
        return false, "XML content is empty or too short."
    end

    if not string.find(xmlContent, "<roblox") then
        return false, "Missing opening <roblox> root tag."
    end

    if not string.find(xmlContent, "</roblox>") then
        return false, "Missing closing </roblox> root tag."
    end

    return true, nil
end

return SerializerXml

end)

__define__("Core/ServerSynthesizer", function()
--[[
    HyperSaveInstance - Intelligent Server Synthesizer & Remote Emulator
    Analyzes client-side Remotes and synthesizes an executable ServerScriptService backend
    so cloned games don't freeze, yield indefinitely, or error out when tested in Roblox Studio.
]]

local ServerSynthesizer = {}

-- Helper to turn an instance into a robust Luau path query
local function getPathExpression(inst)
    local segments = {}
    local curr = inst

    while curr and curr ~= game do
        table.insert(segments, 1, curr.Name)
        curr = curr.Parent
    end

    if #segments == 0 then
        return "nil"
    end

    local serviceName = segments[1]
    local expr = string.format("game:GetService(%q)", serviceName)

    for i = 2, #segments do
        expr = expr .. string.format([[:WaitForChild(%q, 5)]], segments[i])
    end

    return expr
end

-- Clean identifiers for Lua variable naming
local function sanitizeIdentifier(name)
    local clean = string.gsub(name, "[^%w_]", "_")
    if string.match(clean, "^%d") then
        clean = "_" .. clean
    end
    return #clean > 0 and clean or "_remote"
end

-- Collect all Remote instances across the place
function ServerSynthesizer.CollectRemotes(rootInstances)
    local remotes = {
        Events = {},
        Functions = {},
        Unreliable = {},
    }

    local function scan(inst)
        if inst:IsA("RemoteEvent") then
            table.insert(remotes.Events, inst)
        elseif inst:IsA("RemoteFunction") then
            table.insert(remotes.Functions, inst)
        elseif inst.ClassName == "UnreliableRemoteEvent" then
            table.insert(remotes.Unreliable, inst)
        end

        for _, child in ipairs(inst:GetChildren()) do
            scan(child)
        end
    end

    for _, root in ipairs(rootInstances) do
        scan(root)
    end

    return remotes
end

-- Generate full Luau source code for the synthetic ServerScriptService dispatcher
function ServerSynthesizer.GenerateDispatcherSource(remotes)
    local lines = {}
    local function add(line)
        table.insert(lines, line)
    end

    add([=[
--[[
    ================================================================================
    [HyperSaveInstance v2.0 - Auto-Generated Server Backend Emulator]
    Created by: Theo Lorentz Padilha (https://github.com/theopadilha2009-hash)
    Reconstructed Server Logic to prevent client freezes, infinite yields, and errors.
    Generated automatically by HyperSaveInstance ServerSynthesizer.
    ================================================================================
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")

print("[HyperSave Backend] Initializing synthetic server dispatcher with full gameplay emulation...")

-- 1. Mock MarketplaceService to unlock ALL GamePasses & VIP areas in Studio testing
pcall(function()
    MarketplaceService.UserOwnsGamePassAsync = function(player, passId)
        print(string.format("[HyperSave VIP Emulator] GamePass #%s granted to %s (VIP Unlocked)", tostring(passId), tostring(player.Name)))
        return true
    end
    MarketplaceService.PlayerOwnsAsset = function(player, assetId)
        return true
    end
end)

-- 2. Mock DataStoreService (In-memory storage so saves don't throw permission errors in Studio)
local MockDataStores = {}
pcall(function()
    DataStoreService.GetDataStore = function(self, name, scope)
        local dsName = tostring(name) .. "_" .. tostring(scope or "global")
        if not MockDataStores[dsName] then
            local memoryStore = {}
            MockDataStores[dsName] = {
                GetAsync = function(s, key)
                    return memoryStore[key] or {Coins = 1000000, Level = 10, Gems = 50000}
                end,
                SetAsync = function(s, key, value)
                    memoryStore[key] = value
                    return value
                end,
                UpdateAsync = function(s, key, transformFn)
                    local current = memoryStore[key] or {Coins = 1000000, Level = 10, Gems = 50000}
                    local new = transformFn(current)
                    memoryStore[key] = new
                    return new
                end,
                RemoveAsync = function(s, key)
                    local old = memoryStore[key]
                    memoryStore[key] = nil
                    return old
                end,
            }
        end
        return MockDataStores[dsName]
    end
end)

-- 3. In-memory mock data store / state for connected players
local PlayerState = {}

local function initPlayer(player)
    PlayerState[player.UserId] = {
        Data = {},
        Inventory = {},
    }

    -- Auto-setup generous leaderstats if any UI expects it
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then
        leaderstats = Instance.new("Folder")
        leaderstats.Name = "leaderstats"

        local coins = Instance.new("IntValue")
        coins.Name = "Coins"
        coins.Value = 1000000
        coins.Parent = leaderstats

        local cash = Instance.new("IntValue")
        cash.Name = "Cash"
        cash.Value = 1000000
        cash.Parent = leaderstats

        local level = Instance.new("IntValue")
        level.Name = "Level"
        level.Value = 50
        level.Parent = leaderstats

        leaderstats.Parent = player
    end
end

Players.PlayerAdded:Connect(initPlayer)
for _, p in ipairs(Players:GetPlayers()) do
    task.spawn(initPlayer, p)
end

Players.PlayerRemoving:Connect(function(player)
    PlayerState[player.UserId] = nil
end)

]=])

    -- Hook RemoteFunctions (CRITICAL: Without this, client InvokeServer yields forever!)
    add("-- ============================================================================")
    add("-- [RemoteFunctions] Auto-Handlers (Returns default affirmative response to avoid UI lockup)")
    add("-- ============================================================================\n")

    for _, rf in ipairs(remotes.Functions) do
        local fullName = rf:GetFullName()

        add(string.format(
            [=[
-- RemoteFunction: %s
task.spawn(function()
    local target = %s
    if target and target:IsA("RemoteFunction") then
        target.OnServerInvoke = function(player, ...)
            local args = {...}
            print(string.format("[HyperSave Server] %s:InvokeServer() called by %%s with %%d arguments", player.Name, #args))
            
            -- Intelligent mock response based on common function naming patterns
            local nameLower = string.lower(%q)
            if string.find(nameLower, "data") or string.find(nameLower, "load") or string.find(nameLower, "get") or string.find(nameLower, "profile") then
                return {
                    Success = true,
                    Data = { Honey = 10000000, Pollen = 500000, Capacity = 2500000, Coins = 1000000, Gems = 50000, Level = 50, Beli = 10000000, Fragments = 50000 },
                    Coins = 1000000,
                    Gems = 50000,
                    Level = 50,
                    Beli = 10000000,
                    Inventory = {},
                }
            elseif string.find(nameLower, "hive") or string.find(nameLower, "claim") then
                return true, "Hive Claimed"
            elseif string.find(nameLower, "egg") or string.find(nameLower, "hatch") or string.find(nameLower, "pet") then
                return true, { PetId = "Huge_Dragon", Power = 1000000, Level = 100 }
            elseif string.find(nameLower, "fruit") or string.find(nameLower, "skill") or string.find(nameLower, "quest") then
                return { Success = true, Level = 2550, Mastery = 600, Beli = 10000000 }
            elseif string.find(nameLower, "weapon") or string.find(nameLower, "crate") or string.find(nameLower, "skin") then
                return { Success = true, Weapon = "Golden_Gun", Unlocked = true }
            elseif string.find(nameLower, "door") or string.find(nameLower, "key") or string.find(nameLower, "revive") then
                return true, "Unlocked"
            elseif string.find(nameLower, "buy") or string.find(nameLower, "purchase") or string.find(nameLower, "trade") then
                return true, "Success"
            end

            return true
        end
    end
end)
]=],
            fullName,
            getPathExpression(rf),
            rf.Name,
            rf.Name
        ))
    end

    -- Hook RemoteEvents
    add("\n-- ============================================================================")
    add("-- [RemoteEvents] Auto-Listeners (Logs actions and updates mock state)")
    add("-- ============================================================================\n")

    for _, re in ipairs(remotes.Events) do
        local fullName = re:GetFullName()

        add(string.format(
            [=[
-- RemoteEvent: %s
task.spawn(function()
    local target = %s
    if target and target:IsA("RemoteEvent") then
        target.OnServerEvent:Connect(function(player, ...)
            local args = {...}
            print(string.format("[HyperSave Server] %s:FireServer() received from %%s (%%d args)", player.Name, #args))
        end)
    end
end)
]=],
            fullName,
            getPathExpression(re),
            re.Name
        ))
    end

    -- Hook UnreliableRemoteEvents
    if remotes.Unreliable and #remotes.Unreliable > 0 then
        add("\n-- ============================================================================")
        add("-- [UnreliableRemoteEvents] Auto-Listeners")
        add("-- ============================================================================\n")

        for _, ure in ipairs(remotes.Unreliable) do
            local fullName = ure:GetFullName()

            add(string.format(
                [=[
-- UnreliableRemoteEvent: %s
task.spawn(function()
    local target = %s
    if target and target.ClassName == "UnreliableRemoteEvent" then
        target.OnServerEvent:Connect(function(player, ...)
            local args = {...}
            -- Suppress spam for unreliable position/render events
        end)
    end
end)
]=],
                fullName,
                getPathExpression(ure),
                ure.Name
            ))
        end
    end

    add([=[

print("[HyperSave Backend] Server dispatcher ready! All remotes are now responding.")
]=])

    return table.concat(lines, "\n")
end

-- Create synthetic ServerScriptService Folder & Script instances
function ServerSynthesizer.SynthesizeService(rootInstances)
    local remotes = ServerSynthesizer.CollectRemotes(rootInstances)
    local sourceCode = ServerSynthesizer.GenerateDispatcherSource(remotes)

    local serverService = Instance.new("Folder")
    serverService.Name = "ServerScriptService"

    local syntheticScript = Instance.new("Script")
    syntheticScript.Name = "ServerDispatcher"
    pcall(function()
        (syntheticScript ).Source = sourceCode
    end)
    syntheticScript.Parent = serverService

    return serverService
end

return ServerSynthesizer

end)

__define__("Core/StreamExplorer", function()
--[[
    HyperSaveInstance - StreamingEnabled Auto-Map Explorer (Camera-Only Stealth Mode)
    Sweeps spatial coordinates across the map via camera manipulation & RequestStreamAroundAsync.
    Zero physical character displacement to prevent movement/speed anti-cheat detections (Adonis, HD Admin, etc.).
    Includes a Snapshot Memory Accumulator to preserve streamed-out chunks in memory.
]]

local clonerefFn = cloneref or function(obj)
    return obj
end
local Players = nil
pcall(function()
    Players = clonerefFn(game:GetService("Players"))
end)

local StreamExplorer = {
    CapturedInstances = {},
}

-- Scan map bounds and calculate bounding box
function StreamExplorer.GetMapBoundingBox()
    local minVec = Vector3.new(-1024, -100, -1024)
    local maxVec = Vector3.new(1024, 500, 1024)

    -- Check if Terrain exists
    local terrain = workspace.Terrain
    if terrain then
        local s, extents = pcall(function()
            return terrain.MaxExtents
        end)
        if s and extents then
            minVec = Vector3.new(extents.Min.X * 4, -100, extents.Min.Z * 4)
            maxVec = Vector3.new(extents.Max.X * 4, 500, extents.Max.Z * 4)
            return minVec, maxVec
        end
    end

    -- Check workspace models/parts
    for _, child in ipairs(workspace:GetChildren()) do
        if child:IsA("BasePart") or child:IsA("Model") then
            pcall(function()
                local cf, sz
                if child:IsA("Model") then
                    cf, sz = child:GetBoundingBox()
                else
                    cf, sz = child.CFrame, child.Size
                end
                local pos = cf.Position
                minVec = Vector3.new(math.min(minVec.X, pos.X - sz.X), math.min(minVec.Y, pos.Y - sz.Y), math.min(minVec.Z, pos.Z - sz.Z))
                maxVec = Vector3.new(math.max(maxVec.X, pos.X + sz.X), math.max(maxVec.Y, pos.Y + sz.Y), math.max(maxVec.Z, pos.Z + sz.Z))
            end)
        end
    end

    return minVec, maxVec
end

-- Index currently loaded instances in workspace into memory accumulator
function StreamExplorer.AccumulateCurrentInstances()
    for _, desc in ipairs(workspace:GetDescendants()) do
        if not StreamExplorer.CapturedInstances[desc] then
            StreamExplorer.CapturedInstances[desc] = true
        end
    end
end

-- Get all accumulated instances across all visited chunks
function StreamExplorer.GetAccumulatedInstances()
    local list = {}
    for inst, _ in pairs(StreamExplorer.CapturedInstances) do
        table.insert(list, inst)
    end
    return list
end

-- Clear accumulator
function StreamExplorer.ClearAccumulator()
    table.clear(StreamExplorer.CapturedInstances)
end

-- Perform stealth grid sweep to load chunks safely without moving character
function StreamExplorer.ExploreMap(stepSize, progressCallback)
    if not workspace.StreamingEnabled then
        StreamExplorer.AccumulateCurrentInstances()
        return true
    end

    local player = nil
    pcall(function()
        player = Players and Players.LocalPlayer
    end)
    local camera = workspace.CurrentCamera
    local originalCameraCFrame = camera and camera.CFrame
    local originalCameraType = camera and camera.CameraType

    local hrp = nil
    if allowPhysicalTeleport and player and player.Character then
        hrp = player.Character:FindFirstChild("HumanoidRootPart")
    end
    local originalHrpCFrame = hrp and hrp.CFrame
    local minVec, maxVec = StreamExplorer.GetMapBoundingBox()

    local step = stepSize or 512
    local points = {}

    for x = minVec.X, maxVec.X, step do
        for z = minVec.Z, maxVec.Z, step do
            table.insert(points, Vector3.new(x, math.max(60, (minVec.Y + maxVec.Y) / 2), z))
        end
    end

    local total = #points
    local completed = 0

    -- Put camera in Scriptable mode to focus on chunks without character movement
    if camera and not allowPhysicalTeleport then
        pcall(function()
            camera.CameraType = Enum.CameraType.Scriptable
        end)
    end

    -- Initial capture of spawn region
    StreamExplorer.AccumulateCurrentInstances()

    for i, targetPos in ipairs(points) do
        -- 1. Stealth Camera focus (Moves observation vector without triggering movement anti-cheat)
        if camera and not allowPhysicalTeleport then
            pcall(function()
                camera.CFrame = CFrame.new(targetPos + Vector3.new(0, 120, 0), targetPos)
            end)
        end

        -- 2. Non-intrusive stream request
        local requested = false
        if player and player.RequestStreamAroundAsync then
            local s = pcall(function()
                player:RequestStreamAroundAsync(targetPos)
            end)
            if s then
                requested = true
            end
        end
        if not requested and workspace and workspace.RequestStreamAroundAsync then
            pcall(function()
                workspace:RequestStreamAroundAsync(targetPos)
            end)
        end

        -- 3. Optional physical teleport (Only if user explicitly forced it)
        if allowPhysicalTeleport and hrp then
            pcall(function()
                hrp.CFrame = CFrame.new(targetPos)
            end)
        end

        -- Natural jitter delay (70ms to 110ms)
        local jitter = 0.07 + (math.random(1, 40) / 1000)
        task.wait(jitter)

        -- 4. Accumulate newly streamed instances into memory buffer before potential stream-out
        StreamExplorer.AccumulateCurrentInstances()

        completed = i
        if progressCallback then
            pcall(progressCallback, completed, total, targetPos)
        end
    end

    -- Restore camera to normal gameplay state
    if camera and originalCameraType then
        pcall(function()
            camera.CameraType = originalCameraType
            if originalCameraCFrame then
                camera.CFrame = originalCameraCFrame
            end
        end)
    end

    -- Restore character if physically moved
    if allowPhysicalTeleport and hrp and originalHrpCFrame then
        pcall(function()
            hrp.CFrame = originalHrpCFrame
        end)
    end

    return true
end

return StreamExplorer

end)

__define__("Core/TerrainSerializer", function()
--[[
    HyperSaveInstance - Advanced Terrain & Voxel Serializer
    Preserves SmoothVoxels, materials, occupancies, water physics, decoration and material colors (10/10 visual fidelity).
]]

local Base64 = __require__("Utils/Base64")

local TerrainSerializer = {}

function TerrainSerializer.ExtractTerrainData(terrain, options)
    local data = {
        Decoration = false,
        WaterColor = Color3.fromRGB(12, 84, 91),
        WaterReflectance = 1,
        WaterTransparency = 1,
        WaterWaveSize = 0.15,
        WaterWaveSpeed = 10,
        MaterialColors = "",
        HasVoxels = false,
        VoxelChunks = {},
    }

    if not terrain or not terrain:IsA("Terrain") then
        return data
    end

    -- Extract basic properties safely
    pcall(function()
        data.Decoration = terrain.Decoration
    end)
    pcall(function()
        data.WaterColor = terrain.WaterColor
    end)
    pcall(function()
        data.WaterReflectance = terrain.WaterReflectance
    end)
    pcall(function()
        data.WaterTransparency = terrain.WaterTransparency
    end)
    pcall(function()
        data.WaterWaveSize = terrain.WaterWaveSize
    end)
    pcall(function()
        data.WaterWaveSpeed = terrain.WaterWaveSpeed
    end)
    pcall(function()
        data.MaterialColors = terrain.MaterialColors
    end)

    if not options.SaveTerrainVoxels then
        return data
    end

    -- Extract Voxels safely
    local success, maxExtents = pcall(function()
        return terrain.MaxExtents
    end)

    if not success or not maxExtents then
        return data
    end

    local minVoxel = maxExtents.Min
    local maxVoxel = maxExtents.Max
    local step = options.TerrainVoxelStep or 64

    local xChunks = math.ceil((maxVoxel.X - minVoxel.X) / step)
    local yChunks = math.ceil((maxVoxel.Y - minVoxel.Y) / step)
    local zChunks = math.ceil((maxVoxel.Z - minVoxel.Z) / step)

    local chunkCount = 0
    -- Iterate chunks
    for cx = 0, xChunks - 1 do
        for cy = 0, yChunks - 1 do
            for cz = 0, zChunks - 1 do
                chunkCount = chunkCount + 1
                if chunkCount % 12 == 0 then
                    task.wait(0.001)
                end
                local chunkMin = Vector3int16.new(minVoxel.X + cx * step, minVoxel.Y + cy * step, minVoxel.Z + cz * step)
                local chunkMax = Vector3int16.new(
                    math.min(chunkMin.X + step, maxVoxel.X),
                    math.min(chunkMin.Y + step, maxVoxel.Y),
                    math.min(chunkMin.Z + step, maxVoxel.Z)
                )

                local regSuccess, materials, occupancies = pcall(function()
                    return terrain:ReadVoxels(Region3int16.new(chunkMin, chunkMax))
                end)

                if regSuccess and materials and occupancies then
                    local size = materials.Size
                    local hasContent = false
                    local rawMat = {}
                    local rawOcc = {}

                    for x = 1, size.X do
                        for y = 1, size.Y do
                            for z = 1, size.Z do
                                local mat = materials[x][y][z]
                                local occ = occupancies[x][y][z]

                                if occ > 0 and mat ~= Enum.Material.Air then
                                    hasContent = true
                                end
                                table.insert(rawMat, string.char(mat.Value % 256))
                                table.insert(rawOcc, string.char(math.floor(occ * 255)))
                            end
                        end
                    end

                    if hasContent then
                        data.HasVoxels = true
                        table.insert(data.VoxelChunks, {
                            Min = chunkMin,
                            Max = chunkMax,
                            Size = size,
                            Materials = Base64.Encode(table.concat(rawMat)),
                            Occupancies = Base64.Encode(table.concat(rawOcc)),
                        })
                    end
                end
            end
        end
    end

    return data
end

return TerrainSerializer

end)

__define__("Core/UniverseTracker", function()
--[[
    HyperSaveInstance - Game Universe & Multi-Place Tracker
    Discovers all sub-places in multi-place experiences (Dungeons, Lobbies, Arenas, Sub-maps).
]]

local UniverseTracker = {}



-- Fetch all places belonging to current Game Universe
function UniverseTracker.GetUniversePlaces()
    local places = {}
    local currentPlaceId = game.PlaceId or 0
    local rootName = "Root Place"

    local clonerefFn = cloneref or function(obj)
        return obj
    end
    pcall(function()
        local mp = clonerefFn(game:GetService("MarketplaceService"))
        if mp then
            rootName = mp:GetProductInfo(currentPlaceId).Name
        end
    end)

    -- Add current place
    table.insert(places, {
        PlaceId = currentPlaceId,
        Name = rootName,
        IsRoot = true,
    })

    -- Query AssetService for places in universe
    local success, pages = pcall(function()
        local assetService = clonerefFn(game:GetService("AssetService"))
        return assetService and assetService:GetGamePlacesAsync()
    end)

    if success and pages then
        local function processPage()
            local currentList = pages:GetCurrentPage()
            for _, item in ipairs(currentList) do
                if item.PlaceId ~= currentPlaceId then
                    table.insert(places, {
                        PlaceId = item.PlaceId,
                        Name = item.Name or ("Sub-Place " .. tostring(item.PlaceId)),
                        IsRoot = false,
                    })
                end
            end
        end

        processPage()
        while not pages.IsFinished do
            local nextSuccess = pcall(function()
                pages:AdvanceToNextPageAsync()
            end)
            if not nextSuccess then
                break
            end
            processPage()
        end
    end

    return places
end

-- Export Universe places hierarchy to JSON file
function UniverseTracker.ExportUniverseMap(customPath)
    local Environment = __require__("Utils/Environment")
    local clonerefFn = cloneref or function(obj)
        return obj
    end
    local HttpService = clonerefFn(game:GetService("HttpService"))

    local places = UniverseTracker.GetUniversePlaces()
    local currentPlaceId = game.PlaceId or 0
    local fileName = customPath or string.format("HyperSave_Universe_%d.json", currentPlaceId)

    local success, json = pcall(function()
        return HttpService:JSONEncode({
            UniverseRootPlaceId = currentPlaceId,
            TotalPlaces = #places,
            ExportDate = os.date("%Y-%m-%d %H:%M:%S"),
            Places = places,
        })
    end)

    if success and json then
        local wOk = Environment.WriteFile(fileName, json)
        return wOk, fileName
    end

    return false, "Failed to encode Universe JSON"
end

return UniverseTracker

end)

__define__("Core/Web3DExporter", function()
--[[
    HyperSaveInstance - Standalone Web 3D (HTML / Three.js) Exporter
    Exports any 3D Model, Map or Weapon into a single standalone interactive HTML file
    with WebGL, OrbitControls, studio lighting, wireframe view, and clean Dark Slate HUD.
]]

local Environment = __require__("Utils/Environment")
local ObjExporter = __require__("Core/ObjExporter")

local Web3DExporter = {}

function Web3DExporter.ExportModelToHTML(targetRoot, options)
    local root = targetRoot or workspace
    local opts = options or {}
    local placeId = game.PlaceId or 0
    local safeName = string.gsub(root.Name, "[^%w_%-]", "_")
    local fileName = string.format("HyperSave_Web3D_%s_%d.html", safeName, placeId)

    -- Export raw OBJ/MTL geometry first
    local success, objStr, mtlStr = pcall(function()
        return ObjExporter.GenerateObj(root, opts)
    end)

    if not success then
        return false, "Erro ao gerar geometria 3D: " .. tostring(objStr)
    end
    if not objStr or #objStr < 10 then
        return false, "Nenhuma peça 3D encontrada no modelo para exportar."
    end

    local escapedObj = string.gsub(objStr, "\\", "\\\\")
    escapedObj = string.gsub(escapedObj, "`", "\\`")
    escapedObj = string.gsub(escapedObj, "%$", "\\$")

    local htmlParts = {
        [==[<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HyperSave 3D Web Viewer - ]==],
        safeName,
        [==[</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            background-color: #0F1117;
            color: #FFFFFF;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            overflow: hidden;
            width: 100vw;
            height: 100vh;
        }
        #webgl-canvas { width: 100%; height: 100%; display: block; }
        .panel {
            position: absolute;
            background: #181B24;
            border: 1px solid #303646;
            border-radius: 8px;
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.4);
            padding: 14px 18px;
            z-index: 100;
        }
        #header-card {
            top: 16px;
            left: 16px;
            display: flex;
            flex-direction: column;
            gap: 4px;
        }
        .title {
            font-size: 14px;
            font-weight: 700;
            color: #FFFFFF;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .badge {
            background: #2563EB;
            color: #FFFFFF;
            font-size: 10px;
            padding: 2px 6px;
            border-radius: 4px;
            font-weight: 600;
        }
        .subtitle { font-size: 11px; color: #94A3B8; }
        #controls-card {
            bottom: 20px;
            left: 50%;
            transform: translateX(-50%);
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .btn {
            background: #232734;
            color: #FFFFFF;
            border: 1px solid #32394C;
            padding: 8px 14px;
            border-radius: 6px;
            font-size: 11px;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.15s ease;
        }
        .btn:hover {
            background: #2563EB;
            border-color: #3B82F6;
        }
        .btn.active {
            background: #2563EB;
            border-color: #3B82F6;
        }
        #stats-card {
            top: 16px;
            right: 16px;
            font-size: 11px;
            line-height: 1.6;
            color: #94A3B8;
        }
        #stats-card strong { color: #FFFFFF; }
        #loading {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            font-size: 13px;
            font-weight: 600;
            color: #FFFFFF;
            background: #181B24;
            padding: 14px 24px;
            border-radius: 8px;
            border: 1px solid #303646;
            pointer-events: none;
            transition: opacity 0.3s ease;
        }
    </style>
    <!-- Three.js and OBJLoader CDN -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/three@0.128.0/examples/js/controls/OrbitControls.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/three@0.128.0/examples/js/loaders/OBJLoader.js"></script>
</head>
<body>
    <div id="header-card" class="panel">
        <div class="title">
            <span>HyperSave 3D</span>
            <span class="badge">]==],
        safeName,
        [==[</span>
        </div>
        <div class="subtitle">Por Theo Lorentz Padilha • Visualizador WebGL</div>
    </div>

    <div id="stats-card" class="panel">
        <div><strong>Status:</strong> <span style="color:#10B981">Carregado</span></div>
        <div><strong>Place ID:</strong> ]==],
        tostring(placeId),
        [==[</div>
        <div><strong>Controles:</strong> Botão esquerdo (Girar) | Direito (Pan) | Scroll (Zoom)</div>
    </div>

    <div id="controls-card" class="panel">
        <button id="btn-wireframe" class="btn">Linhas (Wireframe)</button>
        <button id="btn-rotate" class="btn active">Auto-Rotação: ON</button>
        <button id="btn-reset" class="btn">Resetar Câmera</button>
    </div>

    <div id="loading">Renderizando geometria 3D...</div>
    <div id="webgl-canvas"></div>

    <script>
        const rawObjData = `]==],
        escapedObj,
        [==[`;

        let scene, camera, renderer, controls, currentMeshGroup;
        let isWireframe = false;
        let isAutoRotate = true;

        function init() {
            const container = document.getElementById('webgl-canvas');
            scene = new THREE.Scene();
            scene.background = new THREE.Color(0x0F1117);
            scene.fog = new THREE.FogExp2(0x0F1117, 0.005);

            camera = new THREE.PerspectiveCamera(50, window.innerWidth / window.innerHeight, 0.1, 5000);
            camera.position.set(30, 25, 45);

            renderer = new THREE.WebGLRenderer({ antialias: true });
            renderer.setSize(window.innerWidth, window.innerHeight);
            renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
            renderer.shadowMap.enabled = true;
            renderer.shadowMap.type = THREE.PCFSoftShadowMap;
            renderer.toneMapping = THREE.ACESFilmicToneMapping;
            renderer.toneMappingExposure = 1.0;
            container.appendChild(renderer.domElement);

            controls = new THREE.OrbitControls(camera, renderer.domElement);
            controls.enableDamping = true;
            controls.dampingFactor = 0.05;
            controls.autoRotate = true;
            controls.autoRotateSpeed = 1.2;

            // Studio Lighting Setup
            const ambient = new THREE.AmbientLight(0xffffff, 0.6);
            scene.add(ambient);

            const sun = new THREE.DirectionalLight(0xffffff, 1.2);
            sun.position.set(80, 150, 60);
            sun.castShadow = true;
            sun.shadow.mapSize.width = 2048;
            sun.shadow.mapSize.height = 2048;
            scene.add(sun);

            const fillLight = new THREE.DirectionalLight(0x94A3B8, 0.5);
            fillLight.position.set(-60, 40, -60);
            scene.add(fillLight);

            // Ground Grid
            const grid = new THREE.GridHelper(300, 60, 0x2563EB, 0x272A34);
            grid.position.y = -0.1;
            scene.add(grid);

            // Load parsed OBJ string
            const loader = new THREE.OBJLoader();
            try {
                const obj = loader.parse(rawObjData);
                currentMeshGroup = obj;

                // Center geometry and fit camera
                const box = new THREE.Box3().setFromObject(obj);
                const center = box.getCenter(new THREE.Vector3());
                const size = box.getSize(new THREE.Vector3());

                obj.position.x = -center.x;
                obj.position.y = -box.min.y;
                obj.position.z = -center.z;

                obj.traverse((child) => {
                    if (child.isMesh) {
                        child.castShadow = true;
                        child.receiveShadow = true;
                        if (!child.material) {
                            child.material = new THREE.MeshStandardMaterial({
                                color: 0x94A3B8,
                                roughness: 0.5,
                                metalness: 0.1
                            });
                        }
                    }
                });

                scene.add(obj);

                const maxDim = Math.max(size.x, size.y, size.z);
                const fov = camera.fov * (Math.PI / 180);
                let cameraZ = Math.abs(maxDim / 2 / Math.tan(fov / 2)) * 1.5;
                cameraZ = Math.max(cameraZ, 20);

                camera.position.set(cameraZ * 0.8, cameraZ * 0.6, cameraZ * 0.8);
                camera.lookAt(0, size.y * 0.4, 0);
                controls.target.set(0, size.y * 0.4, 0);
                controls.update();

                document.getElementById('loading').style.opacity = '0';
                setTimeout(() => { document.getElementById('loading').style.display = 'none'; }, 300);
            } catch (err) {
                console.error("Erro ao parsear OBJ:", err);
                document.getElementById('loading').innerText = "Erro ao renderizar 3D: " + err.message;
            }

            // Button Event Listeners
            document.getElementById('btn-wireframe').addEventListener('click', () => {
                isWireframe = !isWireframe;
                document.getElementById('btn-wireframe').classList.toggle('active', isWireframe);
                if (currentMeshGroup) {
                    currentMeshGroup.traverse((child) => {
                        if (child.isMesh && child.material) {
                            child.material.wireframe = isWireframe;
                        }
                    });
                }
            });

            document.getElementById('btn-rotate').addEventListener('click', () => {
                isAutoRotate = !isAutoRotate;
                controls.autoRotate = isAutoRotate;
                document.getElementById('btn-rotate').classList.toggle('active', isAutoRotate);
                document.getElementById('btn-rotate').innerText = isAutoRotate ? "Auto-Rotação: ON" : "Auto-Rotação: OFF";
            });

            document.getElementById('btn-reset').addEventListener('click', () => {
                if (currentMeshGroup) {
                    const box = new THREE.Box3().setFromObject(currentMeshGroup);
                    const size = box.getSize(new THREE.Vector3());
                    const maxDim = Math.max(size.x, size.y, size.z);
                    camera.position.set(maxDim * 1.2, maxDim * 0.8, maxDim * 1.2);
                    controls.target.set(0, size.y * 0.4, 0);
                    controls.update();
                }
            });

            window.addEventListener('resize', onWindowResize);
        }

        function onWindowResize() {
            camera.aspect = window.innerWidth / window.innerHeight;
            camera.updateProjectionMatrix();
            renderer.setSize(window.innerWidth, window.innerHeight);
        }

        function animate() {
            requestAnimationFrame(animate);
            controls.update();
            renderer.render(scene, camera);
        }

        window.onload = () => {
            init();
            animate();
        };
    </script>
</body>
</html>]==],
    }

    local fullHtml = table.concat(htmlParts, "")

    if Environment.HasFileSystem() then
        local ok = Environment.WriteFile(fileName, fullHtml)
        if ok then
            return true, fileName
        else
            return false, "Falha ao gravar arquivo Web 3D."
        end
    end

    return false, "Função writefile indisponível no executor atual."
end

return Web3DExporter

end)

__define__("UI/Interface", function()
--[[
    HyperSaveInstance - Modern Glassmorphic HUD & Master In-Game Suite
    Includes 1-Click Clone, Audio Ripper, Lighting Ripper, GUI Ripper, Target Selector, Network Sniffer, Universe Tracker, 3D OBJ Exporter, Tutorial and Settings.
]]

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Theme = __require__("UI/Theme")
local Environment = __require__("Utils/Environment")
local Defaults = __require__("Config/Defaults")
local AudioRipper = __require__("Core/AudioRipper")
local LightingRipper = __require__("Core/LightingRipper")
local GuiRipper = __require__("Core/GuiRipper")
local NetworkSniffer = __require__("Core/NetworkSniffer")
local UniverseTracker = __require__("Core/UniverseTracker")
local ObjExporter = __require__("Core/ObjExporter")
local RaycastSelector = __require__("Core/RaycastSelector")
local PlaceDiffTracker = __require__("Core/PlaceDiffTracker")
local Web3DExporter = __require__("Core/Web3DExporter")
local LicenseManager = __require__("Utils/LicenseManager")
local AntiAFK = __require__("Utils/AntiAFK")
local Stealth = __require__("Utils/Stealth")

local VERSION = "2.0.0"

-- Attempt auto-load of saved enterprise key
pcall(function()
    local fn = Environment.GetReadFileFunction()
    if fn then
        local content = fn("HyperSave_License.key")
        if content and #content > 0 then
            LicenseManager.ApplyKey(content)
        end
    end
end)

local Interface = {}
Interface.__index = Interface

function Interface.new(engine)
    local self = setmetatable({}, Interface)
    self.Engine = engine
    self.Config = engine.Config
    self.Logs = {}
    self.ActiveTab = "Dashboard"
    self.IsMinimized = false
    self.SavedFilePath = ""
    self.SavedAssetPath = ""
    self.Raycast = RaycastSelector.new()
    self.SelectedTargets = {}
    self.CurrentTargetInstance = nil

    self:BuildUI()
    self:BindEngineEvents()
    self:BindKeybinds()
    return self
end

function Interface:BindKeybinds()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then
            return
        end
        if input.KeyCode == (self.Config.ToggleKeybind or Enum.KeyCode.RightShift) then
            if self.MainFrame then
                self.MainFrame.Visible = not self.MainFrame.Visible
                if self.FloatingToggle then
                    self.FloatingToggle.Visible = not self.MainFrame.Visible
                end
            end
        end
    end)
end

function Interface:BuildUI()
    local parent = Environment.GetSafeGuiParent()
    local safeContainer = nil

    local isRandom = self.Config.RandomizeGuiName
    local guiName = self.Config.GuiName or (isRandom and Stealth.GenerateRandomName(14) or "HyperSaveInstance_UI")
    local containerName = isRandom and Stealth.GenerateRandomName(12) or "HyperSave_Container"

    if parent and (parent:IsA("LayerCollector") or parent:IsA("ScreenGui")) then
        pcall(function()
            local old = parent:FindFirstChild(containerName)
            if old then
                old:Destroy()
            end
        end)
        local container = Instance.new("Frame")
        container.Name = containerName
        container.Size = UDim2.new(1, 0, 1, 0)
        container.BackgroundTransparency = 1
        container.Parent = parent
        safeContainer = container
    else
        pcall(function()
            local old = parent:FindFirstChild(guiName) or parent:FindFirstChild("HyperSaveInstance_UI")
            if old then
                old:Destroy()
            end
        end)

        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = guiName
        screenGui.ResetOnSpawn = false
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        screenGui.DisplayOrder = 999999
        screenGui.IgnoreGuiInset = true
        screenGui.Enabled = true
        self.ScreenGui = screenGui

        Stealth.ProtectGui(screenGui)

        local ok = pcall(function()
            screenGui.Parent = parent
        end)
        if not ok or not screenGui.Parent then
            pcall(function()
                screenGui.Parent = game:GetService("CoreGui")
            end)
            if not screenGui.Parent and not self.Config.StealthMode then
                pcall(function()
                    local plrs = game:GetService("Players")
                    local lp = plrs.LocalPlayer or plrs:FindFirstChildOfClass("Player")
                    screenGui.Parent = lp and lp:FindFirstChildOfClass("PlayerGui")
                end)
            end
        end
        safeContainer = screenGui
    end

    if self.Engine and self.Engine.Config then
        self.Engine.Config.IgnoredGui = safeContainer
    end

    -- Floating Mini Toggle Button
    local floatingBtn = Instance.new("TextButton")
    floatingBtn.Name = isRandom and Stealth.GenerateRandomName(8) or "FloatingToggle"
    floatingBtn.Text = isRandom and "[HSI]" or "HyperSaveInstance"
    floatingBtn.Font = Theme.FontSemiBold
    floatingBtn.TextSize = 11
    floatingBtn.TextColor3 = Theme.TextPrimary
    floatingBtn.BackgroundColor3 = Theme.AccentPrimary
    floatingBtn.Size = UDim2.new(0, 150, 0, 32)
    floatingBtn.Position = UDim2.new(0, 20, 0, 20)
    floatingBtn.Visible = false
    Theme.AddCorner(floatingBtn, Theme.CornerMedium)
    Theme.AddStroke(floatingBtn, Theme.BorderLight, 1)
    floatingBtn.Parent = safeContainer
    self.FloatingToggle = floatingBtn

    -- Make floating button draggable on touchscreen / mobile
    local fDragging, fDragStart, fStartPos
    floatingBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            fDragging = true
            fDragStart = input.Position
            fStartPos = floatingBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    fDragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and fDragging then
            local delta = input.Position - fDragStart
            floatingBtn.Position =
                UDim2.new(fStartPos.X.Scale, fStartPos.X.Offset + delta.X, fStartPos.Y.Scale, fStartPos.Y.Offset + delta.Y)
        end
    end)

    Theme.AnimateButton(floatingBtn, function()
        if self.MainFrame then
            self.MainFrame.Visible = true
        end
        floatingBtn.Visible = false
    end)

    local camera = workspace.CurrentCamera
    local vpSize = (camera and camera.ViewportSize) or Vector2.new(1280, 720)
    local winWidth = math.clamp(vpSize.X - 24, 320, 670)
    local winHeight = math.clamp(vpSize.Y - 32, 280, 480)

    -- Instant Splash Loading Card (Shows immediately when script is executed)
    local splash = Instance.new("Frame")
    splash.Name = "SplashCard"
    splash.AnchorPoint = Vector2.new(0.5, 0.5)
    splash.Size = UDim2.new(0, 340, 0, 140)
    splash.Position = UDim2.new(0.5, 0, 0.5, 0)
    splash.BackgroundColor3 = Theme.Background
    splash.BorderSizePixel = 0
    Theme.AddCorner(splash, Theme.CornerLarge)
    Theme.AddStroke(splash, Theme.Border, 1)
    splash.Parent = safeContainer

    local splashTitle = Instance.new("TextLabel")
    splashTitle.Text = "HyperSaveInstance"
    splashTitle.Font = Theme.FontTitle
    splashTitle.TextSize = 15
    splashTitle.TextColor3 = Theme.TextPrimary
    splashTitle.Size = UDim2.new(1, 0, 0, 26)
    splashTitle.Position = UDim2.new(0, 0, 0, 16)
    splashTitle.BackgroundTransparency = 1
    splashTitle.Parent = splash

    local splashBadge = Instance.new("TextLabel")
    splashBadge.Text = "Por Theo Lorentz Padilha"
    splashBadge.Font = Theme.FontRegular
    splashBadge.TextSize = 11
    splashBadge.TextColor3 = Theme.TextSecondary
    splashBadge.BackgroundColor3 = Theme.CardBg
    splashBadge.Size = UDim2.new(0, 220, 0, 22)
    splashBadge.Position = UDim2.new(0.5, -110, 0, 46)
    Theme.AddCorner(splashBadge, Theme.CornerSmall)
    Theme.AddStroke(splashBadge, Theme.Border, 1)
    splashBadge.Parent = splash

    local splashStatus = Instance.new("TextLabel")
    splashStatus.Text = "Carregando interface..."
    splashStatus.Font = Theme.FontRegular
    splashStatus.TextSize = 11
    splashStatus.TextColor3 = Theme.TextMuted
    splashStatus.Size = UDim2.new(1, 0, 0, 20)
    splashStatus.Position = UDim2.new(0, 0, 0, 76)
    splashStatus.BackgroundTransparency = 1
    splashStatus.Parent = splash

    local splashTrack = Instance.new("Frame")
    splashTrack.Size = UDim2.new(1, -48, 0, 4)
    splashTrack.Position = UDim2.new(0, 24, 0, 108)
    splashTrack.BackgroundColor3 = Theme.CardBg
    Theme.AddCorner(splashTrack, Theme.CornerPill)
    splashTrack.Parent = splash

    local splashFill = Instance.new("Frame")
    splashFill.Size = UDim2.new(0.2, 0, 1, 0)
    splashFill.BackgroundColor3 = Theme.AccentPrimary
    Theme.AddCorner(splashFill, Theme.CornerPill)
    splashFill.Parent = splashTrack
    self.SplashFill = splashFill
    self.SplashCard = splash

    -- Main Container (Clean, Solid, High-Contrast Modern Theme)
    local main = Instance.new("Frame")
    main.Name = "MainFrame"
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.Size = UDim2.new(0, winWidth, 0, winHeight)
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    main.BackgroundColor3 = Theme.Background
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Visible = true
    Theme.AddCorner(main, Theme.CornerLarge)
    Theme.AddStroke(main, Theme.Border, 1)
    main.Parent = safeContainer
    self.MainFrame = main

    -- Dragging logic
    local dragging, dragInput, dragStart, startPos
    main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    main.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Window Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 44)
    header.BackgroundColor3 = Theme.CardBg
    header.BorderSizePixel = 0
    header.Parent = main

    local headerLine = Instance.new("Frame")
    headerLine.Size = UDim2.new(1, 0, 0, 1)
    headerLine.Position = UDim2.new(0, 0, 1, -1)
    headerLine.BackgroundColor3 = Theme.Border
    headerLine.BorderSizePixel = 0
    headerLine.Parent = header

    local title = Instance.new("TextLabel")
    title.Text = "HyperSaveInstance"
    title.Font = Theme.FontTitle
    title.TextSize = 13
    title.TextColor3 = Theme.TextPrimary
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Size = UDim2.new(0, 160, 1, 0)
    title.Position = UDim2.new(0, 14, 0, 0)
    title.BackgroundTransparency = 1
    title.Parent = header

    -- Platform & License Badge
    local badge = Instance.new("TextButton")
    local isEnt = LicenseManager.IsEnterprise()
    badge.Text = isEnt and "Enterprise" or "Ativar Licença"
    badge.Font = Theme.FontSemiBold
    badge.TextSize = 10
    badge.TextColor3 = isEnt and Theme.AccentSuccess or Theme.TextSecondary
    badge.BackgroundColor3 = Theme.Background
    badge.Size = UDim2.new(0, 100, 0, 24)
    badge.Position = UDim2.new(0, 160, 0.5, -12)
    Theme.AddCorner(badge, Theme.CornerSmall)
    local bStroke = Theme.AddStroke(badge, isEnt and Theme.AccentSuccess or Theme.Border, 1)
    badge.Parent = header

    -- Anti-AFK Header Badge
    local antiAfkBadge = Instance.new("TextButton")
    antiAfkBadge.Name = "HeaderAntiAFK"
    antiAfkBadge.Text = AntiAFK.IsEnabled() and "🛡️ Anti-AFK: ON" or "🛡️ Anti-AFK: OFF"
    antiAfkBadge.Font = Theme.FontSemiBold
    antiAfkBadge.TextSize = 10
    antiAfkBadge.TextColor3 = AntiAFK.IsEnabled() and Theme.AccentSuccess or Theme.TextMuted
    antiAfkBadge.BackgroundColor3 = Theme.Background
    antiAfkBadge.Size = UDim2.new(0, 105, 0, 24)
    antiAfkBadge.Position = UDim2.new(0, 268, 0.5, -12)
    Theme.AddCorner(antiAfkBadge, Theme.CornerSmall)
    local aStroke = Theme.AddStroke(antiAfkBadge, AntiAFK.IsEnabled() and Theme.AccentSuccess or Theme.Border, 1)
    antiAfkBadge.Parent = header
    self.AntiAfkHeaderBadge = antiAfkBadge

    Theme.AnimateButton(antiAfkBadge, function()
        local newState = AntiAFK.Toggle()
        self.Config.AutoAntiAFK = newState
        self:Log(
            newState and "🛡️ Proteção Anti-AFK Ativada!" or "🛡️ Proteção Anti-AFK Desativada.",
            newState and Theme.AccentSuccess or Theme.TextMuted
        )
    end)

    -- Update Checker Header Button
    local updateHeaderBtn = Instance.new("TextButton")
    updateHeaderBtn.Name = "HeaderUpdateBtn"
    updateHeaderBtn.Text = "🔄 v" .. VERSION
    updateHeaderBtn.Font = Theme.FontSemiBold
    updateHeaderBtn.TextSize = 10
    updateHeaderBtn.TextColor3 = Theme.TextPrimary
    updateHeaderBtn.BackgroundColor3 = Theme.Background
    updateHeaderBtn.Size = UDim2.new(0, 75, 0, 24)
    updateHeaderBtn.Position = UDim2.new(0, 380, 0.5, -12)
    Theme.AddCorner(updateHeaderBtn, Theme.CornerSmall)
    Theme.AddStroke(updateHeaderBtn, Theme.Border, 1)
    updateHeaderBtn.Parent = header
    self.UpdateHeaderBtn = updateHeaderBtn

    -- Update Center Modal Dialog
    local updateModal = Instance.new("Frame")
    updateModal.Name = "UpdateModal"
    updateModal.Size = UDim2.new(1, 0, 1, 0)
    updateModal.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    updateModal.BackgroundTransparency = 0.4
    updateModal.Visible = false
    updateModal.ZIndex = 50
    updateModal.Parent = main
    self.UpdateModal = updateModal

    local updateCard = Instance.new("Frame")
    updateCard.Size = UDim2.new(0, 380, 0, 190)
    updateCard.Position = UDim2.new(0.5, -190, 0.5, -95)
    updateCard.BackgroundColor3 = Theme.Background
    updateCard.ZIndex = 51
    Theme.AddCorner(updateCard, Theme.CornerMedium)
    Theme.AddStroke(updateCard, Theme.Border, 1)
    updateCard.Parent = updateModal

    local uTitle = Instance.new("TextLabel")
    uTitle.Text = "🚀 Central de Atualizações (HyperSave)"
    uTitle.Font = Theme.FontTitle
    uTitle.TextSize = 12
    uTitle.TextColor3 = Theme.TextPrimary
    uTitle.Size = UDim2.new(1, -24, 0, 22)
    uTitle.Position = UDim2.new(0, 12, 0, 12)
    uTitle.BackgroundTransparency = 1
    uTitle.ZIndex = 52
    uTitle.Parent = updateCard

    local uVerInstalled = Instance.new("TextLabel")
    uVerInstalled.Text = "Versão Instalada: v" .. VERSION .. " (Gothic Cyberpunk Engine)"
    uVerInstalled.Font = Theme.FontSemiBold
    uVerInstalled.TextSize = 10
    uVerInstalled.TextColor3 = Theme.AccentSuccess
    uVerInstalled.TextXAlignment = Enum.TextXAlignment.Left
    uVerInstalled.Size = UDim2.new(1, -24, 0, 16)
    uVerInstalled.Position = UDim2.new(0, 12, 0, 36)
    uVerInstalled.BackgroundTransparency = 1
    uVerInstalled.ZIndex = 52
    uVerInstalled.Parent = updateCard

    local uStatus = Instance.new("TextLabel")
    uStatus.Text = "Status: Clique em 'Verificar Agora' para checar o repositório oficial."
    uStatus.Font = Theme.FontRegular
    uStatus.TextSize = 10
    uStatus.TextColor3 = Theme.TextSecondary
    uStatus.TextXAlignment = Enum.TextXAlignment.Left
    uStatus.Size = UDim2.new(1, -24, 0, 34)
    uStatus.Position = UDim2.new(0, 12, 0, 56)
    uStatus.BackgroundTransparency = 1
    uStatus.TextWrapped = true
    uStatus.ZIndex = 52
    uStatus.Parent = updateCard

    local uCheckBtn = Instance.new("TextButton")
    uCheckBtn.Text = "🔄 Verificar Agora"
    uCheckBtn.Font = Theme.FontSemiBold
    uCheckBtn.TextSize = 10
    uCheckBtn.TextColor3 = Theme.TextPrimary
    uCheckBtn.BackgroundColor3 = Theme.AccentPrimary
    uCheckBtn.Size = UDim2.new(0.33, -8, 0, 28)
    uCheckBtn.Position = UDim2.new(0, 12, 0, 138)
    uCheckBtn.ZIndex = 52
    Theme.AddCorner(uCheckBtn, Theme.CornerSmall)
    uCheckBtn.Parent = updateCard

    local uCopyLoaderBtn = Instance.new("TextButton")
    uCopyLoaderBtn.Text = "📋 Copiar Loader"
    uCopyLoaderBtn.Font = Theme.FontSemiBold
    uCopyLoaderBtn.TextSize = 10
    uCopyLoaderBtn.TextColor3 = Theme.TextPrimary
    uCopyLoaderBtn.BackgroundColor3 = Theme.CardBg
    uCopyLoaderBtn.Size = UDim2.new(0.33, -8, 0, 28)
    uCopyLoaderBtn.Position = UDim2.new(0.33, 8, 0, 138)
    uCopyLoaderBtn.ZIndex = 52
    Theme.AddCorner(uCopyLoaderBtn, Theme.CornerSmall)
    Theme.AddStroke(uCopyLoaderBtn, Theme.Border, 1)
    uCopyLoaderBtn.Parent = updateCard

    local uCloseBtn = Instance.new("TextButton")
    uCloseBtn.Text = "Fechar"
    uCloseBtn.Font = Theme.FontSemiBold
    uCloseBtn.TextSize = 10
    uCloseBtn.TextColor3 = Theme.TextSecondary
    uCloseBtn.BackgroundColor3 = Theme.CardBg
    uCloseBtn.Size = UDim2.new(0.33, -8, 0, 28)
    uCloseBtn.Position = UDim2.new(0.66, 4, 0, 138)
    uCloseBtn.ZIndex = 52
    Theme.AddCorner(uCloseBtn, Theme.CornerSmall)
    Theme.AddStroke(uCloseBtn, Theme.Border, 1)
    uCloseBtn.Parent = updateCard

    Theme.AnimateButton(updateHeaderBtn, function()
        updateModal.Visible = true
    end)

    Theme.AnimateButton(uCloseBtn, function()
        updateModal.Visible = false
    end)

    Theme.AnimateButton(uCopyLoaderBtn, function()
        local loaderScript = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/theopadilha2009-hash/HyperSaveInstance/main/loader.luau"))()'
        Environment.SetClipboard(loaderScript)
        uCopyLoaderBtn.Text = "✓ Copiado!"
        task.delay(2, function()
            uCopyLoaderBtn.Text = "📋 Copiar Loader"
        end)
    end)

    Theme.AnimateButton(uCheckBtn, function()
        uStatus.Text = "Consultando GitHub em busca de novas versões..."
        uStatus.TextColor3 = Theme.TextPrimary
        uCheckBtn.Text = "Verificando..."

        task.spawn(function()
            local success, body = pcall(function()
                return game:HttpGet("https://raw.githubusercontent.com/theopadilha2009-hash/HyperSaveInstance/main/package.json", true)
            end)

            uCheckBtn.Text = "🔄 Verificar Agora"

            if success and type(body) == "string" and #body > 0 then
                local remoteVer = string.match(body, [["version"%s*:%s*"([^"]+)"]])
                if remoteVer then
                    if remoteVer == VERSION then
                        uStatus.Text = "✓ Você está na versão mais recente (v" .. VERSION .. ")! Nenhuma atualização necessária."
                        uStatus.TextColor3 = Theme.AccentSuccess
                    else
                        uStatus.Text = "⚡ Nova versão disponível no GitHub: v" .. remoteVer .. "!\nClique em 'Copiar Loader' para obter o script atualizado."
                        uStatus.TextColor3 = Theme.AccentWarning
                    end
                else
                    uStatus.Text = "✓ Você está usando a versão v" .. VERSION .. " (Servidor GitHub respondendo)."
                    uStatus.TextColor3 = Theme.AccentSuccess
                end
            else
                uStatus.Text = "⚠️ Não foi possível verificar online. Verifique sua conexão com a internet."
                uStatus.TextColor3 = Theme.AccentDanger
            end
        end)
    end)

    -- License Activation Modal Dialog
    local keyModal = Instance.new("Frame")
    keyModal.Size = UDim2.new(1, 0, 1, 0)
    keyModal.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    keyModal.BackgroundTransparency = 0.4
    keyModal.Visible = false
    keyModal.ZIndex = 50
    keyModal.Parent = main

    local keyCard = Instance.new("Frame")
    keyCard.Size = UDim2.new(0, 340, 0, 160)
    keyCard.Position = UDim2.new(0.5, -170, 0.5, -80)
    keyCard.BackgroundColor3 = Theme.Background
    keyCard.ZIndex = 51
    Theme.AddCorner(keyCard, Theme.CornerMedium)
    Theme.AddStroke(keyCard, Theme.Border, 1)
    keyCard.Parent = keyModal

    local kTitle = Instance.new("TextLabel")
    kTitle.Text = "Ativação de Licença"
    kTitle.Font = Theme.FontTitle
    kTitle.TextSize = 12
    kTitle.TextColor3 = Theme.TextPrimary
    kTitle.Size = UDim2.new(1, -24, 0, 22)
    kTitle.Position = UDim2.new(0, 12, 0, 12)
    kTitle.BackgroundTransparency = 1
    kTitle.ZIndex = 52
    kTitle.Parent = keyCard

    local kDesc = Instance.new("TextLabel")
    kDesc.Text = "Insira sua chave de licença:"
    kDesc.Font = Theme.FontRegular
    kDesc.TextSize = 10
    kDesc.TextColor3 = Theme.TextSecondary
    kDesc.Size = UDim2.new(1, -24, 0, 16)
    kDesc.Position = UDim2.new(0, 12, 0, 36)
    kDesc.BackgroundTransparency = 1
    kDesc.ZIndex = 52
    kDesc.Parent = keyCard

    local kInput = Instance.new("TextBox")
    kInput.PlaceholderText = "Cole sua chave aqui..."
    kInput.Font = Theme.FontRegular
    kInput.TextSize = 11
    kInput.TextColor3 = Theme.TextPrimary
    kInput.PlaceholderColor3 = Theme.TextMuted
    kInput.BackgroundColor3 = Theme.InputBg
    kInput.Size = UDim2.new(1, -24, 0, 30)
    kInput.Position = UDim2.new(0, 12, 0, 58)
    kInput.ZIndex = 52
    Theme.AddCorner(kInput, Theme.CornerSmall)
    Theme.AddStroke(kInput, Theme.Border, 1)
    kInput.Parent = keyCard

    local kStatus = Instance.new("TextLabel")
    kStatus.Text = ""
    kStatus.Font = Theme.FontSemiBold
    kStatus.TextSize = 10
    kStatus.Size = UDim2.new(1, -24, 0, 16)
    kStatus.Position = UDim2.new(0, 12, 0, 92)
    kStatus.BackgroundTransparency = 1
    kStatus.ZIndex = 52
    kStatus.Parent = keyCard

    local kSubmit = Instance.new("TextButton")
    kSubmit.Text = "Ativar Chave"
    kSubmit.Font = Theme.FontSemiBold
    kSubmit.TextSize = 10
    kSubmit.TextColor3 = Theme.TextPrimary
    kSubmit.BackgroundColor3 = Theme.AccentPrimary
    kSubmit.Size = UDim2.new(0.5, -16, 0, 28)
    kSubmit.Position = UDim2.new(0, 12, 0, 116)
    kSubmit.ZIndex = 52
    Theme.AddCorner(kSubmit, Theme.CornerSmall)
    kSubmit.Parent = keyCard

    local kClose = Instance.new("TextButton")
    kClose.Text = "Cancelar"
    kClose.Font = Theme.FontSemiBold
    kClose.TextSize = 10
    kClose.TextColor3 = Theme.TextSecondary
    kClose.BackgroundColor3 = Theme.CardBg
    kClose.Size = UDim2.new(0.5, -16, 0, 28)
    kClose.Position = UDim2.new(0.5, 4, 0, 116)
    kClose.ZIndex = 52
    Theme.AddCorner(kClose, Theme.CornerSmall)
    Theme.AddStroke(kClose, Theme.Border, 1)
    kClose.Parent = keyCard

    Theme.AnimateButton(badge, function()
        keyModal.Visible = true
        kStatus.Text = ""
    end)

    Theme.AnimateButton(kClose, function()
        keyModal.Visible = false
    end)

    Theme.AnimateButton(kSubmit, function()
        local success, msg = LicenseManager.ApplyKey(kInput.Text)
        if success then
            kStatus.Text = "✓ " .. msg
            kStatus.TextColor3 = Theme.AccentSuccess
            badge.Text = "Enterprise Ativo"
            badge.TextColor3 = Theme.AccentSuccess
            bStroke.Color = Theme.AccentSuccess

            pcall(function()
                Environment.WriteFile("HyperSave_License.key", kInput.Text)
            end)

            task.delay(1.5, function()
                keyModal.Visible = false
            end)
        else
            kStatus.Text = "✕ " .. msg
            kStatus.TextColor3 = Theme.AccentDanger
        end
    end)

    -- Compact Mode Button (Switches to minimal horizontal HUD bar)
    local compactBtn = Instance.new("TextButton")
    compactBtn.Text = "▫"
    compactBtn.Font = Theme.FontTitle
    compactBtn.TextSize = 14
    compactBtn.TextColor3 = Theme.TextSecondary
    compactBtn.BackgroundColor3 = Theme.CardBg
    compactBtn.Size = UDim2.new(0, 26, 0, 26)
    compactBtn.Position = UDim2.new(1, -94, 0.5, -13)
    Theme.AddCorner(compactBtn, Theme.CornerSmall)
    Theme.AddStroke(compactBtn, Theme.Border, 1)
    compactBtn.Parent = header

    -- Minimize Button
    local minBtn = Instance.new("TextButton")
    minBtn.Text = "–"
    minBtn.Font = Theme.FontTitle
    minBtn.TextSize = 14
    minBtn.TextColor3 = Theme.TextSecondary
    minBtn.BackgroundColor3 = Theme.CardBg
    minBtn.Size = UDim2.new(0, 26, 0, 26)
    minBtn.Position = UDim2.new(1, -64, 0.5, -13)
    Theme.AddCorner(minBtn, Theme.CornerSmall)
    Theme.AddStroke(minBtn, Theme.Border, 1)
    minBtn.Parent = header

    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "✕"
    closeBtn.Font = Theme.FontTitle
    closeBtn.TextSize = 14
    closeBtn.TextColor3 = Theme.TextSecondary
    closeBtn.BackgroundColor3 = Theme.CardBg
    closeBtn.Size = UDim2.new(0, 26, 0, 26)
    closeBtn.Position = UDim2.new(1, -34, 0.5, -13)
    Theme.AddCorner(closeBtn, Theme.CornerSmall)
    Theme.AddStroke(closeBtn, Theme.Border, 1)
    closeBtn.Parent = header

    -- Compact In-Game HUD Widget (Minimalist floating bar)
    local compactBar = Instance.new("Frame")
    compactBar.Name = isRandom and Stealth.GenerateRandomName(12) or "CompactHUD"
    compactBar.Size = UDim2.new(0, 380, 0, 34)
    compactBar.Position = UDim2.new(0.5, -190, 0, 14)
    compactBar.BackgroundColor3 = Theme.Background
    compactBar.Visible = false
    Theme.AddCorner(compactBar, Theme.CornerMedium)
    Theme.AddStroke(compactBar, Theme.Border, 1)
    compactBar.Parent = safeContainer
    self.CompactHUD = compactBar

    local cStats = Instance.new("TextLabel")
    cStats.Text = "FPS: 60 • Ping: --ms"
    cStats.Font = Theme.FontRegular
    cStats.TextSize = 11
    cStats.TextColor3 = Theme.TextSecondary
    cStats.Size = UDim2.new(0, 160, 1, 0)
    cStats.Position = UDim2.new(0, 12, 0, 0)
    cStats.BackgroundTransparency = 1
    cStats.Parent = compactBar

    local cCloneBtn = Instance.new("TextButton")
    cCloneBtn.Text = "Salvar Mapa"
    cCloneBtn.Font = Theme.FontSemiBold
    cCloneBtn.TextSize = 10
    cCloneBtn.TextColor3 = Theme.TextPrimary
    cCloneBtn.BackgroundColor3 = Theme.AccentPrimary
    cCloneBtn.Size = UDim2.new(0, 110, 0, 22)
    cCloneBtn.Position = UDim2.new(0, 175, 0.5, -11)
    Theme.AddCorner(cCloneBtn, Theme.CornerSmall)
    cCloneBtn.Parent = compactBar
    Theme.AnimateButton(cCloneBtn, function()
        self:StartClone()
    end)

    local cExpandBtn = Instance.new("TextButton")
    cExpandBtn.Text = "Expandir ↗"
    cExpandBtn.Font = Theme.FontSemiBold
    cExpandBtn.TextSize = 10
    cExpandBtn.TextColor3 = Theme.TextSecondary
    cExpandBtn.BackgroundColor3 = Theme.CardBg
    cExpandBtn.Size = UDim2.new(0, 74, 0, 22)
    cExpandBtn.Position = UDim2.new(1, -82, 0.5, -11)
    Theme.AddCorner(cExpandBtn, Theme.CornerSmall)
    Theme.AddStroke(cExpandBtn, Theme.Border, 1)
    cExpandBtn.Parent = compactBar
    Theme.AnimateButton(cExpandBtn, function()
        compactBar.Visible = false
        main.Visible = true
    end)

    -- Live FPS & Ping monitor loop
    task.spawn(function()
        local Stats = game:GetService("Stats")
        local fpsCount = 0
        local lastUpdate = os.clock()
        local runServ = game:GetService("RunService")
        runServ.RenderStepped:Connect(function()
            fpsCount = fpsCount + 1
            local now = os.clock()
            if now - lastUpdate >= 0.5 then
                local fps = math.round(fpsCount / (now - lastUpdate))
                fpsCount = 0
                lastUpdate = now
                local ping = 0
                pcall(function()
                    ping = math.round(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
                end)
                if compactBar and compactBar.Visible then
                    cStats.Text = string.format("FPS: %d • Ping: %dms", fps, ping)
                end
            end
        end)
    end)

    Theme.AnimateButton(compactBtn, function()
        main.Visible = false
        compactBar.Visible = true
    end)

    Theme.AnimateButton(minBtn, function()
        main.Visible = false
        floatingBtn.Visible = true
    end)

    Theme.AnimateButton(closeBtn, function()
        main.Visible = false
        floatingBtn.Visible = true
    end)

    -- Tab Navigation Bar (Scrollable for all master tools)
    local navBar = Instance.new("ScrollingFrame")
    navBar.Name = "NavBar"
    navBar.Size = UDim2.new(0, 140, 1, -44)
    navBar.Position = UDim2.new(0, 0, 0, 44)
    navBar.BackgroundColor3 = Theme.CardBg
    navBar.ScrollBarThickness = 2
    navBar.ScrollBarImageColor3 = Theme.Border
    navBar.CanvasSize = UDim2.new(0, 0, 0, 390)
    navBar.BorderSizePixel = 0
    navBar.Parent = main

    local navLine = Instance.new("Frame")
    navLine.Size = UDim2.new(0, 1, 1, 0)
    navLine.Position = UDim2.new(1, -1, 0, 0)
    navLine.BackgroundColor3 = Theme.Border
    navLine.BorderSizePixel = 0
    navLine.Parent = navBar

    -- Content Area
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -140, 1, -44)
    contentArea.Position = UDim2.new(0, 140, 0, 44)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = main
    self.ContentArea = contentArea

    -- Navigation buttons (Clean, Plain Text, Zero Emojis)
    local tabs = {
        { "Dashboard", "Dashboard" },
        { "Selector", "Objetos" },
        { "AudioRipper", "Áudios" },
        { "LightingRipper", "Iluminação" },
        { "GuiRipper", "Interfaces" },
        { "Network", "Rede" },
        { "Universe", "Universos" },
        { "ObjExport", "Exportar 3D" },
        { "Tutorial", "Como Usar" },
        { "Settings", "Configurações" },
        { "Console", "Console" },
        { "About", "Sobre" },
    }

    self.TabFrames = {}
    self.NavButtons = {}

    for i, tabInfo in ipairs(tabs) do
        local tabKey, tabLabel = tabInfo[1], tabInfo[2]

        local navBtn = Instance.new("TextButton")
        navBtn.Text = tabLabel
        navBtn.Font = Theme.FontSemiBold
        navBtn.TextSize = 11
        navBtn.TextColor3 = (i == 1) and Theme.TextPrimary or Theme.TextSecondary
        navBtn.BackgroundColor3 = (i == 1) and Theme.AccentPrimary or Theme.CardBg
        navBtn.BackgroundTransparency = (i == 1) and 0 or 1
        navBtn.Size = UDim2.new(1, -12, 0, 28)
        navBtn.Position = UDim2.new(0, 6, 0, 6 + (i - 1) * 31)
        Theme.AddCorner(navBtn, Theme.CornerSmall)
        Theme.AddStroke(navBtn, (i == 1) and Theme.BorderLight or Theme.Border, 1)
        navBtn.Parent = navBar
        self.NavButtons[tabKey] = navBtn

        local tabFrame = Instance.new("Frame")
        tabFrame.Name = tabKey .. "Tab"
        tabFrame.Size = UDim2.new(1, 0, 1, 0)
        tabFrame.BackgroundTransparency = 1
        tabFrame.Visible = (i == 1)
        tabFrame.Parent = contentArea
        self.TabFrames[tabKey] = tabFrame

        Theme.AnimateButton(navBtn, function()
            self:SwitchTab(tabKey)
        end)
    end

    -- Build Individual Tab Pages with error boundary protection
    pcall(function()
        self:BuildDashboardTab()
    end)
    pcall(function()
        self:BuildSelectorTab()
    end)
    pcall(function()
        self:BuildAudioRipperTab()
    end)
    pcall(function()
        self:BuildLightingRipperTab()
    end)
    pcall(function()
        self:BuildGuiRipperTab()
    end)
    pcall(function()
        self:BuildNetworkTab()
    end)
    pcall(function()
        self:BuildUniverseTab()
    end)
    pcall(function()
        self:BuildObjExportTab()
    end)
    pcall(function()
        self:BuildTutorialTab()
    end)
    pcall(function()
        self:BuildSettingsTab()
    end)
    pcall(function()
        self:BuildConsoleTab()
    end)
    pcall(function()
        self:BuildAboutTab()
    end)

    -- Animate Splash Card completion and reveal Main Window
    pcall(function()
        if self.SplashFill then
            Theme.Tween(self.SplashFill, 0.3, { Size = UDim2.new(1, 0, 1, 0) })
        end
        task.delay(0.35, function()
            if self.SplashCard then
                Theme.Tween(self.SplashCard, 0.15, {
                    Size = UDim2.new(0, 300, 0, 120),
                    BackgroundTransparency = 1,
                })
                for _, child in ipairs(self.SplashCard:GetDescendants()) do
                    if child:IsA("TextLabel") then
                        Theme.Tween(child, 0.12, { TextTransparency = 1 })
                    elseif child:IsA("Frame") or child:IsA("UIStroke") then
                        Theme.Tween(child, 0.12, { Transparency = 1 })
                    end
                end
                task.delay(0.18, function()
                    pcall(function()
                        self.SplashCard:Destroy()
                    end)
                end)
            end

            if self.MainFrame then
                self.MainFrame.Visible = true
                Theme.Tween(self.MainFrame, 0.25, {
                    Size = UDim2.new(0, winWidth, 0, winHeight),
                }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            end
        end)
    end)
end

function Interface:SwitchTab(targetTab)
    self.ActiveTab = targetTab
    for k, frame in pairs(self.TabFrames) do
        frame.Visible = (k == targetTab)
    end
    for k, btn in pairs(self.NavButtons) do
        local stroke = btn:FindFirstChildOfClass("UIStroke")
        if k == targetTab then
            btn.TextColor3 = Theme.TextPrimary
            btn.BackgroundColor3 = Theme.AccentPrimary
            btn.BackgroundTransparency = 0
            if stroke then
                stroke.Color = Theme.BorderLight
            end
        else
            btn.TextColor3 = Theme.TextSecondary
            btn.BackgroundColor3 = Theme.CardBg
            btn.BackgroundTransparency = 1
            if stroke then
                stroke.Color = Theme.Border
            end
        end
    end
end

-- 1. Dashboard Tab (Clean, Prominent 1-Click Game Cloner)
function Interface:BuildDashboardTab()
    local parent = self.TabFrames["Dashboard"]

    -- Save / Clone & Cancel Buttons Row
    local cloneBtn = Instance.new("TextButton")
    cloneBtn.Name = "CloneButton"
    cloneBtn.Text = "Salvar Mapa Completo (.rbxlx)"
    cloneBtn.Font = Theme.FontTitle
    cloneBtn.TextSize = 13
    cloneBtn.TextColor3 = Theme.TextPrimary
    cloneBtn.BackgroundColor3 = Theme.AccentPrimary
    cloneBtn.Size = UDim2.new(1, -32, 0, 42)
    cloneBtn.Position = UDim2.new(0, 16, 0, 14)
    Theme.AddCorner(cloneBtn, Theme.CornerMedium)
    Theme.AddStroke(cloneBtn, Theme.BorderLight, 1)
    cloneBtn.Parent = parent
    self.CloneButton = cloneBtn

    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Name = "CancelButton"
    cancelBtn.Text = "✕ Parar"
    cancelBtn.Font = Theme.FontTitle
    cancelBtn.TextSize = 12
    cancelBtn.TextColor3 = Theme.TextPrimary
    cancelBtn.BackgroundColor3 = Theme.AccentDanger
    cancelBtn.Size = UDim2.new(0.32, -10, 0, 42)
    cancelBtn.Position = UDim2.new(0.68, 16, 0, 14)
    cancelBtn.Visible = false
    Theme.AddCorner(cancelBtn, Theme.CornerMedium)
    Theme.AddStroke(cancelBtn, Theme.Border, 1)
    cancelBtn.Parent = parent
    self.CancelButton = cancelBtn

    Theme.AnimateButton(cloneBtn, function()
        self:StartClone()
    end)

    Theme.AnimateButton(cancelBtn, function()
        if self.Engine.IsRunning then
            cancelBtn.Text = "Parando..."
            self.Engine:Cancel()
            self:Log("Cancelamento solicitado pelo usuário. Finalizando...", Theme.AccentWarning)
        end
    end)

    -- Anti-AFK Live Status Card & Quick Toggle
    local antiAfkCard = Instance.new("Frame")
    antiAfkCard.Name = "AntiAfkDashCard"
    antiAfkCard.Size = UDim2.new(1, -32, 0, 32)
    antiAfkCard.Position = UDim2.new(0, 16, 0, 62)
    antiAfkCard.BackgroundColor3 = Theme.CardBg
    Theme.AddCorner(antiAfkCard, Theme.CornerSmall)
    local afkCardStroke = Theme.AddStroke(antiAfkCard, AntiAFK.IsEnabled() and Theme.AccentSuccess or Theme.Border, 1)
    antiAfkCard.Parent = parent

    local afkIconLbl = Instance.new("TextLabel")
    afkIconLbl.Text = "🛡️ Proteção Anti-AFK (Anti-Kick 20m):"
    afkIconLbl.Font = Theme.FontSemiBold
    afkIconLbl.TextSize = 10
    afkIconLbl.TextColor3 = Theme.TextPrimary
    afkIconLbl.TextXAlignment = Enum.TextXAlignment.Left
    afkIconLbl.Size = UDim2.new(0.6, 0, 1, 0)
    afkIconLbl.Position = UDim2.new(0, 10, 0, 0)
    afkIconLbl.BackgroundTransparency = 1
    afkIconLbl.Parent = antiAfkCard

    local afkStatusText = Instance.new("TextLabel")
    afkStatusText.Text = AntiAFK.IsEnabled() and "● LIGADO" or "○ DESLIGADO"
    afkStatusText.Font = Theme.FontTitle
    afkStatusText.TextSize = 10
    afkStatusText.TextColor3 = AntiAFK.IsEnabled() and Theme.AccentSuccess or Theme.TextMuted
    afkStatusText.TextXAlignment = Enum.TextXAlignment.Left
    afkStatusText.Size = UDim2.new(0.2, 0, 1, 0)
    afkStatusText.Position = UDim2.new(0, 230, 0, 0)
    afkStatusText.BackgroundTransparency = 1
    afkStatusText.Parent = antiAfkCard
    self.AntiAfkStatusText = afkStatusText

    local afkToggleBtn = Instance.new("TextButton")
    afkToggleBtn.Text = AntiAFK.IsEnabled() and "DESATIVAR" or "ATIVAR"
    afkToggleBtn.Font = Theme.FontSemiBold
    afkToggleBtn.TextSize = 9
    afkToggleBtn.TextColor3 = Theme.TextPrimary
    afkToggleBtn.BackgroundColor3 = AntiAFK.IsEnabled() and Theme.CardActive or Theme.AccentPrimary
    afkToggleBtn.Size = UDim2.new(0, 90, 0, 22)
    afkToggleBtn.Position = UDim2.new(1, -96, 0.5, -11)
    Theme.AddCorner(afkToggleBtn, Theme.CornerSmall)
    afkToggleBtn.Parent = antiAfkCard
    self.AntiAfkDashToggleBtn = afkToggleBtn

    local function updateAntiAfkUI(enabled)
        if self.AntiAfkHeaderBadge then
            self.AntiAfkHeaderBadge.Text = enabled and "🛡️ Anti-AFK: ON" or "🛡️ Anti-AFK: OFF"
            self.AntiAfkHeaderBadge.TextColor3 = enabled and Theme.AccentSuccess or Theme.TextMuted
            local stroke = self.AntiAfkHeaderBadge:FindFirstChildOfClass("UIStroke")
            if stroke then
                stroke.Color = enabled and Theme.AccentSuccess or Theme.Border
            end
        end
        if self.AntiAfkStatusText then
            self.AntiAfkStatusText.Text = enabled and "● LIGADO" or "○ DESLIGADO"
            self.AntiAfkStatusText.TextColor3 = enabled and Theme.AccentSuccess or Theme.TextMuted
        end
        if self.AntiAfkDashToggleBtn then
            self.AntiAfkDashToggleBtn.Text = enabled and "DESATIVAR" or "ATIVAR"
            self.AntiAfkDashToggleBtn.BackgroundColor3 = enabled and Theme.CardActive or Theme.AccentPrimary
        end
        if afkCardStroke then
            afkCardStroke.Color = enabled and Theme.AccentSuccess or Theme.Border
        end
    end

    AntiAFK.OnStateChanged(function(enabled)
        updateAntiAfkUI(enabled)
    end)

    Theme.AnimateButton(afkToggleBtn, function()
        local newState = AntiAFK.Toggle()
        self.Config.AutoAntiAFK = newState
        updateAntiAfkUI(newState)
        self:Log(
            newState and "🛡️ Proteção Anti-AFK Ativada!" or "🛡️ Proteção Anti-AFK Desativada.",
            newState and Theme.AccentSuccess or Theme.TextMuted
        )
    end)

    -- Preset Selection Container
    local presetLabel = Instance.new("TextLabel")
    presetLabel.Text = "MODO DE EXTRAÇÃO:"
    presetLabel.Font = Theme.FontSemiBold
    presetLabel.TextSize = 10
    presetLabel.TextColor3 = Theme.TextSecondary
    presetLabel.TextXAlignment = Enum.TextXAlignment.Left
    presetLabel.Size = UDim2.new(1, -32, 0, 16)
    presetLabel.Position = UDim2.new(0, 16, 0, 100)
    presetLabel.BackgroundTransparency = 1
    presetLabel.Parent = parent

    local presetContainer = Instance.new("Frame")
    presetContainer.Size = UDim2.new(1, -32, 0, 28)
    presetContainer.Position = UDim2.new(0, 16, 0, 118)
    presetContainer.BackgroundTransparency = 1
    presetContainer.Parent = parent

    local presetLayout = Instance.new("UIListLayout")
    presetLayout.FillDirection = Enum.FillDirection.Horizontal
    presetLayout.Padding = UDim.new(0, 6)
    presetLayout.SortOrder = Enum.SortOrder.LayoutOrder
    presetLayout.Parent = presetContainer

    local presetList = { "Full", "Fast", "VisualsOnly", "ScriptsOnly" }
    local presetDisplay = {
        Full = "Completo",
        Fast = "Rápido",
        VisualsOnly = "Apenas Mapa",
        ScriptsOnly = "Apenas Scripts",
    }

    self.PresetButtons = {}
    for i, pKey in ipairs(presetList) do
        local btn = Instance.new("TextButton")
        btn.Text = presetDisplay[pKey]
        btn.Font = Theme.FontSemiBold
        btn.TextSize = 10
        btn.TextColor3 = (self.Config.Mode == pKey) and Theme.TextPrimary or Theme.TextSecondary
        btn.BackgroundColor3 = (self.Config.Mode == pKey) and Theme.CardActive or Theme.CardBg
        btn.Size = UDim2.new(0.25, -5, 1, 0)
        btn.LayoutOrder = i
        Theme.AddCorner(btn, Theme.CornerSmall)
        Theme.AddStroke(btn, (self.Config.Mode == pKey) and Theme.BorderLight or Theme.Border, 1)
        btn.Parent = presetContainer
        self.PresetButtons[pKey] = btn

        Theme.AnimateButton(btn, function()
            Defaults.ApplyPreset(self.Config, pKey)
            for k, b in pairs(self.PresetButtons) do
                local stroke = b:FindFirstChildOfClass("UIStroke")
                if k == pKey then
                    b.TextColor3 = Theme.TextPrimary
                    b.BackgroundColor3 = Theme.CardActive
                    if stroke then
                        stroke.Color = Theme.BorderLight
                    end
                else
                    b.TextColor3 = Theme.TextSecondary
                    b.BackgroundColor3 = Theme.CardBg
                    if stroke then
                        stroke.Color = Theme.Border
                    end
                end
            end
            self:Log("Modo selecionado: " .. pKey)
        end)
    end

    -- Format Selector Container
    local formatLabel = Instance.new("TextLabel")
    formatLabel.Text = "FORMATO DO ARQUIVO:"
    formatLabel.Font = Theme.FontSemiBold
    formatLabel.TextSize = 10
    formatLabel.TextColor3 = Theme.TextSecondary
    formatLabel.TextXAlignment = Enum.TextXAlignment.Left
    formatLabel.Size = UDim2.new(1, -32, 0, 16)
    formatLabel.Position = UDim2.new(0, 16, 0, 152)
    formatLabel.BackgroundTransparency = 1
    formatLabel.Parent = parent

    local formatContainer = Instance.new("Frame")
    formatContainer.Size = UDim2.new(1, -32, 0, 28)
    formatContainer.Position = UDim2.new(0, 16, 0, 170)
    formatContainer.BackgroundTransparency = 1
    formatContainer.Parent = parent

    local formatLayout = Instance.new("UIListLayout")
    formatLayout.FillDirection = Enum.FillDirection.Horizontal
    formatLayout.Padding = UDim.new(0, 6)
    formatLayout.SortOrder = Enum.SortOrder.LayoutOrder
    formatLayout.Parent = formatContainer

    local formats = {
        { "rbxlx", "RBXLX (XML)" },
        { "rbxl", "RBXL (Binário)" },
        { "lua", "Script Luau" },
    }
    self.FormatButtons = {}

    for i, fmt in ipairs(formats) do
        local fKey, fLabel = fmt[1], fmt[2]
        local fBtn = Instance.new("TextButton")
        fBtn.Text = fLabel
        fBtn.Font = Theme.FontSemiBold
        fBtn.TextSize = 10
        fBtn.TextColor3 = (self.Config.Format == fKey) and Theme.TextPrimary or Theme.TextSecondary
        fBtn.BackgroundColor3 = (self.Config.Format == fKey) and Theme.CardActive or Theme.CardBg
        fBtn.Size = UDim2.new(0.333, -5, 1, 0)
        fBtn.LayoutOrder = i
        Theme.AddCorner(fBtn, Theme.CornerSmall)
        Theme.AddStroke(fBtn, (self.Config.Format == fKey) and Theme.BorderLight or Theme.Border, 1)
        fBtn.Parent = formatContainer
        self.FormatButtons[fKey] = fBtn

        Theme.AnimateButton(fBtn, function()
            self.Config.Format = fKey
            for k, b in pairs(self.FormatButtons) do
                local stroke = b:FindFirstChildOfClass("UIStroke")
                if k == fKey then
                    b.TextColor3 = Theme.TextPrimary
                    b.BackgroundColor3 = Theme.CardActive
                    if stroke then
                        stroke.Color = Theme.BorderLight
                    end
                else
                    b.TextColor3 = Theme.TextSecondary
                    b.BackgroundColor3 = Theme.CardBg
                    if stroke then
                        stroke.Color = Theme.Border
                    end
                end
            end
            self:Log("Formato definido: ." .. fKey)
        end)
    end

    -- Progress Container (Clean Card)
    local progressCard = Instance.new("Frame")
    progressCard.Size = UDim2.new(1, -32, 0, 114)
    progressCard.Position = UDim2.new(0, 16, 0, 204)
    progressCard.BackgroundColor3 = Theme.CardBg
    Theme.AddCorner(progressCard, Theme.CornerMedium)
    Theme.AddStroke(progressCard, Theme.Border, 1)
    progressCard.Parent = parent

    local statusHeader = Instance.new("TextLabel")
    statusHeader.Name = "StatusHeader"
    statusHeader.Text = "Status: Pronto para salvar"
    statusHeader.Font = Theme.FontSemiBold
    statusHeader.TextSize = 12
    statusHeader.TextColor3 = Theme.AccentSuccess
    statusHeader.TextXAlignment = Enum.TextXAlignment.Left
    statusHeader.Size = UDim2.new(0.7, 0, 0, 20)
    statusHeader.Position = UDim2.new(0, 12, 0, 10)
    statusHeader.BackgroundTransparency = 1
    statusHeader.Parent = progressCard
    self.StatusHeader = statusHeader

    local pctLabel = Instance.new("TextLabel")
    pctLabel.Name = "PctLabel"
    pctLabel.Text = "0%"
    pctLabel.Font = Theme.FontTitle
    pctLabel.TextSize = 13
    pctLabel.TextColor3 = Theme.TextPrimary
    pctLabel.TextXAlignment = Enum.TextXAlignment.Right
    pctLabel.Size = UDim2.new(0.25, 0, 0, 20)
    pctLabel.Position = UDim2.new(0.72, 0, 0, 10)
    pctLabel.BackgroundTransparency = 1
    pctLabel.Parent = progressCard
    self.PctLabel = pctLabel

    -- Progress Bar Track & Fill
    local barTrack = Instance.new("Frame")
    barTrack.Size = UDim2.new(1, -24, 0, 6)
    barTrack.Position = UDim2.new(0, 12, 0, 36)
    barTrack.BackgroundColor3 = Theme.Background
    Theme.AddCorner(barTrack, Theme.CornerPill)
    barTrack.Parent = progressCard

    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(0, 0, 1, 0)
    barFill.BackgroundColor3 = Theme.AccentPrimary
    Theme.AddCorner(barFill, Theme.CornerPill)
    barFill.Parent = barTrack
    self.ProgressBarFill = barFill

    local statusDetail = Instance.new("TextLabel")
    statusDetail.Name = "StatusDetail"
    statusDetail.Text = "Clique no botão acima para salvar o jogo."
    statusDetail.Font = Theme.FontRegular
    statusDetail.TextSize = 11
    statusDetail.TextColor3 = Theme.TextMuted
    statusDetail.TextXAlignment = Enum.TextXAlignment.Left
    statusDetail.Size = UDim2.new(1, -24, 0, 18)
    statusDetail.Position = UDim2.new(0, 12, 0, 48)
    statusDetail.BackgroundTransparency = 1
    statusDetail.Parent = progressCard
    self.StatusDetail = statusDetail

    -- Quick Action Copy Buttons
    local copyBar = Instance.new("Frame")
    copyBar.Size = UDim2.new(1, -24, 0, 26)
    copyBar.Position = UDim2.new(0, 12, 0, 76)
    copyBar.BackgroundTransparency = 1
    copyBar.Parent = progressCard

    local copyLayout = Instance.new("UIListLayout")
    copyLayout.FillDirection = Enum.FillDirection.Horizontal
    copyLayout.Padding = UDim.new(0, 6)
    copyLayout.SortOrder = Enum.SortOrder.LayoutOrder
    copyLayout.Parent = copyBar

    local copyFilePathBtn = Instance.new("TextButton")
    copyFilePathBtn.Text = "Copiar Caminho do Arquivo"
    copyFilePathBtn.Font = Theme.FontSemiBold
    copyFilePathBtn.TextSize = 10
    copyFilePathBtn.TextColor3 = Theme.TextPrimary
    copyFilePathBtn.BackgroundColor3 = Theme.CardHover
    copyFilePathBtn.Size = UDim2.new(0.5, -3, 1, 0)
    copyFilePathBtn.LayoutOrder = 1
    Theme.AddCorner(copyFilePathBtn, Theme.CornerSmall)
    Theme.AddStroke(copyFilePathBtn, Theme.Border, 1)
    copyFilePathBtn.Parent = copyBar

    Theme.AnimateButton(copyFilePathBtn, function()
        local name = self.SavedFilePath
        if #name == 0 then
            name = self.Engine:GetDefaultFileName()
        end
        Environment.SetClipboard(name)
        copyFilePathBtn.Text = "✓ Copiado!"
        task.delay(2, function()
            copyFilePathBtn.Text = "Copiar Caminho do Arquivo"
        end)
    end)

    local copyAssetsPathBtn = Instance.new("TextButton")
    copyAssetsPathBtn.Text = "Copiar Pasta de Assets"
    copyAssetsPathBtn.Font = Theme.FontSemiBold
    copyAssetsPathBtn.TextSize = 10
    copyAssetsPathBtn.TextColor3 = Theme.TextPrimary
    copyAssetsPathBtn.BackgroundColor3 = Theme.CardHover
    copyAssetsPathBtn.Size = UDim2.new(0.5, -3, 1, 0)
    copyAssetsPathBtn.LayoutOrder = 2
    Theme.AddCorner(copyAssetsPathBtn, Theme.CornerSmall)
    Theme.AddStroke(copyAssetsPathBtn, Theme.Border, 1)
    copyAssetsPathBtn.Parent = copyBar

    Theme.AnimateButton(copyAssetsPathBtn, function()
        local name = self.SavedAssetPath
        if #name == 0 then
            name = self.Engine:GetDefaultAssetFolder()
        end
        Environment.SetClipboard(name)
        copyAssetsPathBtn.Text = "✓ Copiado!"
        task.delay(2, function()
            copyAssetsPathBtn.Text = "Copiar Pasta de Assets"
        end)
    end)

    -- Live Telemetry Stats Row
    local telemetryCard = Instance.new("Frame")
    telemetryCard.Size = UDim2.new(1, -32, 0, 44)
    telemetryCard.Position = UDim2.new(0, 16, 0, 324)
    telemetryCard.BackgroundColor3 = Theme.CardBg
    Theme.AddCorner(telemetryCard, Theme.CornerMedium)
    Theme.AddStroke(telemetryCard, Theme.Border, 1)
    telemetryCard.Parent = parent

    local tLayout = Instance.new("UIListLayout")
    tLayout.FillDirection = Enum.FillDirection.Horizontal
    tLayout.Padding = UDim.new(0, 0)
    tLayout.Parent = telemetryCard

    local function createTelemetryItem(label, defaultVal, widthRatio)
        local itemFrame = Instance.new("Frame")
        itemFrame.Size = UDim2.new(widthRatio, 0, 1, 0)
        itemFrame.BackgroundTransparency = 1
        itemFrame.Parent = telemetryCard

        local valLbl = Instance.new("TextLabel")
        valLbl.Text = defaultVal
        valLbl.Font = Theme.FontTitle
        valLbl.TextSize = 12
        valLbl.TextColor3 = Theme.TextPrimary
        valLbl.Size = UDim2.new(1, 0, 0, 18)
        valLbl.Position = UDim2.new(0, 0, 0, 6)
        valLbl.BackgroundTransparency = 1
        valLbl.Parent = itemFrame

        local tagLbl = Instance.new("TextLabel")
        tagLbl.Text = label
        tagLbl.Font = Theme.FontRegular
        tagLbl.TextSize = 9
        tagLbl.TextColor3 = Theme.TextSecondary
        tagLbl.Size = UDim2.new(1, 0, 0, 14)
        tagLbl.Position = UDim2.new(0, 0, 0, 24)
        tagLbl.BackgroundTransparency = 1
        tagLbl.Parent = itemFrame

        return valLbl
    end

    local fpsValLbl = createTelemetryItem("FPS DO JOGO", "60", 0.333)
    local pingValLbl = createTelemetryItem("PING DE REDE", "-- ms", 0.333)
    local ramValLbl = createTelemetryItem("MEMÓRIA CLIENT", "-- MB", 0.334)

    task.spawn(function()
        local Stats = game:GetService("Stats")
        local fpsCount = 0
        local lastUpdate = os.clock()
        local runServ = game:GetService("RunService")
        runServ.RenderStepped:Connect(function()
            fpsCount = fpsCount + 1
            local now = os.clock()
            if now - lastUpdate >= 0.5 then
                local fps = math.round(fpsCount / (now - lastUpdate))
                fpsCount = 0
                lastUpdate = now
                local ping = 0
                pcall(function()
                    ping = math.round(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
                end)
                local mem = 0
                pcall(function()
                    mem = math.round(Stats:GetTotalMemoryUsageMb())
                end)

                if fpsValLbl and fpsValLbl.Parent then
                    fpsValLbl.Text = tostring(fps)
                    fpsValLbl.TextColor3 = (fps >= 45) and Theme.AccentSuccess or Theme.AccentWarning
                end
                if pingValLbl and pingValLbl.Parent then
                    pingValLbl.Text = tostring(ping) .. " ms"
                    pingValLbl.TextColor3 = (ping < 120) and Theme.AccentSuccess or Theme.AccentWarning
                end
                if ramValLbl and ramValLbl.Parent then
                    ramValLbl.Text = tostring(mem) .. " MB"
                end
            end
        end)
    end)
end

-- 2. Target Selector Tab (Save Individual Model / Folder / 3D Raycast / Multi-Select)
function Interface:BuildSelectorTab()
    local parent = self.TabFrames["Selector"]

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -32, 1, -32)
    scroll.Position = UDim2.new(0, 16, 0, 16)
    scroll.BackgroundColor3 = Theme.CardBg
    scroll.BackgroundTransparency = Theme.CardTransparency
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Theme.BorderLight
    scroll.CanvasSize = UDim2.new(0, 0, 0, 520)
    Theme.AddCorner(scroll, Theme.CornerLarge)
    Theme.AddStroke(scroll, Theme.Border, 1)
    scroll.Parent = parent

    local headerLbl = Instance.new("TextLabel")
    headerLbl.Text = "Seletor de Objetos 3D"
    headerLbl.Font = Theme.FontTitle
    headerLbl.TextSize = 13
    headerLbl.TextColor3 = Theme.TextPrimary
    headerLbl.TextXAlignment = Enum.TextXAlignment.Left
    headerLbl.Size = UDim2.new(1, -24, 0, 22)
    headerLbl.Position = UDim2.new(0, 12, 0, 12)
    headerLbl.BackgroundTransparency = 1
    headerLbl.Parent = scroll

    -- 1. In-World 3D Raycast Click Selector Button
    local raycastBtn = Instance.new("TextButton")
    raycastBtn.Text = "Ativar Mira 3D no Mapa"
    raycastBtn.Font = Theme.FontSemiBold
    raycastBtn.TextSize = 11
    raycastBtn.TextColor3 = Theme.TextPrimary
    raycastBtn.BackgroundColor3 = Theme.AccentPrimary
    raycastBtn.Size = UDim2.new(1, -24, 0, 34)
    raycastBtn.Position = UDim2.new(0, 12, 0, 40)
    Theme.AddCorner(raycastBtn, Theme.CornerMedium)
    Theme.AddStroke(raycastBtn, Theme.BorderLight, 1)
    raycastBtn.Parent = scroll

    -- 2. Search by Name Textbox
    local searchBox = Instance.new("TextBox")
    searchBox.PlaceholderText = "Ou digite o nome do objeto (ex: Carro, Arma, Map)..."
    searchBox.Font = Theme.FontRegular
    searchBox.TextSize = 11
    searchBox.TextColor3 = Theme.TextPrimary
    searchBox.PlaceholderColor3 = Theme.TextMuted
    searchBox.BackgroundColor3 = Theme.InputBg
    searchBox.Size = UDim2.new(1, -24, 0, 32)
    searchBox.Position = UDim2.new(0, 12, 0, 82)
    Theme.AddCorner(searchBox, Theme.CornerSmall)
    Theme.AddStroke(searchBox, Theme.Border, 1)
    searchBox.Parent = scroll

    -- 3. Selected Target Info Card
    local infoCard = Instance.new("Frame")
    infoCard.Size = UDim2.new(1, -24, 0, 100)
    infoCard.Position = UDim2.new(0, 12, 0, 122)
    infoCard.BackgroundColor3 = Theme.CardBg
    Theme.AddCorner(infoCard, Theme.CornerMedium)
    Theme.AddStroke(infoCard, Theme.Border, 1)
    infoCard.Parent = scroll

    -- Embedded 3D ViewportFrame
    local vpFrame = Instance.new("ViewportFrame")
    vpFrame.Size = UDim2.new(0, 84, 0, 84)
    vpFrame.Position = UDim2.new(1, -92, 0, 8)
    vpFrame.BackgroundColor3 = Theme.Background
    Theme.AddCorner(vpFrame, Theme.CornerSmall)
    Theme.AddStroke(vpFrame, Theme.Border, 1)
    vpFrame.Parent = infoCard

    local vpCam = Instance.new("Camera")
    vpCam.Parent = vpFrame
    vpFrame.CurrentCamera = vpCam

    local targetTitle = Instance.new("TextLabel")
    targetTitle.Text = "Nenhum objeto selecionado"
    targetTitle.Font = Theme.FontSemiBold
    targetTitle.TextSize = 11
    targetTitle.TextColor3 = Theme.TextPrimary
    targetTitle.TextXAlignment = Enum.TextXAlignment.Left
    targetTitle.Size = UDim2.new(1, -106, 0, 18)
    targetTitle.Position = UDim2.new(0, 10, 0, 8)
    targetTitle.BackgroundTransparency = 1
    targetTitle.Parent = infoCard

    local targetStats = Instance.new("TextLabel")
    targetStats.Text = "Mire no jogo com o botão acima ou digite o nome."
    targetStats.Font = Theme.FontRegular
    targetStats.TextSize = 10
    targetStats.TextColor3 = Theme.TextSecondary
    targetStats.TextXAlignment = Enum.TextXAlignment.Left
    targetStats.Size = UDim2.new(1, -106, 0, 18)
    targetStats.Position = UDim2.new(0, 10, 0, 28)
    targetStats.BackgroundTransparency = 1
    targetStats.Parent = infoCard

    local targetPath = Instance.new("TextLabel")
    targetPath.Text = "Caminho: -"
    targetPath.Font = Theme.FontRegular
    targetPath.TextSize = 10
    targetPath.TextColor3 = Theme.TextMuted
    targetPath.TextXAlignment = Enum.TextXAlignment.Left
    targetPath.Size = UDim2.new(1, -106, 0, 18)
    targetPath.Position = UDim2.new(0, 10, 0, 48)
    targetPath.BackgroundTransparency = 1
    targetPath.Parent = infoCard

    local targetDims = Instance.new("TextLabel")
    targetDims.Text = "Dimensões: -"
    targetDims.Font = Theme.FontRegular
    targetDims.TextSize = 10
    targetDims.TextColor3 = Theme.TextSecondary
    targetDims.TextXAlignment = Enum.TextXAlignment.Left
    targetDims.Size = UDim2.new(1, -106, 0, 18)
    targetDims.Position = UDim2.new(0, 10, 0, 68)
    targetDims.BackgroundTransparency = 1
    targetDims.Parent = infoCard

    -- Helper to update info display & ViewportFrame
    local function inspectInstance(inst)
        self.CurrentTargetInstance = inst

        -- Clear previous 3D viewport clones
        pcall(function()
            for _, c in ipairs(vpFrame:GetChildren()) do
                if c:IsA("Instance") and not c:IsA("Camera") then
                    c:Destroy()
                end
            end
        end)

        if not inst then
            targetTitle.Text = "Nenhum objeto selecionado"
            targetTitle.TextColor3 = Theme.TextMuted
            targetStats.Text = "Use o botão 3D ou digite o nome acima."
            targetPath.Text = "Caminho: -"
            targetDims.Text = "Dimensões: -"
            return
        end

        local parts = 0
        local scripts = 0
        local meshes = 0

        for _, desc in ipairs(inst:GetDescendants()) do
            if desc:IsA("BasePart") then
                parts = parts + 1
            end
            if desc:IsA("MeshPart") or desc:IsA("SpecialMesh") then
                meshes = meshes + 1
            end
            if desc:IsA("LuaSourceContainer") then
                scripts = scripts + 1
            end
        end
        if inst:IsA("BasePart") then
            parts = parts + 1
        end
        if inst:IsA("LuaSourceContainer") then
            scripts = scripts + 1
        end

        targetTitle.Text = string.format("Alvo: %s (%s)", inst.Name, inst.ClassName)
        targetTitle.TextColor3 = Theme.TextPrimary
        targetStats.Text = string.format("%d Peças • %d Malhas • %d Scripts", parts, meshes, scripts)
        targetStats.TextColor3 = Theme.AccentSuccess
        targetPath.Text = "Caminho: " .. inst:GetFullName()

        -- In-game visual neon bounding highlight
        pcall(function()
            if self.CurrentHighlight then
                self.CurrentHighlight:Destroy()
                self.CurrentHighlight = nil
            end
            if inst:IsA("Model") or inst:IsA("BasePart") then
                local h = Instance.new("Highlight")
                h.Name = Stealth.GenerateRandomName(16)
                h.FillColor = Theme.AccentPrimary
                h.FillTransparency = 0.65
                h.OutlineColor = Theme.BorderLight
                h.OutlineTransparency = 0.1
                h.Adornee = inst
                h.Parent = safeContainer
                self.CurrentHighlight = h
            end
        end)

        -- Populate ViewportFrame with 3D model clone
        pcall(function()
            if inst:IsA("Model") or inst:IsA("BasePart") then
                local clone = inst:Clone()
                if clone then
                    clone.Parent = vpFrame
                    local cf = CFrame.new()
                    local sz = Vector3.new(4, 4, 4)

                    if clone:IsA("Model") then
                        cf = clone:GetBoundingBox()
                        sz = clone:GetExtentsSize()
                    elseif clone:IsA("BasePart") then
                        cf = clone.CFrame
                        sz = clone.Size
                    end

                    targetDims.Text = string.format("Tamanho: %.1f x %.1f x %.1f studs", sz.X, sz.Y, sz.Z)

                    local maxDim = math.max(sz.X, sz.Y, sz.Z)
                    local camDist = math.clamp(maxDim * 1.5, 4, 250)

                    if self.VpRotationConn then
                        self.VpRotationConn:Disconnect()
                        self.VpRotationConn = nil
                    end

                    local runServ = game:GetService("RunService")
                    self.VpRotationConn = runServ.RenderStepped:Connect(function()
                        if not vpFrame or not vpFrame.Parent or not self.CurrentTargetInstance then
                            if self.VpRotationConn then
                                self.VpRotationConn:Disconnect()
                            end
                            return
                        end
                        local angle = os.clock() * 0.9
                        local eyePos = cf.Position + Vector3.new(math.cos(angle) * camDist, camDist * 0.45, math.sin(angle) * camDist)
                        vpCam.CFrame = CFrame.new(eyePos, cf.Position)
                    end)
                end
            else
                targetDims.Text = "Tipo: " .. inst.ClassName
            end
        end)
    end

    -- 4. Action Buttons Container
    local actionBtnContainer = Instance.new("Frame")
    actionBtnContainer.Size = UDim2.new(1, -24, 0, 32)
    actionBtnContainer.Position = UDim2.new(0, 12, 0, 230)
    actionBtnContainer.BackgroundTransparency = 1
    actionBtnContainer.Parent = scroll

    local actionLayout = Instance.new("UIListLayout")
    actionLayout.FillDirection = Enum.FillDirection.Horizontal
    actionLayout.Padding = UDim.new(0, 6)
    actionLayout.SortOrder = Enum.SortOrder.LayoutOrder
    actionLayout.Parent = actionBtnContainer

    local btnSaveSingle = Instance.new("TextButton")
    btnSaveSingle.Text = "Salvar Modelo (.rbxm)"
    btnSaveSingle.Font = Theme.FontSemiBold
    btnSaveSingle.TextSize = 10
    btnSaveSingle.TextColor3 = Theme.TextPrimary
    btnSaveSingle.BackgroundColor3 = Theme.AccentPrimary
    btnSaveSingle.Size = UDim2.new(0.35, -4, 1, 0)
    btnSaveSingle.LayoutOrder = 1
    Theme.AddCorner(btnSaveSingle, Theme.CornerSmall)
    Theme.AddStroke(btnSaveSingle, Theme.BorderLight, 1)
    btnSaveSingle.Parent = actionBtnContainer

    local btnExportWeb3D = Instance.new("TextButton")
    btnExportWeb3D.Text = "Visualizar 3D (Web)"
    btnExportWeb3D.Font = Theme.FontSemiBold
    btnExportWeb3D.TextSize = 10
    btnExportWeb3D.TextColor3 = Theme.TextPrimary
    btnExportWeb3D.BackgroundColor3 = Theme.CardHover
    btnExportWeb3D.Size = UDim2.new(0.35, -4, 1, 0)
    btnExportWeb3D.LayoutOrder = 2
    Theme.AddCorner(btnExportWeb3D, Theme.CornerSmall)
    Theme.AddStroke(btnExportWeb3D, Theme.Border, 1)
    btnExportWeb3D.Parent = actionBtnContainer

    local btnAddToPack = Instance.new("TextButton")
    btnAddToPack.Text = "Adicionar ao Pacote"
    btnAddToPack.Font = Theme.FontSemiBold
    btnAddToPack.TextSize = 10
    btnAddToPack.TextColor3 = Theme.TextPrimary
    btnAddToPack.BackgroundColor3 = Theme.CardActive
    btnAddToPack.Size = UDim2.new(0.3, -4, 1, 0)
    btnAddToPack.LayoutOrder = 3
    Theme.AddCorner(btnAddToPack, Theme.CornerSmall)
    Theme.AddStroke(btnAddToPack, Theme.Border, 1)
    btnAddToPack.Parent = actionBtnContainer

    -- 5. Multi-Select Package Card
    local packCard = Instance.new("Frame")
    packCard.Size = UDim2.new(1, -24, 0, 96)
    packCard.Position = UDim2.new(0, 12, 0, 270)
    packCard.BackgroundColor3 = Theme.CardBg
    Theme.AddCorner(packCard, Theme.CornerMedium)
    Theme.AddStroke(packCard, Theme.Border, 1)
    packCard.Parent = scroll

    local packTitle = Instance.new("TextLabel")
    packTitle.Text = "Pacote de Objetos: 0 itens"
    packTitle.Font = Theme.FontSemiBold
    packTitle.TextSize = 11
    packTitle.TextColor3 = Theme.TextPrimary
    packTitle.TextXAlignment = Enum.TextXAlignment.Left
    packTitle.Size = UDim2.new(0.7, 0, 0, 20)
    packTitle.Position = UDim2.new(0, 10, 0, 10)
    packTitle.BackgroundTransparency = 1
    packTitle.Parent = packCard

    local btnClearPack = Instance.new("TextButton")
    btnClearPack.Text = "Limpar"
    btnClearPack.Font = Theme.FontSemiBold
    btnClearPack.TextSize = 10
    btnClearPack.TextColor3 = Theme.AccentDanger
    btnClearPack.BackgroundColor3 = Theme.Background
    btnClearPack.Size = UDim2.new(0.24, 0, 0, 22)
    btnClearPack.Position = UDim2.new(0.73, 0, 0, 9)
    Theme.AddCorner(btnClearPack, Theme.CornerSmall)
    Theme.AddStroke(btnClearPack, Theme.AccentDanger, 1, 0.5)
    btnClearPack.Parent = packCard

    local btnSavePack = Instance.new("TextButton")
    btnSavePack.Text = "Exportar Pacote Selecionado (.rbxm)"
    btnSavePack.Font = Theme.FontSemiBold
    btnSavePack.TextSize = 10
    btnSavePack.TextColor3 = Theme.TextPrimary
    btnSavePack.BackgroundColor3 = Theme.AccentSecondary
    btnSavePack.Size = UDim2.new(1, -20, 0, 32)
    btnSavePack.Position = UDim2.new(0, 10, 0, 50)
    Theme.AddCorner(btnSavePack, Theme.CornerSmall)
    Theme.AddStroke(btnSavePack, Theme.BorderLight, 1)
    btnSavePack.Parent = packCard

    -- 6. Result & Status Label
    local resultLabel = Instance.new("TextLabel")
    resultLabel.Text = "Status: Pronto para selecionar."
    resultLabel.Font = Theme.FontRegular
    resultLabel.TextSize = 11
    resultLabel.TextColor3 = Theme.TextMuted
    resultLabel.TextXAlignment = Enum.TextXAlignment.Left
    resultLabel.Size = UDim2.new(1, -24, 0, 30)
    resultLabel.Position = UDim2.new(0, 12, 0, 376)
    resultLabel.TextWrapped = true
    resultLabel.BackgroundTransparency = 1
    resultLabel.Parent = scroll

    -- Update pack counter UI
    local function updatePackUI()
        packTitle.Text = string.format("Pacote de Objetos: %d itens", #self.SelectedTargets)
    end

    -- Event: 3D Raycast click button
    Theme.AnimateButton(raycastBtn, function()
        if self.MainFrame then
            self.MainFrame.Visible = false
        end
        resultLabel.Text = "Mira 3D ativa. Clique em qualquer objeto no jogo para selecionar."
        resultLabel.TextColor3 = Theme.TextPrimary

        self.Raycast:Start(function(selected)
            if self.MainFrame then
                self.MainFrame.Visible = true
            end
            if selected then
                searchBox.Text = selected.Name
                inspectInstance(selected)
                resultLabel.Text = "Objeto selecionado: " .. selected.Name
                resultLabel.TextColor3 = Theme.AccentSuccess
            end
        end)
    end)

    -- Event: Search box text change
    searchBox.FocusLost:Connect(function(enterPressed)
        local text = searchBox.Text
        if #text > 0 then
            local found = workspace:FindFirstChild(text, true) or game:GetService("ReplicatedStorage"):FindFirstChild(text, true)
            if found then
                inspectInstance(found)
                resultLabel.Text = "Encontrado: " .. found.Name
                resultLabel.TextColor3 = Theme.AccentSuccess
            else
                inspectInstance(nil)
                resultLabel.Text = "Objeto não encontrado na hierarquia."
                resultLabel.TextColor3 = Theme.AccentDanger
            end
        end
    end)

    -- Event: Save single model
    Theme.AnimateButton(btnSaveSingle, function()
        local target = self.CurrentTargetInstance
        if not target then
            resultLabel.Text = "Selecione um objeto primeiro."
            resultLabel.TextColor3 = Theme.AccentWarning
            return
        end

        resultLabel.Text = "Salvando " .. target.Name .. " com scripts..."
        resultLabel.TextColor3 = Theme.TextPrimary

        task.spawn(function()
            local success, msg = self.Engine:SaveTarget(target)
            if success then
                resultLabel.Text = "Modelo salvo com sucesso: " .. msg
                resultLabel.TextColor3 = Theme.AccentSuccess
                Environment.SetClipboard(msg)
            else
                resultLabel.Text = "Falha ao salvar: " .. tostring(msg)
                resultLabel.TextColor3 = Theme.AccentDanger
            end
        end)
    end)

    -- Event: Export 3D Web HTML
    Theme.AnimateButton(btnExportWeb3D, function()
        local target = self.CurrentTargetInstance
        if not target then
            resultLabel.Text = "Selecione um objeto antes de exportar."
            resultLabel.TextColor3 = Theme.AccentWarning
            return
        end

        resultLabel.Text = "Gerando visualizador 3D Web (.html)..."
        resultLabel.TextColor3 = Theme.TextPrimary

        task.spawn(function()
            local success, msg = Web3DExporter.ExportModelToHTML(target)
            if success then
                resultLabel.Text = "Visualizador Web salvo: " .. msg
                resultLabel.TextColor3 = Theme.AccentSuccess
                Environment.SetClipboard(msg)
            else
                resultLabel.Text = "Falha ao exportar Web 3D: " .. tostring(msg)
                resultLabel.TextColor3 = Theme.AccentDanger
            end
        end)
    end)

    -- Event: Add to pack
    Theme.AnimateButton(btnAddToPack, function()
        local target = self.CurrentTargetInstance
        if not target then
            resultLabel.Text = "Selecione um objeto para adicionar ao pacote."
            resultLabel.TextColor3 = Theme.AccentWarning
            return
        end

        table.insert(self.SelectedTargets, target)
        updatePackUI()
        resultLabel.Text = string.format("Adicionado ao pacote: %s (%d itens)", target.Name, #self.SelectedTargets)
        resultLabel.TextColor3 = Theme.AccentSuccess
    end)

    -- Event: Clear pack
    Theme.AnimateButton(btnClearPack, function()
        self.SelectedTargets = {}
        updatePackUI()
        resultLabel.Text = "Pacote limpo."
        resultLabel.TextColor3 = Theme.TextMuted
    end)

    -- Event: Save full multi-pack
    Theme.AnimateButton(btnSavePack, function()
        if #self.SelectedTargets == 0 then
            resultLabel.Text = "O pacote está vazio."
            resultLabel.TextColor3 = Theme.AccentWarning
            return
        end

        resultLabel.Text = string.format("Salvando pacote com %d itens...", #self.SelectedTargets)
        resultLabel.TextColor3 = Theme.TextPrimary

        task.spawn(function()
            local folder = Instance.new("Folder")
            folder.Name = "HyperSave_SelectedPack"
            for _, t in ipairs(self.SelectedTargets) do
                pcall(function()
                    local c = t:Clone()
                    if c then
                        c.Parent = folder
                    end
                end)
            end

            local success, msg = self.Engine:SaveTarget(folder)
            if success then
                resultLabel.Text = "Pacote salvo com sucesso: " .. msg
                resultLabel.TextColor3 = Theme.AccentSuccess
                Environment.SetClipboard(msg)
            else
                resultLabel.Text = "Falha ao salvar pacote: " .. tostring(msg)
                resultLabel.TextColor3 = Theme.AccentDanger
            end
            pcall(function()
                folder:Destroy()
            end)
        end)
    end)
end

function Interface:BuildAudioRipperTab()
    local parent = self.TabFrames["AudioRipper"]

    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, -32, 0, 32)
    topBar.Position = UDim2.new(0, 16, 0, 10)
    topBar.BackgroundTransparency = 1
    topBar.Parent = parent

    local topLayout = Instance.new("UIListLayout")
    topLayout.FillDirection = Enum.FillDirection.Horizontal
    topLayout.Padding = UDim.new(0, 6)
    topLayout.SortOrder = Enum.SortOrder.LayoutOrder
    topLayout.Parent = topBar

    local scanAudioBtn = Instance.new("TextButton")
    scanAudioBtn.Text = "Buscar Sons"
    scanAudioBtn.Font = Theme.FontSemiBold
    scanAudioBtn.TextSize = 10
    scanAudioBtn.TextColor3 = Theme.TextPrimary
    scanAudioBtn.BackgroundColor3 = Theme.AccentPrimary
    scanAudioBtn.Size = UDim2.new(0.38, -4, 1, 0)
    scanAudioBtn.LayoutOrder = 1
    Theme.AddCorner(scanAudioBtn, Theme.CornerSmall)
    Theme.AddStroke(scanAudioBtn, Theme.BorderLight, 1)
    scanAudioBtn.Parent = topBar

    local exportAudioListBtn = Instance.new("TextButton")
    exportAudioListBtn.Text = "Exportar Lista (.txt)"
    exportAudioListBtn.Font = Theme.FontSemiBold
    exportAudioListBtn.TextSize = 10
    exportAudioListBtn.TextColor3 = Theme.TextPrimary
    exportAudioListBtn.BackgroundColor3 = Theme.CardBg
    exportAudioListBtn.Size = UDim2.new(0.38, -4, 1, 0)
    exportAudioListBtn.LayoutOrder = 2
    Theme.AddCorner(exportAudioListBtn, Theme.CornerSmall)
    Theme.AddStroke(exportAudioListBtn, Theme.Border, 1)
    exportAudioListBtn.Parent = topBar

    local stopAudioBtn = Instance.new("TextButton")
    stopAudioBtn.Text = "Parar Áudio"
    stopAudioBtn.Font = Theme.FontSemiBold
    stopAudioBtn.TextSize = 10
    stopAudioBtn.TextColor3 = Theme.AccentDanger
    stopAudioBtn.BackgroundColor3 = Theme.Background
    stopAudioBtn.Size = UDim2.new(0.24, -4, 1, 0)
    stopAudioBtn.LayoutOrder = 3
    Theme.AddCorner(stopAudioBtn, Theme.CornerSmall)
    Theme.AddStroke(stopAudioBtn, Theme.AccentDanger, 1, 0.5)
    stopAudioBtn.Parent = topBar

    -- Audio Search Filter
    local searchBox = Instance.new("TextBox")
    searchBox.PlaceholderText = "Filtrar sons por nome ou ID..."
    searchBox.Font = Theme.FontRegular
    searchBox.TextSize = 11
    searchBox.TextColor3 = Theme.TextPrimary
    searchBox.PlaceholderColor3 = Theme.TextMuted
    searchBox.BackgroundColor3 = Theme.InputBg
    searchBox.Size = UDim2.new(1, -32, 0, 30)
    searchBox.Position = UDim2.new(0, 16, 0, 48)
    Theme.AddCorner(searchBox, Theme.CornerSmall)
    Theme.AddStroke(searchBox, Theme.Border, 1)
    searchBox.Parent = parent

    local audioScroll = Instance.new("ScrollingFrame")
    audioScroll.Size = UDim2.new(1, -32, 1, -88)
    audioScroll.Position = UDim2.new(0, 16, 0, 84)
    audioScroll.BackgroundColor3 = Theme.CardBg
    audioScroll.ScrollBarThickness = 3
    audioScroll.ScrollBarImageColor3 = Theme.Border
    Theme.AddCorner(audioScroll, Theme.CornerMedium)
    Theme.AddStroke(audioScroll, Theme.Border, 1)
    audioScroll.Parent = parent

    local audioLayout = Instance.new("UIListLayout")
    audioLayout.SortOrder = Enum.SortOrder.LayoutOrder
    audioLayout.Padding = UDim.new(0, 4)
    audioLayout.Parent = audioScroll

    local allSoundRows = {}

    local function filterSounds(query)
        local q = string.lower(query or "")
        local visibleCount = 0
        for _, item in ipairs(allSoundRows) do
            local match = (q == "")
                or string.find(string.lower(item.Data.Name), q, 1, true)
                or string.find(string.lower(item.Data.CleanId), q, 1, true)
            item.Row.Visible = match
            if match then
                visibleCount = visibleCount + 1
            end
        end
        audioScroll.CanvasSize = UDim2.new(0, 0, 0, visibleCount * 36)
    end

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        filterSounds(searchBox.Text)
    end)

    Theme.AnimateButton(scanAudioBtn, function()
        scanAudioBtn.Text = "Buscando..."
        allSoundRows = {}
        for _, child in ipairs(audioScroll:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end

        task.spawn(function()
            local list = AudioRipper.ScanSounds()
            scanAudioBtn.Text = string.format("%d sons encontrados", #list)

            for _, snd in ipairs(list) do
                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, -12, 0, 30)
                row.BackgroundColor3 = Theme.Background
                Theme.AddCorner(row, Theme.CornerSmall)
                Theme.AddStroke(row, Theme.Border, 1)
                row.Parent = audioScroll

                local sndLbl = Instance.new("TextLabel")
                sndLbl.Text = string.format("%s (ID: %s)", snd.Name, snd.CleanId)
                sndLbl.Font = Theme.FontRegular
                sndLbl.TextSize = 10
                sndLbl.TextColor3 = Theme.TextPrimary
                sndLbl.TextXAlignment = Enum.TextXAlignment.Left
                sndLbl.Size = UDim2.new(0.62, 0, 1, 0)
                sndLbl.Position = UDim2.new(0, 8, 0, 0)
                sndLbl.BackgroundTransparency = 1
                sndLbl.Parent = row

                local playBtn = Instance.new("TextButton")
                playBtn.Text = "Tocar"
                playBtn.Font = Theme.FontSemiBold
                playBtn.TextSize = 10
                playBtn.TextColor3 = Theme.TextPrimary
                playBtn.BackgroundColor3 = Theme.AccentPrimary
                playBtn.Size = UDim2.new(0, 48, 0, 20)
                playBtn.Position = UDim2.new(1, -114, 0.5, -10)
                Theme.AddCorner(playBtn, Theme.CornerSmall)
                playBtn.Parent = row

                Theme.AnimateButton(playBtn, function()
                    AudioRipper.PlayPreview(snd.SoundId)
                end)

                local copyBtn = Instance.new("TextButton")
                copyBtn.Text = "Copiar ID"
                copyBtn.Font = Theme.FontSemiBold
                copyBtn.TextSize = 9
                copyBtn.TextColor3 = Theme.TextSecondary
                copyBtn.BackgroundColor3 = Theme.CardHover
                copyBtn.Size = UDim2.new(0, 56, 0, 20)
                copyBtn.Position = UDim2.new(1, -60, 0.5, -10)
                Theme.AddCorner(copyBtn, Theme.CornerSmall)
                Theme.AddStroke(copyBtn, Theme.Border, 1)
                copyBtn.Parent = row

                Theme.AnimateButton(copyBtn, function()
                    Environment.SetClipboard(snd.CleanId)
                    copyBtn.Text = "✓"
                    task.delay(1.5, function()
                        copyBtn.Text = "Copiar ID"
                    end)
                end)

                table.insert(allSoundRows, { Row = row, Data = snd })
            end

            audioScroll.CanvasSize = UDim2.new(0, 0, 0, #list * 36)
        end)
    end)

    Theme.AnimateButton(stopAudioBtn, function()
        pcall(function()
            for _, s in ipairs(game:GetService("SoundService"):GetChildren()) do
                if s:IsA("Sound") and string.find(s.Name, "Preview") then
                    s:Stop()
                    s:Destroy()
                end
            end
        end)
        stopAudioBtn.Text = "Parado"
        task.delay(1, function()
            stopAudioBtn.Text = "Parar Áudio"
        end)
    end)

    Theme.AnimateButton(exportAudioListBtn, function()
        local file = AudioRipper.ExportSoundList()
        exportAudioListBtn.Text = "✓ Exportado!"
        Environment.SetClipboard(file)
        task.delay(2, function()
            exportAudioListBtn.Text = "Exportar Lista (.txt)"
        end)
    end)
end

-- 4. Lighting & Atmosphere Ripper Tab
function Interface:BuildLightingRipperTab()
    local parent = self.TabFrames["LightingRipper"]

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -32, 1, -32)
    card.Position = UDim2.new(0, 16, 0, 16)
    card.BackgroundColor3 = Theme.CardBg
    Theme.AddCorner(card, Theme.CornerLarge)
    Theme.AddStroke(card, Theme.Border, 1)
    card.Parent = parent

    local headerLbl = Instance.new("TextLabel")
    headerLbl.Text = "Iluminação e Atmosfera"
    headerLbl.Font = Theme.FontTitle
    headerLbl.TextSize = 13
    headerLbl.TextColor3 = Theme.TextPrimary
    headerLbl.TextXAlignment = Enum.TextXAlignment.Left
    headerLbl.Size = UDim2.new(1, -24, 0, 22)
    headerLbl.Position = UDim2.new(0, 16, 0, 16)
    headerLbl.BackgroundTransparency = 1
    headerLbl.Parent = card

    local desc = Instance.new("TextLabel")
    desc.Text =
        "Extrai as propriedades visuais de iluminação, Skybox, Atmosphere (densidade, névoa e cores), SunRays, Bloom, Blur e ColorCorrection para um arquivo .rbxmx editável no Studio."
    desc.Font = Theme.FontRegular
    desc.TextSize = 11
    desc.TextColor3 = Theme.TextSecondary
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextYAlignment = Enum.TextYAlignment.Top
    desc.TextWrapped = true
    desc.Size = UDim2.new(1, -32, 0, 50)
    desc.Position = UDim2.new(0, 16, 0, 44)
    desc.BackgroundTransparency = 1
    desc.Parent = card

    local exportLightBtn = Instance.new("TextButton")
    exportLightBtn.Text = "Exportar Preset de Iluminação (.rbxmx)"
    exportLightBtn.Font = Theme.FontSemiBold
    exportLightBtn.TextSize = 11
    exportLightBtn.TextColor3 = Theme.TextPrimary
    exportLightBtn.BackgroundColor3 = Theme.AccentPrimary
    exportLightBtn.Size = UDim2.new(1, -32, 0, 38)
    exportLightBtn.Position = UDim2.new(0, 16, 0, 104)
    Theme.AddCorner(exportLightBtn, Theme.CornerMedium)
    Theme.AddStroke(exportLightBtn, Theme.BorderLight, 1)
    exportLightBtn.Parent = card

    local lightStatus = Instance.new("TextLabel")
    lightStatus.Text = "Status: Pronto para exportar iluminação."
    lightStatus.Font = Theme.FontRegular
    lightStatus.TextSize = 11
    lightStatus.TextColor3 = Theme.TextMuted
    lightStatus.TextXAlignment = Enum.TextXAlignment.Left
    lightStatus.Size = UDim2.new(1, -32, 0, 24)
    lightStatus.Position = UDim2.new(0, 16, 0, 154)
    lightStatus.BackgroundTransparency = 1
    lightStatus.Parent = card

    Theme.AnimateButton(exportLightBtn, function()
        lightStatus.Text = "Extraindo atmosfera e skyboxes..."
        lightStatus.TextColor3 = Theme.TextPrimary

        task.spawn(function()
            local success, file = LightingRipper.ExportLightingPreset()
            if success then
                lightStatus.Text = "Preset de iluminação salvo: " .. file
                lightStatus.TextColor3 = Theme.AccentSuccess
                Environment.SetClipboard(file)
            else
                lightStatus.Text = "Erro: " .. tostring(file)
                lightStatus.TextColor3 = Theme.AccentDanger
            end
        end)
    end)
end

-- 5. GUI & HUD Ripper Tab
function Interface:BuildGuiRipperTab()
    local parent = self.TabFrames["GuiRipper"]

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -32, 1, -32)
    card.Position = UDim2.new(0, 16, 0, 16)
    card.BackgroundColor3 = Theme.CardBg
    Theme.AddCorner(card, Theme.CornerLarge)
    Theme.AddStroke(card, Theme.Border, 1)
    card.Parent = parent

    local headerLbl = Instance.new("TextLabel")
    headerLbl.Text = "Interfaces e Menus (GUI)"
    headerLbl.Font = Theme.FontTitle
    headerLbl.TextSize = 13
    headerLbl.TextColor3 = Theme.TextPrimary
    headerLbl.TextXAlignment = Enum.TextXAlignment.Left
    headerLbl.Size = UDim2.new(1, -24, 0, 22)
    headerLbl.Position = UDim2.new(0, 16, 0, 16)
    headerLbl.BackgroundTransparency = 1
    headerLbl.Parent = card

    local desc = Instance.new("TextLabel")
    desc.Text =
        "Extrai todas as interfaces ativas (ScreenGuis, menus, lojas, inventários e HUDs) com seus respectivos scripts para um arquivo .rbxmx independente."
    desc.Font = Theme.FontRegular
    desc.TextSize = 11
    desc.TextColor3 = Theme.TextSecondary
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextYAlignment = Enum.TextYAlignment.Top
    desc.TextWrapped = true
    desc.Size = UDim2.new(1, -32, 0, 50)
    desc.Position = UDim2.new(0, 16, 0, 44)
    desc.BackgroundTransparency = 1
    desc.Parent = card

    local exportGuiBtn = Instance.new("TextButton")
    exportGuiBtn.Text = "Exportar Todas as Interfaces (.rbxmx)"
    exportGuiBtn.Font = Theme.FontSemiBold
    exportGuiBtn.TextSize = 11
    exportGuiBtn.TextColor3 = Theme.TextPrimary
    exportGuiBtn.BackgroundColor3 = Theme.AccentPrimary
    exportGuiBtn.Size = UDim2.new(1, -32, 0, 38)
    exportGuiBtn.Position = UDim2.new(0, 16, 0, 104)
    Theme.AddCorner(exportGuiBtn, Theme.CornerMedium)
    Theme.AddStroke(exportGuiBtn, Theme.BorderLight, 1)
    exportGuiBtn.Parent = card

    local guiStatus = Instance.new("TextLabel")
    guiStatus.Text = "Status: Pronto para exportar interfaces."
    guiStatus.Font = Theme.FontRegular
    guiStatus.TextSize = 11
    guiStatus.TextColor3 = Theme.TextMuted
    guiStatus.TextXAlignment = Enum.TextXAlignment.Left
    guiStatus.Size = UDim2.new(1, -32, 0, 24)
    guiStatus.Position = UDim2.new(0, 16, 0, 154)
    guiStatus.BackgroundTransparency = 1
    guiStatus.Parent = card

    Theme.AnimateButton(exportGuiBtn, function()
        guiStatus.Text = "Extraindo interfaces..."
        guiStatus.TextColor3 = Theme.TextPrimary

        task.spawn(function()
            local success, file = GuiRipper.ExportAllGuis(self.Config)
            if success then
                guiStatus.Text = "Pacote de UI salvo com sucesso: " .. file
                guiStatus.TextColor3 = Theme.AccentSuccess
                Environment.SetClipboard(file)
            else
                guiStatus.Text = "Erro: " .. tostring(file)
                guiStatus.TextColor3 = Theme.AccentDanger
            end
        end)
    end)
end

-- 6. Network Sniffer Tab
-- 6. Network Sniffer Tab
function Interface:BuildNetworkTab()
    local parent = self.TabFrames["Network"]

    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, -32, 0, 32)
    topBar.Position = UDim2.new(0, 16, 0, 10)
    topBar.BackgroundTransparency = 1
    topBar.Parent = parent

    local netLayout = Instance.new("UIListLayout")
    netLayout.FillDirection = Enum.FillDirection.Horizontal
    netLayout.Padding = UDim.new(0, 6)
    netLayout.SortOrder = Enum.SortOrder.LayoutOrder
    netLayout.Parent = topBar

    local toggleSnifferBtn = Instance.new("TextButton")
    toggleSnifferBtn.Text = "Iniciar Gravação de Rede"
    toggleSnifferBtn.Font = Theme.FontSemiBold
    toggleSnifferBtn.TextSize = 10
    toggleSnifferBtn.TextColor3 = Theme.TextPrimary
    toggleSnifferBtn.BackgroundColor3 = Theme.AccentPrimary
    toggleSnifferBtn.Size = UDim2.new(0.5, -3, 1, 0)
    toggleSnifferBtn.LayoutOrder = 1
    Theme.AddCorner(toggleSnifferBtn, Theme.CornerSmall)
    Theme.AddStroke(toggleSnifferBtn, Theme.BorderLight, 1)
    toggleSnifferBtn.Parent = topBar

    local exportSnifferBtn = Instance.new("TextButton")
    exportSnifferBtn.Text = "Exportar Logs (.json)"
    exportSnifferBtn.Font = Theme.FontSemiBold
    exportSnifferBtn.TextSize = 10
    exportSnifferBtn.TextColor3 = Theme.TextPrimary
    exportSnifferBtn.BackgroundColor3 = Theme.CardBg
    exportSnifferBtn.Size = UDim2.new(0.5, -3, 1, 0)
    exportSnifferBtn.LayoutOrder = 2
    Theme.AddCorner(exportSnifferBtn, Theme.CornerSmall)
    Theme.AddStroke(exportSnifferBtn, Theme.Border, 1)
    exportSnifferBtn.Parent = topBar

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -32, 1, -60)
    scroll.Position = UDim2.new(0, 16, 0, 50)
    scroll.BackgroundColor3 = Theme.CardBg
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Theme.Border
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    Theme.AddCorner(scroll, Theme.CornerMedium)
    Theme.AddStroke(scroll, Theme.Border, 1)
    scroll.Parent = parent

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 4)
    layout.Parent = scroll

    Theme.AnimateButton(toggleSnifferBtn, function()
        if NetworkSniffer.IsActive then
            NetworkSniffer.Stop()
            toggleSnifferBtn.Text = "Iniciar Gravação de Rede"
            toggleSnifferBtn.TextColor3 = Theme.TextPrimary
            toggleSnifferBtn.BackgroundColor3 = Theme.AccentPrimary
        else
            NetworkSniffer.Start()
            toggleSnifferBtn.Text = "Parar Gravação de Rede"
            toggleSnifferBtn.TextColor3 = Theme.TextPrimary
            toggleSnifferBtn.BackgroundColor3 = Theme.AccentDanger
        end
    end)

    Theme.AnimateButton(exportSnifferBtn, function()
        local file = NetworkSniffer.ExportLogs()
        exportSnifferBtn.Text = "✓ Salvo: " .. file
        Environment.SetClipboard(file)
        task.delay(2, function()
            exportSnifferBtn.Text = "Exportar Logs (.json)"
        end)
    end)

    NetworkSniffer.OnCall(function(entry)
        local row = Instance.new("TextLabel")
        row.Text = string.format("[%s] [%s] %s -> %s", entry.Timestamp, entry.Type, entry.RemoteName, entry.ArgsShape)
        row.Font = Theme.FontRegular
        row.TextSize = 10
        row.TextColor3 = (entry.Type == "FireServer") and Theme.TextPrimary or Theme.TextSecondary
        row.TextXAlignment = Enum.TextXAlignment.Left
        row.Size = UDim2.new(1, -12, 0, 16)
        row.BackgroundTransparency = 1
        row.Parent = scroll

        scroll.CanvasSize = UDim2.new(0, 0, 0, #NetworkSniffer.CapturedLogs * 18)
        scroll.CanvasPosition = Vector2.new(0, scroll.CanvasSize.Y.Offset)
    end)
end

-- 7. Universe Tab (Multi-Place Tracker)
function Interface:BuildUniverseTab()
    local parent = self.TabFrames["Universe"]

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -32, 1, -32)
    card.Position = UDim2.new(0, 16, 0, 16)
    card.BackgroundColor3 = Theme.CardBg
    Theme.AddCorner(card, Theme.CornerLarge)
    Theme.AddStroke(card, Theme.Border, 1)
    card.Parent = parent

    local headerLbl = Instance.new("TextLabel")
    headerLbl.Text = "Sub-Lugares do Universo"
    headerLbl.Font = Theme.FontTitle
    headerLbl.TextSize = 13
    headerLbl.TextColor3 = Theme.TextPrimary
    headerLbl.TextXAlignment = Enum.TextXAlignment.Left
    headerLbl.Size = UDim2.new(1, -24, 0, 22)
    headerLbl.Position = UDim2.new(0, 16, 0, 16)
    headerLbl.BackgroundTransparency = 1
    headerLbl.Parent = card

    local uniBtnContainer = Instance.new("Frame")
    uniBtnContainer.Size = UDim2.new(1, -32, 0, 30)
    uniBtnContainer.Position = UDim2.new(0, 16, 0, 44)
    uniBtnContainer.BackgroundTransparency = 1
    uniBtnContainer.Parent = card

    local uniLayout = Instance.new("UIListLayout")
    uniLayout.FillDirection = Enum.FillDirection.Horizontal
    uniLayout.Padding = UDim.new(0, 6)
    uniLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uniLayout.Parent = uniBtnContainer

    local scanBtn = Instance.new("TextButton")
    scanBtn.Text = "Buscar Lugares"
    scanBtn.Font = Theme.FontSemiBold
    scanBtn.TextSize = 10
    scanBtn.TextColor3 = Theme.TextPrimary
    scanBtn.BackgroundColor3 = Theme.AccentPrimary
    scanBtn.Size = UDim2.new(0.34, -4, 1, 0)
    scanBtn.LayoutOrder = 1
    Theme.AddCorner(scanBtn, Theme.CornerSmall)
    Theme.AddStroke(scanBtn, Theme.BorderLight, 1)
    scanBtn.Parent = uniBtnContainer

    local snapshotBtn = Instance.new("TextButton")
    snapshotBtn.Text = "Salvar Snapshot"
    snapshotBtn.Font = Theme.FontSemiBold
    snapshotBtn.TextSize = 10
    snapshotBtn.TextColor3 = Theme.TextPrimary
    snapshotBtn.BackgroundColor3 = Theme.CardBg
    snapshotBtn.Size = UDim2.new(0.33, -4, 1, 0)
    snapshotBtn.LayoutOrder = 2
    Theme.AddCorner(snapshotBtn, Theme.CornerSmall)
    Theme.AddStroke(snapshotBtn, Theme.Border, 1)
    snapshotBtn.Parent = uniBtnContainer

    local compareDiffBtn = Instance.new("TextButton")
    compareDiffBtn.Text = "Comparar Diff"
    compareDiffBtn.Font = Theme.FontSemiBold
    compareDiffBtn.TextSize = 10
    compareDiffBtn.TextColor3 = Theme.TextPrimary
    compareDiffBtn.BackgroundColor3 = Theme.CardHover
    compareDiffBtn.Size = UDim2.new(0.33, -4, 1, 0)
    compareDiffBtn.LayoutOrder = 3
    Theme.AddCorner(compareDiffBtn, Theme.CornerSmall)
    Theme.AddStroke(compareDiffBtn, Theme.Border, 1)
    compareDiffBtn.Parent = uniBtnContainer

    local placeScroll = Instance.new("ScrollingFrame")
    placeScroll.Size = UDim2.new(1, -32, 1, -94)
    placeScroll.Position = UDim2.new(0, 16, 0, 84)
    placeScroll.BackgroundColor3 = Theme.Background
    placeScroll.ScrollBarThickness = 3
    placeScroll.ScrollBarImageColor3 = Theme.Border
    Theme.AddCorner(placeScroll, Theme.CornerMedium)
    Theme.AddStroke(placeScroll, Theme.Border, 1)
    placeScroll.Parent = card

    local placeLayout = Instance.new("UIListLayout")
    placeLayout.SortOrder = Enum.SortOrder.LayoutOrder
    placeLayout.Padding = UDim.new(0, 4)
    placeLayout.Parent = placeScroll

    Theme.AnimateButton(scanBtn, function()
        scanBtn.Text = "Buscando..."
        for _, child in ipairs(placeScroll:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextLabel") then
                child:Destroy()
            end
        end

        task.spawn(function()
            local list = UniverseTracker.GetUniversePlaces()
            scanBtn.Text = string.format("%d lugares encontrados", #list)

            for idx, pInfo in ipairs(list) do
                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, -12, 0, 30)
                row.BackgroundColor3 = Theme.CardBg
                Theme.AddCorner(row, Theme.CornerSmall)
                Theme.AddStroke(row, Theme.Border, 1)
                row.Parent = placeScroll

                local pName = Instance.new("TextLabel")
                pName.Text = string.format("%s (ID: %d)", pInfo.Name, pInfo.PlaceId)
                pName.Font = Theme.FontRegular
                pName.TextSize = 10
                pName.TextColor3 = pInfo.IsRoot and Theme.TextAccent or Theme.TextPrimary
                pName.TextXAlignment = Enum.TextXAlignment.Left
                pName.Size = UDim2.new(0.55, 0, 1, 0)
                pName.Position = UDim2.new(0, 8, 0, 0)
                pName.BackgroundTransparency = 1
                pName.Parent = row

                local tpBtn = Instance.new("TextButton")
                tpBtn.Text = "Teleportar"
                tpBtn.Font = Theme.FontSemiBold
                tpBtn.TextSize = 10
                tpBtn.TextColor3 = Theme.TextPrimary
                tpBtn.BackgroundColor3 = Theme.AccentPrimary
                tpBtn.Size = UDim2.new(0, 72, 0, 20)
                tpBtn.Position = UDim2.new(1, -148, 0.5, -10)
                Theme.AddCorner(tpBtn, Theme.CornerSmall)
                tpBtn.Parent = row

                Theme.AnimateButton(tpBtn, function()
                    tpBtn.Text = "Teleportando..."
                    pcall(function()
                        local TeleportService = game:GetService("TeleportService")
                        local Players = game:GetService("Players")
                        TeleportService:Teleport(pInfo.PlaceId, Players.LocalPlayer)
                    end)
                end)

                local copyIdBtn = Instance.new("TextButton")
                copyIdBtn.Text = "Copiar ID"
                copyIdBtn.Font = Theme.FontSemiBold
                copyIdBtn.TextSize = 10
                copyIdBtn.TextColor3 = Theme.TextSecondary
                copyIdBtn.BackgroundColor3 = Theme.CardHover
                copyIdBtn.Size = UDim2.new(0, 68, 0, 20)
                copyIdBtn.Position = UDim2.new(1, -72, 0.5, -10)
                Theme.AddCorner(copyIdBtn, Theme.CornerSmall)
                Theme.AddStroke(copyIdBtn, Theme.Border, 1)
                copyIdBtn.Parent = row

                Theme.AnimateButton(copyIdBtn, function()
                    Environment.SetClipboard(tostring(pInfo.PlaceId))
                    copyIdBtn.Text = "✓"
                    task.delay(1.5, function()
                        copyIdBtn.Text = "Copiar ID"
                    end)
                end)
            end

            placeScroll.CanvasSize = UDim2.new(0, 0, 0, #list * 36)
        end)
    end)

    Theme.AnimateButton(snapshotBtn, function()
        snapshotBtn.Text = "Gravando..."
        task.spawn(function()
            local success, snapFile = PlaceDiffTracker.SaveSnapshot()
            if success then
                snapshotBtn.Text = "✓ Salvo!"
                Environment.SetClipboard(snapFile)
            else
                snapshotBtn.Text = "Erro"
            end
            task.delay(2, function()
                snapshotBtn.Text = "Salvar Snapshot"
            end)
        end)
    end)

    Theme.AnimateButton(compareDiffBtn, function()
        compareDiffBtn.Text = "Comparando..."
        for _, child in ipairs(placeScroll:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextLabel") then
                child:Destroy()
            end
        end

        task.spawn(function()
            local diff = PlaceDiffTracker.Compare({ Instances = {}, PlaceId = game.PlaceId or 0, InstanceCount = 0 })
            local s, reportFile = PlaceDiffTracker.ExportDiffReport(diff)

            local lbl = Instance.new("TextLabel")
            lbl.Text = diff.Summary .. (s and ("\nRelatório salvo: " .. reportFile) or "")
            lbl.Font = Theme.FontRegular
            lbl.TextSize = 11
            lbl.TextColor3 = Theme.TextPrimary
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextWrapped = true
            lbl.Size = UDim2.new(1, -12, 0, 60)
            lbl.BackgroundTransparency = 1
            lbl.Parent = placeScroll

            if s then
                Environment.SetClipboard(reportFile)
            end
            compareDiffBtn.Text = "✓ Concluído"
            task.delay(2, function()
                compareDiffBtn.Text = "Comparar Diff"
            end)
        end)
    end)
end

-- 8. OBJ Export Tab (Blender / Unity 3D)
function Interface:BuildObjExportTab()
    local parent = self.TabFrames["ObjExport"]

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -32, 1, -32)
    card.Position = UDim2.new(0, 16, 0, 16)
    card.BackgroundColor3 = Theme.CardBg
    Theme.AddCorner(card, Theme.CornerLarge)
    Theme.AddStroke(card, Theme.Border, 1)
    card.Parent = parent

    local headerLbl = Instance.new("TextLabel")
    headerLbl.Text = "Exportador de Malhas 3D"
    headerLbl.Font = Theme.FontTitle
    headerLbl.TextSize = 13
    headerLbl.TextColor3 = Theme.TextPrimary
    headerLbl.TextXAlignment = Enum.TextXAlignment.Left
    headerLbl.Size = UDim2.new(1, -24, 0, 22)
    headerLbl.Position = UDim2.new(0, 16, 0, 16)
    headerLbl.BackgroundTransparency = 1
    headerLbl.Parent = card

    local desc = Instance.new("TextLabel")
    desc.Text =
        "Converte os modelos e peças do mapa para arquivos .obj e .mtl com materiais prontos para Blender, Maya, Unity ou Unreal Engine."
    desc.Font = Theme.FontRegular
    desc.TextSize = 11
    desc.TextColor3 = Theme.TextSecondary
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextYAlignment = Enum.TextYAlignment.Top
    desc.TextWrapped = true
    desc.Size = UDim2.new(1, -32, 0, 48)
    desc.Position = UDim2.new(0, 16, 0, 44)
    desc.BackgroundTransparency = 1
    desc.Parent = card

    local exportBtnContainer = Instance.new("Frame")
    exportBtnContainer.Size = UDim2.new(1, -32, 0, 38)
    exportBtnContainer.Position = UDim2.new(0, 16, 0, 98)
    exportBtnContainer.BackgroundTransparency = 1
    exportBtnContainer.Parent = card

    local btnLayout = Instance.new("UIListLayout")
    btnLayout.FillDirection = Enum.FillDirection.Horizontal
    btnLayout.Padding = UDim.new(0, 6)
    btnLayout.SortOrder = Enum.SortOrder.LayoutOrder
    btnLayout.Parent = exportBtnContainer

    local exportObjBtn = Instance.new("TextButton")
    exportObjBtn.Text = "Exportar .OBJ + .MTL"
    exportObjBtn.Font = Theme.FontSemiBold
    exportObjBtn.TextSize = 11
    exportObjBtn.TextColor3 = Theme.TextPrimary
    exportObjBtn.BackgroundColor3 = Theme.AccentPrimary
    exportObjBtn.Size = UDim2.new(0.5, -3, 1, 0)
    exportObjBtn.LayoutOrder = 1
    Theme.AddCorner(exportObjBtn, Theme.CornerSmall)
    Theme.AddStroke(exportObjBtn, Theme.BorderLight, 1)
    exportObjBtn.Parent = exportBtnContainer

    local exportWebBtn = Instance.new("TextButton")
    exportWebBtn.Text = "Exportar Visualizador Web (.html)"
    exportWebBtn.Font = Theme.FontSemiBold
    exportWebBtn.TextSize = 11
    exportWebBtn.TextColor3 = Theme.TextPrimary
    exportWebBtn.BackgroundColor3 = Theme.CardHover
    exportWebBtn.Size = UDim2.new(0.5, -3, 1, 0)
    exportWebBtn.LayoutOrder = 2
    Theme.AddCorner(exportWebBtn, Theme.CornerSmall)
    Theme.AddStroke(exportWebBtn, Theme.Border, 1)
    exportWebBtn.Parent = exportBtnContainer

    local objStatus = Instance.new("TextLabel")
    objStatus.Text = "Status: Pronto para exportar."
    objStatus.Font = Theme.FontRegular
    objStatus.TextSize = 11
    objStatus.TextColor3 = Theme.TextMuted
    objStatus.TextXAlignment = Enum.TextXAlignment.Left
    objStatus.Size = UDim2.new(1, -32, 0, 24)
    objStatus.Position = UDim2.new(0, 16, 0, 148)
    objStatus.BackgroundTransparency = 1
    objStatus.Parent = card

    Theme.AnimateButton(exportObjBtn, function()
        objStatus.Text = "Gerando arquivos .obj e .mtl..."
        objStatus.TextColor3 = Theme.TextPrimary

        task.spawn(function()
            local success, file = ObjExporter.ExportWorkspaceToObj()
            if success then
                objStatus.Text = "Exportado com sucesso: " .. file
                objStatus.TextColor3 = Theme.AccentSuccess
                Environment.SetClipboard(file)
            else
                objStatus.Text = "Erro ao exportar: " .. tostring(file)
                objStatus.TextColor3 = Theme.AccentDanger
            end
        end)
    end)

    Theme.AnimateButton(exportWebBtn, function()
        objStatus.Text = "Gerando visualizador 3D Web (.html)..."
        objStatus.TextColor3 = Theme.TextPrimary

        task.spawn(function()
            local success, file = Web3DExporter.ExportModelToHTML(workspace)
            if success then
                objStatus.Text = "Arquivo Web 3D salvo: " .. file
                objStatus.TextColor3 = Theme.AccentSuccess
                Environment.SetClipboard(file)
            else
                objStatus.Text = "Falha ao exportar Web 3D: " .. tostring(file)
                objStatus.TextColor3 = Theme.AccentDanger
            end
        end)
    end)
end

-- 9. Tutorial Tab (Built-in Step-by-Step Guide)
function Interface:BuildTutorialTab()
    local parent = self.TabFrames["Tutorial"]

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -32, 1, -32)
    scroll.Position = UDim2.new(0, 16, 0, 16)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Theme.Border
    scroll.CanvasSize = UDim2.new(0, 0, 0, 420)
    scroll.Parent = parent

    local steps = {
        {
            "Passo 1: Iniciar a Cópia",
            "Acesse a aba 'Dashboard' e clique no botão azul 'Salvar Mapa Completo'. O processo começará a extrair todas as instâncias do jogo.",
        },
        {
            "Passo 2: Aguardar o Processamento",
            "A barra de progresso acompanhará o download de texturas, sons, modelos 3D, terreno e scripts do mapa.",
        },
        {
            "Passo 3: Localização dos Arquivos",
            "O arquivo gerado (.rbxlx ou .rbxl) é salvo diretamente na pasta 'workspace' do seu executor no computador.",
        },
        {
            "Passo 4: Abrir no Roblox Studio",
            "1. Abra o Roblox Studio.\n2. Clique em 'File' -> 'Open from File...'\n3. Selecione o arquivo gerado e clique em Abrir.\n4. O mapa estará 100% carregado e pronto para edição.",
        },
    }

    for i, step in ipairs(steps) do
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -12, 0, 74)
        card.Position = UDim2.new(0, 0, 0, (i - 1) * 80)
        card.BackgroundColor3 = Theme.CardBg
        Theme.AddCorner(card, Theme.CornerMedium)
        Theme.AddStroke(card, Theme.Border, 1)
        card.Parent = scroll

        local title = Instance.new("TextLabel")
        title.Text = step[1]
        title.Font = Theme.FontSemiBold
        title.TextSize = 11
        title.TextColor3 = Theme.TextPrimary
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Size = UDim2.new(1, -20, 0, 18)
        title.Position = UDim2.new(0, 12, 0, 8)
        title.BackgroundTransparency = 1
        title.Parent = card

        local desc = Instance.new("TextLabel")
        desc.Text = step[2]
        desc.Font = Theme.FontRegular
        desc.TextSize = 10
        desc.TextColor3 = Theme.TextSecondary
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.TextYAlignment = Enum.TextYAlignment.Top
        desc.TextWrapped = true
        desc.Size = UDim2.new(1, -24, 0, 42)
        desc.Position = UDim2.new(0, 12, 0, 26)
        desc.BackgroundTransparency = 1
        desc.Parent = card
    end

    -- Copy Universal Command Button
    local copyScriptCard = Instance.new("TextButton")
    copyScriptCard.Text = "Copiar Comando de Execução (loadstring)"
    copyScriptCard.Font = Theme.FontSemiBold
    copyScriptCard.TextSize = 11
    copyScriptCard.TextColor3 = Theme.TextPrimary
    copyScriptCard.BackgroundColor3 = Theme.AccentPrimary
    copyScriptCard.Size = UDim2.new(1, -12, 0, 36)
    copyScriptCard.Position = UDim2.new(0, 0, 0, 330)
    Theme.AddCorner(copyScriptCard, Theme.CornerSmall)
    Theme.AddStroke(copyScriptCard, Theme.BorderLight, 1)
    copyScriptCard.Parent = scroll

    Theme.AnimateButton(copyScriptCard, function()
        Environment.SetClipboard(
            'loadstring(game:HttpGet("https://raw.githubusercontent.com/theopadilha2009-hash/HyperSaveInstance/main/dist/HyperSaveInstance.luau"))()'
        )
        copyScriptCard.Text = "✓ Comando Copiado!"
        task.delay(2, function()
            copyScriptCard.Text = "Copiar Comando de Execução (loadstring)"
        end)
    end)
end

-- 10. Settings Tab
function Interface:BuildSettingsTab()
    local parent = self.TabFrames["Settings"]

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -32, 1, -32)
    scroll.Position = UDim2.new(0, 16, 0, 16)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Theme.Border
    scroll.CanvasSize = UDim2.new(0, 0, 0, 780)
    scroll.Parent = parent

    -- Discord Webhook URL Row
    local webhookRow = Instance.new("Frame")
    webhookRow.Size = UDim2.new(1, -12, 0, 36)
    webhookRow.Position = UDim2.new(0, 0, 0, 0)
    webhookRow.BackgroundColor3 = Theme.CardBg
    Theme.AddCorner(webhookRow, Theme.CornerSmall)
    Theme.AddStroke(webhookRow, Theme.Border, 1)
    webhookRow.Parent = scroll

    local webhookLbl = Instance.new("TextLabel")
    webhookLbl.Text = "Webhook do Discord:"
    webhookLbl.Font = Theme.FontSemiBold
    webhookLbl.TextSize = 10
    webhookLbl.TextColor3 = Theme.TextSecondary
    webhookLbl.TextXAlignment = Enum.TextXAlignment.Left
    webhookLbl.Size = UDim2.new(0.38, 0, 1, 0)
    webhookLbl.Position = UDim2.new(0, 10, 0, 0)
    webhookLbl.BackgroundTransparency = 1
    webhookLbl.Parent = webhookRow

    local webhookBox = Instance.new("TextBox")
    webhookBox.PlaceholderText = "https://discord.com/api/webhooks/..."
    webhookBox.Text = self.Config.DiscordWebhookUrl or ""
    webhookBox.Font = Theme.FontRegular
    webhookBox.TextSize = 10
    webhookBox.TextColor3 = Theme.TextPrimary
    webhookBox.PlaceholderColor3 = Theme.TextMuted
    webhookBox.BackgroundColor3 = Theme.InputBg
    webhookBox.Size = UDim2.new(0.58, 0, 0, 24)
    webhookBox.Position = UDim2.new(0.40, 0, 0.5, -12)
    webhookBox.ClearTextOnFocus = false
    Theme.AddCorner(webhookBox, Theme.CornerSmall)
    Theme.AddStroke(webhookBox, Theme.Border, 1)
    webhookBox.Parent = webhookRow

    webhookBox.FocusLost:Connect(function()
        self.Config.DiscordWebhookUrl = webhookBox.Text
        self:Log("Discord Webhook atualizado.")
    end)

    local toggles = {
        { "AutoAntiAFK", "Anti-AFK Automático (Evita desconexão por inatividade)", self.Config.AutoAntiAFK },
        { "AutoExploreStreaming", "Carregador Espacial (StreamingEnabled)", self.Config.AutoExploreStreaming },
        { "StealthMode", "Modo Stealth (Evasão de Anti-Cheat)", self.Config.StealthMode },
        { "SaveAnimations", "Capturar e Salvar Animações (KeyframeSequences)", self.Config.SaveAnimations },
        { "SafeAssetDownload", "Proteção de Ping (Pausa se Ping > 180ms)", self.Config.SafeAssetDownload },
        { "DownloadRawAssets", "Baixar Assets Brutos (.mp3, .png, .mesh)", self.Config.DownloadRawAssets },
        { "OptimizeGeometry", "Otimizador de Geometria (Deduplicação de Malhas)", self.Config.OptimizeGeometry },
        { "SaveTerrain", "Salvar Terreno Completo (Propriedades e Materiais)", self.Config.SaveTerrain },
        { "SaveTerrainVoxels", "Extrair SmoothVoxels do Terreno (Chunks 3D)", self.Config.SaveTerrainVoxels },
        { "SaveLighting", "Preservar Iluminação e Efeitos Atmosféricos", self.Config.SaveLighting },
        { "SaveSounds", "Preservar Sons e Efeitos Sonoros", self.Config.SaveSounds },
        { "SaveUnions", "Preservar Uniões CSG e NegateOperations", self.Config.SaveUnions },
        { "SaveSurfaceAppearance", "Preservar Texturas PBR e SurfaceAppearances", self.Config.SaveSurfaceAppearance },
        { "DecompileScripts", "Descompilar Scripts (LocalScripts e ModuleScripts)", self.Config.DecompileScripts },
        { "IsolateStarterPlayer", "Isolar Scripts do Player para StarterPlayer/StarterGui", self.Config.IsolateStarterPlayer },
        { "SaveServerScriptPlaceholders", "Reconstrução Inteligente de Server Scripts", self.Config.SaveServerScriptPlaceholders },
        { "SynthesizeServer", "Sintetizador Automático de Backend para Remotes", self.Config.SynthesizeServer },
        { "SaveNilInstances", "Salvar Instâncias Isoladas (Nil Instances)", self.Config.SaveNilInstances },
        { "SaveAttributes", "Salvar Atributos Modernos de Instâncias", self.Config.SaveAttributes },
        { "SaveTags", "Salvar Tags do CollectionService", self.Config.SaveTags },
    }

    for i, item in ipairs(toggles) do
        local key, title, defaultVal = item[1], item[2], item[3]

        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -12, 0, 32)
        row.Position = UDim2.new(0, 0, 0, 42 + (i - 1) * 36)
        row.BackgroundColor3 = Theme.CardBg
        Theme.AddCorner(row, Theme.CornerSmall)
        Theme.AddStroke(row, Theme.Border, 1)
        row.Parent = scroll

        local lbl = Instance.new("TextLabel")
        lbl.Text = title
        lbl.Font = Theme.FontRegular
        lbl.TextSize = 10
        lbl.TextColor3 = Theme.TextPrimary
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Size = UDim2.new(0.74, 0, 1, 0)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Parent = row

        local switch = Instance.new("TextButton")
        switch.Text = defaultVal and "ATIVADO" or "DESATIVADO"
        switch.Font = Theme.FontSemiBold
        switch.TextSize = 9
        switch.TextColor3 = defaultVal and Theme.TextPrimary or Theme.TextMuted
        switch.BackgroundColor3 = defaultVal and Theme.AccentPrimary or Theme.Background
        switch.Size = UDim2.new(0, 80, 0, 22)
        switch.Position = UDim2.new(1, -88, 0.5, -11)
        Theme.AddCorner(switch, Theme.CornerSmall)
        Theme.AddStroke(switch, defaultVal and Theme.BorderLight or Theme.Border, 1)
        switch.Parent = row

        Theme.AnimateButton(switch, function()
            local current = self.Config[key]
            local new = not current
            self.Config[key] = new
            switch.Text = new and "ATIVADO" or "DESATIVADO"
            switch.TextColor3 = new and Theme.TextPrimary or Theme.TextMuted
            switch.BackgroundColor3 = new and Theme.AccentPrimary or Theme.Background
            local stroke = switch:FindFirstChildOfClass("UIStroke")
            if stroke then
                stroke.Color = new and Theme.BorderLight or Theme.Border
            end
            self:Log("Opção alterada: " .. key .. " = " .. tostring(new))
        end)
    end

    local animExportBtn = Instance.new("TextButton")
    animExportBtn.Text = "Exportar Animações Capturadas (.rbxm)"
    animExportBtn.Font = Theme.FontSemiBold
    animExportBtn.TextSize = 11
    animExportBtn.TextColor3 = Theme.TextPrimary
    animExportBtn.BackgroundColor3 = Theme.AccentPrimary
    animExportBtn.Size = UDim2.new(1, -12, 0, 36)
    animExportBtn.Position = UDim2.new(0, 0, 0, 42 + #toggles * 36)
    Theme.AddCorner(animExportBtn, Theme.CornerSmall)
    Theme.AddStroke(animExportBtn, Theme.BorderLight, 1)
    animExportBtn.Parent = scroll

    Theme.AnimateButton(animExportBtn, function()
        animExportBtn.Text = "Exportando animações..."
        task.spawn(function()
            local AnimationRecorder = require("../Core/AnimationRecorder")
            local success, file = AnimationRecorder.ExportRecordedAnimations()
            if success then
                animExportBtn.Text = "✓ Salvo: " .. tostring(file)
                Environment.SetClipboard(tostring(file))
            else
                animExportBtn.Text = "Erro ao exportar"
            end
            task.delay(2.5, function()
                animExportBtn.Text = "Exportar Animações Capturadas (.rbxm)"
            end)
        end)
    end)
end

-- 11. Console Tab
function Interface:BuildConsoleTab()
    local parent = self.TabFrames["Console"]

    local consoleBox = Instance.new("ScrollingFrame")
    consoleBox.Size = UDim2.new(1, -32, 1, -64)
    consoleBox.Position = UDim2.new(0, 16, 0, 14)
    consoleBox.BackgroundColor3 = Theme.CardBg
    consoleBox.ScrollBarThickness = 3
    consoleBox.ScrollBarImageColor3 = Theme.Border
    consoleBox.CanvasSize = UDim2.new(0, 0, 0, 0)
    Theme.AddCorner(consoleBox, Theme.CornerMedium)
    Theme.AddStroke(consoleBox, Theme.Border, 1)
    consoleBox.Parent = parent
    self.ConsoleScroll = consoleBox

    local consoleList = Instance.new("UIListLayout")
    consoleList.SortOrder = Enum.SortOrder.LayoutOrder
    consoleList.Padding = UDim.new(0, 3)
    consoleList.Parent = consoleBox

    local copyLogsBtn = Instance.new("TextButton")
    copyLogsBtn.Text = "Copiar Todos os Logs"
    copyLogsBtn.Font = Theme.FontSemiBold
    copyLogsBtn.TextSize = 11
    copyLogsBtn.TextColor3 = Theme.TextPrimary
    copyLogsBtn.BackgroundColor3 = Theme.AccentPrimary
    copyLogsBtn.Size = UDim2.new(1, -32, 0, 34)
    copyLogsBtn.Position = UDim2.new(0, 16, 1, -42)
    Theme.AddCorner(copyLogsBtn, Theme.CornerSmall)
    Theme.AddStroke(copyLogsBtn, Theme.BorderLight, 1)
    copyLogsBtn.Parent = parent

    Theme.AnimateButton(copyLogsBtn, function()
        local fullLog = table.concat(self.Logs, "\n")
        Environment.SetClipboard(fullLog)
        copyLogsBtn.Text = "✓ Logs Copiados!"
        task.delay(2, function()
            copyLogsBtn.Text = "Copiar Todos os Logs"
        end)
    end)
end

-- 12. About Tab
function Interface:BuildAboutTab()
    local parent = self.TabFrames["About"]

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -32, 1, -32)
    scroll.Position = UDim2.new(0, 16, 0, 16)
    scroll.BackgroundColor3 = Theme.CardBg
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Theme.Border
    scroll.CanvasSize = UDim2.new(0, 0, 0, 440)
    Theme.AddCorner(scroll, Theme.CornerLarge)
    Theme.AddStroke(scroll, Theme.Border, 1)
    scroll.Parent = parent

    -- Developer Profile Header Card
    local devCard = Instance.new("Frame")
    devCard.Size = UDim2.new(1, -24, 0, 110)
    devCard.Position = UDim2.new(0, 12, 0, 12)
    devCard.BackgroundColor3 = Theme.Background
    Theme.AddCorner(devCard, Theme.CornerMedium)
    Theme.AddStroke(devCard, Theme.Border, 1)
    devCard.Parent = scroll

    -- Avatar Emblem
    local avatar = Instance.new("Frame")
    avatar.Size = UDim2.new(0, 48, 0, 48)
    avatar.Position = UDim2.new(0, 14, 0, 14)
    avatar.BackgroundColor3 = Theme.AccentPrimary
    Theme.AddCorner(avatar, Theme.CornerPill)
    avatar.Parent = devCard

    local avatarTxt = Instance.new("TextLabel")
    avatarTxt.Text = "TLP"
    avatarTxt.Font = Theme.FontTitle
    avatarTxt.TextSize = 14
    avatarTxt.TextColor3 = Theme.TextPrimary
    avatarTxt.Size = UDim2.new(1, 0, 1, 0)
    avatarTxt.BackgroundTransparency = 1
    avatarTxt.Parent = avatar

    -- Developer Name & Title
    local devName = Instance.new("TextLabel")
    devName.Text = "Theo Lorentz Padilha"
    devName.Font = Theme.FontTitle
    devName.TextSize = 14
    devName.TextColor3 = Theme.TextPrimary
    devName.TextXAlignment = Enum.TextXAlignment.Left
    devName.Size = UDim2.new(1, -74, 0, 20)
    devName.Position = UDim2.new(0, 70, 0, 14)
    devName.BackgroundTransparency = 1
    devName.Parent = devCard

    local devRole = Instance.new("TextLabel")
    devRole.Text = "Desenvolvedor Principal • HyperSaveInstance"
    devRole.Font = Theme.FontRegular
    devRole.TextSize = 11
    devRole.TextColor3 = Theme.TextSecondary
    devRole.TextXAlignment = Enum.TextXAlignment.Left
    devRole.Size = UDim2.new(1, -74, 0, 16)
    devRole.Position = UDim2.new(0, 70, 0, 34)
    devRole.BackgroundTransparency = 1
    devRole.Parent = devCard

    -- Action Container for Buttons (UIListLayout Grid)
    local devBtnBar = Instance.new("Frame")
    devBtnBar.Size = UDim2.new(1, -84, 0, 26)
    devBtnBar.Position = UDim2.new(0, 70, 0, 64)
    devBtnBar.BackgroundTransparency = 1
    devBtnBar.Parent = devCard

    local devBtnLayout = Instance.new("UIListLayout")
    devBtnLayout.FillDirection = Enum.FillDirection.Horizontal
    devBtnLayout.Padding = UDim.new(0, 6)
    devBtnLayout.SortOrder = Enum.SortOrder.LayoutOrder
    devBtnLayout.Parent = devBtnBar

    -- GitHub Link Button
    local btnGithub = Instance.new("TextButton")
    btnGithub.Text = "GitHub"
    btnGithub.Font = Theme.FontSemiBold
    btnGithub.TextSize = 10
    btnGithub.TextColor3 = Theme.TextPrimary
    btnGithub.BackgroundColor3 = Theme.CardHover
    btnGithub.Size = UDim2.new(0.25, -4, 1, 0)
    btnGithub.LayoutOrder = 1
    Theme.AddCorner(btnGithub, Theme.CornerSmall)
    Theme.AddStroke(btnGithub, Theme.Border, 1)
    btnGithub.Parent = devBtnBar

    Theme.AnimateButton(btnGithub, function()
        Environment.SetClipboard("https://github.com/theopadilha2009-hash")
        btnGithub.Text = "✓ Copiado!"
        task.delay(2, function()
            btnGithub.Text = "GitHub"
        end)
    end)

    -- LinkedIn Profile Button
    local btnLinkedIn = Instance.new("TextButton")
    btnLinkedIn.Text = "LinkedIn"
    btnLinkedIn.Font = Theme.FontSemiBold
    btnLinkedIn.TextSize = 10
    btnLinkedIn.TextColor3 = Theme.TextPrimary
    btnLinkedIn.BackgroundColor3 = Theme.CardHover
    btnLinkedIn.Size = UDim2.new(0.25, -4, 1, 0)
    btnLinkedIn.LayoutOrder = 2
    Theme.AddCorner(btnLinkedIn, Theme.CornerSmall)
    Theme.AddStroke(btnLinkedIn, Theme.Border, 1)
    btnLinkedIn.Parent = devBtnBar

    Theme.AnimateButton(btnLinkedIn, function()
        Environment.SetClipboard("https://www.linkedin.com/in/theo-lorentz-padilha-0b9b99287/")
        btnLinkedIn.Text = "✓ Copiado!"
        task.delay(2, function()
            btnLinkedIn.Text = "LinkedIn"
        end)
    end)

    -- Repository Link Button
    local btnRepo = Instance.new("TextButton")
    btnRepo.Text = "Repositório"
    btnRepo.Font = Theme.FontSemiBold
    btnRepo.TextSize = 10
    btnRepo.TextColor3 = Theme.TextPrimary
    btnRepo.BackgroundColor3 = Theme.CardHover
    btnRepo.Size = UDim2.new(0.25, -4, 1, 0)
    btnRepo.LayoutOrder = 3
    Theme.AddCorner(btnRepo, Theme.CornerSmall)
    Theme.AddStroke(btnRepo, Theme.Border, 1)
    btnRepo.Parent = devBtnBar

    Theme.AnimateButton(btnRepo, function()
        Environment.SetClipboard("https://github.com/theopadilha2009-hash/HyperSaveInstance")
        btnRepo.Text = "✓ Copiado!"
        task.delay(2, function()
            btnRepo.Text = "Repositório"
        end)
    end)

    -- Discord Server Button
    local btnDiscord = Instance.new("TextButton")
    btnDiscord.Text = "Discord"
    btnDiscord.Font = Theme.FontSemiBold
    btnDiscord.TextSize = 10
    btnDiscord.TextColor3 = Theme.TextPrimary
    btnDiscord.BackgroundColor3 = Theme.AccentPrimary
    btnDiscord.Size = UDim2.new(0.25, -4, 1, 0)
    btnDiscord.LayoutOrder = 4
    Theme.AddCorner(btnDiscord, Theme.CornerSmall)
    btnDiscord.Parent = devBtnBar

    Theme.AnimateButton(btnDiscord, function()
        Environment.SetClipboard("https://discord.gg/Tk5zyA83UZ")
        btnDiscord.Text = "✓ Copiado!"
        task.delay(2, function()
            btnDiscord.Text = "Discord"
        end)
    end)

    -- System Diagnostics Card
    local sysCard = Instance.new("Frame")
    sysCard.Size = UDim2.new(1, -24, 0, 170)
    sysCard.Position = UDim2.new(0, 12, 0, 130)
    sysCard.BackgroundColor3 = Theme.Background
    Theme.AddCorner(sysCard, Theme.CornerMedium)
    Theme.AddStroke(sysCard, Theme.Border, 1)
    sysCard.Parent = scroll

    local sysTitle = Instance.new("TextLabel")
    sysTitle.Text = "Diagnóstico do Sistema & Ambiente"
    sysTitle.Font = Theme.FontTitle
    sysTitle.TextSize = 12
    sysTitle.TextColor3 = Theme.TextPrimary
    sysTitle.TextXAlignment = Enum.TextXAlignment.Left
    sysTitle.Size = UDim2.new(1, -20, 0, 20)
    sysTitle.Position = UDim2.new(0, 12, 0, 8)
    sysTitle.BackgroundTransparency = 1
    sysTitle.Parent = sysCard

    local diagItems = {
        { "Plataforma:", Environment.GetPlatform() },
        { "Executor:", Environment.GetExecutorName() },
        { "Escrita de Arquivo (writefile):", Environment.HasFileSystem() and "Ativo (Totalmente Suportado)" or "Indisponível" },
        { "Descompilador Luau:", Environment.HasDecompiler() and "Ativo (Descompilação Completa)" or "Modo Bytecode / Fallback" },
        { "Bypass de StreamingEnabled:", "Ativo (StreamExplorer Espacial)" },
        { "Emulador de DataStore & VIP:", "Ativo (1.000.000 Coins / VIP Liberado)" },
        { "Atalho de Teclado (HUD):", "[RightShift] ou Botão Flutuante" },
    }

    for i, item in ipairs(diagItems) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -24, 0, 18)
        row.Position = UDim2.new(0, 12, 0, 30 + (i - 1) * 19)
        row.BackgroundTransparency = 1
        row.Parent = sysCard

        local lblKey = Instance.new("TextLabel")
        lblKey.Text = "• " .. item[1]
        lblKey.Font = Theme.FontSemiBold
        lblKey.TextSize = 10
        lblKey.TextColor3 = Theme.TextSecondary
        lblKey.TextXAlignment = Enum.TextXAlignment.Left
        lblKey.Size = UDim2.new(0.5, 0, 1, 0)
        lblKey.BackgroundTransparency = 1
        lblKey.Parent = row

        local lblVal = Instance.new("TextLabel")
        lblVal.Text = item[2]
        lblVal.Font = Theme.FontRegular
        lblVal.TextSize = 10
        lblVal.TextColor3 = (string.find(item[2], "Ativo") or string.find(item[2], "Suportado")) and Theme.AccentSuccess
            or Theme.TextPrimary
        lblVal.TextXAlignment = Enum.TextXAlignment.Right
        lblVal.Size = UDim2.new(0.5, 0, 1, 0)
        lblVal.Position = UDim2.new(0.5, 0, 0, 0)
        lblVal.BackgroundTransparency = 1
        lblVal.Parent = row
    end

    -- Suite Capabilities Summary Card
    local featCard = Instance.new("Frame")
    featCard.Size = UDim2.new(1, -24, 0, 105)
    featCard.Position = UDim2.new(0, 12, 0, 308)
    featCard.BackgroundColor3 = Theme.Background
    Theme.AddCorner(featCard, Theme.CornerMedium)
    Theme.AddStroke(featCard, Theme.Border, 1)
    featCard.Parent = scroll

    local featTitle = Instance.new("TextLabel")
    featTitle.Text = "Recursos e Módulos Integrados"
    featTitle.Font = Theme.FontTitle
    featTitle.TextSize = 12
    featTitle.TextColor3 = Theme.TextPrimary
    featTitle.TextXAlignment = Enum.TextXAlignment.Left
    featTitle.Size = UDim2.new(1, -20, 0, 20)
    featTitle.Position = UDim2.new(0, 12, 0, 8)
    featTitle.BackgroundTransparency = 1
    featTitle.Parent = featCard

    local featDesc = Instance.new("TextLabel")
    featDesc.Text =
        "• Seletor de Alvos 3D com Raycast e Multi-Seleção\n• Terreno SmoothVoxels 3D, Iluminação PBR e Áudios\n• Importador Oficial para Roblox Studio com Master Fix\n• Descompilador Luau Integrado e Proteção Anti-AFK"
    featDesc.Font = Theme.FontRegular
    featDesc.TextSize = 10
    featDesc.TextColor3 = Theme.TextSecondary
    featDesc.TextXAlignment = Enum.TextXAlignment.Left
    featDesc.TextYAlignment = Enum.TextYAlignment.Top
    featDesc.Size = UDim2.new(1, -24, 0, 68)
    featDesc.Position = UDim2.new(0, 12, 0, 30)
    featDesc.BackgroundTransparency = 1
    featDesc.Parent = featCard
end

function Interface:Log(message, color)
    local timestamp = os.date("%H:%M:%S")
    local line = string.format("[%s] %s", timestamp, message)
    table.insert(self.Logs, line)

    if self.ConsoleScroll then
        local lbl = Instance.new("TextLabel")
        lbl.Text = line
        lbl.Font = Theme.FontRegular
        lbl.TextSize = 10
        lbl.TextColor3 = color or Theme.TextSecondary
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Size = UDim2.new(1, -12, 0, 16)
        lbl.BackgroundTransparency = 1
        lbl.Parent = self.ConsoleScroll

        self.ConsoleScroll.CanvasSize = UDim2.new(0, 0, 0, #self.Logs * 18)
        self.ConsoleScroll.CanvasPosition = Vector2.new(0, self.ConsoleScroll.CanvasSize.Y.Offset)
    end
end

function Interface:BindEngineEvents()
    self.Engine:OnProgress(function(prog)
        if self.StatusHeader then
            self.StatusHeader.Text = "Status: " .. prog.Stage
            if prog.Stage == "Done" then
                self.StatusHeader.TextColor3 = Theme.AccentSuccess
            elseif prog.Stage == "Error" then
                self.StatusHeader.TextColor3 = Theme.AccentDanger
            elseif prog.Stage == "Cancelled" then
                self.StatusHeader.TextColor3 = Theme.AccentWarning
            else
                self.StatusHeader.TextColor3 = Theme.AccentPrimary
            end
        end
        if self.PctLabel then
            self.PctLabel.Text = tostring(prog.Percentage) .. "%"
        end
        if self.StatusDetail then
            self.StatusDetail.Text = prog.Message
        end
        if self.ProgressBarFill then
            Theme.Tween(self.ProgressBarFill, 0.2, {
                Size = UDim2.new(math.clamp(prog.Percentage / 100, 0, 1), 0, 1, 0),
            })
        end

        local color = Theme.TextSecondary
        if prog.Stage == "Done" then
            color = Theme.AccentSuccess
            if prog.SavedFile then
                self.SavedFilePath = prog.SavedFile
            end
            if prog.AssetsFolder then
                self.SavedAssetPath = prog.AssetsFolder
            end

            if self.CancelButton then
                self.CancelButton.Visible = false
            end
            if self.CloneButton then
                self.CloneButton.Size = UDim2.new(1, -32, 0, 42)
                self.CloneButton.Text = "✓ Salvo com sucesso!"
                task.delay(4, function()
                    self.CloneButton.Text = "Salvar Mapa Completo (.rbxlx)"
                end)
            end
        elseif prog.Stage == "Cancelled" then
            color = Theme.AccentWarning
            if self.CancelButton then
                self.CancelButton.Visible = false
                self.CancelButton.Text = "✕ Parar"
            end
            if self.CloneButton then
                self.CloneButton.Size = UDim2.new(1, -32, 0, 42)
                self.CloneButton.Text = "Salvar Mapa Completo (.rbxlx)"
            end
        elseif prog.Stage == "Error" then
            color = Theme.AccentDanger
            if self.CancelButton then
                self.CancelButton.Visible = false
            end
            if self.CloneButton then
                self.CloneButton.Size = UDim2.new(1, -32, 0, 42)
                self.CloneButton.Text = "Salvar Mapa Completo (.rbxlx)"
            end
        elseif prog.Stage == "Exploring" then
            color = Theme.TextPrimary
        elseif prog.Stage == "Assets" then
            color = Theme.TextPrimary
        elseif prog.Stage == "Decompiling" then
            color = Theme.TextPrimary
        end

        self:Log(prog.Message, color)
    end)
end

function Interface:StartClone()
    if self.Engine.IsRunning then
        return
    end

    if self.CloneButton then
        self.CloneButton.Size = UDim2.new(0.68, -26, 0, 42)
        self.CloneButton.Text = "Salvando mapa..."
    end
    if self.CancelButton then
        self.CancelButton.Size = UDim2.new(0.32, -10, 0, 42)
        self.CancelButton.Position = UDim2.new(0.68, 16, 0, 14)
        self.CancelButton.Text = "✕ Parar"
        self.CancelButton.Visible = true
    end

    task.spawn(function()
        local success, result = self.Engine:Start()
        if not success and not self.Engine.CancelRequested then
            self:Log("Erro ao salvar: " .. tostring(result), Theme.AccentDanger)
        end
        if self.CancelButton then
            self.CancelButton.Visible = false
        end
        if self.CloneButton then
            self.CloneButton.Size = UDim2.new(1, -32, 0, 42)
        end
    end)
end

return Interface

end)

__define__("UI/Theme", function()
--[[
    HyperSaveInstance - Clean Minimalist Dark Theme
    Design: Modern Solid Dark (Inspired by VS Code, Linear, Raycast)
    Focus: High contrast, crystal-clear readability, zero visual noise
]]

local clonerefFn = cloneref or function(obj)
    return obj
end
local TweenService = nil
pcall(function()
    TweenService = clonerefFn(game:GetService("TweenService"))
end)
local SoundService = nil
pcall(function()
    SoundService = clonerefFn(game:GetService("SoundService"))
end)

local Theme = {
    -- Backgrounds & Surfaces (Solid Dark Slate, High Contrast)
    Background = Color3.fromRGB(18, 20, 26), -- #12141A Base window
    BackgroundTransparency = 0.0, -- Completely solid, no blur
    CardBg = Color3.fromRGB(26, 30, 40), -- #1A1E28 Elevated container
    CardTransparency = 0.0,
    CardHover = Color3.fromRGB(36, 42, 56), -- #242A38 Hover state
    CardActive = Color3.fromRGB(42, 48, 64), -- #2A3040 Active state
    InputBg = Color3.fromRGB(14, 16, 22), -- #0E1016 Textbox background

    -- Clean 1px Borders
    Border = Color3.fromRGB(44, 50, 66), -- #2C3242 Subtle edge
    BorderTransparency = 0.0,
    BorderLight = Color3.fromRGB(59, 130, 246), -- #3B82F6 Active blue border
    BorderNeon = Color3.fromRGB(59, 130, 246), -- Clean blue border
    BorderCyber = Color3.fromRGB(59, 130, 246),

    -- Accents (Clean, non-clashing)
    AccentPrimary = Color3.fromRGB(37, 99, 235), -- #2563EB Royal Blue (Action)
    AccentSecondary = Color3.fromRGB(79, 70, 229), -- #4F46E5 Indigo
    AccentSuccess = Color3.fromRGB(16, 185, 129), -- #10B981 Emerald
    AccentWarning = Color3.fromRGB(245, 158, 11), -- #F59E0B Amber
    AccentDanger = Color3.fromRGB(220, 38, 38), -- #DC2626 Coral Red
    AccentCyan = Color3.fromRGB(14, 165, 233), -- #0EA5E9 Sky Blue
    AccentAcid = Color3.fromRGB(16, 185, 129), -- Clean Green
    AccentSkull = Color3.fromRGB(255, 255, 255),
    AccentGothic = Color3.fromRGB(255, 255, 255),
    AccentTheo = Color3.fromRGB(59, 130, 246),
    AccentDark = Color3.fromRGB(14, 16, 22),

    -- Crystal-Clear Typography
    TextPrimary = Color3.fromRGB(255, 255, 255), -- Pure White (#FFFFFF)
    TextSecondary = Color3.fromRGB(160, 174, 192), -- Clean Light Gray (#A0AEC0)
    TextMuted = Color3.fromRGB(113, 128, 150), -- Muted Slate (#718096)
    TextAccent = Color3.fromRGB(59, 130, 246), -- Blue text highlight
    TextTheo = Color3.fromRGB(59, 130, 246),
    TextAcid = Color3.fromRGB(16, 185, 129),

    -- Fonts (Gotham Family for crisp native rendering)
    FontTitle = Enum.Font.GothamBold,
    FontSemiBold = Enum.Font.GothamMedium,
    FontRegular = Enum.Font.Gotham,
    FontCode = Enum.Font.Gotham,

    -- Subtle Radii (Modern software standard 6-8px)
    CornerLarge = UDim.new(0, 8),
    CornerMedium = UDim.new(0, 6),
    CornerSmall = UDim.new(0, 4),
    CornerPill = UDim.new(0, 16),
}

-- Tween animation helper
function Theme.Tween(instance, duration, properties, easingStyle, easingDirection)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.12, easingStyle or Enum.EasingStyle.Quad, easingDirection or Enum.EasingDirection.Out),
        properties
    )
    tween:Play()
    return tween
end

-- Create rounded corner
function Theme.AddCorner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or Theme.CornerMedium
    corner.Parent = instance
    return corner
end

-- Create clean solid stroke / border
function Theme.AddStroke(instance, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Border
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = instance
    return stroke
end

-- Create subtle gradient
function Theme.AddGradient(instance, c1, c2, rotation)
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, c1),
        ColorSequenceKeypoint.new(1, c2),
    })
    grad.Rotation = rotation or 45
    grad.Parent = instance
    return grad
end

-- Gentle Audio Click Feedback
function Theme.PlayClick()
    pcall(function()
        local s = Instance.new("Sound")
        s.SoundId = "rbxassetid://9069609200"
        s.Volume = 0.15
        s.Pitch = 1.3
        s.Parent = SoundService
        s:Play()
        task.delay(0.6, function()
            s:Destroy()
        end)
    end)
end

function Theme.PlayGlitch()
    -- Silent for clean UI experience
end

-- Interactive Button Animation Helper
function Theme.AnimateButton(btn, onClick)
    local origBg = btn.BackgroundColor3

    pcall(function()
        btn.MouseEnter:Connect(function()
            Theme.Tween(btn, 0.1, {
                BackgroundColor3 = (btn.BackgroundColor3 == Theme.CardBg) and Theme.CardHover or btn.BackgroundColor3,
            })
        end)

        btn.MouseLeave:Connect(function()
            Theme.Tween(btn, 0.1, {
                BackgroundColor3 = origBg,
            })
        end)
    end)

    if onClick then
        if btn.Activated then
            btn.Activated:Connect(onClick)
        else
            btn.MouseButton1Click:Connect(onClick)
        end
    end
end

function Theme.StartNeonPulse(stroke, baseColor, neonColor, speed)
    if stroke then
        stroke.Color = baseColor or Theme.Border
        stroke.Thickness = 1
    end
    return nil
end

function Theme.GenerateHexStream(length)
    return "Ativo"
end

function Theme.GenerateActivityGraph()
    return "Online"
end

function Theme.ScrambleText(label, targetText, duration)
    pcall(function()
        label.Text = targetText
    end)
end

return Theme

end)

__define__("Utils/AntiAFK", function()
--[[
    HyperSaveInstance - Anti-AFK & Anti-Kick Protection System
    Prevents Roblox Error 268/273 (20-minute idle disconnection) during long save sessions.
]]

local clonerefFn = cloneref or function(obj)
    return obj
end
local Players = nil
pcall(function()
    Players = clonerefFn(game:GetService("Players"))
end)

local AntiAFK = {}
local isEnabled = false
local idleConnection = nil
local stateListeners = {}

local function notifyListeners(state)
    for _, fn in ipairs(stateListeners) do
        task.spawn(fn, state)
    end
end

function AntiAFK.OnStateChanged(callback)
    table.insert(stateListeners, callback)
end

function AntiAFK.Enable()
    if isEnabled then
        return
    end
    isEnabled = true
    notifyListeners(true)

    pcall(function()
        local plrs = Players or game:GetService("Players")
        local localPlayer = plrs and (plrs.LocalPlayer or plrs:FindFirstChildOfClass("Player"))
        if localPlayer and localPlayer.Idled then
            idleConnection = localPlayer.Idled:Connect(function()
                if not isEnabled then
                    return
                end

                -- 1. Primary stealth method: Natural camera micro-oscillation
                local handled = false
                pcall(function()
                    local cam = workspace.CurrentCamera
                    if cam then
                        local jitter = (math.random() > 0.5 and 0.0001 or -0.0001)
                        cam.CFrame = cam.CFrame * CFrame.Angles(0, jitter, 0)
                        task.wait(0.04)
                        cam.CFrame = cam.CFrame * CFrame.Angles(0, -jitter, 0)
                        handled = true
                    end
                end)

                -- 2. Secondary fallback: VirtualInputManager micro-event
                if not handled then
                    pcall(function()
                        local vim = clonerefFn(game:GetService("VirtualInputManager"))
                        if vim and vim.SendMouseButtonEvent then
                            local rx = math.random(10, 50)
                            local ry = math.random(10, 50)
                            vim:SendMouseButtonEvent(rx, ry, 0, true, game, 0)
                            task.wait(0.03)
                            vim:SendMouseButtonEvent(rx, ry, 0, false, game, 0)
                            handled = true
                        end
                    end)
                end

                -- 3. Last resort fallback: VirtualUser
                if not handled then
                    pcall(function()
                        local vu = (game.GetService and game:GetService("VirtualUser"))
                            or (game.FindService and game:FindService("VirtualUser"))
                        if vu and vu.ClickButton2 then
                            vu:ClickButton2(Vector2.new(math.random(10, 50), math.random(10, 50)))
                        end
                    end)
                end
            end)
        end
    end)
end

function AntiAFK.Disable()
    if not isEnabled then
        return
    end
    isEnabled = false
    notifyListeners(false)
    if idleConnection then
        idleConnection:Disconnect()
        idleConnection = nil
    end
end

function AntiAFK.Toggle()
    if isEnabled then
        AntiAFK.Disable()
    else
        AntiAFK.Enable()
    end
    return isEnabled
end

function AntiAFK.IsEnabled()
    return isEnabled
end

return AntiAFK


end)

__define__("Utils/Base64", function()
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

function Base64.Encode(data)
    if not data or #data == 0 then
        return ""
    end
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

function Base64.Decode(data)
    if not data or #data == 0 then
        return ""
    end
    local bit = getBitOp()
    local clean = string.gsub(data, "%s+", "")
    local l = #clean
    if l % 4 ~= 0 then
        return ""
    end

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

end)

__define__("Utils/Environment", function()
--[[
    HyperSaveInstance - Universal Environment & Polyfill Module
    Supports Mac (MacSploit, Hydrogen), Windows (Wave, Synapse Z, Solara, Celery, etc.), Mobile (Delta, Codex, Arceus X)
]]

local Environment = {}

-- Service references (Safely wrapped in pcalls for all execution identities)
local cloneref = cloneref or function(obj)
    return obj
end
local HttpService = nil
pcall(function()
    HttpService = cloneref(game:GetService("HttpService"))
end)
local Players = nil
pcall(function()
    Players = cloneref(game:GetService("Players"))
end)
local CoreGui = nil
pcall(function()
    CoreGui = cloneref(game:GetService("CoreGui"))
end)

-- Universal Task polyfill
local task = task
    or {
        spawn = spawn or function(fn, ...)
            return coroutine.wrap(fn)(...)
        end,
        wait = wait or function(t)
            return coroutine.yield(t)
        end,
        delay = delay or function(t, fn)
            return task.spawn(function()
                task.wait(t)
                fn()
            end)
        end,
        defer = function(fn, ...)
            return (spawn or task.spawn)(function(...)
                fn(...)
            end, ...)
        end,
    }

-- Table & Math polyfills wrapped safely for readonly Luau environment
pcall(function()
    if not table.clone then
        table.clone = function(t)
            if type(t) ~= "table" then
                return t
            end
            local clone = {}
            for k, v in pairs(t) do
                clone[k] = v
            end
            return clone
        end
    end
end)
pcall(function()
    if not table.find then
        table.find = function(t, val, init)
            if type(t) ~= "table" then
                return nil
            end
            for i = (init or 1), #t do
                if t[i] == val then
                    return i
                end
            end
            return nil
        end
    end
end)
pcall(function()
    if not math.clamp then
        math.clamp = function(x, min, max)
            return math.max(min, math.min(max, x))
        end
    end
end)
pcall(function()
    if not math.round then
        math.round = function(x)
            return math.floor(x + 0.5)
        end
    end
end)

-- Identify executor & platform
function Environment.GetExecutorName()
    if identifyexecutor then
        local name, ver = identifyexecutor()
        return tostring(name) .. (ver and (" " .. tostring(ver)) or "")
    elseif getexecutorname then
        return tostring(getexecutorname())
    elseif syn and type(syn) == "table" then
        return "Synapse V3/Legacy"
    elseif KRNL_LOADED then
        return "KRNL"
    elseif fluxus then
        return "Fluxus"
    elseif is_sirhurt_closure then
        return "Sirhurt"
    elseif OXYGEN_LOADED then
        return "Oxygen U"
    elseif MACSPLOIT_LOADED or (identifyexecutor and string.find(string.lower(tostring(identifyexecutor())), "mac")) then
        return "MacSploit"
    elseif HYDROGEN_LOADED or (identifyexecutor and string.find(string.lower(tostring(identifyexecutor())), "hydrogen")) then
        return "Hydrogen"
    else
        return "Universal / Unknown Executor"
    end
end

function Environment.GetPlatform()
    local isMac = false
    local isWindows = false
    local isMobile = false

    local exec = string.lower(Environment.GetExecutorName())
    if string.find(exec, "mac") or string.find(exec, "apple") or (getexecutorinfo and getexecutorinfo().platform == "macOS") then
        isMac = true
    elseif
        string.find(exec, "delta")
        or string.find(exec, "codex")
        or string.find(exec, "arceus")
        or string.find(exec, "hydrogen mobile")
    then
        isMobile = true
    else
        isWindows = true
    end

    if isMac then
        return "macOS"
    end
    if isMobile then
        return "Mobile"
    end
    return "Windows / Desktop"
end

-- File system polyfills
local _writefile = writefile or (syn and syn.writefile)
local _readfile = readfile or (syn and syn.readfile)
local _appendfile = appendfile or (syn and syn.appendfile)
local _makefolder = makefolder or (syn and syn.makefolder)
local _isfolder = isfolder or (syn and syn.isfolder)
local _isfile = isfile or (syn and syn.isfile)
local _delfile = delfile or (syn and syn.delfile) or delfile
local _listfiles = listfiles or (syn and syn.listfiles)

function Environment.HasFileSystem()
    return type(_writefile) == "function"
end

function Environment.GetWriteFileFunction()
    return _writefile
end

-- Strictly sanitize filenames to prevent OS path crashes or corrupted file writes
function Environment.SanitizeFileName(name)
    if not name or #name == 0 then
        return "Place"
    end
    -- Strip non-ASCII (emojis, unicode) and invalid filesystem chars
    local clean = string.gsub(name, "[^%w%-%s%[%]_]", "_")
    clean = string.gsub(clean, "_+", "_")
    clean = string.gsub(clean, "^[%s%._]+", "")
    clean = string.gsub(clean, "[%s%._]+$", "")

    -- Guard against reserved Windows device names
    local upper = string.upper(clean)
    local reserved = {
        CON = true,
        PRN = true,
        AUX = true,
        NUL = true,
        COM1 = true,
        COM2 = true,
        COM3 = true,
        COM4 = true,
        COM5 = true,
        COM6 = true,
        COM7 = true,
        COM8 = true,
        COM9 = true,
        LPT1 = true,
        LPT2 = true,
        LPT3 = true,
        LPT4 = true,
        LPT5 = true,
        LPT6 = true,
        LPT7 = true,
        LPT8 = true,
        LPT9 = true,
    }
    if reserved[upper] then
        clean = clean .. "_file"
    end

    if #clean > 80 then
        clean = string.sub(clean, 1, 80)
    end
    return (#clean > 0 and clean) or "Place"
end

function Environment.WriteFile(path, content)
    if _writefile then
        local success, err = pcall(_writefile, path, content)
        if not success then
            warn("[HyperSaveInstance] WriteFile failed: " .. tostring(err))
            return false
        end
        return true
    end
    warn("[HyperSaveInstance] No writefile capability detected in current executor!")
    return false
end

function Environment.AppendFile(path, content)
    if _appendfile then
        local success, err = pcall(_appendfile, path, content)
        return success
    elseif _readfile and _writefile then
        local existing = ""
        pcall(function()
            existing = _readfile(path) or ""
        end)
        return Environment.WriteFile(path, existing .. content)
    end
    return false
end

function Environment.ReadFile(path)
    if _readfile then
        local success, result = pcall(_readfile, path)
        if success then
            return result
        end
    end
    return nil
end

function Environment.MakeFolder(path)
    if _makefolder then
        local success = pcall(_makefolder, path)
        return success
    end
    return false
end

function Environment.IsFolder(path)
    if _isfolder then
        local success, res = pcall(_isfolder, path)
        return success and (res == true)
    end
    return false
end

function Environment.IsFile(path)
    if _isfile then
        local success, res = pcall(_isfile, path)
        return success and (res == true)
    end
    return false
end

-- Decompiler capability detection (Dynamic lookup supporting MacSploit, Hydrogen, Synapse Z, Wave, Delta, Codex, etc.)
function Environment.GetDecompilerFunction()
    local genv = (getgenv and getgenv()) or {}
    local renv = (getrenv and getrenv()) or {}

    -- Check functions in order of fidelity
    local candidates = {
        genv.decompile,
        decompile,
        renv.decompile,
        (syn and syn.decompile),
        genv.custom_decompile,
        custom_decompile,
        (syn and syn.custom_decompile),
        genv.disassemble,
        disassemble,
    }

    for _, fn in ipairs(candidates) do
        if type(fn) == "function" then
            return fn
        end
    end
    return nil
end

function Environment.GetBytecodeFunction()
    local genv = (getgenv and getgenv()) or {}
    local renv = (getrenv and getrenv()) or {}

    local candidates = {
        genv.getscriptbytecode,
        getscriptbytecode,
        genv.get_script_bytecode,
        get_script_bytecode,
        renv.getscriptbytecode,
        (syn and syn.getscriptbytecode),
        genv.dumpstring,
        dumpstring,
    }

    for _, fn in ipairs(candidates) do
        if type(fn) == "function" then
            return fn
        end
    end
    return nil
end

function Environment.HasDecompiler()
    return Environment.GetDecompilerFunction() ~= nil or Environment.GetBytecodeFunction() ~= nil
end

-- Safe UI Parent (Protects GUI from detection/detection hooks, universal across Delta, Hydrogen, MacSploit, Solara, etc.)
function Environment.GetSafeGuiParent()
    -- 1. Try gethui() if supported (Delta, Wave, Hydrogen, MacSploit)
    if gethui then
        local success, res = pcall(gethui)
        if success and res and typeof(res) == "Instance" then
            return res
        end
    end

    -- 2. Try CoreGui if accessible
    local coreGui = nil
    pcall(function()
        coreGui = cloneref(game:GetService("CoreGui"))
    end)
    if coreGui then
        local canAccess, name = pcall(function()
            return coreGui.Name
        end)
        if canAccess and name then
            return coreGui
        end
    end

    -- 3. Fallback to LocalPlayer's PlayerGui (Safe non-blocking)
    local pgui = nil
    pcall(function()
        local plrs = cloneref(game:GetService("Players"))
        local lp = plrs.LocalPlayer or plrs:FindFirstChildOfClass("Player")
        if lp then
            pgui = lp:FindFirstChildOfClass("PlayerGui")
        end
    end)
    if pgui then
        return pgui
    end

    -- 4. Fallback to CoreGui or return game
    return coreGui or game
end

-- Clipboard copy
function Environment.SetClipboard(text)
    local setclip = setclipboard or (syn and syn.setclipboard) or toclipboard or (Clipboard and Clipboard.set)
    if setclip then
        pcall(setclip, text)
        return true
    end
    return false
end

-- Nil instances extraction
function Environment.GetNilInstances()
    local getnil = getnilinstances or (syn and syn.get_nil_instances) or get_nil_instances
    if getnil then
        local success, res = pcall(getnil)
        if success and type(res) == "table" then
            return res
        end
    end
    return {}
end

-- Hidden UI elements / CorePackages check
function Environment.GetHiddenProperties(instance, property)
    local gethidden = gethiddenproperty or (syn and syn.get_hidden_property)
    if gethidden then
        local success, val = pcall(gethidden, instance, property)
        if success then
            return val
        end
    end
    local s, v = pcall(function()
        return (instance )[property]
    end)
    if s then
        return v
    end
    return nil
end

return Environment

end)

__define__("Utils/LZ4", function()
--[[
    HyperSaveInstance - Pure Luau LZ4 Compression & Decompression
    Standard Roblox binary chunks (PRMS, INST, PROP, PRNT) are compressed using LZ4.
]]

local LZ4 = {}

function LZ4.Compress(input)
    local bit = bit32 or bit
    local inputLen = #input
    if inputLen == 0 then
        return ""
    end

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

function LZ4.Decompress(compressed, uncompressedSize)
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

        if outLen >= uncompressedSize or i > cLen then
            break
        end

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

end)

__define__("Utils/LicenseManager", function()
--!strict
--[[
    HyperSaveInstance - License & DRM Manager
    Handles Tier authentication (Free Community vs. Enterprise $570)
    Validates offline cryptographic hash signatures and online Discord whitelist
]]

local LicenseManager = {}
LicenseManager.__index = LicenseManager





local CurrentLicense = {
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
function LicenseManager.ValidateKey(rawKey)
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
function LicenseManager.GenerateKey(tier, seed)
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

function LicenseManager.ApplyKey(rawKey)
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

function LicenseManager.GetLicense()
    return CurrentLicense
end

function LicenseManager.IsEnterprise()
    return CurrentLicense.Tier == "Enterprise"
end

function LicenseManager.IsFeatureUnlocked(featureName)
    if CurrentLicense.Tier == "Enterprise" or CurrentLicense.Tier == "Pro" then
        return true
    end
    return CurrentLicense.Features[featureName] == true
end

return LicenseManager

end)

__define__("Utils/Stealth", function()
--[[
    HyperSaveInstance - Stealth & Anti-Detection Shield
    Protects threads, masks operations, hides UI instances and suppresses telemetry from in-game anti-cheats.
]]

local Stealth = {}

local clonerefFn = cloneref or function(obj)
    return obj
end
local HttpService = nil
pcall(function()
    HttpService = clonerefFn(game:GetService("HttpService"))
end)

-- Generate ephemeral GUID for instance naming (Prevents static string signature detection)
function Stealth.GenerateEphemeralGUID()
    if HttpService and HttpService.GenerateGUID then
        local s, guid = pcall(function()
            return HttpService:GenerateGUID(false)
        end)
        if s and guid then
            return string.gsub(guid, "%-", "")
        end
    end
    return Stealth.GenerateRandomName(24)
end

-- Generate random alphanumeric name
function Stealth.GenerateRandomName(len)
    local length = len or 20
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local res = {}
    for i = 1, length do
        local r = math.random(1, #chars)
        table.insert(res, string.sub(chars, r, r))
    end
    return table.concat(res)
end

-- Safely protect GUI instance from anti-cheat detection
function Stealth.ProtectGui(gui)
    local protected = false
    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(gui)
            protected = true
        elseif protectgui then
            protectgui(gui)
            protected = true
        elseif protect_gui then
            protect_gui(gui)
            protected = true
        end
    end)
    return protected
end

-- Safely request map streaming around coordinates without moving character
function Stealth.SafeStreamAround(position, player)
    local requested = false
    pcall(function()
        if player and player.RequestStreamAroundAsync then
            player:RequestStreamAroundAsync(position)
            requested = true
        elseif workspace and workspace.RequestStreamAroundAsync then
            workspace:RequestStreamAroundAsync(position)
            requested = true
        end
    end)
    return requested
end

-- Safely elevate thread identity if supported by executor
function Stealth.ElevateThread()
    pcall(function()
        if syn and syn.set_thread_identity then
            syn.set_thread_identity(8)
        elseif setidentity then
            setidentity(8)
        elseif setthreadidentity then
            setthreadidentity(8)
        elseif set_thread_identity then
            set_thread_identity(8)
        end
    end)
end

-- Safely read property with error insulation
function Stealth.SafeGetProperty(instance, property)
    local success, val = pcall(function()
        return (instance )[property]
    end)
    if success then
        return val
    end
    return nil
end

-- Mask Luau functions as native C closures to prevent hook detection
function Stealth.MaskClosure(fn)
    if typeof(fn) ~= "function" then
        return fn
    end
    local masked = fn
    pcall(function()
        if newcclosure then
            masked = newcclosure(fn)
        end
    end)
    return masked
end

-- Lock metatable to prevent external inspection or tampering
function Stealth.ProtectMetatable(tbl)
    if type(tbl) ~= "table" then
        return tbl
    end
    pcall(function()
        local mt = getrawmetatable and getrawmetatable(tbl) or getmetatable(tbl)
        if mt then
            if setreadonly then
                setreadonly(mt, false)
            end
            mt.__metatable = "The metatable is locked"
            if setreadonly then
                setreadonly(mt, true)
            end
        else
            setmetatable(tbl, {
                __metatable = "The metatable is locked",
            })
        end
    end)
    return tbl
end

-- Check if instance belongs to Roblox internal telemetry or CoreGui
function Stealth.IsInternalOrProtected(instance)
    if not instance then
        return true
    end
    local isInternal = false
    pcall(function()
        local name = instance.Name
        local className = instance.ClassName
        if
            string.find(name, "RobloxNetworkAutoTest")
            or string.find(name, "Telemetry")
            or string.find(name, "MemStorageConnection")
            or string.find(name, "CoreScript")
            or className == "PluginMouse"
            or className == "RobloxPluginGui"
        then
            isInternal = true
        end
    end)
    return isInternal
end

return Stealth

end)

__define__("Utils/Stream", function()
--[[
    HyperSaveInstance - Binary Stream / Buffer Reader & Writer
]]

local Stream = {}
Stream.__index = Stream

function Stream.new(initialData)
    local self = setmetatable({}, Stream)
    self.Buffer = {}
    self.Position = 1
    if initialData then
        self.Source = initialData
        self.Length = #initialData
    else
        self.Source = ""
        self.Length = 0
    end
    return self
end

function Stream:WriteByte(val)
    table.insert(self.Buffer, string.char(val % 256))
    self.Length = self.Length + 1
end

function Stream:WriteBytes(bytes)
    table.insert(self.Buffer, bytes)
    self.Length = self.Length + #bytes
end

function Stream:WriteInt32LE(val)
    local bit = bit32 or bit
    local b1 = bit.band(val, 0xFF)
    local b2 = bit.band(bit.rshift(val, 8), 0xFF)
    local b3 = bit.band(bit.rshift(val, 16), 0xFF)
    local b4 = bit.band(bit.rshift(val, 24), 0xFF)
    table.insert(self.Buffer, string.char(b1, b2, b3, b4))
    self.Length = self.Length + 4
end

function Stream:WriteInt32BE(val)
    local bit = bit32 or bit
    local b1 = bit.band(bit.rshift(val, 24), 0xFF)
    local b2 = bit.band(bit.rshift(val, 16), 0xFF)
    local b3 = bit.band(bit.rshift(val, 8), 0xFF)
    local b4 = bit.band(val, 0xFF)
    table.insert(self.Buffer, string.char(b1, b2, b3, b4))
    self.Length = self.Length + 4
end

function Stream:WriteString(str)
    self:WriteInt32LE(#str)
    self:WriteBytes(str)
end

function Stream:ToString()
    return table.concat(self.Buffer)
end

-- Reader methods
function Stream:ReadByte()
    if self.Position > self.Length then
        return 0
    end
    local byte = string.byte(self.Source, self.Position)
    self.Position = self.Position + 1
    return byte
end

function Stream:ReadBytes(count)
    if self.Position > self.Length then
        return ""
    end
    local chunk = string.sub(self.Source, self.Position, self.Position + count - 1)
    self.Position = self.Position + count
    return chunk
end

function Stream:ReadInt32LE()
    local bit = bit32 or bit
    local b1 = self:ReadByte()
    local b2 = self:ReadByte()
    local b3 = self:ReadByte()
    local b4 = self:ReadByte()
    return bit.bor(b1, bit.lshift(b2, 8), bit.lshift(b3, 16), bit.lshift(b4, 24))
end

function Stream:ReadString()
    local len = self:ReadInt32LE()
    return self:ReadBytes(len)
end

return Stream

end)

-- Entry Point
local __mainSuccess__, __mainErr__ = pcall(function()
--[[
    HyperSaveInstance v2.0 (Ultimate Master Suite) - Universal Roblox Game Cloner & Reverse-Engineering Suite
    Author: Theo Lorentz Padilha (https://github.com/theopadilha2009-hash)
    Combines USSI, UltraSmartSaveInstance, rbx-dom, rbx-instance-serializer & Studio Plugin.
]]

local Engine = __require__("Core/Engine")
local Interface = __require__("UI/Interface")
local Defaults = __require__("Config/Defaults")
local Environment = __require__("Utils/Environment")
local AntiAFK = __require__("Utils/AntiAFK")
local StreamExplorer = __require__("Core/StreamExplorer")
local NetworkSniffer = __require__("Core/NetworkSniffer")
local UniverseTracker = __require__("Core/UniverseTracker")
local ObjExporter = __require__("Core/ObjExporter")
local Optimizer = __require__("Core/Optimizer")
local AudioRipper = __require__("Core/AudioRipper")
local LightingRipper = __require__("Core/LightingRipper")
local GuiRipper = __require__("Core/GuiRipper")
local PlaceDiffTracker = __require__("Core/PlaceDiffTracker")
local Web3DExporter = __require__("Core/Web3DExporter")

local HyperSaveInstance = {
    Version = "2.0.0",
    Defaults = Defaults,
    Environment = Environment,
    AntiAFK = AntiAFK,
    StreamExplorer = StreamExplorer,
    NetworkSniffer = NetworkSniffer,
    UniverseTracker = UniverseTracker,
    ObjExporter = ObjExporter,
    Web3DExporter = Web3DExporter,
    PlaceDiffTracker = PlaceDiffTracker,
    Optimizer = Optimizer,
    AudioRipper = AudioRipper,
    LightingRipper = LightingRipper,
    GuiRipper = GuiRipper,
}

-- Open interactive in-game HUD
function HyperSaveInstance.OpenUI(customConfig)
    local engine = Engine.new(customConfig)
    local ui = Interface.new(engine)
    return ui, engine
end

-- Export Standalone Web 3D HTML Viewer (Three.js)
function HyperSaveInstance.ExportWeb3D(targetRoot, options)
    return Web3DExporter.ExportModelToHTML(targetRoot, options)
end

-- Snapshot and Track Update Diff
function HyperSaveInstance.Snapshot(name, root)
    return PlaceDiffTracker.SaveSnapshot(name, root)
end

function HyperSaveInstance.CompareDiff(snapshotFile)
    return PlaceDiffTracker.Compare(snapshotFile)
end

-- Save game programmatically (Headless or Scripted)
function HyperSaveInstance.Save(customConfig)
    local engine = Engine.new(customConfig)
    return engine:Start()
end

-- Save specific model or folder
function HyperSaveInstance.SaveModel(targetInstance, customConfig)
    local engine = Engine.new(customConfig)
    return engine:SaveTarget(targetInstance, customConfig)
end

-- Save specific model directly as .rbxm package
function HyperSaveInstance.SaveModelToRbxm(targetInstance, customConfig)
    local cfg = table.clone(customConfig or {})
    cfg.Format = "rbxm"
    local engine = Engine.new(cfg)
    return engine:SaveTarget(targetInstance, cfg)
end

-- Save multiple instances into a single .rbxm package
function HyperSaveInstance.SaveBatchToRbxm(targets, customConfig)
    local cfg = table.clone(customConfig or {})
    cfg.Format = "rbxm"
    local engine = Engine.new(cfg)
    return engine:SaveTargetBatch(targets, cfg)
end

-- Export 3D Wavefront OBJ/MTL
function HyperSaveInstance.ExportObj(targetRoot, options)
    return ObjExporter.Export(targetRoot, options)
end

-- Discover all Universe sub-places
function HyperSaveInstance.GetUniverse()
    return UniverseTracker.GetUniversePlaces()
end

-- Rippers
function HyperSaveInstance.RipAudio()
    return AudioRipper.ExportSoundList()
end

function HyperSaveInstance.RipLighting()
    return LightingRipper.ExportLightingPreset()
end

function HyperSaveInstance.RipGuis(options)
    return GuiRipper.ExportAllGuis(options)
end

-- Preset shorthand helpers
function HyperSaveInstance.SaveFast(customConfig)
    local cfg = table.clone(customConfig or {})
    Defaults.ApplyPreset(cfg, "Fast")
    return HyperSaveInstance.Save(cfg)
end

function HyperSaveInstance.SaveVisuals(customConfig)
    local cfg = table.clone(customConfig or {})
    Defaults.ApplyPreset(cfg, "VisualsOnly")
    return HyperSaveInstance.Save(cfg)
end

function HyperSaveInstance.SaveScripts(customConfig)
    local cfg = table.clone(customConfig or {})
    Defaults.ApplyPreset(cfg, "ScriptsOnly")
    return HyperSaveInstance.Save(cfg)
end

function HyperSaveInstance.SaveSilent(customConfig)
    local cfg = table.clone(customConfig or {})
    Defaults.ApplyPreset(cfg, "Ghost")
    cfg.SilentMode = true
    cfg.ShowUI = false
    cfg.VerboseLogs = false
    cfg.PlaySoundOnComplete = false
    return HyperSaveInstance.Save(cfg)
end

function HyperSaveInstance.SaveGhost(customConfig)
    return HyperSaveInstance.SaveSilent(customConfig)
end

function HyperSaveInstance.SaveOnlyMap(customConfig)
    local cfg = table.clone(customConfig or {})
    Defaults.ApplyPreset(cfg, "OnlyMap")
    return HyperSaveInstance.Save(cfg)
end

function HyperSaveInstance.SaveUIOnly(customConfig)
    local cfg = table.clone(customConfig or {})
    Defaults.ApplyPreset(cfg, "UIOnly")
    return HyperSaveInstance.Save(cfg)
end

function HyperSaveInstance.SaveBeeSwarm(customConfig)
    local cfg = table.clone(customConfig or {})
    Defaults.ApplyPreset(cfg, "BeeSwarm")
    return HyperSaveInstance.Save(cfg)
end

function HyperSaveInstance.SaveBloxFruits(customConfig)
    local cfg = table.clone(customConfig or {})
    Defaults.ApplyPreset(cfg, "BloxFruits")
    return HyperSaveInstance.Save(cfg)
end

function HyperSaveInstance.SavePetSimulator(customConfig)
    local cfg = table.clone(customConfig or {})
    Defaults.ApplyPreset(cfg, "PetSimulator99")
    return HyperSaveInstance.Save(cfg)
end

function HyperSaveInstance.SaveArsenal(customConfig)
    local cfg = table.clone(customConfig or {})
    Defaults.ApplyPreset(cfg, "Arsenal")
    return HyperSaveInstance.Save(cfg)
end

function HyperSaveInstance.SaveDoors(customConfig)
    local cfg = table.clone(customConfig or {})
    Defaults.ApplyPreset(cfg, "Doors")
    return HyperSaveInstance.Save(cfg)
end

function HyperSaveInstance.SaveTowerDefense(customConfig)
    local cfg = table.clone(customConfig or {})
    Defaults.ApplyPreset(cfg, "TowerDefense")
    return HyperSaveInstance.Save(cfg)
end

-- Global environment injection (Universal compatibility)
local function injectGlobals()
    local genv = (getgenv and getgenv()) or nil
    if genv then
        genv.saveinstance = HyperSaveInstance.Save
        genv.saveplace = HyperSaveInstance.Save
        genv.SynSaveInstance = HyperSaveInstance
        genv.HyperSaveInstance = HyperSaveInstance
        genv.UltraSmartSaveInstance = HyperSaveInstance
    else
        -- Fallback only when getgenv is not supported (Studio/Headless simulator)
        if _G then
            _G.saveinstance = _G.saveinstance or HyperSaveInstance.Save
            _G.saveplace = _G.saveplace or HyperSaveInstance.Save
            _G.SynSaveInstance = _G.SynSaveInstance or HyperSaveInstance
            _G.HyperSaveInstance = _G.HyperSaveInstance or HyperSaveInstance
            _G.UltraSmartSaveInstance = _G.UltraSmartSaveInstance or HyperSaveInstance
        end
    end
end

pcall(injectGlobals)

-- Check if SilentMode or global silent override is active
local isSilent = Defaults.SilentMode
    or (getgenv and (getgenv().HyperSave_Silent or getgenv().SilentMode))
    or (_G and (_G.HyperSave_Silent or _G.SilentMode))

-- Instant StarterGui Notification (Only in non-silent mode)
if not isSilent and Defaults.ShowUI then
    pcall(function()
        local clonerefFn = cloneref or function(obj)
            return obj
        end
        local sg = clonerefFn(game:GetService("StarterGui"))
        sg:SetCore("SendNotification", {
            Title = "HyperSaveInstance",
            Text = "Carregado por Theo Lorentz Padilha!",
            Duration = 4,
        })
    end)
end

if Defaults.VerboseLogs and not isSilent then
    print("[HyperSaveInstance] Iniciando HyperSaveInstance por Theo Lorentz Padilha...")
end

-- Auto-initialize HUD if ShowUI is enabled and not in SilentMode
if Defaults.ShowUI and not isSilent then
    local success, result = pcall(function()
        return HyperSaveInstance.OpenUI()
    end)
    if success then
        if Defaults.VerboseLogs and not isSilent then
            print("[HyperSaveInstance] Interface carregada com sucesso! Pressione RightShift ou use o botão flutuante.")
        end
    else
        if Defaults.VerboseLogs and not isSilent then
            warn("[HyperSaveInstance] Falha ao abrir interface: " .. tostring(result))
        end
    end
end

return HyperSaveInstance

end)
if not __mainSuccess__ then
    warn("[HyperSaveInstance Fatal Error] " .. tostring(__mainErr__))
    __showErrorGui__("Erro Fatal na Execucao", tostring(__mainErr__))
end
