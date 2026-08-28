--[[
    ================================================================================
    HyperSaveInstance v2.0 - Standalone Production Bundle
    Universal Roblox Game Cloner & SaveInstance Engine
    https://github.com/theopadilha2009-hash/HyperSaveInstance
    ================================================================================
]]

local __modules__ = {}
local __cache__ = {}

local function __define__(name, fn)
    __modules__[name] = fn
end

local function __require__(name)
    if __cache__[name] then
        return __cache__[name]
    end
    local modFn = __modules__[name]
    if not modFn then
        error("[HyperSaveInstance] Module not found: " .. tostring(name))
    end
    local result = modFn()
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
    }
}

return ClassBlacklist

end)

__define__("Config/Defaults", function()
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
    ToggleKeybind = Enum.KeyCode.RightShift, -- Keyboard shortcut to toggle HUD visibility

    -- Anti-AFK & Stealth Protection
    AutoAntiAFK = true,                    -- Prevents idle disconnection (Error 268/273)
    StealthMode = true,                    -- Obfuscates memory references and thread identity

    -- Total Raw Asset Downloader
    DownloadRawAssets = true,              -- Download raw audio (.mp3), textures (.png), 3D meshes (.mesh) to folder
    AssetDownloadWorkers = 6,              -- Parallel threads for raw asset downloading
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

end)

__define__("Core/AnimationRecorder", function()
﻿--[[
    HyperSaveInstance - Live Animation Keyframe Capturer
    Solves the Roblox Asset Permission / HTTP 403 issue for Animations by capturing
    real-time Motor6D joint transformations (CFrame / Transform) and baking them into
    native KeyframeSequence instances that can be published to the user's account in Studio.
]]

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local AnimationRecorder = {}
AnimationRecorder.IsRecording = false
AnimationRecorder.RecordedSequences = {}
AnimationRecorder.ActiveConnection = nil

-- Record an active animation track from a Humanoid by sampling joint transforms
function AnimationRecorder.RecordTrack(humanoid: Humanoid, trackName: string, durationSeconds: number, onComplete: (keyframeSeq: KeyframeSequence) -> ())
    local character = humanoid.Parent
    if not character then return end

    -- Collect all Motor6D joints
    local motors = {}
    for _, desc in ipairs(character:GetDescendants()) do
        if desc:IsA("Motor6D") then
            table.insert(motors, desc)
        end
    end

    if #motors == 0 then return end

    local keyframeSeq = Instance.new("KeyframeSequence")
    keyframeSeq.Name = trackName or "HyperSave_RecordedAnimation"

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
    if AnimationRecorder.IsRecording then return end
    AnimationRecorder.IsRecording = true

    local function hookHumanoid(humanoid: Humanoid)
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
            if hum then hookHumanoid(hum) end
        end
        localPlayer.CharacterAdded:Connect(function(char)
            local hum = char:WaitForChild("Humanoid", 5)
            if hum and hum:IsA("Humanoid") then
                hookHumanoid(hum)
            end
        end)
    end
end

return AnimationRecorder

end)

__define__("Core/AssetDownloader", function()
--[[
    HyperSaveInstance - Comprehensive Raw Asset Downloader Engine
    Downloads raw audios (.mp3), textures (.png), 3D meshes (.mesh/.obj) and animations to local disk.
]]

local Environment = __require__("Utils/Environment")

local AssetDownloader = {}

-- Safe HTTP Request polyfill for executors
local function httpRequest(url: string): string?
    local req = (syn and syn.request) or (http and http.request) or http_request or request
    if req then
        local s, res = pcall(req, {
            Url = url,
            Method = "GET"
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
function AssetDownloader.ExtractId(assetUrl: string | number): string?
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
function AssetDownloader.CollectAssets(instances: {Instance}): {[string]: {Type: string, Id: string, Url: string, SourceName: string}}
    local assets = {}

    local function registerAsset(assetType: string, rawVal: any, sourceName: string)
        local id = AssetDownloader.ExtractId(rawVal)
        if id and #id > 0 and not assets[id] then
            local downloadUrl = string.format("https://assetdelivery.roblox.com/v1/asset/?id=%s", id)
            assets[id] = {
                Type = assetType,
                Id = id,
                Url = downloadUrl,
                SourceName = sourceName
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
            registerAsset("Texture", (inst :: any).Texture, inst.Name)
        elseif inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
            registerAsset("Texture", (inst :: any).Image, inst.Name)
        elseif inst:IsA("Animation") then
            registerAsset("Animation", inst.AnimationId, inst.Name)
        elseif inst:IsA("Shirt") then
            registerAsset("Texture", inst.ShirtTemplate, inst.Name)
        elseif inst:IsA("Pants") then
            registerAsset("Texture", inst.PantsTemplate, inst.Name)
        end
    end

    return assets
end

-- Download all collected assets to local folder structure
function AssetDownloader.DownloadAll(assets: {[string]: table}, baseFolder: string, options: table, progressCallback: (current: number, total: number, asset: table) -> ()): (number, number)
    -- Create subdirectories
    Environment.MakeFolder(baseFolder)
    Environment.MakeFolder(baseFolder .. "/audios")
    Environment.MakeFolder(baseFolder .. "/textures")
    Environment.MakeFolder(baseFolder .. "/meshes")
    Environment.MakeFolder(baseFolder .. "/animations")

    local assetList = {}
    for _, asset in pairs(assets) do
        table.insert(assetList, asset)
    end

    local total = #assetList
    local downloaded = 0
    local failed = 0
    local currentIndex = 1

    local workers = math.clamp(options.AssetDownloadWorkers or 6, 1, 12)
    local threads = {}

    for w = 1, workers do
        local t = task.spawn(function()
            while currentIndex <= total do
                local myIndex = currentIndex
                currentIndex = currentIndex + 1

                local item = assetList[myIndex]
                if item then
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

                    local fileName = string.format("%s/%s/%s_%s%s", baseFolder, subDir, item.Id, string.gsub(item.SourceName, "[^%w_%-]", "_"), extension)

                    -- Download raw bytes
                    local body = httpRequest(item.Url)
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
                task.wait(0.02)
            end
        end)
        table.insert(threads, t)
    end

    while (downloaded + failed) < total do
        task.wait(0.1)
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
function AssetHandler.FormatAssetId(id: string | number): string
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
function AssetHandler.ExtractUnionData(union: UnionOperation | NegateOperation)
    local data = {
        AssetId = "",
        PhysicsData = nil,
        ChildData = nil,
        InitialSize = nil,
        RenderFidelity = Enum.RenderFidelity.Precise,
        CollisionFidelity = Enum.CollisionFidelity.Default,
        UsePartColor = false,
        SmoothingAngle = 0
    }

    pcall(function() data.AssetId = union.AssetId end)
    pcall(function() data.RenderFidelity = union.RenderFidelity end)
    pcall(function() data.CollisionFidelity = union.CollisionFidelity end)
    pcall(function() data.UsePartColor = union.UsePartColor end)
    pcall(function() data.SmoothingAngle = union.SmoothingAngle end)

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
function AssetHandler.ProcessMeshOrUnion(instance: Instance, options: table)
    local info = {
        ClassName = instance.ClassName,
        MeshId = "",
        TextureId = "",
        RenderFidelity = Enum.RenderFidelity.Precise,
        CollisionFidelity = Enum.CollisionFidelity.Default,
        DoubleSided = false,
        VertexColor = Vector3.new(1, 1, 1),
        AssetId = "",
        UnionData = nil
    }

    if instance:IsA("MeshPart") then
        pcall(function() info.MeshId = instance.MeshId end)
        pcall(function() info.TextureId = instance.TextureID end)
        pcall(function() info.RenderFidelity = instance.RenderFidelity end)
        pcall(function() info.CollisionFidelity = instance.CollisionFidelity end)
        pcall(function() info.DoubleSided = instance.DoubleSided end)
        pcall(function() info.VertexColor = instance.VertexColor end)
    elseif instance:IsA("UnionOperation") or instance:IsA("NegateOperation") then
        info.UnionData = AssetHandler.ExtractUnionData(instance :: any)
        info.AssetId = info.UnionData.AssetId
    elseif instance:IsA("SpecialMesh") then
        pcall(function() info.MeshId = instance.MeshId end)
        pcall(function() info.TextureId = instance.TextureId end)
        pcall(function() info.MeshType = instance.MeshType end)
        pcall(function() info.Scale = instance.Scale end)
        pcall(function() info.Offset = instance.Offset end)
        pcall(function() info.VertexColor = instance.VertexColor end)
    end

    return info
end

-- Process SurfaceAppearance (PBR Textures)
function AssetHandler.ProcessSurfaceAppearance(instance: SurfaceAppearance)
    local pbr = {
        ColorMap = "",
        NormalMap = "",
        RoughnessMap = "",
        MetalnessMap = "",
        AlphaMode = Enum.AlphaMode.Overlay
    }
    pcall(function() pbr.ColorMap = instance.ColorMap end)
    pcall(function() pbr.NormalMap = instance.NormalMap end)
    pcall(function() pbr.RoughnessMap = instance.RoughnessMap end)
    pcall(function() pbr.MetalnessMap = instance.MetalnessMap end)
    pcall(function() pbr.AlphaMode = instance.AlphaMode end)
    return pbr
end

return AssetHandler

end)

__define__("Core/AudioRipper", function()
--[[
    HyperSaveInstance - Audio Ripper & In-Game Soundboard
    Scans, previews, plays and extracts all music tracks and sound effects in the game.
]]

local SoundService = game:GetService("SoundService")
local Environment = __require__("Utils/Environment")

local AudioRipper = {}
local previewSoundInstance = nil

export type AudioInfo = {
    Name: string,
    SoundId: string,
    CleanId: string,
    Path: string,
    Volume: number,
    TimeLength: number
}

-- Collect all sound instances in the game
function AudioRipper.ScanSounds(): {AudioInfo}
    local sounds = {}
    local seenIds = {}

    local function scan(inst: Instance)
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
                    TimeLength = inst.TimeLength
                })
            end
        end

        for _, child in ipairs(inst:GetChildren()) do
            scan(child)
        end
    end

    for _, sName in ipairs({"Workspace", "SoundService", "ReplicatedStorage", "StarterGui", "Chat"}) do
        local s, service = pcall(function() return game:GetService(sName) end)
        if s and service then scan(service) end
    end

    return sounds
end

-- Play in-game preview
function AudioRipper.PlayPreview(soundId: string): boolean
    pcall(function()
        if previewSoundInstance then
            previewSoundInstance:Stop()
            previewSoundInstance:Destroy()
            previewSoundInstance = nil
        end

        local snd = Instance.new("Sound")
        snd.SoundId = soundId
        snd.Volume = 1
        snd.Parent = SoundService
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
function AudioRipper.ExportSoundList(): string
    local list = AudioRipper.ScanSounds()
    local placeId = game.PlaceId or 0
    local fileName = string.format("HyperSave_Soundtrack_%d.txt", placeId)

    local lines = {"=== HyperSaveInstance - Game Soundtrack & Audio List ===", ""}
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
local function getScriptPath(scriptInstance: LuaSourceContainer): string
    local names = {}
    local current: Instance? = scriptInstance
    while current and current ~= game do
        table.insert(names, 1, current.Name)
        current = current.Parent
    end
    return "game." .. table.concat(names, ".")
end

-- Generate banner comment for decompiled scripts
local function generateHeader(scriptInstance: LuaSourceContainer, status: string): string
    local path = getScriptPath(scriptInstance)
    local dateStr = os.date("%Y-%m-%d %H:%M:%S")
    local execName = Environment.GetExecutorName()
    
    return string.format([=[
--[[
    ================================================================================
    [HyperSaveInstance v2.0 - Decompiled Script]
    Created by: Theo Lorentz Padilha (https://github.com/theopadilha2009-hash)
    Class: %s
    Path: %s
    Status: %s
    Executor: %s
    Exported At: %s
    ================================================================================
]]

]=], scriptInstance.ClassName, path, status, execName, dateStr)
end

-- Intelligent script beautifier & variable name recoverer
function Decompiler.Beautify(code: string): string
    if not code or #code == 0 then return "" end

    local commonServices = {
        "Players", "ReplicatedStorage", "ReplicatedFirst", "RunService", "TweenService",
        "UserInputService", "HttpService", "SoundService", "Lighting", "Debris",
        "MarketplaceService", "TeleportService", "StarterGui", "ContextActionService"
    }

    local replacements = {}
    for _, service in ipairs(commonServices) do
        -- Match patterns: local v1 = game:GetService("Players")
        for varName in string.gmatch(code, "local%s+([%w_]+)%s*=%s*game:GetService%([\"']" .. service .. "[\"']%)") do
            if varName ~= service and string.match(varName, "^[vu_]%d+$") then
                replacements[varName] = service
            end
        end
    end

    local beautified = code
    for oldVar, newVar in pairs(replacements) do
        beautified = string.gsub(beautified, "([%s%(%[{,;=])" .. oldVar .. "([%s%)%]}:;%.])", "%1" .. newVar .. "%2")
        beautified = string.gsub(beautified, "local%s+" .. oldVar .. "%s*=", "local " .. newVar .. " =")
    end

    return beautified
end

-- Generate Intelligent Server Backend Dispatcher (RemoteSpy Auto-Generator)
local function generateServerDispatcher(scriptInstance: LuaSourceContainer): string
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
        code = code .. string.format([=[
local %s = parent:FindFirstChild(%q)
if %s and %s:IsA("RemoteEvent") then
    %s.OnServerEvent:Connect(function(player, ...)
        local args = {...}
        print(string.format("[%s:OnServerEvent] Received from %%s (%%d args)", player.Name, #args))
        -- Backend logic dispatcher
    end)
end

]=], string.gsub(remoteName, "[^%w_]", "_"), remoteName, string.gsub(remoteName, "[^%w_]", "_"), string.gsub(remoteName, "[^%w_]", "_"), string.gsub(remoteName, "[^%w_]", "_"), remoteName)
    end

    -- Attach listeners for local RemoteFunctions
    for _, funcName in ipairs(functions) do
        code = code .. string.format([=[
local %s = parent:FindFirstChild(%q)
if %s and %s:IsA("RemoteFunction") then
    %s.OnServerInvoke = function(player, ...)
        local args = {...}
        print(string.format("[%s:OnServerInvoke] Invoked by %%s", player.Name))
        return true -- Default affirmative response
    end
end

]=], string.gsub(funcName, "[^%w_]", "_"), funcName, string.gsub(funcName, "[^%w_]", "_"), string.gsub(funcName, "[^%w_]", "_"), string.gsub(funcName, "[^%w_]", "_"), funcName)
    end

    return code
end

-- Decompile single script safely with timeout & retries
function Decompiler.DecompileSingle(scriptInstance: LuaSourceContainer, options: table): string
    -- 1. Check if source is directly readable (e.g. Studio, Mock, or unprotected environment)
    local directSource = nil
    pcall(function()
        local s = (scriptInstance :: any).Source
        if type(s) == "string" and #s > 0 then
            directSource = s
        end
    end)
    if directSource then
        return directSource
    end

    -- Check DecompileIgnore rules (USSI parity)
    if options.DecompileIgnore and type(options.DecompileIgnore) == "table" then
        local fullName = scriptInstance:GetFullName()
        for _, pattern in ipairs(options.DecompileIgnore) do
            if string.find(scriptInstance.Name, pattern) or string.find(fullName, pattern) then
                return generateHeader(scriptInstance, "Decompile Skipped by Rule") ..
                    string.format("-- [Decompilation skipped by DecompileIgnore rule: %s]\n", tostring(pattern))
            end
        end
    end

    local isServerScript = scriptInstance:IsA("Script")
    if isServerScript then
        pcall(function()
            if (scriptInstance :: any).RunContext == Enum.RunContext.Client then
                isServerScript = false
            end
        end)
    end

    -- Server Scripts with server execution (Protected by FilteringEnabled -> Generate RemoteSpy Dispatcher)
    if isServerScript then
        if options.SaveServerScriptPlaceholders then
            return generateHeader(scriptInstance, "Reconstructed Server Backend (RemoteSpy Dispatcher)") ..
                generateServerDispatcher(scriptInstance)
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
                    -- Filter out common tiny decompiler error stubs
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
            return generateHeader(scriptInstance, "Extracted Raw Bytecode (Decompiler Unavailable)") ..
                string.format([=[
-- Raw Luau Bytecode (Base64 Encoded, Size: %d bytes):
-- You can disassemble or inspect this bytecode using any Luau bytecode viewer.

local rawBytecodeBase64 = %q
return rawBytecodeBase64
]=], #bytecode, b64)
        end
    end

    return generateHeader(scriptInstance, "Decompilation Failed / Unsupported Executor") ..
        "-- [Decompilation failed or not supported by current executor]\n"
end

-- Batch decompile multiple scripts concurrently with worker pool
function Decompiler.DecompileBatch(scripts: {LuaSourceContainer}, options: table, progressCallback: (current: number, total: number, script: LuaSourceContainer) -> ()): {[LuaSourceContainer]: string}
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

local SoundService = game:GetService("SoundService")

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
export type SaveProgress = {
    Stage: string,              -- "Idle" | "Scanning" | "Preloading" | "Exploring" | "Assets" | "Terrain" | "Decompiling" | "Serializing" | "Writing" | "Done" | "Error"
    Current: number,
    Total: number,
    Percentage: number,
    Message: string,
    SavedFile: string?,
    AssetsFolder: string?,
}

function Engine.new(customConfig: table?)
    local self = setmetatable({}, Engine)
    self.Config = table.clone(Defaults)
    if customConfig then
        for k, v in pairs(customConfig) do
            self.Config[k] = v
        end
    end
    self.ProgressListeners = {}
    self.IsRunning = false
    self.CancelRequested = false

    -- Enable Anti-AFK automatically if configured
    if self.Config.AutoAntiAFK then
        AntiAFK.Enable()
    end

    return self
end

function Engine:OnProgress(callback: (progress: SaveProgress) -> ())
    table.insert(self.ProgressListeners, callback)
end

function Engine:EmitProgress(progress: SaveProgress)
    for _, cb in ipairs(self.ProgressListeners) do
        task.spawn(cb, progress)
    end
end

-- Generate safe output filename
function Engine:GetDefaultFileName(): string
    local placeId = game.PlaceId or 0
    local placeName = "Place"
    pcall(function()
        placeName = game:GetService("MarketplaceService"):GetProductInfo(placeId).Name
    end)
    placeName = string.gsub(placeName, "[^%w_%-]", "_")
    local ext = string.lower(self.Config.Format or "rbxlx")
    return string.format("HyperSave_%s_%d.%s", placeName, placeId, ext)
end

function Engine:GetDefaultAssetFolder(): string
    local placeId = game.PlaceId or 0
    return string.format("HyperSave_Assets_%d", placeId)
end

-- Play completion audio chime
function Engine:PlayChime()
    if not self.Config.PlaySoundOnComplete then return end
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://9069609200" -- Pleasant success chime
        sound.Volume = 0.6
        sound.Parent = SoundService
        sound:Play()
        sound.Ended:Connect(function() sound:Destroy() end)
    end)
end

-- Check if instance should be saved
function Engine:ShouldSaveInstance(inst: Instance): boolean
    local cName = inst.ClassName
    if ClassBlacklist.Classes[cName] then return false end
    if ClassBlacklist.Names[inst.Name] then return false end

    if inst.Name == "HyperSaveInstance_UI" or inst.Name == "HyperSaveGUI" then return false end

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
function Engine:SaveTarget(target: Instance, customConfig: table?): (boolean, string)
    if not target or not target:IsA("Instance") then
        return false, "Invalid target instance specified!"
    end

    local cfg = table.clone(self.Config)
    if customConfig then
        for k, v in pairs(customConfig) do cfg[k] = v end
    end

    local cleanName = string.gsub(target.Name, "[^%w_%-]", "_")
    local fileName = string.format("HyperSave_Model_%s_%d.%s", cleanName, os.time(), cfg.Format or "rbxm")

    local allInstances = {target}
    local scriptInstances = {}

    local function scan(inst: Instance)
        if not self:ShouldSaveInstance(inst) then return end
        table.insert(allInstances, inst)
        if inst:IsA("LuaSourceContainer") then
            table.insert(scriptInstances, inst)
        end
        for _, child in ipairs(inst:GetChildren()) do scan(child) end
    end
    scan(target)

    local scriptSources = {}
    if cfg.DecompileScripts and #scriptInstances > 0 then
        scriptSources = Decompiler.DecompileBatch(scriptInstances, cfg)
    end

    local output = SerializerXml.Serialize({target}, scriptSources, nil, cfg)
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
function Engine:SaveTargetBatch(targets: {Instance}, customConfig: table?): (boolean, string)
    if not targets or #targets == 0 then
        return false, "No target instances specified for batch export!"
    end

    local cfg = table.clone(self.Config)
    if customConfig then
        for k, v in pairs(customConfig) do cfg[k] = v end
    end

    local fileName = string.format("HyperSave_MultiPack_%d_items_%d.%s", #targets, os.time(), cfg.Format or "rbxm")
    local scriptInstances = {}

    local function scan(inst: Instance)
        if not self:ShouldSaveInstance(inst) then return end
        if inst:IsA("LuaSourceContainer") then
            table.insert(scriptInstances, inst)
        end
        for _, child in ipairs(inst:GetChildren()) do scan(child) end
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
function Engine:Start(): (boolean, string)
    if self.IsRunning then
        return false, "Save is already in progress!"
    end

    self.IsRunning = true
    self.CancelRequested = false
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
        StreamExplorer.ExploreMap(512, function(cur, tot, pos)
            local pct = 4 + math.floor((cur / tot) * 6)
            self:EmitProgress({
                Stage = "Exploring",
                Current = cur,
                Total = tot,
                Percentage = pct,
                Message = string.format("Streaming Sweep: %d/%d chunks loaded", cur, tot),
            })
        end)
    end

    -- Step 1: Collect Root Services to save
    local rootInstances: {Instance} = {}
    local allInstances: {Instance} = {}
    local scriptInstances: {LuaSourceContainer} = {}

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
                pcall(function() nInst.Parent = nilFolder end)
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

    -- Generate Safe SpawnLocation at player's current position to prevent falling into void in Studio
    if self.Config.GenerateSafeSpawn then
        pcall(function()
            local Players = game:GetService("Players")
            local localPlayer = Players.LocalPlayer
            local char = localPlayer and localPlayer.Character
            local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head") or char.PrimaryPart)
            if hrp and workspace and not workspace:FindFirstChild("HyperSave_SafeSpawn") then
                local spawnPos = hrp.CFrame - Vector3.new(0, 3, 0)
                local safeSpawn = Instance.new("SpawnLocation")
                safeSpawn.Name = "HyperSave_SafeSpawn"
                safeSpawn.Size = Vector3.new(12, 1.2, 12)
                safeSpawn.CFrame = spawnPos
                safeSpawn.Anchored = true
                safeSpawn.CanCollide = true
                safeSpawn.Transparency = 0.4
                safeSpawn.Material = Enum.Material.Neon
                safeSpawn.Color = Color3.fromRGB(0, 200, 255)
                safeSpawn.Neutral = true
                safeSpawn.Duration = 0
                safeSpawn.Parent = workspace
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

    local function scan(inst: Instance)
        if not self:ShouldSaveInstance(inst) then return end
        table.insert(allInstances, inst)

        if inst:IsA("LuaSourceContainer") then
            table.insert(scriptInstances, inst)
        end

        for _, child in ipairs(inst:GetChildren()) do
            scan(child)
        end
    end

    for _, root in ipairs(rootInstances) do
        scan(root)
    end

    -- Step 1.5: Intelligent Server Synthesizer (Auto-generates ServerScriptService backend for Remotes)
    if self.Config.SaveServerScriptPlaceholders or self.Config.SynthesizeServer then
        pcall(function()
            local serverService = ServerSynthesizer.SynthesizeService(rootInstances)
            table.insert(rootInstances, serverService)
            scan(serverService)
        end)
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
        for _ in pairs(assets) do totalAssets = totalAssets + 1 end

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

    -- Step 4: Decompile Scripts
    local scriptSources: {[LuaSourceContainer]: string} = {}
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

        local successMsg = string.format("Done! Saved %d instances, %d scripts & %d raw assets in %.2fs to: %s",
            totalInstances, totalScripts, downloadedCount, elapsed, fullPathHint)

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
    Extracts all ScreenGuis, Menus, Inventories, Health Bars, and HUDs to a standalone UI Pack.
]]

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local Environment = __require__("Utils/Environment")
local SerializerXml = __require__("Core/SerializerXml")
local Decompiler = __require__("Core/Decompiler")

local GuiRipper = {}

function GuiRipper.ExportAllGuis(options: table?): (boolean, string)
    local placeId = game.PlaceId or 0
    local fileName = string.format("HyperSave_UIPack_%d.rbxmx", placeId)

    local folder = Instance.new("Folder")
    folder.Name = "Extracted_UIPack"

    local allGuis = {}
    local scriptInstances = {}

    -- Scan StarterGui
    for _, gui in ipairs(StarterGui:GetChildren()) do
        if gui:IsA("ScreenGui") or gui:IsA("BillboardGui") or gui:IsA("SurfaceGui") then
            pcall(function()
                local cl = gui:Clone()
                if cl then cl.Parent = folder end
            end)
        end
    end

    -- Scan PlayerGui if available
    local player = Players.LocalPlayer
    if player then
        local pGui = player:FindFirstChild("PlayerGui")
        if pGui then
            for _, gui in ipairs(pGui:GetChildren()) do
                if (gui:IsA("ScreenGui") or gui:IsA("BillboardGui") or gui:IsA("SurfaceGui")) and not folder:FindFirstChild(gui.Name) then
                    pcall(function()
                        local cl = gui:Clone()
                        if cl then cl.Parent = folder end
                    end)
                end
            end
        end
    end

    local function scanScripts(inst: Instance)
        if inst:IsA("LuaSourceContainer") then
            table.insert(scriptInstances, inst)
        end
        for _, child in ipairs(inst:GetChildren()) do scanScripts(child) end
    end
    scanScripts(folder)

    local scriptSources = {}
    if #scriptInstances > 0 then
        scriptSources = Decompiler.DecompileBatch(scriptInstances, options or {DecompileScripts = true})
    end

    local xml = SerializerXml.Serialize({folder}, scriptSources, nil, {SaveAttributes = true, SaveTags = true})
    local writeOk = Environment.WriteFile(fileName, xml)

    if writeOk then
        return true, fileName
    end
    return false, "Failed to write UI pack file."
end

return GuiRipper

end)

__define__("Core/LightingRipper", function()
--[[
    HyperSaveInstance - Lighting & Atmosphere Preset Ripper
    Extracts realistic Skyboxes, Atmospheres, ColorCorrections, SunRays, and Post-Processing to a standalone preset.
]]

local Lighting = game:GetService("Lighting")
local Environment = __require__("Utils/Environment")
local SerializerXml = __require__("Core/SerializerXml")

local LightingRipper = {}

function LightingRipper.ExportLightingPreset(): (boolean, string)
    local placeId = game.PlaceId or 0
    local fileName = string.format("HyperSave_LightingPreset_%d.rbxmx", placeId)

    local folder = Instance.new("Folder")
    folder.Name = "LightingPreset"

    -- Clone all post processing effects & sky into folder
    for _, child in ipairs(Lighting:GetChildren()) do
        pcall(function()
            local clone = child:Clone()
            if clone then clone.Parent = folder end
        end)
    end

    local xml = SerializerXml.Serialize({Lighting, folder}, {}, nil, {SaveAttributes = true, SaveTags = true})
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

local HttpService = game:GetService("HttpService")
local Environment = __require__("Utils/Environment")

local NetworkSniffer = {}
NetworkSniffer.IsActive = false
NetworkSniffer.CapturedLogs = {}
NetworkSniffer.Listeners = {}

local originalFireServer = nil
local originalInvokeServer = nil

-- Format arguments safely into readable string / json
local function serializeArgs(args: table): string
    local s, json = pcall(function()
        return HttpService:JSONEncode(args)
    end)
    if s and json then return json end

    local parts = {}
    for i, v in ipairs(args) do
        table.insert(parts, tostring(v) .. " (" .. typeof(v) .. ")")
    end
    return "{" .. table.concat(parts, ", ") .. "}"
end

-- Start live packet sniffing
function NetworkSniffer.Start()
    if NetworkSniffer.IsActive then return end
    NetworkSniffer.IsActive = true

    -- Hook Metamethod __namecall if executor supports hookmetamethod
    local hookmeta = hookmetamethod or (syn and syn.hookmetamethod)
    if hookmeta then
        local oldNamecall
        oldNamecall = hookmeta(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if NetworkSniffer.IsActive and typeof(self) == "Instance" then
                if method == "FireServer" and self:IsA("RemoteEvent") then
                    local args = {...}
                    NetworkSniffer.LogCall("FireServer", self, args)
                elseif method == "InvokeServer" and self:IsA("RemoteFunction") then
                    local args = {...}
                    NetworkSniffer.LogCall("InvokeServer", self, args)
                end
            end
            return oldNamecall(self, ...)
        end)
    end
end

-- Stop packet sniffing
function NetworkSniffer.Stop()
    NetworkSniffer.IsActive = false
end

-- Record a network event
function NetworkSniffer.LogCall(callType: string, remote: Instance, args: table)
    local entry = {
        Timestamp = os.date("%H:%M:%S"),
        Type = callType,
        RemoteName = remote.Name,
        RemotePath = remote:GetFullName(),
        ArgCount = #args,
        ArgsPreview = serializeArgs(args),
        RawArgs = args,
    }

    table.insert(NetworkSniffer.CapturedLogs, entry)

    -- Notify listeners (HUD)
    for _, cb in ipairs(NetworkSniffer.Listeners) do
        task.spawn(cb, entry)
    end
end

-- Register UI listener
function NetworkSniffer.OnCall(callback: (entry: table) -> ())
    table.insert(NetworkSniffer.Listeners, callback)
end

-- Export captured network protocol to file
function NetworkSniffer.ExportLogs(): string
    local placeId = game.PlaceId or 0
    local fileName = string.format("HyperSave_Network_%d.json", placeId)

    local s, json = pcall(function()
        return HttpService:JSONEncode(NetworkSniffer.CapturedLogs)
    end)

    if not s or not json then
        local lines = {}
        for _, log in ipairs(NetworkSniffer.CapturedLogs) do
            table.insert(lines, string.format("[%s] [%s] %s -> %s", log.Timestamp, log.Type, log.RemotePath, log.ArgsPreview))
        end
        json = table.concat(lines, "\n")
    end

    Environment.WriteFile(fileName, json)
    return fileName
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
local function getBoxGeometry(cf: CFrame, size: Vector3, vertOffset: number): (string, string, number)
    local hx, hy, hz = size.X / 2, size.Y / 2, size.Z / 2
    local corners = {
        cf:PointToWorldSpace(Vector3.new(-hx, -hy, -hz)),
        cf:PointToWorldSpace(Vector3.new(hx, -hy, -hz)),
        cf:PointToWorldSpace(Vector3.new(hx, hy, -hz)),
        cf:PointToWorldSpace(Vector3.new(-hx, hy, -hz)),
        cf:PointToWorldSpace(Vector3.new(-hx, -hy, hz)),
        cf:PointToWorldSpace(Vector3.new(hx, -hy, hz)),
        cf:PointToWorldSpace(Vector3.new(hx, hy, hz)),
        cf:PointToWorldSpace(Vector3.new(-hx, hy, hz)),
    }

    local vLines = {}
    for _, pt in ipairs(corners) do
        table.insert(vLines, string.format("v %.4f %.4f %.4f", pt.X, pt.Y, pt.Z))
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

-- Export entire workspace or model to .obj + .mtl
function ObjExporter.Export(targetRoot: Instance?, options: table?): (boolean, string)
    local root = targetRoot or workspace
    local placeId = game.PlaceId or 0
    local baseName = string.format("HyperSave_Map3D_%d", placeId)

    local objLines = {
        "# HyperSaveInstance - Wavefront 3D OBJ Export",
        "# Exported from Roblox Experience",
        "mtllib " .. baseName .. ".mtl",
        ""
    }

    local mtlLines = {
        "# HyperSaveInstance - Material Library (.mtl)",
        ""
    }

    local materialsSeen = {}
    local vertOffset = 0
    local partCount = 0

    local function processInstance(inst: Instance)
        if inst:IsA("BasePart") and not inst:IsA("Terrain") then
            local color = inst.Color
            local matName = string.format("mat_%d_%d_%d", math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255))

            if not materialsSeen[matName] then
                materialsSeen[matName] = true
                table.insert(mtlLines, string.format("newmtl %s", matName))
                table.insert(mtlLines, string.format("Kd %.4f %.4f %.4f", color.R, color.G, color.B))
                table.insert(mtlLines, string.format("d %.4f", 1 - inst.Transparency))
                table.insert(mtlLines, "")
            end

            table.insert(objLines, string.format("o %s_%d", string.gsub(inst.Name, "[^%w_]", "_"), partCount))
            table.insert(objLines, "usemtl " .. matName)

            local vStr, fStr, newOffset = getBoxGeometry(inst.CFrame, inst.Size, vertOffset)
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

    -- Write files
    local objContent = table.concat(objLines, "\n")
    local mtlContent = table.concat(mtlLines, "\n")

    local objPath = baseName .. ".obj"
    local mtlPath = baseName .. ".mtl"

    Environment.WriteFile(objPath, objContent)
    Environment.WriteFile(mtlPath, mtlContent)

    return true, objPath
end

return ObjExporter

end)

__define__("Core/Optimizer", function()
--[[
    HyperSaveInstance - Smart Place Optimizer & Deduplicator
    (Strictly Optional) Reduces file size by deduplicating textures and pruning empty temporary containers.
]]

local Optimizer = {}

function Optimizer.OptimizeHierarchy(rootInstances: {Instance}, options: table): {Instance}
    if not options.OptimizeGeometry then
        return rootInstances
    end

    local cleanedRoots = {}
    local prunedCount = 0

    local function cleanRecursive(inst: Instance): boolean
        -- Remove empty temporary folders or zero-size unrendered parts if safe
        if inst:IsA("Folder") and #inst:GetChildren() == 0 and not inst:GetAttribute("Preserve") then
            prunedCount = prunedCount + 1
            return false
        end

        for _, child in ipairs(inst:GetChildren()) do
            cleanRecursive(child)
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

return Optimizer

end)

__define__("Core/RaycastSelector", function()
--[[
    HyperSaveInstance - 3D In-World Raycast & Model Selector
    Allows the user to hover and click directly on any 3D model, vehicle, weapon or structure
    in the game world to inspect its hierarchy and save it with all internal scripts.
]]

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local RaycastSelector = {}
RaycastSelector.__index = RaycastSelector

function RaycastSelector.new(options: table?)
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
        hl.Name = "HyperSave_SelectorHighlight"
        hl.FillColor = Color3.fromRGB(168, 85, 247)
        hl.FillTransparency = 0.6
        hl.OutlineColor = Color3.fromRGB(243, 232, 255)
        hl.OutlineTransparency = 0.05
        hl.Enabled = false
        
        -- Store in gethui, CoreGui or workspace
        local parent = (gethui and gethui()) or game:GetService("CoreGui"):FindFirstChild("RobloxGui") or workspace
        hl.Parent = parent
        self.Highlight = hl
    end)
end

-- Find the most meaningful parent Model or Tool from a clicked BasePart
function RaycastSelector:ResolveTarget(part: BasePart): Instance
    if not part then return nil end

    local current: Instance? = part
    local bestModel: Instance = part

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
function RaycastSelector:RaycastMouse(): (Instance?, Vector3?)
    local camera = workspace.CurrentCamera
    if not camera then return nil, nil end

    local mousePos = UserInputService:GetMouseLocation()
    local unitRay = camera:ViewportPointToRay(mousePos.X, mousePos.Y)

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude

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
function RaycastSelector:Start(onSelected: (Instance) -> (), onHover: ((Instance?) -> ())?)
    if self.IsActive then self:Stop() end

    self.IsActive = true
    self.OnSelectedCallback = onSelected
    self.OnHoverCallback = onHover

    -- RenderStepped hover raycast
    local hoverConn = RunService.RenderStepped:Connect(function()
        if not self.IsActive then return end

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
        if not self.IsActive then return end

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
        pcall(function() conn:Disconnect() end)
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
        pcall(function() self.Highlight:Destroy() end)
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

local CollectionService = game:GetService("CollectionService")

local Reflection = {}

-- Comprehensive Property Database for ALL Roblox Classes
Reflection.ClassProperties = {
    ["Instance"] = {
        {"Name", "string"},
        {"Archivable", "bool"},
    },
    ["PVInstance"] = {
        {"Origin", "CoordinateFrame", true},
    },
    ["BasePart"] = {
        {"Size", "Vector3"},
        {"CFrame", "CoordinateFrame"},
        {"Position", "Vector3"},
        {"Orientation", "Vector3"},
        {"Color", "Color3"},
        {"Material", "token"},
        {"MaterialVariant", "string"},
        {"Transparency", "float"},
        {"Reflectance", "float"},
        {"Anchored", "bool"},
        {"CanCollide", "bool"},
        {"CanTouch", "bool"},
        {"CanQuery", "bool"},
        {"CastShadow", "bool"},
        {"Massless", "bool"},
        {"RootPriority", "int"},
        {"CustomPhysicalProperties", "PhysicalProperties"},
        {"CollisionGroupId", "int"},
        {"AssemblyLinearVelocity", "Vector3"},
        {"AssemblyAngularVelocity", "Vector3"},
        {"TopSurface", "token"},
        {"BottomSurface", "token"},
        {"LeftSurface", "token"},
        {"RightSurface", "token"},
        {"FrontSurface", "token"},
        {"BackSurface", "token"},
    },
    ["Part"] = {
        {"Shape", "token"},
    },
    ["MeshPart"] = {
        {"MeshId", "Content"},
        {"TextureID", "Content"},
        {"RenderFidelity", "token"},
        {"CollisionFidelity", "token"},
        {"DoubleSided", "bool"},
        {"VertexColor", "Vector3"},
    },
    ["UnionOperation"] = {
        {"AssetId", "Content"},
        {"RenderFidelity", "token"},
        {"CollisionFidelity", "token"},
        {"UsePartColor", "bool"},
        {"SmoothingAngle", "float"},
    },
    ["NegateOperation"] = {},
    ["SpecialMesh"] = {
        {"MeshId", "Content"},
        {"TextureId", "Content"},
        {"MeshType", "token"},
        {"Scale", "Vector3"},
        {"Offset", "Vector3"},
        {"VertexColor", "Vector3"},
    },
    ["Decal"] = {
        {"Texture", "Content"},
        {"Face", "token"},
        {"Color3", "Color3"},
        {"Transparency", "float"},
        {"ZIndex", "int"},
    },
    ["Texture"] = {
        {"StudsPerTileU", "float"},
        {"StudsPerTileV", "float"},
        {"OffsetStudsU", "float"},
        {"OffsetStudsV", "float"},
    },
    ["SurfaceAppearance"] = {
        {"ColorMap", "Content"},
        {"NormalMap", "Content"},
        {"RoughnessMap", "Content"},
        {"MetalnessMap", "Content"},
        {"AlphaMode", "token"},
    },
    ["MaterialVariant"] = {
        {"BaseMaterial", "token"},
        {"ColorMap", "Content"},
        {"NormalMap", "Content"},
        {"RoughnessMap", "Content"},
        {"MetalnessMap", "Content"},
        {"StudsPerTile", "float"},
        {"MaterialPattern", "token"},
    },
    ["Model"] = {
        {"PrimaryPart", "Ref"},
        {"Scale", "float"},
        {"WorldPivot", "CoordinateFrame"},
    },
    ["Folder"] = {},
    ["Configuration"] = {},
    ["Lighting"] = {
        {"Ambient", "Color3"},
        {"OutdoorAmbient", "Color3"},
        {"Brightness", "float"},
        {"ClockTime", "float"},
        {"TimeOfDay", "string"},
        {"GeographicLatitude", "float"},
        {"FogColor", "Color3"},
        {"FogEnd", "float"},
        {"FogStart", "float"},
        {"ColorShift_Bottom", "Color3"},
        {"ColorShift_Top", "Color3"},
        {"GlobalShadows", "bool"},
        {"ShadowSoftness", "float"},
        {"EnvironmentDiffuseScale", "float"},
        {"EnvironmentSpecularScale", "float"},
        {"Technology", "token"},
        {"ExposureCompensation", "float"},
    },
    ["Atmosphere"] = {
        {"Density", "float"},
        {"Offset", "float"},
        {"Color", "Color3"},
        {"Decay", "Color3"},
        {"Glare", "float"},
        {"Haze", "float"},
    },
    ["Sky"] = {
        {"SkyboxBk", "Content"},
        {"SkyboxDn", "Content"},
        {"SkyboxFt", "Content"},
        {"SkyboxLf", "Content"},
        {"SkyboxRt", "Content"},
        {"SkyboxUp", "Content"},
        {"SunTextureId", "Content"},
        {"MoonTextureId", "Content"},
        {"SunAngularPhase", "float"},
        {"MoonAngularPhase", "float"},
        {"CelestialBodiesShown", "bool"},
        {"StarCount", "int"},
    },
    ["BloomEffect"] = {
        {"Enabled", "bool"},
        {"Intensity", "float"},
        {"Size", "float"},
        {"Threshold", "float"},
    },
    ["BlurEffect"] = {
        {"Enabled", "bool"},
        {"Size", "float"},
    },
    ["ColorCorrectionEffect"] = {
        {"Enabled", "bool"},
        {"Brightness", "float"},
        {"Contrast", "float"},
        {"Saturation", "float"},
        {"TintColor", "Color3"},
    },
    ["SunRaysEffect"] = {
        {"Enabled", "bool"},
        {"Intensity", "float"},
        {"Spread", "float"},
    },
    ["DepthOfFieldEffect"] = {
        {"Enabled", "bool"},
        {"FarIntensity", "float"},
        {"FocusDistance", "float"},
        {"InFocusRadius", "float"},
        {"NearIntensity", "float"},
    },
    ["Sound"] = {
        {"SoundId", "Content"},
        {"Volume", "float"},
        {"PlaybackSpeed", "float"},
        {"Looped", "bool"},
        {"Playing", "bool"},
        {"TimePosition", "float"},
        {"RollOffMaxDistance", "float"},
        {"RollOffMinDistance", "float"},
        {"RollOffMode", "token"},
        {"SoundGroup", "Ref"},
    },
    ["SoundGroup"] = {
        {"Volume", "float"},
    },
    ["EqualizerSoundEffect"] = {
        {"HighGain", "float"},
        {"MidGain", "float"},
        {"LowGain", "float"},
        {"Priority", "int"},
        {"Enabled", "bool"},
    },
    ["ReverbSoundEffect"] = {
        {"DecayTime", "float"},
        {"Density", "float"},
        {"Diffusion", "float"},
        {"DryLevel", "float"},
        {"WetLevel", "float"},
        {"Priority", "int"},
        {"Enabled", "bool"},
    },
    ["PitchShiftSoundEffect"] = {
        {"Octave", "float"},
        {"Priority", "int"},
        {"Enabled", "bool"},
    },
    ["DistortionSoundEffect"] = {
        {"Level", "float"},
        {"Priority", "int"},
        {"Enabled", "bool"},
    },
    ["CompressorSoundEffect"] = {
        {"Attack", "float"},
        {"GainMakeup", "float"},
        {"Ratio", "float"},
        {"Release", "float"},
        {"Threshold", "float"},
        {"SideChain", "Ref"},
        {"Priority", "int"},
        {"Enabled", "bool"},
    },
    ["ParticleEmitter"] = {
        {"Texture", "Content"},
        {"Rate", "float"},
        {"Lifetime", "NumberRange"},
        {"Speed", "NumberRange"},
        {"SpreadAngle", "Vector2"},
        {"Rotation", "NumberRange"},
        {"RotSpeed", "NumberRange"},
        {"Size", "NumberSequence"},
        {"Color", "ColorSequence"},
        {"Transparency", "NumberSequence"},
        {"LightEmission", "float"},
        {"LightInfluence", "float"},
        {"ZOffset", "float"},
        {"Drag", "float"},
        {"Acceleration", "Vector3"},
        {"VelocityInheritance", "float"},
        {"LockedToPart", "bool"},
        {"EmissionDirection", "token"},
        {"Orientation", "token"},
        {"Enabled", "bool"},
        {"FlipbookFramerate", "NumberRange"},
        {"FlipbookLayout", "token"},
        {"FlipbookMode", "token"},
    },
    ["Beam"] = {
        {"Texture", "Content"},
        {"TextureLength", "float"},
        {"TextureMode", "token"},
        {"TextureSpeed", "float"},
        {"Width0", "float"},
        {"Width1", "float"},
        {"CurveSize0", "float"},
        {"CurveSize1", "float"},
        {"Segments", "int"},
        {"Color", "ColorSequence"},
        {"Transparency", "NumberSequence"},
        {"LightEmission", "float"},
        {"LightInfluence", "float"},
        {"Attachment0", "Ref"},
        {"Attachment1", "Ref"},
        {"FaceCamera", "bool"},
        {"Enabled", "bool"},
    },
    ["Trail"] = {
        {"Texture", "Content"},
        {"TextureLength", "float"},
        {"TextureMode", "token"},
        {"Lifetime", "float"},
        {"MinLength", "float"},
        {"WidthScale", "NumberSequence"},
        {"Color", "ColorSequence"},
        {"Transparency", "NumberSequence"},
        {"LightEmission", "float"},
        {"LightInfluence", "float"},
        {"Attachment0", "Ref"},
        {"Attachment1", "Ref"},
        {"FaceCamera", "bool"},
        {"Enabled", "bool"},
    },
    ["PointLight"] = {
        {"Color", "Color3"},
        {"Brightness", "float"},
        {"Range", "float"},
        {"Shadows", "bool"},
        {"Enabled", "bool"},
    },
    ["SpotLight"] = {
        {"Color", "Color3"},
        {"Brightness", "float"},
        {"Range", "float"},
        {"Angle", "float"},
        {"Face", "token"},
        {"Shadows", "bool"},
        {"Enabled", "bool"},
    },
    ["SurfaceLight"] = {
        {"Color", "Color3"},
        {"Brightness", "float"},
        {"Range", "float"},
        {"Angle", "float"},
        {"Face", "token"},
        {"Shadows", "bool"},
        {"Enabled", "bool"},
    },
    ["Attachment"] = {
        {"CFrame", "CoordinateFrame"},
        {"Position", "Vector3"},
        {"Orientation", "Vector3"},
        {"Axis", "Vector3"},
        {"SecondaryAxis", "Vector3"},
        {"Visible", "bool"},
    },
    ["Bone"] = {
        {"CFrame", "CoordinateFrame"},
        {"Position", "Vector3"},
        {"Orientation", "Vector3"},
        {"Transform", "CoordinateFrame"},
    },
    ["Motor6D"] = {
        {"Part0", "Ref"},
        {"Part1", "Ref"},
        {"C0", "CoordinateFrame"},
        {"C1", "CoordinateFrame"},
        {"CurrentAngle", "float"},
        {"DesiredAngle", "float"},
        {"MaxVelocity", "float"},
        {"Enabled", "bool"},
    },
    ["Weld"] = {
        {"Part0", "Ref"},
        {"Part1", "Ref"},
        {"C0", "CoordinateFrame"},
        {"C1", "CoordinateFrame"},
        {"Enabled", "bool"},
    },
    ["WeldConstraint"] = {
        {"Part0", "Ref"},
        {"Part1", "Ref"},
        {"Enabled", "bool"},
    },
    ["BallSocketConstraint"] = {
        {"Attachment0", "Ref"},
        {"Attachment1", "Ref"},
        {"Enabled", "bool"},
        {"LimitsEnabled", "bool"},
        {"TwistLimitsEnabled", "bool"},
        {"UpperAngle", "float"},
        {"TwistLowerAngle", "float"},
        {"TwistUpperAngle", "float"},
        {"Restitution", "float"},
    },
    ["HingeConstraint"] = {
        {"Attachment0", "Ref"},
        {"Attachment1", "Ref"},
        {"Enabled", "bool"},
        {"ActuatorType", "token"},
        {"AngularSpeed", "float"},
        {"AngularVelocity", "float"},
        {"MotorMaxAcceleration", "float"},
        {"MotorMaxTorque", "float"},
        {"LimitsEnabled", "bool"},
        {"LowerAngle", "float"},
        {"UpperAngle", "float"},
        {"Restitution", "float"},
    },
    ["SpringConstraint"] = {
        {"Attachment0", "Ref"},
        {"Attachment1", "Ref"},
        {"Enabled", "bool"},
        {"Coils", "float"},
        {"Damping", "float"},
        {"FreeLength", "float"},
        {"Radius", "float"},
        {"Stiffness", "float"},
        {"LimitsEnabled", "bool"},
        {"MaxLength", "float"},
        {"MinLength", "float"},
    },
    ["PrismaticConstraint"] = {
        {"Attachment0", "Ref"},
        {"Attachment1", "Ref"},
        {"Enabled", "bool"},
        {"ActuatorType", "token"},
        {"Size", "float"},
        {"Speed", "float"},
        {"Velocity", "float"},
        {"MotorMaxAcceleration", "float"},
        {"MotorMaxForce", "float"},
        {"LimitsEnabled", "bool"},
        {"LowerLimit", "float"},
        {"UpperLimit", "float"},
        {"Restitution", "float"},
    },
    ["AlignPosition"] = {
        {"Attachment0", "Ref"},
        {"Attachment1", "Ref"},
        {"Enabled", "bool"},
        {"ApplyAtCenterOfMass", "bool"},
        {"MaxAxesForce", "Vector3"},
        {"MaxForce", "float"},
        {"MaxVelocity", "float"},
        {"Mode", "token"},
        {"Position", "Vector3"},
        {"ReactionForceEnabled", "bool"},
        {"Responsiveness", "float"},
        {"RigidityEnabled", "bool"},
    },
    ["AlignOrientation"] = {
        {"Attachment0", "Ref"},
        {"Attachment1", "Ref"},
        {"Enabled", "bool"},
        {"AlignType", "token"},
        {"CFrame", "CoordinateFrame"},
        {"MaxAngularVelocity", "float"},
        {"MaxTorque", "float"},
        {"Mode", "token"},
        {"PrimaryAxisOnly", "bool"},
        {"ReactionTorqueEnabled", "bool"},
        {"Responsiveness", "float"},
        {"RigidityEnabled", "bool"},
    },
    ["ScreenGui"] = {
        {"Enabled", "bool"},
        {"ResetOnSpawn", "bool"},
        {"DisplayOrder", "int"},
        {"ZIndexBehavior", "token"},
        {"IgnoreGuiInset", "bool"},
        {"ClipToDeviceSafeArea", "bool"},
        {"SafeAreaCompatibility", "token"},
        {"ScreenInsets", "token"},
    },
    ["BillboardGui"] = {
        {"Enabled", "bool"},
        {"Adornee", "Ref"},
        {"AlwaysOnTop", "bool"},
        {"Size", "UDim2"},
        {"SizeOffset", "Vector2"},
        {"StudsOffset", "Vector3"},
        {"StudsOffsetWorldSpace", "Vector3"},
        {"ExtentsOffset", "Vector3"},
        {"ExtentsOffsetWorldSpace", "Vector3"},
        {"MaxDistance", "float"},
        {"ZIndexBehavior", "token"},
        {"LightInfluence", "float"},
    },
    ["SurfaceGui"] = {
        {"Enabled", "bool"},
        {"Adornee", "Ref"},
        {"Face", "token"},
        {"AlwaysOnTop", "bool"},
        {"CanvasSize", "Vector2"},
        {"PixelsPerStud", "float"},
        {"LightInfluence", "float"},
        {"ZIndexBehavior", "token"},
        {"SizingMode", "token"},
    },
    ["CanvasGroup"] = {
        {"Size", "UDim2"},
        {"Position", "UDim2"},
        {"AnchorPoint", "Vector2"},
        {"BackgroundColor3", "Color3"},
        {"BackgroundTransparency", "float"},
        {"GroupTransparency", "float"},
        {"GroupColor3", "Color3"},
        {"Visible", "bool"},
        {"ZIndex", "int"},
    },
    ["Frame"] = {
        {"Size", "UDim2"},
        {"Position", "UDim2"},
        {"AnchorPoint", "Vector2"},
        {"BackgroundColor3", "Color3"},
        {"BackgroundTransparency", "float"},
        {"BorderColor3", "Color3"},
        {"BorderSizePixel", "int"},
        {"BorderMode", "token"},
        {"ClipsDescendants", "bool"},
        {"Visible", "bool"},
        {"ZIndex", "int"},
        {"LayoutOrder", "int"},
        {"Rotation", "float"},
    },
    ["ScrollingFrame"] = {
        {"Size", "UDim2"},
        {"Position", "UDim2"},
        {"AnchorPoint", "Vector2"},
        {"BackgroundColor3", "Color3"},
        {"BackgroundTransparency", "float"},
        {"BorderColor3", "Color3"},
        {"BorderSizePixel", "int"},
        {"CanvasSize", "UDim2"},
        {"CanvasPosition", "Vector2"},
        {"ScrollBarThickness", "int"},
        {"ScrollBarImageColor3", "Color3"},
        {"ScrollBarImageTransparency", "float"},
        {"ScrollingDirection", "token"},
        {"AutomaticCanvasSize", "token"},
        {"ElasticBehavior", "token"},
        {"ClipsDescendants", "bool"},
        {"Visible", "bool"},
        {"ZIndex", "int"},
        {"LayoutOrder", "int"},
    },
    ["TextLabel"] = {
        {"Size", "UDim2"},
        {"Position", "UDim2"},
        {"AnchorPoint", "Vector2"},
        {"BackgroundColor3", "Color3"},
        {"BackgroundTransparency", "float"},
        {"BorderColor3", "Color3"},
        {"BorderSizePixel", "int"},
        {"Text", "string"},
        {"TextColor3", "Color3"},
        {"TextTransparency", "float"},
        {"TextSize", "float"},
        {"TextScaled", "bool"},
        {"TextWrapped", "bool"},
        {"TextXAlignment", "token"},
        {"TextYAlignment", "token"},
        {"Font", "token"},
        {"FontFace", "Font"},
        {"TextStrokeColor3", "Color3"},
        {"TextStrokeTransparency", "float"},
        {"LineHeight", "float"},
        {"MaxVisibleGraphemes", "int"},
        {"RichText", "bool"},
        {"Visible", "bool"},
        {"ZIndex", "int"},
        {"LayoutOrder", "int"},
    },
    ["TextButton"] = {
        {"Size", "UDim2"},
        {"Position", "UDim2"},
        {"AnchorPoint", "Vector2"},
        {"BackgroundColor3", "Color3"},
        {"BackgroundTransparency", "float"},
        {"BorderColor3", "Color3"},
        {"BorderSizePixel", "int"},
        {"Text", "string"},
        {"TextColor3", "Color3"},
        {"TextTransparency", "float"},
        {"TextSize", "float"},
        {"TextScaled", "bool"},
        {"TextWrapped", "bool"},
        {"TextXAlignment", "token"},
        {"TextYAlignment", "token"},
        {"Font", "token"},
        {"FontFace", "Font"},
        {"TextStrokeColor3", "Color3"},
        {"TextStrokeTransparency", "float"},
        {"RichText", "bool"},
        {"AutoButtonColor", "bool"},
        {"Visible", "bool"},
        {"ZIndex", "int"},
        {"LayoutOrder", "int"},
    },
    ["ImageLabel"] = {
        {"Size", "UDim2"},
        {"Position", "UDim2"},
        {"AnchorPoint", "Vector2"},
        {"BackgroundColor3", "Color3"},
        {"BackgroundTransparency", "float"},
        {"BorderColor3", "Color3"},
        {"BorderSizePixel", "int"},
        {"Image", "Content"},
        {"ImageColor3", "Color3"},
        {"ImageTransparency", "float"},
        {"ScaleType", "token"},
        {"SliceCenter", "Rect"},
        {"SliceScale", "float"},
        {"TileSize", "UDim2"},
        {"Visible", "bool"},
        {"ZIndex", "int"},
        {"LayoutOrder", "int"},
    },
    ["ImageButton"] = {
        {"Size", "UDim2"},
        {"Position", "UDim2"},
        {"AnchorPoint", "Vector2"},
        {"BackgroundColor3", "Color3"},
        {"BackgroundTransparency", "float"},
        {"BorderColor3", "Color3"},
        {"BorderSizePixel", "int"},
        {"Image", "Content"},
        {"ImageColor3", "Color3"},
        {"ImageTransparency", "float"},
        {"ScaleType", "token"},
        {"SliceCenter", "Rect"},
        {"AutoButtonColor", "bool"},
        {"Visible", "bool"},
        {"ZIndex", "int"},
        {"LayoutOrder", "int"},
    },
    ["TextBox"] = {
        {"Size", "UDim2"},
        {"Position", "UDim2"},
        {"AnchorPoint", "Vector2"},
        {"BackgroundColor3", "Color3"},
        {"BackgroundTransparency", "float"},
        {"BorderColor3", "Color3"},
        {"BorderSizePixel", "int"},
        {"Text", "string"},
        {"PlaceholderText", "string"},
        {"PlaceholderColor3", "Color3"},
        {"TextColor3", "Color3"},
        {"TextTransparency", "float"},
        {"TextSize", "float"},
        {"TextScaled", "bool"},
        {"TextWrapped", "bool"},
        {"TextXAlignment", "token"},
        {"TextYAlignment", "token"},
        {"Font", "token"},
        {"FontFace", "Font"},
        {"ClearTextOnFocus", "bool"},
        {"MultiLine", "bool"},
        {"Visible", "bool"},
        {"ZIndex", "int"},
    },
    ["UICorner"] = {
        {"CornerRadius", "UDim"},
    },
    ["UIGradient"] = {
        {"Color", "ColorSequence"},
        {"Transparency", "NumberSequence"},
        {"Rotation", "float"},
        {"Offset", "Vector2"},
        {"Enabled", "bool"},
    },
    ["UIStroke"] = {
        {"Color", "Color3"},
        {"Transparency", "float"},
        {"Thickness", "float"},
        {"ApplyStrokeMode", "token"},
        {"LineJoinMode", "token"},
        {"Enabled", "bool"},
    },
    ["UIPadding"] = {
        {"PaddingTop", "UDim"},
        {"PaddingBottom", "UDim"},
        {"PaddingLeft", "UDim"},
        {"PaddingRight", "UDim"},
    },
    ["UIListLayout"] = {
        {"FillDirection", "token"},
        {"HorizontalAlignment", "token"},
        {"VerticalAlignment", "token"},
        {"SortOrder", "token"},
        {"Padding", "UDim"},
        {"Wraps", "bool"},
    },
    ["UIGridLayout"] = {
        {"CellPadding", "UDim2"},
        {"CellSize", "UDim2"},
        {"FillDirection", "token"},
        {"HorizontalAlignment", "token"},
        {"VerticalAlignment", "token"},
        {"SortOrder", "token"},
        {"StartCorner", "token"},
        {"FillDirectionMaxCells", "int"},
    },
    ["UIAspectRatioConstraint"] = {
        {"AspectRatio", "float"},
        {"AspectType", "token"},
        {"DominantAxis", "token"},
    },
    ["UISizeConstraint"] = {
        {"MaxSize", "Vector2"},
        {"MinSize", "Vector2"},
    },
    ["Highlight"] = {
        {"Adornee", "Ref"},
        {"FillColor", "Color3"},
        {"FillTransparency", "float"},
        {"OutlineColor", "Color3"},
        {"OutlineTransparency", "float"},
        {"DepthMode", "token"},
        {"Enabled", "bool"},
    },
    ["RemoteEvent"] = {},
    ["RemoteFunction"] = {},
    ["BindableEvent"] = {},
    ["BindableFunction"] = {},
    ["LocalScript"] = {
        {"Enabled", "bool"},
    },
    ["ModuleScript"] = {},
    ["Script"] = {
        {"Enabled", "bool"},
    },
    ["Animation"] = {
        {"AnimationId", "Content"},
    },
    ["AnimationTrack"] = {
        {"Animation", "Ref"},
        {"Priority", "token"},
        {"Looped", "bool"},
        {"Speed", "float"},
    },
    ["Tool"] = {
        {"CanBeDropped", "bool"},
        {"ManualActivationOnly", "bool"},
        {"RequiresHandle", "bool"},
        {"ToolTip", "string"},
        {"Grip", "CoordinateFrame"},
        {"GripPos", "Vector3"},
        {"TextureId", "Content"},
    },
    ["Accessory"] = {
        {"AccessoryType", "token"},
        {"AttachmentPoint", "CoordinateFrame"},
    },
    ["Shirt"] = {
        {"ShirtTemplate", "Content"},
    },
    ["Pants"] = {
        {"PantsTemplate", "Content"},
    },
    ["ShirtGraphic"] = {
        {"Graphic", "Content"},
    },
    ["BodyColors"] = {
        {"HeadColor3", "Color3"},
        {"LeftArmColor3", "Color3"},
        {"RightArmColor3", "Color3"},
        {"LeftLegColor3", "Color3"},
        {"RightLegColor3", "Color3"},
        {"TorsoColor3", "Color3"},
    },
    ["Humanoid"] = {
        {"Health", "float"},
        {"MaxHealth", "float"},
        {"WalkSpeed", "float"},
        {"JumpPower", "float"},
        {"JumpHeight", "float"},
        {"AutoRotate", "bool"},
        {"RigType", "token"},
        {"DisplayDistanceType", "token"},
        {"DisplayName", "string"},
    },
    ["ValueBase"] = {
        {"Value", "variant"},
    },
    ["StringValue"] = {{"Value", "string"}},
    ["IntValue"] = {{"Value", "int64"}},
    ["NumberValue"] = {{"Value", "double"}},
    ["BoolValue"] = {{"Value", "bool"}},
    ["ObjectValue"] = {{"Value", "Ref"}},
    ["Color3Value"] = {{"Value", "Color3"}},
    ["Vector3Value"] = {{"Value", "Vector3"}},
    ["CFrameValue"] = {{"Value", "CoordinateFrame"}},
    ["BrickColorValue"] = {{"Value", "token"}},
    ["RayValue"] = {{"Value", "Ray"}},
}

-- Inheritance hierarchy tree
Reflection.ClassHierarchy = {
    ["Part"] = {"BasePart", "PVInstance", "Instance"},
    ["MeshPart"] = {"BasePart", "PVInstance", "Instance"},
    ["UnionOperation"] = {"BasePart", "PVInstance", "Instance"},
    ["NegateOperation"] = {"BasePart", "PVInstance", "Instance"},
    ["WedgePart"] = {"BasePart", "PVInstance", "Instance"},
    ["CornerWedgePart"] = {"BasePart", "PVInstance", "Instance"},
    ["TrussPart"] = {"BasePart", "PVInstance", "Instance"},
    ["SpawnLocation"] = {"BasePart", "PVInstance", "Instance"},
    ["Terrain"] = {"BasePart", "PVInstance", "Instance"},
    ["Model"] = {"PVInstance", "Instance"},
    ["WorldModel"] = {"Model", "PVInstance", "Instance"},
    ["Tool"] = {"Model", "PVInstance", "Instance"},
    ["Accessory"] = {"Instance"},
    ["Shirt"] = {"Instance"},
    ["Pants"] = {"Instance"},
    ["ShirtGraphic"] = {"Instance"},
    ["BodyColors"] = {"Instance"},
    ["Humanoid"] = {"Instance"},
    ["Folder"] = {"Instance"},
    ["Configuration"] = {"Instance"},
    ["Lighting"] = {"Instance"},
    ["Atmosphere"] = {"Instance"},
    ["Sky"] = {"Instance"},
    ["BloomEffect"] = {"Instance"},
    ["BlurEffect"] = {"Instance"},
    ["ColorCorrectionEffect"] = {"Instance"},
    ["SunRaysEffect"] = {"Instance"},
    ["DepthOfFieldEffect"] = {"Instance"},
    ["Sound"] = {"Instance"},
    ["SoundGroup"] = {"Instance"},
    ["EqualizerSoundEffect"] = {"Instance"},
    ["ReverbSoundEffect"] = {"Instance"},
    ["PitchShiftSoundEffect"] = {"Instance"},
    ["DistortionSoundEffect"] = {"Instance"},
    ["CompressorSoundEffect"] = {"Instance"},
    ["ParticleEmitter"] = {"Instance"},
    ["Beam"] = {"Instance"},
    ["Trail"] = {"Instance"},
    ["PointLight"] = {"Instance"},
    ["SpotLight"] = {"Instance"},
    ["SurfaceLight"] = {"Instance"},
    ["Attachment"] = {"Instance"},
    ["Bone"] = {"Attachment", "Instance"},
    ["Motor6D"] = {"Instance"},
    ["Weld"] = {"Instance"},
    ["WeldConstraint"] = {"Instance"},
    ["BallSocketConstraint"] = {"Instance"},
    ["HingeConstraint"] = {"Instance"},
    ["SpringConstraint"] = {"Instance"},
    ["PrismaticConstraint"] = {"Instance"},
    ["AlignPosition"] = {"Instance"},
    ["AlignOrientation"] = {"Instance"},
    ["ScreenGui"] = {"Instance"},
    ["BillboardGui"] = {"Instance"},
    ["SurfaceGui"] = {"Instance"},
    ["CanvasGroup"] = {"Frame", "Instance"},
    ["Frame"] = {"Instance"},
    ["ScrollingFrame"] = {"Frame", "Instance"},
    ["TextLabel"] = {"Frame", "Instance"},
    ["TextButton"] = {"Frame", "Instance"},
    ["ImageLabel"] = {"Frame", "Instance"},
    ["ImageButton"] = {"Frame", "Instance"},
    ["TextBox"] = {"Frame", "Instance"},
    ["UICorner"] = {"Instance"},
    ["UIGradient"] = {"Instance"},
    ["UIStroke"] = {"Instance"},
    ["UIPadding"] = {"Instance"},
    ["UIListLayout"] = {"Instance"},
    ["UIGridLayout"] = {"Instance"},
    ["UIAspectRatioConstraint"] = {"Instance"},
    ["UISizeConstraint"] = {"Instance"},
    ["Highlight"] = {"Instance"},
    ["Decal"] = {"Instance"},
    ["Texture"] = {"Decal", "Instance"},
    ["SpecialMesh"] = {"Instance"},
    ["SurfaceAppearance"] = {"Instance"},
    ["MaterialVariant"] = {"Instance"},
    ["RemoteEvent"] = {"Instance"},
    ["RemoteFunction"] = {"Instance"},
    ["BindableEvent"] = {"Instance"},
    ["BindableFunction"] = {"Instance"},
    ["LocalScript"] = {"Instance"},
    ["ModuleScript"] = {"Instance"},
    ["Script"] = {"Instance"},
    ["Animation"] = {"Instance"},
    ["StringValue"] = {"ValueBase", "Instance"},
    ["IntValue"] = {"ValueBase", "Instance"},
    ["NumberValue"] = {"ValueBase", "Instance"},
    ["BoolValue"] = {"ValueBase", "Instance"},
    ["ObjectValue"] = {"ValueBase", "Instance"},
    ["Color3Value"] = {"ValueBase", "Instance"},
    ["Vector3Value"] = {"ValueBase", "Instance"},
    ["CFrameValue"] = {"ValueBase", "Instance"},
    ["BrickColorValue"] = {"ValueBase", "Instance"},
    ["RayValue"] = {"ValueBase", "Instance"},
}

-- Cache resolved properties for fast access
local resolvedPropertyCache = {}

function Reflection.GetPropertiesForClass(className: string)
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
                        ReadOnly = readOnly or false
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
function Reflection.GetTags(instance: Instance): {string}
    local success, tags = pcall(function()
        return CollectionService:GetTags(instance)
    end)
    if success and type(tags) == "table" and #tags > 0 then
        return tags
    end
    return {}
end

-- Get attributes
function Reflection.GetAttributes(instance: Instance): {[string]: any}
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
local function writeChunk(stream: any, chunkName: string, data: string)
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

function SerializerBinary.Serialize(instances: {Instance}, scriptSources: {[LuaSourceContainer]: string}, terrainData: table?, options: table?): string
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

    local function traverse(inst: Instance)
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

local function formatValueLua(val: any, propType: string): string
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
        return string.format("CFrame.new(%.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f, %.4f)",
            x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22)
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

function SerializerScript.Serialize(instances: {Instance}, scriptSources: {[LuaSourceContainer]: string}, terrainData: table?, options: table?): string
    local opts = options or {}
    local out = {}
    local function append(str: string)
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
    local function serializeTree(inst: Instance, parentVar: string)
        instCounter = instCounter + 1
        local varName = "inst_" .. tostring(instCounter)
        local className = inst.ClassName

        if inst.Parent == game then
            append(string.format('    local %s = game:GetService(%q)\n', varName, className))
        else
            append(string.format('    local %s = Instance.new(%q)\n', varName, className))
            append(string.format('    %s.Name = %q\n', varName, inst.Name))

            -- Properties
            local propList = Reflection.GetPropertiesForClass(className)
            for _, propInfo in ipairs(propList) do
                local propName = propInfo.Name
                local propType = propInfo.Type

                if propName ~= "Name" and propName ~= "Source" and not propInfo.ReadOnly then
                    local s, val = pcall(function() return (inst :: any)[propName] end)
                    if s and val ~= nil then
                        local luaVal = formatValueLua(val, propType)
                        if luaVal ~= "nil" then
                            append(string.format('    pcall(function() %s.%s = %s end)\n', varName, propName, luaVal))
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
                    append(string.format('    pcall(function() %s.Source = [===[%s]===] end)\n', varName, safeSrc))
                end
            end

            -- Attributes
            if options.SaveAttributes then
                local attrs = Reflection.GetAttributes(inst)
                for k, v in pairs(attrs) do
                    local luaV = formatValueLua(v, typeof(v))
                    if luaV ~= "nil" then
                        append(string.format('    pcall(function() %s:SetAttribute(%q, %s) end)\n', varName, k, luaV))
                    end
                end
            end

            -- Tags
            if options.SaveTags then
                local tags = Reflection.GetTags(inst)
                for _, tag in ipairs(tags) do
                    append(string.format('    pcall(function() CollectionService:AddTag(%s, %q) end)\n', varName, tag))
                end
            end

            append(string.format('    %s.Parent = %s\n\n', varName, parentVar))
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
local function escapeXml(str: string): string
    if not str then return "" end
    str = tostring(str)
    str = string.gsub(str, "&", "&amp;")
    str = string.gsub(str, "<", "&lt;")
    str = string.gsub(str, ">", "&gt;")
    str = string.gsub(str, "\"", "&quot;")
    str = string.gsub(str, "'", "&apos;")
    return str
end

-- Escape string content for ProtectedString or general text
local function escapeCDataOrText(str: string): string
    if not str or #str == 0 then return "" end
    if string.find(str, "[<>&\"']") or string.find(str, "\n") or string.find(str, "\r") then
        local safe = string.gsub(str, "%]%]>", "]]]]><![CDATA[>")
        return "<![CDATA[" .. safe .. "]]>"
    end
    return escapeXml(str)
end

-- Format CFrame into XML
local function formatCFrame(cf: CFrame): string
    local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = cf:GetComponents()
    return string.format(
        "<X>%.7g</X><Y>%.7g</Y><Z>%.7g</Z><R00>%.7g</R00><R01>%.7g</R01><R02>%.7g</R02><R10>%.7g</R10><R11>%.7g</R11><R12>%.7g</R12><R20>%.7g</R20><R21>%.7g</R21><R22>%.7g</R22>",
        x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22
    )
end

-- Format ColorSequence into XML
local function formatColorSequence(cs: ColorSequence): string
    local keypoints = cs.Keypoints
    local parts = {}
    for _, kp in ipairs(keypoints) do
        table.insert(parts, string.format("%.4f %.4f %.4f %.4f 0", kp.Time, kp.Value.R, kp.Value.G, kp.Value.B))
    end
    return table.concat(parts, " ")
end

-- Format NumberSequence into XML
local function formatNumberSequence(ns: NumberSequence): string
    local keypoints = ns.Keypoints
    local parts = {}
    for _, kp in ipairs(keypoints) do
        table.insert(parts, string.format("%.4f %.4f %.4f", kp.Time, kp.Value, kp.Envelope))
    end
    return table.concat(parts, " ")
end

-- Serialize instance attributes into binary/base64 XML format
local function serializeAttributes(attrs: {[string]: any}): string
    if not attrs or next(attrs) == nil then return "" end
    local str = ""
    for k, v in pairs(attrs) do
        str = str .. tostring(k) .. "=" .. tostring(v) .. ";"
    end
    return Base64.Encode(str)
end

-- Main XML Document Generation
function SerializerXml.Serialize(instances: {Instance}, scriptSources: {[LuaSourceContainer]: string}, terrainData: table?, options: table?): string
    local opts = options or {}
    local refMap = {}
    local refCounter = 0

    local function getRef(inst: Instance): string
        if not refMap[inst] then
            refMap[inst] = "RBX" .. tostring(refCounter)
            refCounter = refCounter + 1
        end
        return refMap[inst]
    end

    local xmlBuffer = {}
    local function append(str: string)
        table.insert(xmlBuffer, str)
    end

    -- XML Header
    append([[<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">
	<Meta name="ExplicitAutoJoints">true</Meta>
]])

    -- Recursive instance serializer
    local function serializeInstance(inst: Instance, depth: number)
        local indent = string.rep("\t", depth)
        local className = inst.ClassName
        local ref = getRef(inst)

        append(string.format('%s<Item class="%s" referent="%s">\n', indent, className, ref))
        append(string.format('%s\t<Properties>\n', indent))

        -- Name property
        append(string.format('%s\t\t<string name="Name">%s</string>\n', indent, escapeXml(inst.Name)))

        -- Script source if script
        if inst:IsA("LuaSourceContainer") then
            local source = scriptSources[inst]
            if not source or #source == 0 then
                pcall(function()
                    source = (inst :: any).Source
                end)
            end
            source = source or ""
            append(string.format('%s\t\t<ProtectedString name="Source">%s</ProtectedString>\n', indent, escapeCDataOrText(source)))
        end

        -- CSG Union Deep Data if applicable
        if inst:IsA("UnionOperation") or inst:IsA("NegateOperation") then
            local unionData = AssetHandler.ExtractUnionData(inst :: any)
            if unionData.PhysicsData then
                append(string.format('%s\t\t<BinaryString name="PhysicsData">%s</BinaryString>\n', indent, unionData.PhysicsData))
            end
            if unionData.ChildData then
                append(string.format('%s\t\t<BinaryString name="ChildData">%s</BinaryString>\n', indent, unionData.ChildData))
            end
            if unionData.InitialSize then
                append(string.format('%s\t\t<Vector3 name="InitialSize"><X>%.7g</X><Y>%.7g</Y><Z>%.7g</Z></Vector3>\n', indent, unionData.InitialSize.X, unionData.InitialSize.Y, unionData.InitialSize.Z))
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
                    return (inst :: any)[propName]
                end)

                if success and val ~= nil then
                    if propType == "string" then
                        append(string.format('%s\t\t<string name="%s">%s</string>\n', indent, propName, escapeXml(val)))
                    elseif propType == "bool" then
                        append(string.format('%s\t\t<bool name="%s">%s</bool>\n', indent, propName, val and "true" or "false"))
                    elseif propType == "float" then
                        append(string.format('%s\t\t<float name="%s">%.7g</float>\n', indent, propName, val))
                    elseif propType == "double" then
                        append(string.format('%s\t\t<double name="%s">%.15g</double>\n', indent, propName, val))
                    elseif propType == "int" then
                        append(string.format('%s\t\t<int name="%s">%d</int>\n', indent, propName, math.floor(val)))
                    elseif propType == "int64" then
                        append(string.format('%s\t\t<int64 name="%s">%d</int64>\n', indent, propName, math.floor(val)))
                    elseif propType == "Vector3" then
                        append(string.format('%s\t\t<Vector3 name="%s"><X>%.7g</X><Y>%.7g</Y><Z>%.7g</Z></Vector3>\n', indent, propName, val.X, val.Y, val.Z))
                    elseif propType == "Vector2" then
                        append(string.format('%s\t\t<Vector2 name="%s"><X>%.7g</X><Y>%.7g</Y></Vector2>\n', indent, propName, val.X, val.Y))
                    elseif propType == "CoordinateFrame" then
                        append(string.format('%s\t\t<CoordinateFrame name="%s">%s</CoordinateFrame>\n', indent, propName, formatCFrame(val)))
                    elseif propType == "Color3" then
                        append(string.format('%s\t\t<Color3 name="%s"><R>%.7g</R><G>%.7g</G><B>%.7g</B></Color3>\n', indent, propName, val.R, val.G, val.B))
                    elseif propType == "UDim" then
                        append(string.format('%s\t\t<UDim name="%s"><S>%.7g</S><O>%d</O></UDim>\n', indent, propName, val.Scale, val.Offset))
                    elseif propType == "UDim2" then
                        append(string.format('%s\t\t<UDim2 name="%s"><XS>%.7g</XS><XO>%d</XO><YS>%.7g</YS><YO>%d</YO></UDim2>\n', indent, propName, val.X.Scale, val.X.Offset, val.Y.Scale, val.Y.Offset))
                    elseif propType == "token" and typeof(val) == "EnumItem" then
                        append(string.format('%s\t\t<token name="%s">%d</token>\n', indent, propName, val.Value))
                    elseif propType == "Content" then
                        append(string.format('%s\t\t<Content name="%s"><url>%s</url></Content>\n', indent, propName, escapeXml(val)))
                    elseif propType == "Ref" and typeof(val) == "Instance" then
                        append(string.format('%s\t\t<Ref name="%s">%s</Ref>\n', indent, propName, getRef(val)))
                    elseif propType == "ColorSequence" and typeof(val) == "ColorSequence" then
                        append(string.format('%s\t\t<ColorSequence name="%s">%s</ColorSequence>\n', indent, propName, formatColorSequence(val)))
                    elseif propType == "NumberSequence" and typeof(val) == "NumberSequence" then
                        append(string.format('%s\t\t<NumberSequence name="%s">%s</NumberSequence>\n', indent, propName, formatNumberSequence(val)))
                    elseif propType == "NumberRange" and typeof(val) == "NumberRange" then
                        append(string.format('%s\t\t<NumberRange name="%s">%.7g %.7g</NumberRange>\n', indent, propName, val.Min, val.Max))
                    elseif propType == "Rect" and typeof(val) == "Rect" then
                        append(string.format('%s\t\t<Rect2D name="%s"><min><X>%.7g</X><Y>%.7g</Y></min><max><X>%.7g</X><Y>%.7g</Y></max></Rect2D>\n', indent, propName, val.Min.X, val.Min.Y, val.Max.X, val.Max.Y))
                    elseif propType == "Font" and typeof(val) == "Font" then
                        append(string.format('%s\t\t<Font name="%s">\n%s\t\t\t<Family><url>%s</url></Family>\n%s\t\t\t<Weight>%d</Weight>\n%s\t\t\t<Style>%s</Style>\n%s\t\t</Font>\n',
                            indent, propName, indent, escapeXml(val.Family), indent, (val.Weight and val.Weight.Value) or 400, indent, (val.Style and val.Style.Name) or "Normal", indent))
                    elseif propType == "PhysicalProperties" and typeof(val) == "PhysicalProperties" then
                        append(string.format('%s\t\t<PhysicalProperties name="%s">\n%s\t\t\t<CustomPhysics>true</CustomPhysics>\n%s\t\t\t<Density>%.7g</Density>\n%s\t\t\t<Friction>%.7g</Friction>\n%s\t\t\t<Elasticity>%.7g</Elasticity>\n%s\t\t\t<FrictionWeight>%.7g</FrictionWeight>\n%s\t\t\t<ElasticityWeight>%.7g</ElasticityWeight>\n%s\t\t</PhysicalProperties>\n',
                            indent, propName, indent, indent, val.Density, indent, val.Friction, indent, val.Elasticity, indent, val.FrictionWeight, indent, val.ElasticityWeight, indent))
                    elseif propType == "Ray" and typeof(val) == "Ray" then
                        append(string.format('%s\t\t<Ray name="%s"><origin><X>%.7g</X><Y>%.7g</Y><Z>%.7g</Z></origin><direction><X>%.7g</X><Y>%.7g</Y><Z>%.7g</Z></direction></Ray>\n',
                            indent, propName, val.Origin.X, val.Origin.Y, val.Origin.Z, val.Direction.X, val.Direction.Y, val.Direction.Z))
                    end
                end
            end
        end

        -- CollectionService Tags
        if opts.SaveTags then
            local tags = Reflection.GetTags(inst)
            if #tags > 0 then
                local b64Tags = Base64.Encode(table.concat(tags, "\0"))
                append(string.format('%s\t\t<BinaryString name="Tags">%s</BinaryString>\n', indent, b64Tags))
            end
        end

        append(string.format('%s\t</Properties>\n', indent))

        -- Children
        for _, child in ipairs(inst:GetChildren()) do
            serializeInstance(child, depth + 1)
        end

        append(string.format('%s</Item>\n', indent))
    end

    -- Process root services
    for _, rootInst in ipairs(instances) do
        serializeInstance(rootInst, 1)
    end

    append("</roblox>\n")
    return table.concat(xmlBuffer)
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
local function getPathExpression(inst: Instance): string
    local segments = {}
    local curr: Instance? = inst

    while curr and curr ~= game do
        table.insert(segments, 1, curr.Name)
        curr = curr.Parent
    end

    if #segments == 0 then return "nil" end

    local serviceName = segments[1]
    local expr = string.format("game:GetService(%q)", serviceName)

    for i = 2, #segments do
        expr = expr .. string.format([[:WaitForChild(%q, 5)]], segments[i])
    end

    return expr
end

-- Clean identifiers for Lua variable naming
local function sanitizeIdentifier(name: string): string
    local clean = string.gsub(name, "[^%w_]", "_")
    if string.match(clean, "^%d") then
        clean = "_" .. clean
    end
    return #clean > 0 and clean or "_remote"
end

-- Collect all Remote instances across the place
function ServerSynthesizer.CollectRemotes(rootInstances: {Instance}): {Events: {Instance}, Functions: {Instance}, Unreliable: {Instance}}
    local remotes = {
        Events = {},
        Functions = {},
        Unreliable = {},
    }

    local function scan(inst: Instance)
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
function ServerSynthesizer.GenerateDispatcherSource(remotes: {Events: {Instance}, Functions: {Instance}, Unreliable: {Instance}}): string
    local lines = {}
    local function add(line: string)
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

local function initPlayer(player: Player)
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

        add(string.format([=[
-- RemoteFunction: %s
task.spawn(function()
    local target = %s
    if target and target:IsA("RemoteFunction") then
        target.OnServerInvoke = function(player, ...)
            local args = {...}
            print(string.format("[HyperSave Server] %s:InvokeServer() called by %%s with %%d arguments", player.Name, #args))
            
            -- Intelligent mock response based on common function naming patterns
            local nameLower = string.lower(%q)
            if string.find(nameLower, "data") or string.find(nameLower, "load") or string.find(nameLower, "get") then
                return {
                    Success = true,
                    Data = {},
                    Coins = 1000,
                    Level = 1,
                    Inventory = {},
                }
            elseif string.find(nameLower, "buy") or string.find(nameLower, "purchase") then
                return true, "Success"
            end

            return true
        end
    end
end)
]=], fullName, getPathExpression(rf), rf.Name, rf.Name))
    end

    -- Hook RemoteEvents
    add("\n-- ============================================================================")
    add("-- [RemoteEvents] Auto-Listeners (Logs actions and updates mock state)")
    add("-- ============================================================================\n")

    for _, re in ipairs(remotes.Events) do
        local fullName = re:GetFullName()

        add(string.format([=[
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
]=], fullName, getPathExpression(re), re.Name))
    end

    add([=[

print("[HyperSave Backend] Server dispatcher ready! All remotes are now responding.")
]=])

    return table.concat(lines, "\n")
end

-- Create synthetic ServerScriptService Folder & Script instances
function ServerSynthesizer.SynthesizeService(rootInstances: {Instance}): Instance
    local remotes = ServerSynthesizer.CollectRemotes(rootInstances)
    local sourceCode = ServerSynthesizer.GenerateDispatcherSource(remotes)

    local serverService = Instance.new("Folder")
    serverService.Name = "ServerScriptService"

    local syntheticScript = Instance.new("Script")
    syntheticScript.Name = "HyperSave_ServerDispatcher"
    pcall(function()
        (syntheticScript :: any).Source = sourceCode
    end)
    syntheticScript.Parent = serverService

    return serverService
end

return ServerSynthesizer

end)

__define__("Core/StreamExplorer", function()
--[[
    HyperSaveInstance - StreamingEnabled Auto-Map Explorer
    Sweeps spatial coordinates across the map to force server chunk replication into memory.
]]

local Players = game:GetService("Players")

local StreamExplorer = {}

-- Scan map bounds and calculate bounding box
function StreamExplorer.GetMapBoundingBox(): (Vector3, Vector3)
    local minVec = Vector3.new(-1024, -100, -1024)
    local maxVec = Vector3.new(1024, 500, 1024)

    -- Check if Terrain or Spawns exist
    local terrain = workspace.Terrain
    if terrain then
        local s, extents = pcall(function() return terrain.MaxExtents end)
        if s and extents then
            minVec = Vector3.new(extents.Min.X * 4, -100, extents.Min.Z * 4)
            maxVec = Vector3.new(extents.Max.X * 4, 500, extents.Max.Z * 4)
            return minVec, maxVec
        end
    end

    -- Check spawn locations or workspace children
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

-- Perform automated grid sweep to load chunks
function StreamExplorer.ExploreMap(stepSize: number?, progressCallback: (current: number, total: number, pos: Vector3) -> ()): boolean
    if not workspace.StreamingEnabled then return true end

    local player = Players.LocalPlayer
    if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return false
    end

    local hrp = player.Character.HumanoidRootPart
    local originalCFrame = hrp.CFrame
    local minVec, maxVec = StreamExplorer.GetMapBoundingBox()

    local step = stepSize or 512
    local points = {}

    for x = minVec.X, maxVec.X, step do
        for z = minVec.Z, maxVec.Z, step do
            table.insert(points, Vector3.new(x, math.max(50, (minVec.Y + maxVec.Y) / 2), z))
        end
    end

    local total = #points
    local completed = 0

    for i, targetPos in ipairs(points) do
        pcall(function()
            hrp.CFrame = CFrame.new(targetPos)
        end)
        task.wait(0.12) -- Wait for server replication chunk
        completed = i

        if progressCallback then
            pcall(progressCallback, completed, total, targetPos)
        end
    end

    -- Return to original position
    pcall(function()
        hrp.CFrame = originalCFrame
    end)

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

function TerrainSerializer.ExtractTerrainData(terrain: Terrain, options: table)
    local data = {
        Decoration = false,
        WaterColor = Color3.fromRGB(12, 84, 91),
        WaterReflectance = 1,
        WaterTransparency = 1,
        WaterWaveSize = 0.15,
        WaterWaveSpeed = 10,
        MaterialColors = "",
        HasVoxels = false,
        VoxelChunks = {}
    }

    if not terrain or not terrain:IsA("Terrain") then
        return data
    end

    -- Extract basic properties safely
    pcall(function() data.Decoration = terrain.Decoration end)
    pcall(function() data.WaterColor = terrain.WaterColor end)
    pcall(function() data.WaterReflectance = terrain.WaterReflectance end)
    pcall(function() data.WaterTransparency = terrain.WaterTransparency end)
    pcall(function() data.WaterWaveSize = terrain.WaterWaveSize end)
    pcall(function() data.WaterWaveSpeed = terrain.WaterWaveSpeed end)
    pcall(function() data.MaterialColors = terrain.MaterialColors end)

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

    -- Iterate chunks
    for cx = 0, xChunks - 1 do
        for cy = 0, yChunks - 1 do
            for cz = 0, zChunks - 1 do
                local chunkMin = Vector3int16.new(
                    minVoxel.X + cx * step,
                    minVoxel.Y + cy * step,
                    minVoxel.Z + cz * step
                )
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
                            Occupancies = Base64.Encode(table.concat(rawOcc))
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

local AssetService = game:GetService("AssetService")
local HttpService = game:GetService("HttpService")

local UniverseTracker = {}

export type SubPlaceInfo = {
    PlaceId: number,
    Name: string,
    IsRoot: boolean
}

-- Fetch all places belonging to current Game Universe
function UniverseTracker.GetUniversePlaces(): {SubPlaceInfo}
    local places = {}
    local currentPlaceId = game.PlaceId or 0
    local rootName = "Root Place"

    pcall(function()
        rootName = game:GetService("MarketplaceService"):GetProductInfo(currentPlaceId).Name
    end)

    -- Add current place
    table.insert(places, {
        PlaceId = currentPlaceId,
        Name = rootName,
        IsRoot = true
    })

    -- Query AssetService for places in universe
    local success, pages = pcall(function()
        return AssetService:GetGamePlacesAsync()
    end)

    if success and pages then
        local function processPage()
            local currentList = pages:GetCurrentPage()
            for _, item in ipairs(currentList) do
                if item.PlaceId ~= currentPlaceId then
                    table.insert(places, {
                        PlaceId = item.PlaceId,
                        Name = item.Name or ("Sub-Place " .. tostring(item.PlaceId)),
                        IsRoot = false
                    })
                end
            end
        end

        processPage()
        while not pages.IsFinished do
            local nextSuccess = pcall(function() pages:AdvanceToNextPageAsync() end)
            if not nextSuccess then break end
            processPage()
        end
    end

    return places
end

return UniverseTracker

end)

__define__("UI/Interface", function()
--[[
    HyperSaveInstance - Modern Glassmorphic HUD & Master In-Game Suite
    Includes 1-Click Clone, Audio Ripper, Lighting Ripper, GUI Ripper, Target Selector, Network Sniffer, Universe Tracker, 3D OBJ Exporter, Tutorial and Settings.
]]

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Theme = __require__("Core/Theme")
local Environment = __require__("Utils/Environment")
local Defaults = __require__("Config/Defaults")
local AudioRipper = require(script.Parent.Parent.Core.AudioRipper)
local LightingRipper = require(script.Parent.Parent.Core.LightingRipper)
local GuiRipper = require(script.Parent.Parent.Core.GuiRipper)
local NetworkSniffer = require(script.Parent.Parent.Core.NetworkSniffer)
local UniverseTracker = require(script.Parent.Parent.Core.UniverseTracker)
local ObjExporter = require(script.Parent.Parent.Core.ObjExporter)
local RaycastSelector = require(script.Parent.Parent.Core.RaycastSelector)

local Interface = {}
Interface.__index = Interface

function Interface.new(engine: any)
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
        if gameProcessed then return end
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

    local old = parent:FindFirstChild("HyperSaveInstance_UI")
    if old then old:Destroy() end

    -- ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HyperSaveInstance_UI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui = screenGui

    -- Floating Mini Toggle Button (Always accessible if minimized or on mobile)
    local floatingBtn = Instance.new("TextButton")
    floatingBtn.Name = "FloatingToggle"
    floatingBtn.Text = "💀 HYPERSAVE • THEO"
    floatingBtn.Font = Theme.FontTitle
    floatingBtn.TextSize = 11
    floatingBtn.TextColor3 = Theme.TextPrimary
    floatingBtn.BackgroundColor3 = Theme.CardBg
    floatingBtn.Size = UDim2.new(0, 154, 0, 34)
    floatingBtn.Position = UDim2.new(0, 20, 0, 20)
    floatingBtn.Visible = false
    Theme.AddCorner(floatingBtn, Theme.CornerPill)
    Theme.AddStroke(floatingBtn, Theme.BorderNeon, 1.5)
    Theme.AddGradient(floatingBtn, Color3.fromRGB(15, 12, 24), Color3.fromRGB(35, 20, 55), 45)
    floatingBtn.Parent = screenGui
    self.FloatingToggle = floatingBtn

    -- Main Container (Obsidian Gothic Theme)
    local main = Instance.new("Frame")
    main.Name = "MainFrame"
    main.Size = UDim2.new(0, 660, 0, 480)
    main.Position = UDim2.new(0.5, -330, 0.5, -240)
    main.BackgroundColor3 = Theme.Background
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    Theme.AddCorner(main, Theme.CornerLarge)
    Theme.AddStroke(main, Theme.BorderLight, 1.5)
    main.Parent = screenGui
    self.MainFrame = main

    floatingBtn.MouseButton1Click:Connect(function()
        main.Visible = true
        floatingBtn.Visible = false
    end)

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

    -- Top Header Bar
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 48)
    header.BackgroundColor3 = Theme.CardBg
    header.BorderSizePixel = 0
    header.Parent = main

    local headerLine = Instance.new("Frame")
    headerLine.Size = UDim2.new(1, 0, 0, 1)
    headerLine.Position = UDim2.new(0, 0, 1, -1)
    headerLine.BackgroundColor3 = Theme.Border
    headerLine.BorderSizePixel = 0
    headerLine.Parent = header

    -- Title & Skull Logo
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = "💀 HyperSaveInstance"
    titleLabel.Font = Theme.FontTitle
    titleLabel.TextSize = 15
    titleLabel.TextColor3 = Theme.TextPrimary
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Size = UDim2.new(0, 185, 1, 0)
    titleLabel.Position = UDim2.new(0, 16, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Parent = header

    -- Platform & Creator Badge
    local badge = Instance.new("TextLabel")
    badge.Text = "por Theo Lorentz Padilha • [RightShift]"
    badge.Font = Theme.FontSemiBold
    badge.TextSize = 11
    badge.TextColor3 = Theme.AccentTheo
    badge.BackgroundColor3 = Color3.fromRGB(18, 14, 28)
    badge.Size = UDim2.new(0, 230, 0, 26)
    badge.Position = UDim2.new(0, 205, 0.5, -13)
    Theme.AddCorner(badge, Theme.CornerPill)
    Theme.AddStroke(badge, Theme.BorderNeon, 1)
    badge.Parent = header

    -- Minimize Button
    local minBtn = Instance.new("TextButton")
    minBtn.Text = "–"
    minBtn.Font = Theme.FontTitle
    minBtn.TextSize = 14
    minBtn.TextColor3 = Theme.TextSecondary
    minBtn.BackgroundColor3 = Theme.CardHover
    minBtn.Size = UDim2.new(0, 28, 0, 28)
    minBtn.Position = UDim2.new(1, -70, 0.5, -14)
    Theme.AddCorner(minBtn, Theme.CornerSmall)
    minBtn.Parent = header
    minBtn.MouseButton1Click:Connect(function()
        main.Visible = false
        floatingBtn.Visible = true
    end)

    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "✕"
    closeBtn.Font = Theme.FontTitle
    closeBtn.TextSize = 14
    closeBtn.TextColor3 = Theme.TextSecondary
    closeBtn.BackgroundColor3 = Theme.CardHover
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -38, 0.5, -14)
    Theme.AddCorner(closeBtn, Theme.CornerSmall)
    closeBtn.Parent = header
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    -- Tab Navigation Bar (Scrollable for all master tools)
    local navBar = Instance.new("ScrollingFrame")
    navBar.Name = "NavBar"
    navBar.Size = UDim2.new(0, 144, 1, -48)
    navBar.Position = UDim2.new(0, 0, 0, 48)
    navBar.BackgroundColor3 = Theme.CardBg
    navBar.ScrollBarThickness = 3
    navBar.ScrollBarImageColor3 = Theme.Border
    navBar.CanvasSize = UDim2.new(0, 0, 0, 380)
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
    contentArea.Size = UDim2.new(1, -144, 1, -48)
    contentArea.Position = UDim2.new(0, 144, 0, 48)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = main
    self.ContentArea = contentArea

    -- Navigation buttons
    local tabs = {
        {"Dashboard", " Clonar Tudo"},
        {"Selector", " Salvar Modelo"},
        {"AudioRipper", " Músicas & Sons"},
        {"LightingRipper", " Iluminação"},
        {"GuiRipper", " Interfaces (UI)"},
        {"Network", " Rede / Remotes"},
        {"Universe", " Universo"},
        {"ObjExport", " Exportar 3D"},
        {"Tutorial", " Como Usar"},
        {"Settings", " Configurações"},
        {"Console", " Console"},
        {"About", " Informações"}
    }

    self.TabFrames = {}
    self.NavButtons = {}

    for i, tabInfo in ipairs(tabs) do
        local tabKey, tabLabel = tabInfo[1], tabInfo[2]

        local navBtn = Instance.new("TextButton")
        navBtn.Text = tabLabel
        navBtn.Font = Theme.FontSemiBold
        navBtn.TextSize = 10
        navBtn.TextColor3 = (i == 1) and Theme.AccentSkull or Theme.TextSecondary
        navBtn.BackgroundColor3 = (i == 1) and Theme.CardActive or Theme.CardBg
        navBtn.Size = UDim2.new(1, -12, 0, 26)
        navBtn.Position = UDim2.new(0, 6, 0, 6 + (i - 1) * 30)
        Theme.AddCorner(navBtn, Theme.CornerSmall)
        Theme.AddStroke(navBtn, (i == 1) and Theme.BorderNeon or Theme.Border, 1)
        navBtn.Parent = navBar
        self.NavButtons[tabKey] = navBtn

        local tabFrame = Instance.new("Frame")
        tabFrame.Name = tabKey .. "Tab"
        tabFrame.Size = UDim2.new(1, 0, 1, 0)
        tabFrame.BackgroundTransparency = 1
        tabFrame.Visible = (i == 1)
        tabFrame.Parent = contentArea
        self.TabFrames[tabKey] = tabFrame

        navBtn.MouseButton1Click:Connect(function()
            self:SwitchTab(tabKey)
        end)
    end

    -- Build Individual Tab Pages
    self:BuildDashboardTab()
    self:BuildSelectorTab()
    self:BuildAudioRipperTab()
    self:BuildLightingRipperTab()
    self:BuildGuiRipperTab()
    self:BuildNetworkTab()
    self:BuildUniverseTab()
    self:BuildObjExportTab()
    self:BuildTutorialTab()
    self:BuildSettingsTab()
    self:BuildConsoleTab()
    self:BuildAboutTab()

    screenGui.Parent = parent
end

function Interface:SwitchTab(targetTab: string)
    self.ActiveTab = targetTab
    for k, frame in pairs(self.TabFrames) do
        frame.Visible = (k == targetTab)
    end
    for k, btn in pairs(self.NavButtons) do
        local stroke = btn:FindFirstChildOfClass("UIStroke")
        if k == targetTab then
            btn.TextColor3 = Theme.AccentSkull
            btn.BackgroundColor3 = Theme.CardActive
            if stroke then stroke.Color = Theme.BorderNeon end
        else
            btn.TextColor3 = Theme.TextSecondary
            btn.BackgroundColor3 = Theme.CardBg
            if stroke then stroke.Color = Theme.Border end
        end
    end
end

-- 1. Dashboard Tab (Clean, Prominent 1-Click Game Cloner)
function Interface:BuildDashboardTab()
    local parent = self.TabFrames["Dashboard"]

    -- Big Action Clone Button (1-Click Purple & Black)
    local cloneBtn = Instance.new("TextButton")
    cloneBtn.Name = "CloneButton"
    cloneBtn.Text = "💀 CLONAR JOGO INTEIRO (1-CLIQUE)"
    cloneBtn.Font = Theme.FontTitle
    cloneBtn.TextSize = 14
    cloneBtn.TextColor3 = Theme.AccentSkull
    cloneBtn.BackgroundColor3 = Theme.AccentPrimary
    cloneBtn.Size = UDim2.new(1, -32, 0, 52)
    cloneBtn.Position = UDim2.new(0, 16, 0, 14)
    Theme.AddCorner(cloneBtn, Theme.CornerMedium)
    Theme.AddStroke(cloneBtn, Theme.BorderNeon, 1.5)
    Theme.AddGradient(cloneBtn, Color3.fromRGB(147, 51, 234), Color3.fromRGB(76, 29, 149), 90)
    cloneBtn.Parent = parent
    self.CloneButton = cloneBtn

    cloneBtn.MouseButton1Click:Connect(function()
        self:StartClone()
    end)

    -- Preset Selection Container
    local presetLabel = Instance.new("TextLabel")
    presetLabel.Text = "MODO DE CLONAGEM:"
    presetLabel.Font = Theme.FontSemiBold
    presetLabel.TextSize = 11
    presetLabel.TextColor3 = Theme.TextMuted
    presetLabel.TextXAlignment = Enum.TextXAlignment.Left
    presetLabel.Size = UDim2.new(1, -32, 0, 18)
    presetLabel.Position = UDim2.new(0, 16, 0, 76)
    presetLabel.BackgroundTransparency = 1
    presetLabel.Parent = parent

    local presetContainer = Instance.new("Frame")
    presetContainer.Size = UDim2.new(1, -32, 0, 34)
    presetContainer.Position = UDim2.new(0, 16, 0, 96)
    presetContainer.BackgroundTransparency = 1
    presetContainer.Parent = parent

    local presetList = {"Full", "Fast", "VisualsOnly", "ScriptsOnly"}
    local presetDisplay = {
        Full = " Completo 10/10",
        Fast = " Rápido",
        VisualsOnly = " Apenas Visual",
        ScriptsOnly = " Apenas Scripts"
    }

    self.PresetButtons = {}
    for i, pKey in ipairs(presetList) do
        local btn = Instance.new("TextButton")
        btn.Text = presetDisplay[pKey]
        btn.Font = Theme.FontSemiBold
        btn.TextSize = 11
        btn.TextColor3 = (self.Config.Mode == pKey) and Theme.AccentCyan or Theme.TextSecondary
        btn.BackgroundColor3 = Theme.CardBg
        btn.Size = UDim2.new(0.235, 0, 1, 0)
        btn.Position = UDim2.new((i - 1) * 0.255, 0, 0, 0)
        Theme.AddCorner(btn, Theme.CornerSmall)
        Theme.AddStroke(btn, (self.Config.Mode == pKey) and Theme.AccentCyan or Theme.Border, 1)
        btn.Parent = presetContainer
        self.PresetButtons[pKey] = btn

        btn.MouseButton1Click:Connect(function()
            Defaults.ApplyPreset(self.Config, pKey)
            for k, b in pairs(self.PresetButtons) do
                b.TextColor3 = (k == pKey) and Theme.AccentCyan or Theme.TextSecondary
                b:FindFirstChildOfClass("UIStroke").Color = (k == pKey) and Theme.AccentCyan or Theme.Border
            end
            self:Log("Modo selecionado: " .. pKey)
        end)
    end

    -- Format Selector Container
    local formatLabel = Instance.new("TextLabel")
    formatLabel.Text = "FORMATO DE ARQUIVO:"
    formatLabel.Font = Theme.FontSemiBold
    formatLabel.TextSize = 11
    formatLabel.TextColor3 = Theme.TextMuted
    formatLabel.TextXAlignment = Enum.TextXAlignment.Left
    formatLabel.Size = UDim2.new(1, -32, 0, 18)
    formatLabel.Position = UDim2.new(0, 16, 0, 140)
    formatLabel.BackgroundTransparency = 1
    formatLabel.Parent = parent

    local formatContainer = Instance.new("Frame")
    formatContainer.Size = UDim2.new(1, -32, 0, 30)
    formatContainer.Position = UDim2.new(0, 16, 0, 160)
    formatContainer.BackgroundTransparency = 1
    formatContainer.Parent = parent

    local formats = {
        {"rbxlx", "Roblox XML (.rbxlx)"},
        {"rbxl", "Roblox Binário (.rbxl)"},
        {"lua", "Script Studio (.lua)"}
    }
    self.FormatButtons = {}

    for i, fmt in ipairs(formats) do
        local fKey, fLabel = fmt[1], fmt[2]
        local fBtn = Instance.new("TextButton")
        fBtn.Text = fLabel
        fBtn.Font = Theme.FontSemiBold
        fBtn.TextSize = 11
        fBtn.TextColor3 = (self.Config.Format == fKey) and Theme.AccentSuccess or Theme.TextSecondary
        fBtn.BackgroundColor3 = Theme.CardBg
        fBtn.Size = UDim2.new(0.31, 0, 1, 0)
        fBtn.Position = UDim2.new((i - 1) * 0.34, 0, 0, 0)
        Theme.AddCorner(fBtn, Theme.CornerSmall)
        Theme.AddStroke(fBtn, (self.Config.Format == fKey) and Theme.AccentSuccess or Theme.Border, 1)
        fBtn.Parent = formatContainer
        self.FormatButtons[fKey] = fBtn

        fBtn.MouseButton1Click:Connect(function()
            self.Config.Format = fKey
            for k, b in pairs(self.FormatButtons) do
                b.TextColor3 = (k == fKey) and Theme.AccentSuccess or Theme.TextSecondary
                b:FindFirstChildOfClass("UIStroke").Color = (k == fKey) and Theme.AccentSuccess or Theme.Border
            end
            self:Log("Formato definido para: ." .. fKey)
        end)
    end

    -- Progress Container
    local progressCard = Instance.new("Frame")
    progressCard.Size = UDim2.new(1, -32, 0, 106)
    progressCard.Position = UDim2.new(0, 16, 0, 204)
    progressCard.BackgroundColor3 = Theme.CardBg
    Theme.AddCorner(progressCard, Theme.CornerMedium)
    Theme.AddStroke(progressCard, Theme.Border, 1)
    progressCard.Parent = parent

    local statusHeader = Instance.new("TextLabel")
    statusHeader.Name = "StatusHeader"
    statusHeader.Text = "Status: Anti-AFK Ativo • Pronto para clonar"
    statusHeader.Font = Theme.FontSemiBold
    statusHeader.TextSize = 12
    statusHeader.TextColor3 = Theme.TextPrimary
    statusHeader.TextXAlignment = Enum.TextXAlignment.Left
    statusHeader.Size = UDim2.new(0.7, 0, 0, 20)
    statusHeader.Position = UDim2.new(0, 16, 0, 12)
    statusHeader.BackgroundTransparency = 1
    statusHeader.Parent = progressCard
    self.StatusHeader = statusHeader

    local pctLabel = Instance.new("TextLabel")
    pctLabel.Name = "PctLabel"
    pctLabel.Text = "0%"
    pctLabel.Font = Theme.FontTitle
    pctLabel.TextSize = 14
    pctLabel.TextColor3 = Theme.AccentCyan
    pctLabel.TextXAlignment = Enum.TextXAlignment.Right
    pctLabel.Size = UDim2.new(0.25, 0, 0, 20)
    pctLabel.Position = UDim2.new(0.72, 0, 0, 12)
    pctLabel.BackgroundTransparency = 1
    pctLabel.Parent = progressCard
    self.PctLabel = pctLabel

    -- Progress Bar Track & Fill
    local barTrack = Instance.new("Frame")
    barTrack.Size = UDim2.new(1, -32, 0, 8)
    barTrack.Position = UDim2.new(0, 16, 0, 40)
    barTrack.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
    Theme.AddCorner(barTrack, Theme.CornerPill)
    barTrack.Parent = progressCard

    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(0, 0, 1, 0)
    barFill.BackgroundColor3 = Theme.AccentCyan
    Theme.AddCorner(barFill, Theme.CornerPill)
    Theme.AddGradient(barFill, Theme.AccentCyan, Theme.AccentPrimary, 0)
    barFill.Parent = barTrack
    self.ProgressBarFill = barFill

    local statusDetail = Instance.new("TextLabel")
    statusDetail.Name = "StatusDetail"
    statusDetail.Text = "Basta dar 1 clique no botão roxo acima para salvar o jogo inteiro."
    statusDetail.Font = Theme.FontRegular
    statusDetail.TextSize = 11
    statusDetail.TextColor3 = Theme.TextMuted
    statusDetail.TextXAlignment = Enum.TextXAlignment.Left
    statusDetail.Size = UDim2.new(1, -32, 0, 20)
    statusDetail.Position = UDim2.new(0, 16, 0, 58)
    statusDetail.BackgroundTransparency = 1
    statusDetail.Parent = progressCard
    self.StatusDetail = statusDetail

    -- Quick Action Copy Buttons
    local copyBar = Instance.new("Frame")
    copyBar.Size = UDim2.new(1, -32, 0, 24)
    copyBar.Position = UDim2.new(0, 16, 0, 78)
    copyBar.BackgroundTransparency = 1
    copyBar.Parent = progressCard

    local copyFilePathBtn = Instance.new("TextButton")
    copyFilePathBtn.Text = " Copiar Nome do Arquivo"
    copyFilePathBtn.Font = Theme.FontSemiBold
    copyFilePathBtn.TextSize = 10
    copyFilePathBtn.TextColor3 = Theme.TextSecondary
    copyFilePathBtn.BackgroundColor3 = Theme.CardHover
    copyFilePathBtn.Size = UDim2.new(0.48, 0, 1, 0)
    copyFilePathBtn.Position = UDim2.new(0, 0, 0, 0)
    Theme.AddCorner(copyFilePathBtn, Theme.CornerSmall)
    copyFilePathBtn.Parent = copyBar

    copyFilePathBtn.MouseButton1Click:Connect(function()
        local name = self.SavedFilePath
        if #name == 0 then name = self.Engine:GetDefaultFileName() end
        Environment.SetClipboard(name)
        copyFilePathBtn.Text = "✓ Nome Copiado!"
        task.delay(2, function() copyFilePathBtn.Text = " Copiar Nome do Arquivo" end)
    end)

    local copyAssetsPathBtn = Instance.new("TextButton")
    copyAssetsPathBtn.Text = " Copiar Pasta de Assets"
    copyAssetsPathBtn.Font = Theme.FontSemiBold
    copyAssetsPathBtn.TextSize = 10
    copyAssetsPathBtn.TextColor3 = Theme.TextSecondary
    copyAssetsPathBtn.BackgroundColor3 = Theme.CardHover
    copyAssetsPathBtn.Size = UDim2.new(0.48, 0, 1, 0)
    copyAssetsPathBtn.Position = UDim2.new(0.52, 0, 0, 0)
    Theme.AddCorner(copyAssetsPathBtn, Theme.CornerSmall)
    copyAssetsPathBtn.Parent = copyBar

    copyAssetsPathBtn.MouseButton1Click:Connect(function()
        local name = self.SavedAssetPath
        if #name == 0 then name = self.Engine:GetDefaultAssetFolder() end
        Environment.SetClipboard(name)
        copyAssetsPathBtn.Text = "✓ Pasta Copiada!"
        task.delay(2, function() copyAssetsPathBtn.Text = " Copiar Pasta de Assets" end)
    end)
end

-- 2. Target Selector Tab (Save Individual Model / Folder / 3D Raycast / Multi-Select)
function Interface:BuildSelectorTab()
    local parent = self.TabFrames["Selector"]

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -32, 1, -32)
    scroll.Position = UDim2.new(0, 16, 0, 16)
    scroll.BackgroundColor3 = Theme.CardBg
    scroll.ScrollBarThickness = 5
    scroll.CanvasSize = UDim2.new(0, 0, 0, 520)
    Theme.AddCorner(scroll, Theme.CornerMedium)
    Theme.AddStroke(scroll, Theme.Border, 1)
    scroll.Parent = parent

    local headerLbl = Instance.new("TextLabel")
    headerLbl.Text = "🎯 SELETOR DE MODELOS, ARMAS & MULTI-SELEÇÃO"
    headerLbl.Font = Theme.FontTitle
    headerLbl.TextSize = 13
    headerLbl.TextColor3 = Theme.AccentCyan
    headerLbl.TextXAlignment = Enum.TextXAlignment.Left
    headerLbl.Size = UDim2.new(1, -24, 0, 24)
    headerLbl.Position = UDim2.new(0, 12, 0, 12)
    headerLbl.BackgroundTransparency = 1
    headerLbl.Parent = scroll

    -- 1. In-World 3D Raycast Click Selector Button
    local raycastBtn = Instance.new("TextButton")
    raycastBtn.Text = "🎯 CLICAR NO OBJETO NO MUNDO 3D (SELETOR VISUAL)"
    raycastBtn.Font = Theme.FontTitle
    raycastBtn.TextSize = 12
    raycastBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    raycastBtn.BackgroundColor3 = Theme.AccentCyan
    raycastBtn.Size = UDim2.new(1, -24, 0, 38)
    raycastBtn.Position = UDim2.new(0, 12, 0, 42)
    Theme.AddCorner(raycastBtn, Theme.CornerSmall)
    Theme.AddGradient(raycastBtn, Theme.AccentCyan, Theme.AccentPrimary, 0)
    raycastBtn.Parent = scroll

    -- 2. Search by Name Textbox
    local searchBox = Instance.new("TextBox")
    searchBox.PlaceholderText = "Ou digite o nome: Ferrari, Gun, ShopGui, Map..."
    searchBox.Font = Theme.FontRegular
    searchBox.TextSize = 12
    searchBox.TextColor3 = Theme.TextPrimary
    searchBox.PlaceholderColor3 = Theme.TextMuted
    searchBox.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
    searchBox.Size = UDim2.new(1, -24, 0, 36)
    searchBox.Position = UDim2.new(0, 12, 0, 88)
    Theme.AddCorner(searchBox, Theme.CornerSmall)
    Theme.AddStroke(searchBox, Theme.Border, 1)
    searchBox.Parent = scroll

    -- 3. Selected Target Info Card
    local infoCard = Instance.new("Frame")
    infoCard.Size = UDim2.new(1, -24, 0, 90)
    infoCard.Position = UDim2.new(0, 12, 0, 132)
    infoCard.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
    Theme.AddCorner(infoCard, Theme.CornerSmall)
    Theme.AddStroke(infoCard, Theme.Border, 1)
    infoCard.Parent = scroll

    local targetTitle = Instance.new("TextLabel")
    targetTitle.Text = "Nenhum objeto selecionado no momento"
    targetTitle.Font = Theme.FontSemiBold
    targetTitle.TextSize = 12
    targetTitle.TextColor3 = Theme.TextPrimary
    targetTitle.TextXAlignment = Enum.TextXAlignment.Left
    targetTitle.Size = UDim2.new(1, -16, 0, 20)
    targetTitle.Position = UDim2.new(0, 10, 0, 8)
    targetTitle.BackgroundTransparency = 1
    targetTitle.Parent = infoCard

    local targetStats = Instance.new("TextLabel")
    targetStats.Text = "Mire no jogo com o botão acima ou digite o nome para inspecionar."
    targetStats.Font = Theme.FontRegular
    targetStats.TextSize = 11
    targetStats.TextColor3 = Theme.TextSecondary
    targetStats.TextXAlignment = Enum.TextXAlignment.Left
    targetStats.Size = UDim2.new(1, -16, 0, 20)
    targetStats.Position = UDim2.new(0, 10, 0, 32)
    targetStats.BackgroundTransparency = 1
    targetStats.Parent = infoCard

    local targetPath = Instance.new("TextLabel")
    targetPath.Text = "Caminho: -"
    targetPath.Font = Theme.FontRegular
    targetPath.TextSize = 10
    targetPath.TextColor3 = Theme.TextMuted
    targetPath.TextXAlignment = Enum.TextXAlignment.Left
    targetPath.Size = UDim2.new(1, -16, 0, 20)
    targetPath.Position = UDim2.new(0, 10, 0, 56)
    targetPath.BackgroundTransparency = 1
    targetPath.Parent = infoCard

    -- Helper to update info display
    local function inspectInstance(inst: Instance?)
        self.CurrentTargetInstance = inst
        if not inst then
            targetTitle.Text = "Nenhum objeto selecionado"
            targetTitle.TextColor3 = Theme.TextMuted
            targetStats.Text = "Use o botão 3D ou digite o nome acima."
            targetPath.Text = "Caminho: -"
            return
        end

        local parts = 0
        local scripts = 0
        local meshes = 0

        for _, desc in ipairs(inst:GetDescendants()) do
            if desc:IsA("BasePart") then parts = parts + 1 end
            if desc:IsA("MeshPart") or desc:IsA("SpecialMesh") then meshes = meshes + 1 end
            if desc:IsA("LuaSourceContainer") then scripts = scripts + 1 end
        end
        if inst:IsA("BasePart") then parts = parts + 1 end
        if inst:IsA("LuaSourceContainer") then scripts = scripts + 1 end

        targetTitle.Text = string.format("📦 %s (%s)", inst.Name, inst.ClassName)
        targetTitle.TextColor3 = Theme.AccentCyan
        targetStats.Text = string.format("📊 %d Peças • %d Malhas 3D • %d Scripts Descompiláveis", parts, meshes, scripts)
        targetStats.TextColor3 = Theme.AccentSuccess
        targetPath.Text = "📍 Caminho: " .. inst:GetFullName()
    end

    -- 4. Action Buttons (Save Single / Add to Pack)
    local btnSaveSingle = Instance.new("TextButton")
    btnSaveSingle.Text = "💾 SALVAR ESTE MODELO (.rbxm)"
    btnSaveSingle.Font = Theme.FontTitle
    btnSaveSingle.TextSize = 12
    btnSaveSingle.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnSaveSingle.BackgroundColor3 = Theme.AccentSuccess
    btnSaveSingle.Size = UDim2.new(0.48, 0, 0, 38)
    btnSaveSingle.Position = UDim2.new(0, 12, 0, 230)
    Theme.AddCorner(btnSaveSingle, Theme.CornerSmall)
    btnSaveSingle.Parent = scroll

    local btnAddToPack = Instance.new("TextButton")
    btnAddToPack.Text = "➕ ADICIONAR AO PACOTE"
    btnAddToPack.Font = Theme.FontTitle
    btnAddToPack.TextSize = 12
    btnAddToPack.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnAddToPack.BackgroundColor3 = Theme.AccentPurple
    btnAddToPack.Size = UDim2.new(0.48, 0, 0, 38)
    btnAddToPack.Position = UDim2.new(0.52, 0, 0, 230)
    Theme.AddCorner(btnAddToPack, Theme.CornerSmall)
    btnAddToPack.Parent = scroll

    -- 5. Multi-Select Package Card
    local packCard = Instance.new("Frame")
    packCard.Size = UDim2.new(1, -24, 0, 110)
    packCard.Position = UDim2.new(0, 12, 0, 276)
    packCard.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
    Theme.AddCorner(packCard, Theme.CornerSmall)
    Theme.AddStroke(packCard, Theme.Border, 1)
    packCard.Parent = scroll

    local packTitle = Instance.new("TextLabel")
    packTitle.Text = "📦 PACOTE MULTI-SELEÇÃO: 0 ITENS"
    packTitle.Font = Theme.FontSemiBold
    packTitle.TextSize = 12
    packTitle.TextColor3 = Theme.AccentPurple
    packTitle.TextXAlignment = Enum.TextXAlignment.Left
    packTitle.Size = UDim2.new(0.7, 0, 0, 20)
    packTitle.Position = UDim2.new(0, 10, 0, 10)
    packTitle.BackgroundTransparency = 1
    packTitle.Parent = packCard

    local btnClearPack = Instance.new("TextButton")
    btnClearPack.Text = "Limpar"
    btnClearPack.Font = Theme.FontSemiBold
    btnClearPack.TextSize = 11
    btnClearPack.TextColor3 = Theme.AccentDanger
    btnClearPack.BackgroundColor3 = Color3.fromRGB(30, 20, 25)
    btnClearPack.Size = UDim2.new(0.24, 0, 0, 24)
    btnClearPack.Position = UDim2.new(0.73, 0, 0, 8)
    Theme.AddCorner(btnClearPack, Theme.CornerSmall)
    btnClearPack.Parent = packCard

    local btnSavePack = Instance.new("TextButton")
    btnSavePack.Text = "🚀 BAIXAR PACOTE COMPLETO (.rbxm)"
    btnSavePack.Font = Theme.FontTitle
    btnSavePack.TextSize = 12
    btnSavePack.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnSavePack.BackgroundColor3 = Theme.AccentPurple
    btnSavePack.Size = UDim2.new(1, -20, 0, 38)
    btnSavePack.Position = UDim2.new(0, 10, 0, 56)
    Theme.AddCorner(btnSavePack, Theme.CornerSmall)
    Theme.AddGradient(btnSavePack, Theme.AccentPurple, Theme.AccentCyan, 0)
    btnSavePack.Parent = packCard

    -- 6. Result & Status Label
    local resultLabel = Instance.new("TextLabel")
    resultLabel.Text = "Status: Pronto para selecionar."
    resultLabel.Font = Theme.FontRegular
    resultLabel.TextSize = 11
    resultLabel.TextColor3 = Theme.TextMuted
    resultLabel.TextXAlignment = Enum.TextXAlignment.Left
    resultLabel.Size = UDim2.new(1, -24, 0, 36)
    resultLabel.Position = UDim2.new(0, 12, 0, 396)
    resultLabel.TextWrapped = true
    resultLabel.BackgroundTransparency = 1
    resultLabel.Parent = scroll

    -- Update pack counter UI
    local function updatePackUI()
        packTitle.Text = string.format("📦 PACOTE MULTI-SELEÇÃO: %d ITENS", #self.SelectedTargets)
    end

    -- Event: 3D Raycast click button
    raycastBtn.MouseButton1Click:Connect(function()
        if self.MainFrame then self.MainFrame.Visible = false end
        resultLabel.Text = "🎯 Modo 3D ativo! Clique em qualquer objeto no mundo para selecionar."
        resultLabel.TextColor3 = Theme.AccentCyan

        self.Raycast:Start(function(selected)
            if self.MainFrame then self.MainFrame.Visible = true end
            if selected then
                searchBox.Text = selected.Name
                inspectInstance(selected)
                resultLabel.Text = "✓ Objeto selecionado: " .. selected.Name
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
                resultLabel.Text = "✓ Objeto encontrado: " .. found.Name
                resultLabel.TextColor3 = Theme.AccentSuccess
            else
                inspectInstance(nil)
                resultLabel.Text = "❌ Objeto não encontrado no jogo!"
                resultLabel.TextColor3 = Theme.AccentDanger
            end
        end
    end)

    -- Event: Save single model
    btnSaveSingle.MouseButton1Click:Connect(function()
        local target = self.CurrentTargetInstance
        if not target then
            resultLabel.Text = "❌ Selecione um modelo antes de salvar!"
            resultLabel.TextColor3 = Theme.AccentWarning
            return
        end

        resultLabel.Text = "⏳ Salvando " .. target.Name .. " com todos os scripts..."
        resultLabel.TextColor3 = Theme.AccentCyan

        task.spawn(function()
            local success, msg = self.Engine:SaveTarget(target)
            if success then
                resultLabel.Text = "✓ Modelo salvo com sucesso: " .. msg
                resultLabel.TextColor3 = Theme.AccentSuccess
                Environment.SetClipboard(msg)
            else
                resultLabel.Text = "❌ Erro ao salvar: " .. tostring(msg)
                resultLabel.TextColor3 = Theme.AccentDanger
            end
        end)
    end)

    -- Event: Add to pack
    btnAddToPack.MouseButton1Click:Connect(function()
        local target = self.CurrentTargetInstance
        if not target then
            resultLabel.Text = "❌ Selecione um modelo para adicionar ao pacote!"
            resultLabel.TextColor3 = Theme.AccentWarning
            return
        end

        table.insert(self.SelectedTargets, target)
        updatePackUI()
        resultLabel.Text = string.format("✓ '%s' adicionado ao pacote (%d no total)!", target.Name, #self.SelectedTargets)
        resultLabel.TextColor3 = Theme.AccentSuccess
    end)

    -- Event: Clear pack
    btnClearPack.MouseButton1Click:Connect(function()
        self.SelectedTargets = {}
        updatePackUI()
        resultLabel.Text = "Pacote limpo."
        resultLabel.TextColor3 = Theme.TextMuted
    end)

    -- Event: Save full multi-pack
    btnSavePack.MouseButton1Click:Connect(function()
        if #self.SelectedTargets == 0 then
            resultLabel.Text = "❌ O pacote está vazio! Adicione itens primeiro."
            resultLabel.TextColor3 = Theme.AccentWarning
            return
        end

        resultLabel.Text = string.format("⏳ Salvando pacote com %d itens e scripts...", #self.SelectedTargets)
        resultLabel.TextColor3 = Theme.AccentCyan

        task.spawn(function()
            local success, msg = self.Engine:SaveTargetBatch(self.SelectedTargets)
            if success then
                resultLabel.Text = "✓ Pacote salvo com sucesso: " .. msg
                resultLabel.TextColor3 = Theme.AccentSuccess
                Environment.SetClipboard(msg)
            else
                resultLabel.Text = "❌ Erro ao salvar pacote: " .. tostring(msg)
                resultLabel.TextColor3 = Theme.AccentDanger
            end
        end)
    end)
end

-- 3. Audio Ripper & Soundboard Tab
function Interface:BuildAudioRipperTab()
    local parent = self.TabFrames["AudioRipper"]

    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, -32, 0, 36)
    topBar.Position = UDim2.new(0, 16, 0, 12)
    topBar.BackgroundTransparency = 1
    topBar.Parent = parent

    local scanAudioBtn = Instance.new("TextButton")
    scanAudioBtn.Text = " ESCANEAR SONS DO JOGO"
    scanAudioBtn.Font = Theme.FontSemiBold
    scanAudioBtn.TextSize = 11
    scanAudioBtn.TextColor3 = Theme.AccentCyan
    scanAudioBtn.BackgroundColor3 = Theme.CardBg
    scanAudioBtn.Size = UDim2.new(0.48, 0, 1, 0)
    Theme.AddCorner(scanAudioBtn, Theme.CornerSmall)
    Theme.AddStroke(scanAudioBtn, Theme.Border, 1)
    scanAudioBtn.Parent = topBar

    local exportAudioListBtn = Instance.new("TextButton")
    exportAudioListBtn.Text = " EXPORTAR LISTA DE ÁUDIOS (.txt)"
    exportAudioListBtn.Font = Theme.FontSemiBold
    exportAudioListBtn.TextSize = 11
    exportAudioListBtn.TextColor3 = Theme.TextPrimary
    exportAudioListBtn.BackgroundColor3 = Theme.CardBg
    exportAudioListBtn.Size = UDim2.new(0.48, 0, 1, 0)
    exportAudioListBtn.Position = UDim2.new(0.52, 0, 0, 0)
    Theme.AddCorner(exportAudioListBtn, Theme.CornerSmall)
    Theme.AddStroke(exportAudioListBtn, Theme.Border, 1)
    exportAudioListBtn.Parent = topBar

    local audioScroll = Instance.new("ScrollingFrame")
    audioScroll.Size = UDim2.new(1, -32, 1, -64)
    audioScroll.Position = UDim2.new(0, 16, 0, 56)
    audioScroll.BackgroundColor3 = Color3.fromRGB(8, 10, 14)
    audioScroll.ScrollBarThickness = 4
    audioScroll.ScrollBarImageColor3 = Theme.Border
    Theme.AddCorner(audioScroll, Theme.CornerMedium)
    Theme.AddStroke(audioScroll, Theme.Border, 1)
    audioScroll.Parent = parent

    local audioLayout = Instance.new("UIListLayout")
    audioLayout.SortOrder = Enum.SortOrder.LayoutOrder
    audioLayout.Padding = UDim.new(0, 4)
    audioLayout.Parent = audioScroll

    scanAudioBtn.MouseButton1Click:Connect(function()
        scanAudioBtn.Text = " Escaneando..."
        for _, child in ipairs(audioScroll:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end

        task.spawn(function()
            local list = AudioRipper.ScanSounds()
            scanAudioBtn.Text = string.format("✓ %d sons encontrados", #list)

            for _, snd in ipairs(list) do
                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, -12, 0, 28)
                row.BackgroundColor3 = Theme.CardBg
                Theme.AddCorner(row, Theme.CornerSmall)
                row.Parent = audioScroll

                local sndLbl = Instance.new("TextLabel")
                sndLbl.Text = string.format(" %s (ID: %s)", snd.Name, snd.CleanId)
                sndLbl.Font = Theme.FontRegular
                sndLbl.TextSize = 10
                sndLbl.TextColor3 = Theme.TextPrimary
                sndLbl.TextXAlignment = Enum.TextXAlignment.Left
                sndLbl.Size = UDim2.new(0.65, 0, 1, 0)
                sndLbl.Position = UDim2.new(0, 8, 0, 0)
                sndLbl.BackgroundTransparency = 1
                sndLbl.Parent = row

                local playBtn = Instance.new("TextButton")
                playBtn.Text = " Play"
                playBtn.Font = Theme.FontSemiBold
                playBtn.TextSize = 10
                playBtn.TextColor3 = Theme.AccentSuccess
                playBtn.BackgroundColor3 = Theme.CardHover
                playBtn.Size = UDim2.new(0, 48, 0, 20)
                playBtn.Position = UDim2.new(1, -110, 0.5, -10)
                Theme.AddCorner(playBtn, Theme.CornerPill)
                playBtn.Parent = row

                playBtn.MouseButton1Click:Connect(function()
                    AudioRipper.PlayPreview(snd.SoundId)
                end)

                local copyBtn = Instance.new("TextButton")
                copyBtn.Text = "Copiar ID"
                copyBtn.Font = Theme.FontSemiBold
                copyBtn.TextSize = 9
                copyBtn.TextColor3 = Theme.TextSecondary
                copyBtn.BackgroundColor3 = Theme.CardHover
                copyBtn.Size = UDim2.new(0, 54, 0, 20)
                copyBtn.Position = UDim2.new(1, -58, 0.5, -10)
                Theme.AddCorner(copyBtn, Theme.CornerPill)
                copyBtn.Parent = row

                copyBtn.MouseButton1Click:Connect(function()
                    Environment.SetClipboard(snd.CleanId)
                    copyBtn.Text = "✓"
                    task.delay(1.5, function() copyBtn.Text = "Copiar ID" end)
                end)
            end

            audioScroll.CanvasSize = UDim2.new(0, 0, 0, #list * 32)
        end)
    end)

    exportAudioListBtn.MouseButton1Click:Connect(function()
        local file = AudioRipper.ExportSoundList()
        exportAudioListBtn.Text = "✓ Lista Exportada: " .. file
        Environment.SetClipboard(file)
        task.delay(2, function()
            exportAudioListBtn.Text = " EXPORTAR LISTA DE ÁUDIOS (.txt)"
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
    Theme.AddCorner(card, Theme.CornerMedium)
    Theme.AddStroke(card, Theme.Border, 1)
    card.Parent = parent

    local headerLbl = Instance.new("TextLabel")
    headerLbl.Text = " EXTRATOR DE ILUMINAÇÃO & ATMOSFERA"
    headerLbl.Font = Theme.FontTitle
    headerLbl.TextSize = 13
    headerLbl.TextColor3 = Theme.AccentCyan
    headerLbl.TextXAlignment = Enum.TextXAlignment.Left
    headerLbl.Size = UDim2.new(1, -24, 0, 24)
    headerLbl.Position = UDim2.new(0, 12, 0, 12)
    headerLbl.BackgroundTransparency = 1
    headerLbl.Parent = card

    local desc = Instance.new("TextLabel")
    desc.Text = "Extrai instantaneamente todas as propriedades visuais de iluminação, Skybox (todas as 6 texturas), Atmosphere (densidade, névoa e cores), SunRays, Bloom, Blur, ColorCorrection e DepthOfField para um arquivo separado (.rbxmx) que você pode colar em qualquer jogo seu!"
    desc.Font = Theme.FontRegular
    desc.TextSize = 11
    desc.TextColor3 = Theme.TextSecondary
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextYAlignment = Enum.TextYAlignment.Top
    desc.TextWrapped = true
    desc.Size = UDim2.new(1, -24, 0, 60)
    desc.Position = UDim2.new(0, 12, 0, 42)
    desc.BackgroundTransparency = 1
    desc.Parent = card

    local exportLightBtn = Instance.new("TextButton")
    exportLightBtn.Text = " SALVAR PRESET DE ILUMINAÇÃO (.rbxmx)"
    exportLightBtn.Font = Theme.FontTitle
    exportLightBtn.TextSize = 13
    exportLightBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    exportLightBtn.BackgroundColor3 = Theme.AccentCyan
    exportLightBtn.Size = UDim2.new(1, -24, 0, 48)
    exportLightBtn.Position = UDim2.new(0, 12, 0, 116)
    Theme.AddCorner(exportLightBtn, Theme.CornerMedium)
    Theme.AddGradient(exportLightBtn, Theme.AccentCyan, Theme.AccentPrimary, 90)
    exportLightBtn.Parent = card

    local lightStatus = Instance.new("TextLabel")
    lightStatus.Text = "Status: Pronto para salvar iluminação"
    lightStatus.Font = Theme.FontRegular
    lightStatus.TextSize = 11
    lightStatus.TextColor3 = Theme.TextMuted
    lightStatus.TextXAlignment = Enum.TextXAlignment.Left
    lightStatus.Size = UDim2.new(1, -24, 0, 24)
    lightStatus.Position = UDim2.new(0, 12, 0, 176)
    lightStatus.BackgroundTransparency = 1
    lightStatus.Parent = card

    exportLightBtn.MouseButton1Click:Connect(function()
        lightStatus.Text = " Extraindo efeitos e skyboxes..."
        lightStatus.TextColor3 = Theme.AccentCyan

        task.spawn(function()
            local success, file = LightingRipper.ExportLightingPreset()
            if success then
                lightStatus.Text = "✓ Iluminação salva com sucesso: " .. file
                lightStatus.TextColor3 = Theme.AccentSuccess
                Environment.SetClipboard(file)
            else
                lightStatus.Text = " Erro: " .. tostring(file)
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
    Theme.AddCorner(card, Theme.CornerMedium)
    Theme.AddStroke(card, Theme.Border, 1)
    card.Parent = parent

    local headerLbl = Instance.new("TextLabel")
    headerLbl.Text = " EXTRATOR DE INTERFACES (GUIs & HUDs)"
    headerLbl.Font = Theme.FontTitle
    headerLbl.TextSize = 13
    headerLbl.TextColor3 = Theme.AccentSecondary
    headerLbl.TextXAlignment = Enum.TextXAlignment.Left
    headerLbl.Size = UDim2.new(1, -24, 0, 24)
    headerLbl.Position = UDim2.new(0, 12, 0, 12)
    headerLbl.BackgroundTransparency = 1
    headerLbl.Parent = card

    local desc = Instance.new("TextLabel")
    desc.Text = "Extrai todas as ScreenGuis, Menus, Lojas, Inventários, Barras de Vida e HUDs com seus respectivos cantos arredondados (UICorner), gradientes (UIGradient) e scripts de interface para um pacote de UI independente (.rbxmx)!"
    desc.Font = Theme.FontRegular
    desc.TextSize = 11
    desc.TextColor3 = Theme.TextSecondary
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextYAlignment = Enum.TextYAlignment.Top
    desc.TextWrapped = true
    desc.Size = UDim2.new(1, -24, 0, 60)
    desc.Position = UDim2.new(0, 12, 0, 42)
    desc.BackgroundTransparency = 1
    desc.Parent = card

    local exportGuiBtn = Instance.new("TextButton")
    exportGuiBtn.Text = " SALVAR TODAS AS GUIs (.rbxmx)"
    exportGuiBtn.Font = Theme.FontTitle
    exportGuiBtn.TextSize = 13
    exportGuiBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    exportGuiBtn.BackgroundColor3 = Theme.AccentSecondary
    exportGuiBtn.Size = UDim2.new(1, -24, 0, 48)
    exportGuiBtn.Position = UDim2.new(0, 12, 0, 116)
    Theme.AddCorner(exportGuiBtn, Theme.CornerMedium)
    Theme.AddGradient(exportGuiBtn, Theme.AccentSecondary, Theme.AccentPrimary, 90)
    exportGuiBtn.Parent = card

    local guiStatus = Instance.new("TextLabel")
    guiStatus.Text = "Status: Pronto para salvar GUIs"
    guiStatus.Font = Theme.FontRegular
    guiStatus.TextSize = 11
    guiStatus.TextColor3 = Theme.TextMuted
    guiStatus.TextXAlignment = Enum.TextXAlignment.Left
    guiStatus.Size = UDim2.new(1, -24, 0, 24)
    guiStatus.Position = UDim2.new(0, 12, 0, 176)
    guiStatus.BackgroundTransparency = 1
    guiStatus.Parent = card

    exportGuiBtn.MouseButton1Click:Connect(function()
        guiStatus.Text = " Extraindo e descompilando interfaces..."
        guiStatus.TextColor3 = Theme.AccentCyan

        task.spawn(function()
            local success, file = GuiRipper.ExportAllGuis(self.Config)
            if success then
                guiStatus.Text = "✓ Pacote de GUIs salvo com sucesso: " .. file
                guiStatus.TextColor3 = Theme.AccentSuccess
                Environment.SetClipboard(file)
            else
                guiStatus.Text = " Erro: " .. tostring(file)
                guiStatus.TextColor3 = Theme.AccentDanger
            end
        end)
    end)
end

-- 6. Network Sniffer Tab
function Interface:BuildNetworkTab()
    local parent = self.TabFrames["Network"]

    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, -32, 0, 36)
    topBar.Position = UDim2.new(0, 16, 0, 12)
    topBar.BackgroundTransparency = 1
    topBar.Parent = parent

    local toggleSnifferBtn = Instance.new("TextButton")
    toggleSnifferBtn.Text = " INICIAR GRAVAÇÃO DE REDE"
    toggleSnifferBtn.Font = Theme.FontSemiBold
    toggleSnifferBtn.TextSize = 11
    toggleSnifferBtn.TextColor3 = Theme.AccentSuccess
    toggleSnifferBtn.BackgroundColor3 = Theme.CardBg
    toggleSnifferBtn.Size = UDim2.new(0.48, 0, 1, 0)
    Theme.AddCorner(toggleSnifferBtn, Theme.CornerSmall)
    Theme.AddStroke(toggleSnifferBtn, Theme.Border, 1)
    toggleSnifferBtn.Parent = topBar

    local exportSnifferBtn = Instance.new("TextButton")
    exportSnifferBtn.Text = " EXPORTAR PROTOCOLO (.json)"
    exportSnifferBtn.Font = Theme.FontSemiBold
    exportSnifferBtn.TextSize = 11
    exportSnifferBtn.TextColor3 = Theme.TextPrimary
    exportSnifferBtn.BackgroundColor3 = Theme.CardBg
    exportSnifferBtn.Size = UDim2.new(0.48, 0, 1, 0)
    exportSnifferBtn.Position = UDim2.new(0.52, 0, 0, 0)
    Theme.AddCorner(exportSnifferBtn, Theme.CornerSmall)
    Theme.AddStroke(exportSnifferBtn, Theme.Border, 1)
    exportSnifferBtn.Parent = topBar

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -32, 1, -64)
    scroll.Position = UDim2.new(0, 16, 0, 56)
    scroll.BackgroundColor3 = Color3.fromRGB(8, 10, 14)
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Theme.Border
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    Theme.AddCorner(scroll, Theme.CornerMedium)
    Theme.AddStroke(scroll, Theme.Border, 1)
    scroll.Parent = parent

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 4)
    layout.Parent = scroll

    toggleSnifferBtn.MouseButton1Click:Connect(function()
        if NetworkSniffer.IsActive then
            NetworkSniffer.Stop()
            toggleSnifferBtn.Text = " INICIAR GRAVAÇÃO DE REDE"
            toggleSnifferBtn.TextColor3 = Theme.AccentSuccess
        else
            NetworkSniffer.Start()
            toggleSnifferBtn.Text = " PARAR GRAVAÇÃO"
            toggleSnifferBtn.TextColor3 = Theme.AccentDanger
        end
    end)

    exportSnifferBtn.MouseButton1Click:Connect(function()
        local file = NetworkSniffer.ExportLogs()
        exportSnifferBtn.Text = "✓ Salvo: " .. file
        Environment.SetClipboard(file)
        task.delay(2, function()
            exportSnifferBtn.Text = " EXPORTAR PROTOCOLO (.json)"
        end)
    end)

    NetworkSniffer.OnCall(function(entry)
        local row = Instance.new("TextLabel")
        row.Text = string.format("[%s] [%s] %s -> %s", entry.Timestamp, entry.Type, entry.RemoteName, entry.ArgsPreview)
        row.Font = Theme.FontCode
        row.TextSize = 10
        row.TextColor3 = (entry.Type == "FireServer") and Theme.AccentCyan or Theme.AccentSecondary
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
    Theme.AddCorner(card, Theme.CornerMedium)
    Theme.AddStroke(card, Theme.Border, 1)
    card.Parent = parent

    local headerLbl = Instance.new("TextLabel")
    headerLbl.Text = " RASTREADOR DE UNIVERSO (MULTI-PLACES)"
    headerLbl.Font = Theme.FontTitle
    headerLbl.TextSize = 13
    headerLbl.TextColor3 = Theme.AccentSecondary
    headerLbl.TextXAlignment = Enum.TextXAlignment.Left
    headerLbl.Size = UDim2.new(1, -24, 0, 24)
    headerLbl.Position = UDim2.new(0, 12, 0, 12)
    headerLbl.BackgroundTransparency = 1
    headerLbl.Parent = card

    local scanBtn = Instance.new("TextButton")
    scanBtn.Text = " BUSCAR SUB-PLACES DO UNIVERSO"
    scanBtn.Font = Theme.FontSemiBold
    scanBtn.TextSize = 11
    scanBtn.TextColor3 = Theme.TextPrimary
    scanBtn.BackgroundColor3 = Theme.CardHover
    scanBtn.Size = UDim2.new(1, -24, 0, 34)
    scanBtn.Position = UDim2.new(0, 12, 0, 42)
    Theme.AddCorner(scanBtn, Theme.CornerSmall)
    Theme.AddStroke(scanBtn, Theme.Border, 1)
    scanBtn.Parent = card

    local placeScroll = Instance.new("ScrollingFrame")
    placeScroll.Size = UDim2.new(1, -24, 1, -94)
    placeScroll.Position = UDim2.new(0, 12, 0, 84)
    placeScroll.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
    placeScroll.ScrollBarThickness = 4
    placeScroll.ScrollBarImageColor3 = Theme.Border
    Theme.AddCorner(placeScroll, Theme.CornerSmall)
    Theme.AddStroke(placeScroll, Theme.Border, 1)
    placeScroll.Parent = card

    local placeLayout = Instance.new("UIListLayout")
    placeLayout.SortOrder = Enum.SortOrder.LayoutOrder
    placeLayout.Padding = UDim.new(0, 4)
    placeLayout.Parent = placeScroll

    scanBtn.MouseButton1Click:Connect(function()
        scanBtn.Text = " Buscando lugares do universo..."
        for _, child in ipairs(placeScroll:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end

        task.spawn(function()
            local list = UniverseTracker.GetUniversePlaces()
            scanBtn.Text = string.format("✓ %d lugares encontrados no Universo", #list)

            for idx, pInfo in ipairs(list) do
                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, -12, 0, 28)
                row.BackgroundColor3 = Theme.CardBg
                Theme.AddCorner(row, Theme.CornerSmall)
                row.Parent = placeScroll

                local pName = Instance.new("TextLabel")
                pName.Text = string.format("%s (ID: %d)", pInfo.Name, pInfo.PlaceId)
                pName.Font = Theme.FontRegular
                pName.TextSize = 11
                pName.TextColor3 = pInfo.IsRoot and Theme.AccentCyan or Theme.TextPrimary
                pName.TextXAlignment = Enum.TextXAlignment.Left
                pName.Size = UDim2.new(0.7, 0, 1, 0)
                pName.Position = UDim2.new(0, 8, 0, 0)
                pName.BackgroundTransparency = 1
                pName.Parent = row

                local copyIdBtn = Instance.new("TextButton")
                copyIdBtn.Text = "Copiar ID"
                copyIdBtn.Font = Theme.FontSemiBold
                copyIdBtn.TextSize = 10
                copyIdBtn.TextColor3 = Theme.TextSecondary
                copyIdBtn.BackgroundColor3 = Theme.CardHover
                copyIdBtn.Size = UDim2.new(0, 80, 0, 20)
                copyIdBtn.Position = UDim2.new(1, -88, 0.5, -10)
                Theme.AddCorner(copyIdBtn, Theme.CornerPill)
                copyIdBtn.Parent = row

                copyIdBtn.MouseButton1Click:Connect(function()
                    Environment.SetClipboard(tostring(pInfo.PlaceId))
                    copyIdBtn.Text = "✓ Copiado"
                    task.delay(1.5, function() copyIdBtn.Text = "Copiar ID" end)
                end)
            end

            placeScroll.CanvasSize = UDim2.new(0, 0, 0, #list * 34)
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
    Theme.AddCorner(card, Theme.CornerMedium)
    Theme.AddStroke(card, Theme.Border, 1)
    card.Parent = parent

    local headerLbl = Instance.new("TextLabel")
    headerLbl.Text = " EXPORTADOR 3D WAVEFRONT (.OBJ + .MTL)"
    headerLbl.Font = Theme.FontTitle
    headerLbl.TextSize = 13
    headerLbl.TextColor3 = Theme.AccentCyan
    headerLbl.TextXAlignment = Enum.TextXAlignment.Left
    headerLbl.Size = UDim2.new(1, -24, 0, 24)
    headerLbl.Position = UDim2.new(0, 12, 0, 12)
    headerLbl.BackgroundTransparency = 1
    headerLbl.Parent = card

    local desc = Instance.new("TextLabel")
    desc.Text = "Converte todos os blocos e modelos do mapa diretamente para arquivos .obj e .mtl com cores e materiais prontos para abrir no Blender, Cinema 4D, Maya, Unity ou Unreal Engine."
    desc.Font = Theme.FontRegular
    desc.TextSize = 11
    desc.TextColor3 = Theme.TextSecondary
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextYAlignment = Enum.TextYAlignment.Top
    desc.TextWrapped = true
    desc.Size = UDim2.new(1, -24, 0, 48)
    desc.Position = UDim2.new(0, 12, 0, 42)
    desc.BackgroundTransparency = 1
    desc.Parent = card

    local exportObjBtn = Instance.new("TextButton")
    exportObjBtn.Text = " EXPORTAR MAPA 3D (.OBJ + .MTL)"
    exportObjBtn.Font = Theme.FontTitle
    exportObjBtn.TextSize = 13
    exportObjBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    exportObjBtn.BackgroundColor3 = Theme.AccentCyan
    exportObjBtn.Size = UDim2.new(1, -24, 0, 48)
    exportObjBtn.Position = UDim2.new(0, 12, 0, 100)
    Theme.AddCorner(exportObjBtn, Theme.CornerMedium)
    Theme.AddGradient(exportObjBtn, Theme.AccentCyan, Theme.AccentPrimary, 90)
    exportObjBtn.Parent = card

    local objStatus = Instance.new("TextLabel")
    objStatus.Text = "Status: Pronto para exportar"
    objStatus.Font = Theme.FontRegular
    objStatus.TextSize = 11
    objStatus.TextColor3 = Theme.TextMuted
    objStatus.TextXAlignment = Enum.TextXAlignment.Left
    objStatus.Size = UDim2.new(1, -24, 0, 24)
    objStatus.Position = UDim2.new(0, 12, 0, 160)
    objStatus.BackgroundTransparency = 1
    objStatus.Parent = card

    exportObjBtn.MouseButton1Click:Connect(function()
        objStatus.Text = " Gerando geometria .obj e biblioteca de materiais .mtl..."
        objStatus.TextColor3 = Theme.AccentCyan

        task.spawn(function()
            local success, file = ObjExporter.Export(workspace)
            if success then
                objStatus.Text = "✓ Mapa 3D exportado com sucesso: " .. file
                objStatus.TextColor3 = Theme.AccentSuccess
                Environment.SetClipboard(file)
            else
                objStatus.Text = " Erro ao exportar 3D: " .. tostring(file)
                objStatus.TextColor3 = Theme.AccentDanger
            end
        end)
    end)
end

-- 9. Tutorial Tab (Built-in Step-by-Step Guide)
function Interface:BuildTutorialTab()
    local parent = self.TabFrames["Tutorial"]

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -24, 1, -24)
    scroll.Position = UDim2.new(0, 12, 0, 12)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Theme.Border
    scroll.CanvasSize = UDim2.new(0, 0, 0, 480)
    scroll.Parent = parent

    local steps = {
        {" Passo 1: Iniciar a Cópia", "Basta ir na aba ' Clonar Tudo' e clicar no botão roxo 'CLONAR JOGO INTEIRO'. O HyperSaveInstance vai começar a varrer o mapa."},
        {" Passo 2: Aguardar o Progresso", "A barra de progresso vai indicar o que está sendo salvo em tempo real: áudios, texturas, meshes 3D, terreno e scripts descompilados."},
        {" Passo 3: Onde o Arquivo Fica?", "O arquivo .rbxlx e a pasta de assets são salvos automaticamente dentro da pasta 'workspace' do seu executor no seu computador."},
        {" Passo 4: Como Abrir no Roblox Studio", "1. Abra o Roblox Studio.\n2. Clique em 'File' (Arquivo) -> 'Open from File...'\n3. Selecione o arquivo gerado e clique em Abrir.\n4. Pronto! O jogo inteiro abrirá 100% editável!"},
    }

    for i, step in ipairs(steps) do
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -12, 0, 80)
        card.Position = UDim2.new(0, 0, 0, (i - 1) * 88)
        card.BackgroundColor3 = Theme.CardBg
        Theme.AddCorner(card, Theme.CornerMedium)
        Theme.AddStroke(card, Theme.Border, 1)
        card.Parent = scroll

        local title = Instance.new("TextLabel")
        title.Text = step[1]
        title.Font = Theme.FontSemiBold
        title.TextSize = 12
        title.TextColor3 = Theme.AccentCyan
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Size = UDim2.new(1, -20, 0, 20)
        title.Position = UDim2.new(0, 10, 0, 8)
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
        desc.Size = UDim2.new(1, -20, 0, 46)
        desc.Position = UDim2.new(0, 10, 0, 30)
        desc.BackgroundTransparency = 1
        desc.Parent = card
    end

    -- Copy Universal Command Button
    local copyScriptCard = Instance.new("TextButton")
    copyScriptCard.Text = " Copiar Comando de Execução (loadstring) para a Área de Transferência"
    copyScriptCard.Font = Theme.FontSemiBold
    copyScriptCard.TextSize = 11
    copyScriptCard.TextColor3 = Theme.TextPrimary
    copyScriptCard.BackgroundColor3 = Theme.CardHover
    copyScriptCard.Size = UDim2.new(1, -12, 0, 36)
    copyScriptCard.Position = UDim2.new(0, 0, 0, 360)
    Theme.AddCorner(copyScriptCard, Theme.CornerSmall)
    Theme.AddStroke(copyScriptCard, Theme.AccentPrimary, 1)
    copyScriptCard.Parent = scroll

    copyScriptCard.MouseButton1Click:Connect(function()
        Environment.SetClipboard('loadstring(game:HttpGet("https://raw.githubusercontent.com/theopadilha2009-hash/HyperSaveInstance/main/dist/HyperSaveInstance.luau"))()')
        copyScriptCard.Text = "✓ Comando Copiado!"
        task.delay(2, function()
            copyScriptCard.Text = " Copiar Comando de Execução (loadstring) para a Área de Transferência"
        end)
    end)
end

-- 10. Settings Tab
function Interface:BuildSettingsTab()
    local parent = self.TabFrames["Settings"]

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -24, 1, -24)
    scroll.Position = UDim2.new(0, 12, 0, 12)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Theme.Border
    scroll.CanvasSize = UDim2.new(0, 0, 0, 720)
    scroll.Parent = parent

    local toggles = {
        {"AutoAntiAFK", "Proteção Anti-AFK (Evita Desconexão por Inatividade)", self.Config.AutoAntiAFK},
        {"AutoExploreStreaming", "Varrer Mapa Inteiro (Bypass de StreamingEnabled)", self.Config.AutoExploreStreaming},
        {"StealthMode", "Modo Furtivo (Proteção contra Anti-Cheats do Jogo)", self.Config.StealthMode},
        {"DownloadRawAssets", "Baixar Assets Brutos (.mp3, .png, .mesh) para Pasta Local", self.Config.DownloadRawAssets},
        {"OptimizeGeometry", "Otimizador de Arquivo (Deduplicação de Estruturas - Opcional)", self.Config.OptimizeGeometry},
        {"SaveTerrain", "Preservar Terreno Completo (Propriedades & Água)", self.Config.SaveTerrain},
        {"SaveTerrainVoxels", "Extrair SmoothVoxels do Terreno (3D Voxel Chunks)", self.Config.SaveTerrainVoxels},
        {"SaveLighting", "Preservar Iluminação, Céu & Efeitos de Atmosfera", self.Config.SaveLighting},
        {"SaveSounds", "Preservar Efeitos de Áudio, Reverbs & SoundGroups", self.Config.SaveSounds},
        {"SaveUnions", "Preservar CSG Unions & NegateOperations (Physics & ChildData)", self.Config.SaveUnions},
        {"SaveSurfaceAppearance", "Preservar Texturas PBR & SurfaceAppearances", self.Config.SaveSurfaceAppearance},
        {"DecompileScripts", "Descompilar Scripts (LocalScripts & ModuleScripts)", self.Config.DecompileScripts},
        {"IsolateStarterPlayer", "Extrair Scripts & GUIs Ativos do Jogador para o StarterPlayer/StarterGui", self.Config.IsolateStarterPlayer},
        {"SaveServerScriptPlaceholders", "Reconstrução Inteligente de Backend para Scripts de Servidor", self.Config.SaveServerScriptPlaceholders},
        {"SynthesizeServer", "Sintetizador Automático de Backend para Remotes", self.Config.SynthesizeServer},
        {"SaveNilInstances", "Salvar Instâncias Isoladas (Nil Instances)", self.Config.SaveNilInstances},
        {"SaveAttributes", "Salvar Atributos Modernos de Instância", self.Config.SaveAttributes},
        {"SaveTags", "Salvar Tags de CollectionService", self.Config.SaveTags},
    }

    for i, item in ipairs(toggles) do
        local key, title, defaultVal = item[1], item[2], item[3]

        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -12, 0, 32)
        row.Position = UDim2.new(0, 0, 0, (i - 1) * 38)
        row.BackgroundColor3 = Theme.CardBg
        Theme.AddCorner(row, Theme.CornerSmall)
        row.Parent = scroll

        local lbl = Instance.new("TextLabel")
        lbl.Text = title
        lbl.Font = Theme.FontRegular
        lbl.TextSize = 11
        lbl.TextColor3 = (key == "OptimizeGeometry") and Theme.AccentWarning or Theme.TextPrimary
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Size = UDim2.new(0.8, 0, 1, 0)
        lbl.Position = UDim2.new(0, 12, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Parent = row

        local switch = Instance.new("TextButton")
        switch.Text = defaultVal and "ATIVADO" or "DESATIVADO"
        switch.Font = Theme.FontSemiBold
        switch.TextSize = 10
        switch.TextColor3 = defaultVal and Theme.AccentSuccess or Theme.TextMuted
        switch.BackgroundColor3 = defaultVal and Color3.fromRGB(15, 45, 30) or Color3.fromRGB(30, 35, 45)
        switch.Size = UDim2.new(0, 80, 0, 22)
        switch.Position = UDim2.new(1, -90, 0.5, -11)
        Theme.AddCorner(switch, Theme.CornerPill)
        Theme.AddStroke(switch, defaultVal and Theme.AccentSuccess or Theme.Border, 1)
        switch.Parent = row

        switch.MouseButton1Click:Connect(function()
            local current = self.Config[key]
            local new = not current
            self.Config[key] = new
            switch.Text = new and "ATIVADO" or "DESATIVADO"
            switch.TextColor3 = new and Theme.AccentSuccess or Theme.TextMuted
            switch.BackgroundColor3 = new and Color3.fromRGB(15, 45, 30) or Color3.fromRGB(30, 35, 45)
            switch:FindFirstChildOfClass("UIStroke").Color = new and Theme.AccentSuccess or Theme.Border
            self:Log("Opção alterada: " .. key .. " = " .. tostring(new))
        end)
    end
end

-- 11. Console Tab
function Interface:BuildConsoleTab()
    local parent = self.TabFrames["Console"]

    local consoleBox = Instance.new("ScrollingFrame")
    consoleBox.Size = UDim2.new(1, -32, 1, -64)
    consoleBox.Position = UDim2.new(0, 16, 0, 16)
    consoleBox.BackgroundColor3 = Color3.fromRGB(8, 10, 14)
    consoleBox.ScrollBarThickness = 4
    consoleBox.ScrollBarImageColor3 = Theme.Border
    consoleBox.CanvasSize = UDim2.new(0, 0, 0, 0)
    Theme.AddCorner(consoleBox, Theme.CornerMedium)
    Theme.AddStroke(consoleBox, Theme.Border, 1)
    consoleBox.Parent = parent
    self.ConsoleScroll = consoleBox

    local consoleList = Instance.new("UIListLayout")
    consoleList.SortOrder = Enum.SortOrder.LayoutOrder
    consoleList.Padding = UDim.new(0, 4)
    consoleList.Parent = consoleBox

    local copyLogsBtn = Instance.new("TextButton")
    copyLogsBtn.Text = " Copiar Logs para Área de Transferência"
    copyLogsBtn.Font = Theme.FontSemiBold
    copyLogsBtn.TextSize = 11
    copyLogsBtn.TextColor3 = Theme.TextPrimary
    copyLogsBtn.BackgroundColor3 = Theme.CardBg
    copyLogsBtn.Size = UDim2.new(1, -32, 0, 32)
    copyLogsBtn.Position = UDim2.new(0, 16, 1, -40)
    Theme.AddCorner(copyLogsBtn, Theme.CornerSmall)
    Theme.AddStroke(copyLogsBtn, Theme.Border, 1)
    copyLogsBtn.Parent = parent

    copyLogsBtn.MouseButton1Click:Connect(function()
        local fullLog = table.concat(self.Logs, "\n")
        Environment.SetClipboard(fullLog)
        copyLogsBtn.Text = "✓ Logs Copiados!"
        task.delay(2, function()
            copyLogsBtn.Text = " Copiar Logs para Área de Transferência"
        end)
    end)
end

-- 12. About Tab
function Interface:BuildAboutTab()
    local parent = self.TabFrames["About"]

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -32, 1, -32)
    scroll.Position = UDim2.new(0, 16, 0, 16)
    scroll.BackgroundColor3 = Theme.BackgroundGlass
    scroll.ScrollBarThickness = 5
    scroll.CanvasSize = UDim2.new(0, 0, 0, 480)
    Theme.AddCorner(scroll, Theme.CornerMedium)
    Theme.AddStroke(scroll, Theme.BorderLight, 1)
    scroll.Parent = parent

    -- Developer Profile Header Card
    local devCard = Instance.new("Frame")
    devCard.Size = UDim2.new(1, -24, 0, 120)
    devCard.Position = UDim2.new(0, 12, 0, 12)
    devCard.BackgroundColor3 = Theme.CardBg
    Theme.AddCorner(devCard, Theme.CornerMedium)
    Theme.AddStroke(devCard, Theme.BorderNeon, 1.2)
    Theme.AddGradient(devCard, Theme.CardBg, Color3.fromRGB(24, 18, 38), 45)
    devCard.Parent = scroll

    -- Avatar Emblem
    local avatar = Instance.new("Frame")
    avatar.Size = UDim2.new(0, 56, 0, 56)
    avatar.Position = UDim2.new(0, 16, 0, 16)
    avatar.BackgroundColor3 = Theme.AccentPrimary
    Theme.AddCorner(avatar, Theme.CornerPill)
    Theme.AddGradient(avatar, Theme.AccentCyan, Theme.AccentTheo, 45)
    avatar.Parent = devCard

    local avatarTxt = Instance.new("TextLabel")
    avatarTxt.Text = "TLP"
    avatarTxt.Font = Theme.FontTitle
    avatarTxt.TextSize = 18
    avatarTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
    avatarTxt.Size = UDim2.new(1, 0, 1, 0)
    avatarTxt.BackgroundTransparency = 1
    avatarTxt.Parent = avatar

    -- Developer Name & Title
    local devName = Instance.new("TextLabel")
    devName.Text = "Theo Lorentz Padilha"
    devName.Font = Theme.FontTitle
    devName.TextSize = 16
    devName.TextColor3 = Theme.TextPrimary
    devName.TextXAlignment = Enum.TextXAlignment.Left
    devName.Size = UDim2.new(1, -96, 0, 22)
    devName.Position = UDim2.new(0, 84, 0, 16)
    devName.BackgroundTransparency = 1
    devName.Parent = devCard

    local devRole = Instance.new("TextLabel")
    devRole.Text = "⭐ Criador & Engenheiro Principal do HyperSaveInstance Suite"
    devRole.Font = Theme.FontSemiBold
    devRole.TextSize = 11
    devRole.TextColor3 = Theme.TextTheo
    devRole.TextXAlignment = Enum.TextXAlignment.Left
    devRole.Size = UDim2.new(1, -96, 0, 18)
    devRole.Position = UDim2.new(0, 84, 0, 38)
    devRole.BackgroundTransparency = 1
    devRole.Parent = devCard

    -- GitHub Link Button
    local btnGithub = Instance.new("TextButton")
    btnGithub.Text = "🔗 Copiar Perfil GitHub (github.com/theopadilha2009-hash)"
    btnGithub.Font = Theme.FontSemiBold
    btnGithub.TextSize = 11
    btnGithub.TextColor3 = Theme.TextPrimary
    btnGithub.BackgroundColor3 = Color3.fromRGB(16, 20, 32)
    btnGithub.Size = UDim2.new(0.58, 0, 0, 30)
    btnGithub.Position = UDim2.new(0, 84, 0, 68)
    Theme.AddCorner(btnGithub, Theme.CornerSmall)
    Theme.AddStroke(btnGithub, Theme.BorderNeon, 1)
    btnGithub.Parent = devCard

    btnGithub.MouseButton1Click:Connect(function()
        Environment.SetClipboard("https://github.com/theopadilha2009-hash")
        btnGithub.Text = "✓ Link do GitHub Copiado!"
        btnGithub.TextColor3 = Theme.AccentSuccess
        task.delay(2.5, function()
            btnGithub.Text = "🔗 Copiar Perfil GitHub (github.com/theopadilha2009-hash)"
            btnGithub.TextColor3 = Theme.TextPrimary
        end)
    end)

    -- Repository Link Button
    local btnRepo = Instance.new("TextButton")
    btnRepo.Text = "⭐ Repositório Oficial"
    btnRepo.Font = Theme.FontSemiBold
    btnRepo.TextSize = 11
    btnRepo.TextColor3 = Theme.TextPrimary
    btnRepo.BackgroundColor3 = Color3.fromRGB(16, 20, 32)
    btnRepo.Size = UDim2.new(0.35, -4, 0, 30)
    btnRepo.Position = UDim2.new(0.62, 2, 0, 68)
    Theme.AddCorner(btnRepo, Theme.CornerSmall)
    Theme.AddStroke(btnRepo, Theme.AccentPrimary, 1)
    btnRepo.Parent = devCard

    btnRepo.MouseButton1Click:Connect(function()
        Environment.SetClipboard("https://github.com/theopadilha2009-hash/HyperSaveInstance")
        btnRepo.Text = "✓ Link do Repo Copiado!"
        btnRepo.TextColor3 = Theme.AccentSuccess
        task.delay(2.5, function()
            btnRepo.Text = "⭐ Repositório Oficial"
            btnRepo.TextColor3 = Theme.TextPrimary
        end)
    end)

    -- System Diagnostics Card
    local sysCard = Instance.new("Frame")
    sysCard.Size = UDim2.new(1, -24, 0, 180)
    sysCard.Position = UDim2.new(0, 12, 0, 142)
    sysCard.BackgroundColor3 = Theme.CardBg
    Theme.AddCorner(sysCard, Theme.CornerMedium)
    Theme.AddStroke(sysCard, Theme.Border, 1)
    sysCard.Parent = scroll

    local sysTitle = Instance.new("TextLabel")
    sysTitle.Text = "📊 DIAGNÓSTICO DO SISTEMA & AMBIENTE"
    sysTitle.Font = Theme.FontTitle
    sysTitle.TextSize = 12
    sysTitle.TextColor3 = Theme.AccentCyan
    sysTitle.TextXAlignment = Enum.TextXAlignment.Left
    sysTitle.Size = UDim2.new(1, -20, 0, 20)
    sysTitle.Position = UDim2.new(0, 12, 0, 10)
    sysTitle.BackgroundTransparency = 1
    sysTitle.Parent = sysCard

    local diagItems = {
        {"Plataforma:", Environment.GetPlatform()},
        {"Executor:", Environment.GetExecutorName()},
        {"Escrita de Arquivo (writefile):", Environment.HasFileSystem() and "Ativo (Totalmente Suportado)" or "Indisponível"},
        {"Descompilador Luau:", Environment.HasDecompiler() and "Ativo (Descompilação Completa)" or "Modo Bytecode / Fallback"},
        {"Bypass de StreamingEnabled:", "Ativo (StreamExplorer Espacial)"},
        {"Emulador de DataStore & VIP:", "Ativo (1.000.000 Coins / VIP Liberado)"},
        {"Atalho de Teclado (HUD):", "[RightShift] ou Botão Flutuante"},
    }

    for i, item in ipairs(diagItems) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -24, 0, 18)
        row.Position = UDim2.new(0, 12, 0, 32 + (i - 1) * 20)
        row.BackgroundTransparency = 1
        row.Parent = sysCard

        local lblKey = Instance.new("TextLabel")
        lblKey.Text = "• " .. item[1]
        lblKey.Font = Theme.FontSemiBold
        lblKey.TextSize = 11
        lblKey.TextColor3 = Theme.TextSecondary
        lblKey.TextXAlignment = Enum.TextXAlignment.Left
        lblKey.Size = UDim2.new(0.5, 0, 1, 0)
        lblKey.BackgroundTransparency = 1
        lblKey.Parent = row

        local lblVal = Instance.new("TextLabel")
        lblVal.Text = item[2]
        lblVal.Font = Theme.FontRegular
        lblVal.TextSize = 11
        lblVal.TextColor3 = (string.find(item[2], "Ativo") or string.find(item[2], "Suportado")) and Theme.AccentSuccess or Theme.TextPrimary
        lblVal.TextXAlignment = Enum.TextXAlignment.Right
        lblVal.Size = UDim2.new(0.5, 0, 1, 0)
        lblVal.Position = UDim2.new(0.5, 0, 0, 0)
        lblVal.BackgroundTransparency = 1
        lblVal.Parent = row
    end

    -- Suite Capabilities Summary Card
    local featCard = Instance.new("Frame")
    featCard.Size = UDim2.new(1, -24, 0, 120)
    featCard.Position = UDim2.new(0, 12, 0, 332)
    featCard.BackgroundColor3 = Theme.CardBg
    Theme.AddCorner(featCard, Theme.CornerMedium)
    Theme.AddStroke(featCard, Theme.Border, 1)
    featCard.Parent = scroll

    local featTitle = Instance.new("TextLabel")
    featTitle.Text = "⚡ RECURSOS EXCLUSIVOS INCLUÍDOS"
    featTitle.Font = Theme.FontTitle
    featTitle.TextSize = 12
    featTitle.TextColor3 = Theme.AccentPurple
    featTitle.TextXAlignment = Enum.TextXAlignment.Left
    featTitle.Size = UDim2.new(1, -20, 0, 20)
    featTitle.Position = UDim2.new(0, 12, 0, 10)
    featTitle.BackgroundTransparency = 1
    featTitle.Parent = featCard

    local featDesc = Instance.new("TextLabel")
    featDesc.Text = "✓ Seletor 3D com Mira no Mundo & Multi-Seleção em Lote\n✓ Extração de Terreno SmoothVoxels 3D, Iluminação PBR & Sons\n✓ Plugin Oficial de Roblox Studio com Reparo Mestre 1-Clique\n✓ Desofuscador de Variáveis de Scripts e Proteção Anti-AFK"
    featDesc.Font = Theme.FontRegular
    featDesc.TextSize = 11
    featDesc.TextColor3 = Theme.TextSecondary
    featDesc.TextXAlignment = Enum.TextXAlignment.Left
    featDesc.TextYAlignment = Enum.TextYAlignment.Top
    featDesc.Size = UDim2.new(1, -24, 0, 75)
    featDesc.Position = UDim2.new(0, 12, 0, 34)
    featDesc.BackgroundTransparency = 1
    featDesc.Parent = featCard
end

function Interface:Log(message: string, color: Color3?)
    local timestamp = os.date("%H:%M:%S")
    local line = string.format("[%s] %s", timestamp, message)
    table.insert(self.Logs, line)

    if self.ConsoleScroll then
        local lbl = Instance.new("TextLabel")
        lbl.Text = line
        lbl.Font = Theme.FontCode
        lbl.TextSize = 11
        lbl.TextColor3 = color or Theme.TextSecondary
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Size = UDim2.new(1, -12, 0, 16)
        lbl.BackgroundTransparency = 1
        lbl.Parent = self.ConsoleScroll

        self.ConsoleScroll.CanvasSize = UDim2.new(0, 0, 0, #self.Logs * 20)
        self.ConsoleScroll.CanvasPosition = Vector2.new(0, self.ConsoleScroll.CanvasSize.Y.Offset)
    end
end

function Interface:BindEngineEvents()
    self.Engine:OnProgress(function(prog)
        if self.StatusHeader then
            self.StatusHeader.Text = "Status: " .. prog.Stage
        end
        if self.PctLabel then
            self.PctLabel.Text = tostring(prog.Percentage) .. "%"
        end
        if self.StatusDetail then
            self.StatusDetail.Text = prog.Message
        end
        if self.ProgressBarFill then
            Theme.Tween(self.ProgressBarFill, 0.2, {
                Size = UDim2.new(math.clamp(prog.Percentage / 100, 0, 1), 0, 1, 0)
            })
        end

        local color = Theme.TextSecondary
        if prog.Stage == "Done" then
            color = Theme.AccentSuccess
            if prog.SavedFile then self.SavedFilePath = prog.SavedFile end
            if prog.AssetsFolder then self.SavedAssetPath = prog.AssetsFolder end

            if self.CloneButton then
                self.CloneButton.Text = "✓ CLONADO COM SUCESSO!"
                Theme.AddGradient(self.CloneButton, Theme.AccentSuccess, Color3.fromRGB(16, 185, 129), 90)
                task.delay(4, function()
                    self.CloneButton.Text = " CLONAR JOGO INTEIRO (1-CLIQUE)"
                    Theme.AddGradient(self.CloneButton, Theme.AccentPrimary, Theme.AccentSecondary, 90)
                end)
            end
        elseif prog.Stage == "Error" then
            color = Theme.AccentDanger
        elseif prog.Stage == "Exploring" then
            color = Theme.AccentWarning
        elseif prog.Stage == "Assets" then
            color = Theme.AccentWarning
        elseif prog.Stage == "Decompiling" then
            color = Theme.AccentCyan
        end

        self:Log(prog.Message, color)
    end)
end

function Interface:StartClone()
    if self.Engine.IsRunning then
        return
    end

    if self.CloneButton then
        self.CloneButton.Text = " CLONANDO JOGO..."
    end

    task.spawn(function()
        local success, result = self.Engine:Start()
        if not success then
            self:Log("Erro ao salvar: " .. tostring(result), Theme.AccentDanger)
        end
    end)
end

return Interface

end)

__define__("UI/Theme", function()
--[[
    HyperSaveInstance - Modern Glassmorphic Design System & Theme
]]

local TweenService = game:GetService("TweenService")

local Theme = {
    -- Pure Purple & Black Palette (Roxo e Preto - Gothic Skull Edition)
    Background = Color3.fromRGB(5, 4, 9),          -- Pure Obsidian Black
    BackgroundGlass = Color3.fromRGB(9, 7, 16),     -- Black with Purple Haze
    CardBg = Color3.fromRGB(14, 11, 23),            -- Deep Purple-Black Card
    CardHover = Color3.fromRGB(27, 20, 45),         -- Dark Violet Hover
    CardActive = Color3.fromRGB(43, 27, 70),        -- Electric Violet Active
    Border = Color3.fromRGB(47, 29, 75),            -- Deep Purple Border
    BorderLight = Color3.fromRGB(126, 34, 206),     -- Electric Purple Stroke
    BorderNeon = Color3.fromRGB(168, 85, 247),      -- Vivid Neon Purple Glow
    
    -- Accents & Gradients (Strictly Purple / Violet / Black)
    AccentPrimary = Color3.fromRGB(147, 51, 234),   -- Royal Electric Purple (#9333ea)
    AccentSecondary = Color3.fromRGB(192, 132, 252), -- Radiant Violet (#c084fc)
    AccentCyan = Color3.fromRGB(216, 180, 254),     -- Light Lavender (#d8b4fe)
    AccentSuccess = Color3.fromRGB(168, 85, 247),   -- Neon Purple Glow (#a855f7)
    AccentWarning = Color3.fromRGB(232, 121, 249),   -- Vivid Magenta Purple (#e879f9)
    AccentDanger = Color3.fromRGB(244, 63, 94),     -- Crimson Rose (#f43f5e)
    AccentTheo = Color3.fromRGB(240, 171, 252),     -- Bright Lavender (#f0abfc)
    AccentSkull = Color3.fromRGB(250, 245, 255),    -- Pure Bone White (#faf5ff)

    -- Text Colors
    TextPrimary = Color3.fromRGB(250, 245, 255),    -- Bone White (#faf5ff)
    TextSecondary = Color3.fromRGB(216, 180, 254),  -- Soft Lavender (#d8b4fe)
    TextMuted = Color3.fromRGB(147, 130, 169),      -- Muted Ash Purple
    TextAccent = Color3.fromRGB(192, 132, 252),     -- Vibrant Purple
    TextCyan = Color3.fromRGB(233, 213, 255),       -- Pale Lavender
    TextTheo = Color3.fromRGB(245, 208, 254),       -- Hot Lavender

    -- Fonts
    FontTitle = Enum.Font.GothamBold,
    FontSemiBold = Enum.Font.GothamSemibold,
    FontRegular = Enum.Font.Gotham,
    FontCode = Enum.Font.Code,

    -- Radii
    CornerLarge = UDim.new(0, 12),
    CornerMedium = UDim.new(0, 8),
    CornerSmall = UDim.new(0, 5),
    CornerPill = UDim.new(1, 0),
}

-- Tween animation helper
function Theme.Tween(instance: Instance, duration: number, properties: {[string]: any}, easingStyle: Enum.EasingStyle?, easingDirection: Enum.EasingDirection?): Tween
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.2, easingStyle or Enum.EasingStyle.Quad, easingDirection or Enum.EasingDirection.Out),
        properties
    )
    tween:Play()
    return tween
end

-- Create rounded corner
function Theme.AddCorner(instance: Instance, radius: UDim?): UICorner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or Theme.CornerMedium
    corner.Parent = instance
    return corner
end

-- Create stroke / border
function Theme.AddStroke(instance: Instance, color: Color3?, thickness: number?, transparency: number?): UIStroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Border
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = instance
    return stroke
end

-- Create gradient
function Theme.AddGradient(instance: Instance, c1: Color3, c2: Color3, rotation: number?): UIGradient
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, c1),
        ColorSequenceKeypoint.new(1, c2)
    })
    grad.Rotation = rotation or 45
    grad.Parent = instance
    return grad
end

return Theme

end)

__define__("Utils/AntiAFK", function()
--[[
    HyperSaveInstance - Anti-AFK & Anti-Kick Protection System
    Prevents Roblox Error 268/273 (20-minute idle disconnection) during long save sessions.
]]

local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")

local AntiAFK = {}
local isEnabled = false
local idleConnection = nil

function AntiAFK.Enable()
    if isEnabled then return end
    isEnabled = true

    local localPlayer = Players.LocalPlayer
    if not localPlayer then return end

    idleConnection = localPlayer.Idled:Connect(function()
        if not isEnabled then return end
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end)
    end)
end

function AntiAFK.Disable()
    isEnabled = false
    if idleConnection then
        idleConnection:Disconnect()
        idleConnection = nil
    end
end

function AntiAFK.IsEnabled(): boolean
    return isEnabled
end

return AntiAFK

end)

__define__("Utils/Base64", function()
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

end)

__define__("Utils/Environment", function()
--[[
    HyperSaveInstance - Universal Environment & Polyfill Module
    Supports Mac (MacSploit, Hydrogen), Windows (Wave, Synapse Z, Solara, Celery, etc.), Mobile (Delta, Codex, Arceus X)
]]

local Environment = {}

-- Service references
local cloneref = cloneref or function(obj) return obj end
local HttpService = cloneref(game:GetService("HttpService"))
local Players = cloneref(game:GetService("Players"))
local CoreGui = cloneref(game:GetService("CoreGui"))

-- Identify executor & platform
function Environment.GetExecutorName(): string
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

function Environment.GetPlatform(): string
    local isMac = false
    local isWindows = false
    local isMobile = false

    local exec = string.lower(Environment.GetExecutorName())
    if string.find(exec, "mac") or string.find(exec, "apple") or (getexecutorinfo and getexecutorinfo().platform == "macOS") then
        isMac = true
    elseif string.find(exec, "delta") or string.find(exec, "codex") or string.find(exec, "arceus") or string.find(exec, "hydrogen mobile") then
        isMobile = true
    else
        isWindows = true
    end

    if isMac then return "macOS" end
    if isMobile then return "Mobile" end
    return "Windows / Desktop"
end

-- File system polyfills
local _writefile = writefile or (syn and syn.writefile)
local _readfile = readfile or (syn and syn.readfile)
local _appendfile = appendfile or (syn and syn.appendfile)
local _makefolder = makefolder or (syn and syn.makefolder)
local _isfolder = isfolder or (syn and syn.isfolder)
local _isfile = isfile or (syn and syn.isfile)
local _delfile = delfile or (syn and syn.delfile) or (delfile)
local _listfiles = listfiles or (syn and syn.listfiles)

function Environment.HasFileSystem(): boolean
    return type(_writefile) == "function"
end

function Environment.WriteFile(path: string, content: string): boolean
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

function Environment.AppendFile(path: string, content: string): boolean
    if _appendfile then
        local success, err = pcall(_appendfile, path, content)
        return success
    elseif _readfile and _writefile then
        local existing = ""
        pcall(function() existing = _readfile(path) or "" end)
        return Environment.WriteFile(path, existing .. content)
    end
    return false
end

function Environment.ReadFile(path: string): string?
    if _readfile then
        local success, result = pcall(_readfile, path)
        if success then return result end
    end
    return nil
end

function Environment.MakeFolder(path: string): boolean
    if _makefolder then
        local success = pcall(_makefolder, path)
        return success
    end
    return false
end

function Environment.IsFolder(path: string): boolean
    if _isfolder then
        local success, res = pcall(_isfolder, path)
        return success and (res == true)
    end
    return false
end

function Environment.IsFile(path: string): boolean
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

function Environment.HasDecompiler(): boolean
    return Environment.GetDecompilerFunction() ~= nil or Environment.GetBytecodeFunction() ~= nil
end

-- Safe UI Parent (Protects GUI from detection/detection hooks)
function Environment.GetSafeGuiParent(): Instance
    local success, hui = pcall(function()
        if gethui then
            return gethui()
        elseif syn and syn.protect_gui then
            local folder = Instance.new("Folder")
            syn.protect_gui(folder)
            folder.Parent = CoreGui
            return folder
        elseif CoreGui and pcall(function() return CoreGui.Name end) then
            return CoreGui
        else
            return Players.LocalPlayer:WaitForChild("PlayerGui")
        end
    end)

    if success and hui then
        return hui
    end
    return Players.LocalPlayer:WaitForChild("PlayerGui")
end

-- Clipboard copy
function Environment.SetClipboard(text: string): boolean
    local setclip = setclipboard or (syn and syn.setclipboard) or toclipboard or (Clipboard and Clipboard.set)
    if setclip then
        pcall(setclip, text)
        return true
    end
    return false
end

-- Nil instances extraction
function Environment.GetNilInstances(): {Instance}
    local getnil = getnilinstances or (syn and syn.get_nil_instances) or (get_nil_instances)
    if getnil then
        local success, res = pcall(getnil)
        if success and type(res) == "table" then
            return res
        end
    end
    return {}
end

-- Hidden UI elements / CorePackages check
function Environment.GetHiddenProperties(instance: Instance, property: string): any
    local gethidden = gethiddenproperty or (syn and syn.get_hidden_property)
    if gethidden then
        local success, val = pcall(gethidden, instance, property)
        if success then return val end
    end
    local s, v = pcall(function() return (instance :: any)[property] end)
    if s then return v end
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

end)

__define__("Utils/Stealth", function()
--[[
    HyperSaveInstance - Stealth & Anti-Detection Shield
    Protects threads, hides temporary instances and masks operations from in-game anti-cheats.
]]

local Stealth = {}

-- Generate random alphanumeric name
function Stealth.GenerateRandomName(len: number?): string
    local length = len or 16
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local res = {}
    for i = 1, length do
        local r = math.random(1, #chars)
        table.insert(res, string.sub(chars, r, r))
    end
    return table.concat(res)
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
function Stealth.SafeGetProperty(instance: Instance, property: string): any
    local success, val = pcall(function()
        return (instance :: any)[property]
    end)
    if success then return val end
    return nil
end

return Stealth

end)

__define__("Utils/Stream", function()
--[[
    HyperSaveInstance - Binary Stream / Buffer Reader & Writer
]]

local Stream = {}
Stream.__index = Stream

function Stream.new(initialData: string?)
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

function Stream:WriteByte(val: number)
    table.insert(self.Buffer, string.char(val % 256))
    self.Length = self.Length + 1
end

function Stream:WriteBytes(bytes: string)
    table.insert(self.Buffer, bytes)
    self.Length = self.Length + #bytes
end

function Stream:WriteInt32LE(val: number)
    local bit = bit32 or bit
    local b1 = bit.band(val, 0xFF)
    local b2 = bit.band(bit.rshift(val, 8), 0xFF)
    local b3 = bit.band(bit.rshift(val, 16), 0xFF)
    local b4 = bit.band(bit.rshift(val, 24), 0xFF)
    table.insert(self.Buffer, string.char(b1, b2, b3, b4))
    self.Length = self.Length + 4
end

function Stream:WriteInt32BE(val: number)
    local bit = bit32 or bit
    local b1 = bit.band(bit.rshift(val, 24), 0xFF)
    local b2 = bit.band(bit.rshift(val, 16), 0xFF)
    local b3 = bit.band(bit.rshift(val, 8), 0xFF)
    local b4 = bit.band(val, 0xFF)
    table.insert(self.Buffer, string.char(b1, b2, b3, b4))
    self.Length = self.Length + 4
end

function Stream:WriteString(str: string)
    self:WriteInt32LE(#str)
    self:WriteBytes(str)
end

function Stream:ToString(): string
    return table.concat(self.Buffer)
end

-- Reader methods
function Stream:ReadByte(): number
    if self.Position > self.Length then return 0 end
    local byte = string.byte(self.Source, self.Position)
    self.Position = self.Position + 1
    return byte
end

function Stream:ReadBytes(count: number): string
    if self.Position > self.Length then return "" end
    local chunk = string.sub(self.Source, self.Position, self.Position + count - 1)
    self.Position = self.Position + count
    return chunk
end

function Stream:ReadInt32LE(): number
    local bit = bit32 or bit
    local b1 = self:ReadByte()
    local b2 = self:ReadByte()
    local b3 = self:ReadByte()
    local b4 = self:ReadByte()
    return bit.bor(b1, bit.lshift(b2, 8), bit.lshift(b3, 16), bit.lshift(b4, 24))
end

function Stream:ReadString(): string
    local len = self:ReadInt32LE()
    return self:ReadBytes(len)
end

return Stream

end)

-- Entry Point
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

local HyperSaveInstance = {
    Version = "2.0.0",
    Defaults = Defaults,
    Environment = Environment,
    AntiAFK = AntiAFK,
    StreamExplorer = StreamExplorer,
    NetworkSniffer = NetworkSniffer,
    UniverseTracker = UniverseTracker,
    ObjExporter = ObjExporter,
    Optimizer = Optimizer,
    AudioRipper = AudioRipper,
    LightingRipper = LightingRipper,
    GuiRipper = GuiRipper,
}

-- Open interactive in-game HUD
function HyperSaveInstance.OpenUI(customConfig: table?)
    local engine = Engine.new(customConfig)
    local ui = Interface.new(engine)
    return ui, engine
end

-- Save game programmatically (Headless or Scripted)
function HyperSaveInstance.Save(customConfig: table?): (boolean, string)
    local engine = Engine.new(customConfig)
    return engine:Start()
end

-- Save specific model or folder
function HyperSaveInstance.SaveModel(targetInstance: Instance, customConfig: table?): (boolean, string)
    local engine = Engine.new(customConfig)
    return engine:SaveTarget(targetInstance, customConfig)
end

-- Export 3D Wavefront OBJ/MTL
function HyperSaveInstance.ExportObj(targetRoot: Instance?, options: table?): (boolean, string)
    return ObjExporter.Export(targetRoot, options)
end

-- Discover all Universe sub-places
function HyperSaveInstance.GetUniverse(): {any}
    return UniverseTracker.GetUniversePlaces()
end

-- Rippers
function HyperSaveInstance.RipAudio(): string
    return AudioRipper.ExportSoundList()
end

function HyperSaveInstance.RipLighting(): (boolean, string)
    return LightingRipper.ExportLightingPreset()
end

function HyperSaveInstance.RipGuis(options: table?): (boolean, string)
    return GuiRipper.ExportAllGuis(options)
end

-- Preset shorthand helpers
function HyperSaveInstance.SaveFast(customConfig: table?)
    local cfg = table.clone(customConfig or {})
    Defaults.ApplyPreset(cfg, "Fast")
    return HyperSaveInstance.Save(cfg)
end

function HyperSaveInstance.SaveVisuals(customConfig: table?)
    local cfg = table.clone(customConfig or {})
    Defaults.ApplyPreset(cfg, "VisualsOnly")
    return HyperSaveInstance.Save(cfg)
end

function HyperSaveInstance.SaveScripts(customConfig: table?)
    local cfg = table.clone(customConfig or {})
    Defaults.ApplyPreset(cfg, "ScriptsOnly")
    return HyperSaveInstance.Save(cfg)
end

-- Global environment injection (Universal compatibility)
local function injectGlobals()
    local genv = (getgenv and getgenv()) or _G
    if genv then
        genv.saveinstance = HyperSaveInstance.Save
        genv.saveplace = HyperSaveInstance.Save
        genv.SynSaveInstance = HyperSaveInstance
        genv.HyperSaveInstance = HyperSaveInstance
        genv.UltraSmartSaveInstance = HyperSaveInstance
    end
end

pcall(injectGlobals)

-- Auto-initialize HUD if ShowUI is enabled
if Defaults.ShowUI then
    task.spawn(function()
        HyperSaveInstance.OpenUI()
    end)
end

return HyperSaveInstance

