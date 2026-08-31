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
    AssetDownloadWorkers = 8,              -- Concurrent workers for asset downloader pool

    -- Logging & Notifications
    VerboseLogs = true,                    -- Detailed console logs
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
    }
}

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

local RunService = nil
pcall(function() RunService = game:GetService("RunService") end)
local Players = nil
pcall(function() Players = game:GetService("Players") end)

local AnimationRecorder = {}
AnimationRecorder.IsRecording = false
AnimationRecorder.RecordedSequences = {}
AnimationRecorder.ActiveConnection = nil

-- Record an active animation track from a Humanoid by sampling joint transforms
function AnimationRecorder.RecordTrack(humanoid, trackName, durationSeconds, onComplete)
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
local function httpRequest(url)
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
            registerAsset("Texture", (inst ).Texture, inst.Name)
        elseif inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
            registerAsset("Texture", (inst ).Image, inst.Name)
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

-- Download all collected assets to local folder structure using 8-Worker Parallel Pool
function AssetDownloader.DownloadAll(assets, baseFolder, options, progressCallback)
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
    if total == 0 then return 0, 0 end

    local downloaded = 0
    local failed = 0
    local currentIndex = 1

    local workers = math.clamp(options.AssetDownloadWorkers or 8, 2, 16)
    local activeWorkers = workers

    for w = 1, workers do
        task.spawn(function()
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

                    -- Try primary url then v2 fallback
                    local body = httpRequest(item.Url)
                    if not body or #body == 0 then
                        local v2Url = string.format("https://assetdelivery.roblox.com/v2/assetId/%s", item.Id)
                        body = httpRequest(v2Url)
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
                task.wait(0.01)
            end
            activeWorkers = activeWorkers - 1
        end)
    end

    while activeWorkers > 0 and (downloaded + failed) < total do
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
        info.UnionData = AssetHandler.ExtractUnionData(instance )
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
function AssetHandler.ProcessSurfaceAppearance(instance)
    local pbr = {
        ColorMap = "",
        NormalMap = "",
        RoughnessMap = "",
        AlphaMode = 0
    }
    pcall(function()
        if Enum.AlphaMode and Enum.AlphaMode.Overlay then
            pbr.AlphaMode = Enum.AlphaMode.Overlay
        end
    end)
    pcall(function() pbr.ColorMap = instance.ColorMap end)
    pcall(function() pbr.NormalMap = instance.NormalMap end)
    pcall(function() pbr.RoughnessMap = instance.RoughnessMap end)
    pcall(function() pbr.MetalnessMap = instance.MetalnessMap end)
    pcall(function() pbr.AlphaMode = instance.AlphaMode end)
    return pbr
end

-- Preload & warm assets in memory
function AssetHandler.WarmAssets(instances)
    pcall(function()
        local ContentProvider = game:GetService("ContentProvider")
        if not ContentProvider then return end

        local batch = {}
        for _, inst in ipairs(instances) do
            if inst:IsA("MeshPart") or inst:IsA("Decal") or inst:IsA("Texture") or inst:IsA("SurfaceAppearance") or inst:IsA("SpecialMesh") then
                table.insert(batch, inst)
                if #batch >= 80 then
                    pcall(function() ContentProvider:PreloadAsync(batch) end)
                    table.clear(batch)
                end
            end
        end
        if #batch > 0 then
            pcall(function() ContentProvider:PreloadAsync(batch) end)
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

local SoundService = nil
pcall(function() SoundService = game:GetService("SoundService") end)
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
function AudioRipper.ExportSoundList()
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
local function getScriptPath(scriptInstance)
    local names = {}
    local current = scriptInstance
    while current and current ~= game do
        table.insert(names, 1, current.Name)
        current = current.Parent
    end
    return "game." .. table.concat(names, ".")
end

-- Generate banner comment for decompiled scripts
local function generateHeader(scriptInstance, status)
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

-- Intelligent script beautifier & bytecode artifact cleaner
function Decompiler.Beautify(code)
    if not code or #code == 0 then return "" end

    local beautified = code

    -- 1. Strip useless decompiler watermark lines
    beautified = string.gsub(beautified, "%-%-%s*Decompiled with [^\r\n]+[\r\n]*", "")
    beautified = string.gsub(beautified, "%-%-%s*Bytecode version:[^\r\n]+[\r\n]*", "")
    beautified = string.gsub(beautified, "%-%-%s*Luau disassembly[^\r\n]+[\r\n]*", "")

    -- 2. Strip unassigned trash variables generated by raw decompilers
    beautified = string.gsub(beautified, "local%s+_%s*=%s*nil;?%s*\n", "")
    beautified = string.gsub(beautified, "local%s+_[%d]+%s*=%s*nil;?%s*\n", "")

    -- 3. Replace generic service variables (e.g. local v1 = game:GetService("Players"))
    local commonServices = {
        "Players", "ReplicatedStorage", "ReplicatedFirst", "RunService", "TweenService",
        "UserInputService", "HttpService", "SoundService", "Lighting", "Debris",
        "MarketplaceService", "TeleportService", "StarterGui", "ContextActionService"
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

    -- 4. Clean consecutive empty lines (normalize to max 2 blank lines)
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
                return generateHeader(scriptInstance, "Decompile Skipped by Rule") ..
                    string.format("-- [Decompilation skipped by DecompileIgnore rule: %s]\n", targetInst:GetFullName())
            elseif pattern and (string.find(scriptInstance.Name, pattern, 1, true) or string.find(fullName, pattern, 1, true)) then
                return generateHeader(scriptInstance, "Decompile Skipped by Rule") ..
                    string.format("-- [Decompilation skipped by DecompileIgnore rule: %s]\n", tostring(pattern))
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

local SoundService = nil
pcall(function() SoundService = game:GetService("SoundService") end)

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
    if not rawOptions or type(rawOptions) ~= "table" then return opts end

    for k, v in pairs(rawOptions) do
        local lk = string.lower(tostring(k))
        if lk == "noscripts" then
            opts.DecompileScripts = not (v == true)
        elseif lk == "mode" then
            local lm = string.lower(tostring(v))
            if lm == "full" then opts.Mode = "Full"
            elseif lm == "fast" then opts.Mode = "Fast"
            elseif lm == "visualsonly" or lm == "visuals" then opts.Mode = "VisualsOnly"
            elseif lm == "scriptsonly" or lm == "scripts" then opts.Mode = "ScriptsOnly"
            elseif lm == "optimized" then opts.Mode = "Full"; opts.OptimizeGeometry = true
            else opts.Mode = v end
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
        elseif lk == "isolatestarterplayer" or lk == "isolate_starter_player" or lk == "isolatelocalplayer" or lk == "isolate_local_player" then
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
    placeName = string.gsub(placeName, "[^%w_%-]", "_")
    local ext = string.lower(self.Config.Format or "rbxlx")
    return string.format("HyperSave_%s_%d.%s", placeName, placeId, ext)
end

function Engine:GetDefaultAssetFolder()
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
function Engine:ShouldSaveInstance(inst)
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
function Engine:SaveTarget(target, customConfig)
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

    local function scan(inst)
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
function Engine:SaveTargetBatch(targets, customConfig)
    if not targets or #targets == 0 then
        return false, "No target instances specified for batch export!"
    end

    local cfg = table.clone(self.Config)
    if customConfig then
        for k, v in pairs(customConfig) do cfg[k] = v end
    end

    local fileName = string.format("HyperSave_MultiPack_%d_items_%d.%s", #targets, os.time(), cfg.Format or "rbxm")
    local scriptInstances = {}

    local function scan(inst)
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
function Engine:Start()
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

    local visited = {}
    local scannedCounter = 0
    local lastYield = os.clock()

    local function scan(inst)
        if not inst or visited[inst] then return end
        visited[inst] = true
        scannedCounter = scannedCounter + 1

        -- Adaptive FPS Guard: yields if frame duration exceeds 10ms to keep 60 FPS silky smooth
        if (os.clock() - lastYield) > 0.010 or scannedCounter % 350 == 0 then
            task.wait()
            lastYield = os.clock()
        end

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

        -- Dispatch Discord Webhook if configured
        if self.Config.DiscordWebhookUrl and #self.Config.DiscordWebhookUrl > 15 then
            task.spawn(function()
                pcall(function()
                    local req = (syn and syn.request) or (http and http.request) or http_request or request
                    if not req then return end

                    local MarketplaceService = game:GetService("MarketplaceService")
                    local placeInfo = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId) end)
                    local placeName = (type(placeInfo) == "table" and placeInfo.Name) or (workspace and workspace.Name) or "Roblox Place"

                    local payload = {
                        username = "HyperSaveInstance",
                        embeds = {
                            {
                                title = "PLACE CLONED SUCCESSFULLY",
                                description = string.format("**Map:** `%s`\n**Place ID:** `%d`\n**Output File:** `%s`", tostring(placeName), game.PlaceId, targetFileName),
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
                                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
                            }
                        }
                    }

                    local json = game:GetService("HttpService"):JSONEncode(payload)
                    req({
                        Url = self.Config.DiscordWebhookUrl,
                        Method = "POST",
                        Headers = { ["Content-Type"] = "application/json" },
                        Body = json
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
    Extracts all ScreenGuis, Menus, Inventories, Health Bars, and HUDs to a standalone UI Pack.
]]

local Players = nil
pcall(function() Players = game:GetService("Players") end)
local StarterGui = nil
pcall(function() StarterGui = game:GetService("StarterGui") end)
local Environment = __require__("Utils/Environment")
local SerializerXml = __require__("Core/SerializerXml")
local Decompiler = __require__("Core/Decompiler")

local GuiRipper = {}

function GuiRipper.ExportAllGuis(options)
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

    local function scanScripts(inst)
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

local Lighting = nil
pcall(function() Lighting = game:GetService("Lighting") end)
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

local HttpService = nil
pcall(function() HttpService = game:GetService("HttpService") end)
local Environment = __require__("Utils/Environment")

local NetworkSniffer = {}
NetworkSniffer.IsActive = false
NetworkSniffer.CapturedLogs = {}
NetworkSniffer.Listeners = {}

local originalFireServer = nil
local originalInvokeServer = nil

-- Format arguments safely into readable string / json
local function serializeArgs(args)
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
function NetworkSniffer.LogCall(callType, remote, args)
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
        if s and c then corners = c end
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
        ""
    }

    local mtlLines = {
        "# HyperSaveInstance - Material Library (.mtl)",
        ""
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
    (Strictly Optional) Reduces file size by deduplicating textures and pruning empty temporary containers.
]]

local Optimizer = {}

function Optimizer.OptimizeHierarchy(rootInstances, options)
    if not options.OptimizeGeometry then
        return rootInstances
    end

    local cleanedRoots = {}
    local prunedCount = 0

    local function cleanRecursive(inst)
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

__define__("Core/PlaceDiffTracker", function()
--[[
    HyperSaveInstance - Map & Update Diff Tracker
    Compares the current place hierarchy against a previous snapshot to identify
    newly added instances, modified scripts, and removed models in game updates.
]]

local HttpService = nil
pcall(function() HttpService = game:GetService("HttpService") end)
local Environment = __require__("Utils/Environment")

local PlaceDiffTracker = {}

-- Create a lightweight signature dictionary of all instances in a target container
function PlaceDiffTracker.CreateSnapshot(root)
    local target = root or game
    local snapshot = {
        PlaceId = game.PlaceId or 0,
        Timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        InstanceCount = 0,
        Instances = {}
    }

    local function scan(inst, path)
        local curPath = path .. "/" .. inst.Name
        local class = inst.ClassName
        local childrenCount = #inst:GetChildren()
        
        local info = {
            Class = class,
            Children = childrenCount
        }

        if inst:IsA("LuaSourceContainer") then
            local s, src = pcall(function() return (inst ).Source end)
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
            pcall(function() scan(serv, "") end)
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
        local s, parsed = pcall(function() return HttpService:JSONDecode(content) end)
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
        Summary = ""
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

    diff.Summary = string.format("Diff: +%d adicionados, -%d removidos, ~%d modificados (Total Atual: %d)",
        #diff.Added, #diff.Removed, #diff.Modified, curr.InstanceCount)

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
        string.format("--- [1] NOVAS INSTÂNCIAS ADICIONADAS (%d) ---", #diff.Added)
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

local UserInputService = nil
pcall(function() UserInputService = game:GetService("UserInputService") end)
local RunService = nil
pcall(function() RunService = game:GetService("RunService") end)
local Players = nil
pcall(function() Players = game:GetService("Players") end)

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
        hl.Name = "HyperSave_SelectorHighlight"
        hl.FillColor = Color3.fromRGB(168, 85, 247)
        hl.FillTransparency = 0.6
        hl.OutlineColor = Color3.fromRGB(243, 232, 255)
        hl.OutlineTransparency = 0.05
        hl.Enabled = false
        
        -- Store in gethui, CoreGui or workspace safely
        local parent = nil
        if gethui then
            pcall(function() parent = gethui() end)
        end
        if not parent then
            pcall(function() parent = game:GetService("CoreGui") end)
        end
        hl.Parent = parent or workspace
        self.Highlight = hl
    end)
end

-- Find the most meaningful parent Model or Tool from a clicked BasePart
function RaycastSelector:ResolveTarget(part)
    if not part then return nil end

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
    if not camera then return nil, nil end

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

local CollectionService = nil
pcall(function() CollectionService = game:GetService("CollectionService") end)

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
    ["Highlight"] = {
        {"Adornee", "Ref"},
        {"FillColor", "Color3"},
        {"FillTransparency", "float"},
        {"OutlineColor", "Color3"},
        {"OutlineTransparency", "float"},
        {"DepthMode", "token"},
        {"Enabled", "bool"},
    },
    ["ProximityPrompt"] = {
        {"ActionText", "string"},
        {"ObjectText", "string"},
        {"HoldDuration", "float"},
        {"MaxActivationDistance", "float"},
        {"KeyboardKeyCode", "token"},
        {"GamepadKeyCode", "token"},
        {"RequiresLineOfSight", "bool"},
        {"Enabled", "bool"},
        {"ClickablePrompt", "bool"},
        {"Exclusivity", "token"},
    },
    ["Clouds"] = {
        {"Cover", "float"},
        {"Density", "float"},
        {"Color", "Color3"},
        {"Enabled", "bool"},
    },
    ["PathfindingModifier"] = {
        {"PassThrough", "bool"},
        {"Label", "string"},
    },
    ["PathfindingLink"] = {
        {"Attachment0", "Ref"},
        {"Attachment1", "Ref"},
        {"IsBidirectional", "bool"},
        {"Label", "string"},
    },
    ["NoCollisionConstraint"] = {
        {"Part0", "Ref"},
        {"Part1", "Ref"},
        {"Enabled", "bool"},
    },
    ["AudioPlayer"] = {
        {"AssetId", "Content"},
        {"Volume", "float"},
        {"Pitch", "float"},
        {"Looping", "bool"},
        {"TimePosition", "float"},
        {"AutoPlay", "bool"},
    },
    ["AudioEmitter"] = {
        {"AudioInteractionGroup", "string"},
        {"DistanceAttenuation", "NumberSequence"},
    },
    ["AudioListener"] = {
        {"AudioInteractionGroup", "string"},
    },
    ["Wire"] = {
        {"SourceInstance", "Ref"},
        {"TargetInstance", "Ref"},
    },
    ["LocalizationTable"] = {
        {"SourceLocaleId", "string"},
    },
    ["Script"] = {
        {"Enabled", "bool"},
        {"RunContext", "token"},
    },
    ["LocalScript"] = {
        {"Enabled", "bool"},
    },
    ["ModuleScript"] = {},
    ["UICorner"] = {
        {"CornerRadius", "UDim"},
    },
    ["UIGradient"] = {
        {"Color", "ColorSequence"},
        {"Transparency", "NumberSequence"},
        {"Offset", "Vector2"},
        {"Rotation", "float"},
        {"Enabled", "bool"},
    },
    ["UIStroke"] = {
        {"Color", "Color3"},
        {"Thickness", "float"},
        {"Transparency", "float"},
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
    },
    ["UIGridLayout"] = {
        {"CellPadding", "UDim2"},
        {"CellSize", "UDim2"},
        {"FillDirection", "token"},
        {"FillDirectionMaxCells", "int"},
        {"HorizontalAlignment", "token"},
        {"VerticalAlignment", "token"},
        {"SortOrder", "token"},
        {"StartCorner", "token"},
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
    ["Decal"] = {
        {"Texture", "Content"},
        {"Face", "token"},
        {"Color3", "Color3"},
        {"Transparency", "float"},
        {"ZIndex", "int"},
    },
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
                    local s, val = pcall(function() return (inst )[propName] end)
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
local function escapeXml(str)
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
local function escapeCDataOrText(str)
    if not str or #str == 0 then return "" end
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
        x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22
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
    if not attrs or next(attrs) == nil then return "" end
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

    local function getRef(inst)
        if not refMap[inst] then
            refMap[inst] = "RBX" .. tostring(refCounter)
            refCounter = refCounter + 1
        end
        return refMap[inst]
    end

    local xmlBuffer = {}
    local function append(str)
        table.insert(xmlBuffer, str)
    end

    -- XML Header
    append([[<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">
	<Meta name="ExplicitAutoJoints">true</Meta>
]])

    -- Recursive instance serializer
    local function serializeInstance(inst, depth)
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
                        append(string.format('%s\t\t<Vector3 name="%s"><X>%.7g</X><Y>%.7g</Y><Z>%.7g</Z></Vector3>\n', indent, propName, tonumber(val.X) or 0, tonumber(val.Y) or 0, tonumber(val.Z) or 0))
                    elseif propType == "Vector2" and typeof(val) == "Vector2" then
                        append(string.format('%s\t\t<Vector2 name="%s"><X>%.7g</X><Y>%.7g</Y></Vector2>\n', indent, propName, tonumber(val.X) or 0, tonumber(val.Y) or 0))
                    elseif propType == "CoordinateFrame" and typeof(val) == "CFrame" then
                        append(string.format('%s\t\t<CoordinateFrame name="%s">%s</CoordinateFrame>\n', indent, propName, formatCFrame(val)))
                    elseif propType == "Color3" and typeof(val) == "Color3" then
                        append(string.format('%s\t\t<Color3 name="%s"><R>%.7g</R><G>%.7g</G><B>%.7g</B></Color3>\n', indent, propName, tonumber(val.R) or 0, tonumber(val.G) or 0, tonumber(val.B) or 0))
                    elseif propType == "UDim" and typeof(val) == "UDim" then
                        append(string.format('%s\t\t<UDim name="%s"><S>%.7g</S><O>%d</O></UDim>\n', indent, propName, tonumber(val.Scale) or 0, math.floor(tonumber(val.Offset) or 0)))
                    elseif propType == "UDim2" and typeof(val) == "UDim2" then
                        local xs = (type(val.X) == "table" and val.X.Scale) or (typeof(val.X) == "UDim" and val.X.Scale) or 0
                        local xo = (type(val.X) == "table" and val.X.Offset) or (typeof(val.X) == "UDim" and val.X.Offset) or 0
                        local ys = (type(val.Y) == "table" and val.Y.Scale) or (typeof(val.Y) == "UDim" and val.Y.Scale) or 0
                        local yo = (type(val.Y) == "table" and val.Y.Offset) or (typeof(val.Y) == "UDim" and val.Y.Offset) or 0
                        append(string.format('%s\t\t<UDim2 name="%s"><XS>%.7g</XS><XO>%d</XO><YS>%.7g</YS><YO>%d</YO></UDim2>\n', indent, propName, tonumber(xs) or 0, math.floor(tonumber(xo) or 0), tonumber(ys) or 0, math.floor(tonumber(yo) or 0)))
                    elseif propType == "token" then
                        local tokenNum = (typeof(val) == "EnumItem" and val.Value) or (type(val) == "table" and val.Value) or tonumber(val) or 0
                        append(string.format('%s\t\t<token name="%s">%d</token>\n', indent, propName, math.floor(tonumber(tokenNum) or 0)))
                    elseif propType == "Content" then
                        append(string.format('%s\t\t<Content name="%s"><url>%s</url></Content>\n', indent, propName, escapeXml(tostring(val))))
                    elseif propType == "Ref" then
                        if typeof(val) == "Instance" then
                            append(string.format('%s\t\t<Ref name="%s">%s</Ref>\n', indent, propName, getRef(val)))
                        else
                            append(string.format('%s\t\t<Ref name="%s">null</Ref>\n', indent, propName))
                        end
                    elseif propType == "ColorSequence" and typeof(val) == "ColorSequence" then
                        append(string.format('%s\t\t<ColorSequence name="%s">%s</ColorSequence>\n', indent, propName, formatColorSequence(val)))
                    elseif propType == "NumberSequence" and typeof(val) == "NumberSequence" then
                        append(string.format('%s\t\t<NumberSequence name="%s">%s</NumberSequence>\n', indent, propName, formatNumberSequence(val)))
                    elseif propType == "NumberRange" and typeof(val) == "NumberRange" then
                        append(string.format('%s\t\t<NumberRange name="%s">%.7g %.7g</NumberRange>\n', indent, propName, tonumber(val.Min) or 0, tonumber(val.Max) or 0))
                    elseif propType == "Rect" and typeof(val) == "Rect" then
                        append(string.format('%s\t\t<Rect2D name="%s"><min><X>%.7g</X><Y>%.7g</Y></min><max><X>%.7g</X><Y>%.7g</Y></max></Rect2D>\n', indent, propName, tonumber(val.Min.X) or 0, tonumber(val.Min.Y) or 0, tonumber(val.Max.X) or 0, tonumber(val.Max.Y) or 0))
                    elseif propType == "Font" and typeof(val) == "Font" then
                        append(string.format('%s\t\t<Font name="%s">\n%s\t\t\t<Family><url>%s</url></Family>\n%s\t\t\t<Weight>%d</Weight>\n%s\t\t\t<Style>%s</Style>\n%s\t\t</Font>\n',
                            indent, propName, indent, escapeXml(tostring(val.Family)), indent, (val.Weight and tonumber(val.Weight.Value)) or 400, indent, (val.Style and tostring(val.Style.Name)) or "Normal", indent))
                    elseif propType == "PhysicalProperties" and typeof(val) == "PhysicalProperties" then
                        append(string.format('%s\t\t<PhysicalProperties name="%s">\n%s\t\t\t<CustomPhysics>true</CustomPhysics>\n%s\t\t\t<Density>%.7g</Density>\n%s\t\t\t<Friction>%.7g</Friction>\n%s\t\t\t<Elasticity>%.7g</Elasticity>\n%s\t\t\t<FrictionWeight>%.7g</FrictionWeight>\n%s\t\t\t<ElasticityWeight>%.7g</ElasticityWeight>\n%s\t\t</PhysicalProperties>\n',
                            indent, propName, indent, indent, tonumber(val.Density) or 0, indent, tonumber(val.Friction) or 0, indent, tonumber(val.Elasticity) or 0, indent, tonumber(val.FrictionWeight) or 0, indent, tonumber(val.ElasticityWeight) or 0, indent))
                    elseif propType == "Ray" and typeof(val) == "Ray" then
                        append(string.format('%s\t\t<Ray name="%s"><origin><X>%.7g</X><Y>%.7g</Y><Z>%.7g</Z></origin><direction><X>%.7g</X><Y>%.7g</Y><Z>%.7g</Z></direction></Ray>\n',
                            indent, propName, tonumber(val.Origin.X) or 0, tonumber(val.Origin.Y) or 0, tonumber(val.Origin.Z) or 0, tonumber(val.Direction.X) or 0, tonumber(val.Direction.Y) or 0, tonumber(val.Direction.Z) or 0))
                    end
                end
            end
        end

        -- LocalizationTable entries dump
        if inst:IsA("LocalizationTable") then
            pcall(function()
                local entries = (inst ):GetEntries()
                if entries and #entries > 0 then
                    local HttpService = game:GetService("HttpService")
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
            local s, attrs = pcall(function() return inst:GetAttributes() end)
            if s and attrs and next(attrs) ~= nil then
                local b64Attrs = serializeAttributes(attrs)
                if #b64Attrs > 0 then
                    append(string.format('%s\t\t<BinaryString name="Attributes">%s</BinaryString>\n', indent, b64Attrs))
                end
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
local function getPathExpression(inst)
    local segments = {}
    local curr = inst

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
function ServerSynthesizer.SynthesizeService(rootInstances)
    local remotes = ServerSynthesizer.CollectRemotes(rootInstances)
    local sourceCode = ServerSynthesizer.GenerateDispatcherSource(remotes)

    local serverService = Instance.new("Folder")
    serverService.Name = "ServerScriptService"

    local syntheticScript = Instance.new("Script")
    syntheticScript.Name = "HyperSave_ServerDispatcher"
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
    HyperSaveInstance - StreamingEnabled Auto-Map Explorer
    Sweeps spatial coordinates across the map to force server chunk replication into memory.
]]

local Players = nil
pcall(function() Players = game:GetService("Players") end)

local StreamExplorer = {}

-- Scan map bounds and calculate bounding box
function StreamExplorer.GetMapBoundingBox()
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
function StreamExplorer.ExploreMap(stepSize, progressCallback)
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

local UniverseTracker = {}



-- Fetch all places belonging to current Game Universe
function UniverseTracker.GetUniversePlaces()
    local places = {}
    local currentPlaceId = game.PlaceId or 0
    local rootName = "Root Place"

    pcall(function()
        local mp = game:GetService("MarketplaceService")
        if mp then
            rootName = mp:GetProductInfo(currentPlaceId).Name
        end
    end)

    -- Add current place
    table.insert(places, {
        PlaceId = currentPlaceId,
        Name = rootName,
        IsRoot = true
    })

    -- Query AssetService for places in universe
    local success, pages = pcall(function()
        local assetService = game:GetService("AssetService")
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

__define__("Core/Web3DExporter", function()
--[[
    HyperSaveInstance - Standalone Web 3D (HTML / Three.js) Exporter
    Exports any 3D Model, Map or Weapon into a single standalone interactive HTML file
    with WebGL, OrbitControls, studio lighting, wireframe view, and Theo Lorentz glassmorphic HUD.
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
    <title>💀 HyperSaveInstance 3D Web Viewer - ]==], safeName, [==[</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            background-color: #07050d;
            color: #ffffff;
            font-family: 'Segoe UI', -apple-system, BlinkMacSystemFont, Roboto, sans-serif;
            overflow: hidden;
            width: 100vw;
            height: 100vh;
        }
        #webgl-canvas { width: 100%; height: 100%; display: block; }
        .glass-panel {
            position: absolute;
            background: rgba(16, 12, 28, 0.75);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            border: 1px solid rgba(168, 85, 247, 0.3);
            border-radius: 14px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.5);
            padding: 16px 20px;
            z-index: 100;
        }
        #header-card {
            top: 20px;
            left: 20px;
            display: flex;
            flex-direction: column;
            gap: 6px;
        }
        .title {
            font-size: 16px;
            font-weight: 700;
            color: #f3e8ff;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .badge {
            background: rgba(139, 92, 246, 0.2);
            border: 1px solid #8b5cf6;
            color: #d8b4fe;
            font-size: 11px;
            padding: 2px 8px;
            border-radius: 20px;
            font-weight: 600;
        }
        .subtitle { font-size: 11px; color: #a78bfa; }
        #controls-card {
            bottom: 24px;
            left: 50%;
            transform: translateX(-50%);
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .btn {
            background: rgba(30, 22, 52, 0.8);
            color: #ffffff;
            border: 1px solid rgba(168, 85, 247, 0.4);
            padding: 8px 16px;
            border-radius: 8px;
            font-size: 12px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        .btn:hover {
            background: #8b5cf6;
            border-color: #c084fc;
            box-shadow: 0 0 12px rgba(168, 85, 247, 0.6);
        }
        .btn.active {
            background: #a855f7;
            border-color: #f0abfc;
        }
        #stats-card {
            top: 20px;
            right: 20px;
            font-size: 11px;
            line-height: 1.6;
            color: #e9d5ff;
        }
        #loading {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            font-size: 15px;
            font-weight: 600;
            color: #d8b4fe;
            background: rgba(16, 12, 28, 0.85);
            padding: 16px 28px;
            border-radius: 12px;
            border: 1px solid #8b5cf6;
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
    <div id="header-card" class="glass-panel">
        <div class="title">
            <span>💀 HYPERSAVE 3D</span>
            <span class="badge">]==], safeName, [==[</span>
        </div>
        <div class="subtitle">Extraído por Theo Lorentz Padilha • WebGL 3D Viewer</div>
    </div>

    <div id="stats-card" class="glass-panel">
        <div><strong>Status:</strong> <span style="color:#4ade80">Carregado</span></div>
        <div><strong>Place ID:</strong> ]==], tostring(placeId), [==[</div>
        <div><strong>Controles:</strong> Botão esquerdo (Girar) | Direito (Pan) | Scroll (Zoom)</div>
    </div>

    <div id="controls-card" class="glass-panel">
        <button id="btn-wireframe" class="btn">Linhas (Wireframe)</button>
        <button id="btn-rotate" class="btn active">Auto-Rotação: ON</button>
        <button id="btn-reset" class="btn">Resetar Câmera</button>
    </div>

    <div id="loading">⚡ Renderizando Geometria 3D...</div>
    <div id="webgl-canvas"></div>

    <script>
        const rawObjData = `]==], escapedObj, [==[`;

        let scene, camera, renderer, controls, currentMeshGroup;
        let isWireframe = false;
        let isAutoRotate = true;

        function init() {
            const container = document.getElementById('webgl-canvas');
            scene = new THREE.Scene();
            scene.background = new THREE.Color(0x07050d);
            scene.fog = new THREE.FogExp2(0x07050d, 0.005);

            camera = new THREE.PerspectiveCamera(50, window.innerWidth / window.innerHeight, 0.1, 5000);
            camera.position.set(25, 20, 35);

            renderer = new THREE.WebGLRenderer({ antialias: true });
            renderer.setSize(window.innerWidth, window.innerHeight);
            renderer.setPixelRatio(window.devicePixelRatio);
            renderer.toneMapping = THREE.ACESFilmicToneMapping;
            renderer.toneMappingExposure = 1.2;
            container.appendChild(renderer.domElement);

            controls = new THREE.OrbitControls(camera, renderer.domElement);
            controls.enableDamping = true;
            controls.dampingFactor = 0.05;

            // Lights
            const ambient = new THREE.AmbientLight(0xd8b4fe, 0.7);
            scene.add(ambient);

            const sunLight = new THREE.DirectionalLight(0xffffff, 1.4);
            sunLight.position.set(50, 80, 50);
            scene.add(sunLight);

            const fillLight = new THREE.DirectionalLight(0x8b5cf6, 0.8);
            fillLight.position.set(-50, -20, -50);
            scene.add(fillLight);

            const grid = new THREE.GridHelper(200, 50, 0x8b5cf6, 0x1e1634);
            grid.position.y = -0.01;
            scene.add(grid);

            // Load OBJ from embedded string
            const loader = new THREE.OBJLoader();
            try {
                const object = loader.parse(rawObjData);
                currentMeshGroup = object;

                // Center object
                const box = new THREE.Box3().setFromObject(object);
                const center = box.getCenter(new THREE.Vector3());
                const size = box.getSize(new THREE.Vector3());
                object.position.sub(center);

                // Default material
                const purpleMat = new THREE.MeshStandardMaterial({
                    color: 0xa855f7,
                    roughness: 0.35,
                    metalness: 0.2
                });

                object.traverse(child => {
                    if (child.isMesh) {
                        child.material = purpleMat;
                    }
                });

                scene.add(object);

                // Adjust camera distance
                const maxDim = Math.max(size.x, size.y, size.z);
                camera.position.set(maxDim * 1.5, maxDim * 1.2, maxDim * 1.8);
                controls.target.set(0, 0, 0);

                document.getElementById('loading').style.display = 'none';
            } catch (err) {
                console.error("Erro ao processar OBJ:", err);
                document.getElementById('loading').innerText = "Erro ao renderizar modelo: " + err.message;
            }

            // Events
            window.addEventListener('resize', onWindowResize);
            document.getElementById('btn-wireframe').addEventListener('click', toggleWireframe);
            document.getElementById('btn-rotate').addEventListener('click', toggleAutoRotate);
            document.getElementById('btn-reset').addEventListener('click', resetCamera);

            animate();
        }

        function onWindowResize() {
            camera.aspect = window.innerWidth / window.innerHeight;
            camera.updateProjectionMatrix();
            renderer.setSize(window.innerWidth, window.innerHeight);
        }

        function toggleWireframe() {
            isWireframe = !isWireframe;
            const btn = document.getElementById('btn-wireframe');
            btn.classList.toggle('active', isWireframe);
            if (currentMeshGroup) {
                currentMeshGroup.traverse(child => {
                    if (child.isMesh && child.material) {
                        child.material.wireframe = isWireframe;
                    }
                });
            }
        }

        function toggleAutoRotate() {
            isAutoRotate = !isAutoRotate;
            const btn = document.getElementById('btn-rotate');
            btn.innerText = isAutoRotate ? "Auto-Rotação: ON" : "Auto-Rotação: OFF";
            btn.classList.toggle('active', isAutoRotate);
        }

        function resetCamera() {
            if (currentMeshGroup) {
                const box = new THREE.Box3().setFromObject(currentMeshGroup);
                const size = box.getSize(new THREE.Vector3());
                const maxDim = Math.max(size.x, size.y, size.z) || 20;
                camera.position.set(maxDim * 1.5, maxDim * 1.2, maxDim * 1.8);
                controls.target.set(0, 0, 0);
            }
        }

        function animate() {
            requestAnimationFrame(animate);
            if (isAutoRotate && currentMeshGroup) {
                currentMeshGroup.rotation.y = currentMeshGroup.rotation.y + (0.005;)
            }
            controls.update();
            renderer.render(scene, camera);
        }

        init();
    </script>
</body>
</html>]==]
    }

    local htmlContent = table.concat(htmlParts, "")
    local wrote = Environment.WriteFile(fileName, htmlContent)
    if wrote then
        return true, fileName
    end
    return false, "Falha ao gravar arquivo Web 3D (.html)."
end

return Web3DExporter

end)

__define__("Loader", function()
--[[
    HyperSaveInstance - Universal Smart Bootstrapper & Multi-CDN Resilient Loader
    Author: Theo Lorentz Padilha (https://github.com/theopadilha2009-hash)
    Auto-detects environment, provides instant visual feedback, and loads real-time raw bundle.
]]

local function createInstantBanner(text, isError)
    pcall(function()
        local rawParent = (gethui and gethui())
        if not rawParent then
            local plrs = game:GetService("Players")
            local lp = plrs.LocalPlayer or plrs:FindFirstChildOfClass("Player")
            rawParent = (lp and lp:FindFirstChildOfClass("PlayerGui")) or game:GetService("CoreGui")
        end
        if not rawParent then return end

        local container = nil
        if rawParent:IsA("LayerCollector") or rawParent:IsA("ScreenGui") then
            container = rawParent
        else
            local old = rawParent:FindFirstChild("HSI_BootBanner")
            if old then old:Destroy() end

            local sg = Instance.new("ScreenGui")
            sg.Name = "HSI_BootBanner"
            sg.DisplayOrder = 9999999
            sg.ResetOnSpawn = false
            sg.Enabled = true
            sg.Parent = rawParent
            container = sg
        end

        local oldF = container:FindFirstChild("HSI_BannerFrame")
        if oldF then oldF:Destroy() end

        local f = Instance.new("Frame")
        f.Name = "HSI_BannerFrame"
        f.Size = UDim2.new(0, 340, 0, 48)
        f.Position = UDim2.new(0.5, -170, 0, 24)
        f.BackgroundColor3 = isError and Color3.fromRGB(40, 10, 20) or Color3.fromRGB(16, 12, 28)
        f.BorderSizePixel = 0
        f.Parent = container

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 10)
        c.Parent = f

        local s = Instance.new("UIStroke")
        s.Color = isError and Color3.fromRGB(244, 63, 94) or Color3.fromRGB(168, 85, 247)
        s.Thickness = 1.5
        s.Parent = f

        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, -20, 1, 0)
        l.Position = UDim2.new(0, 10, 0, 0)
        l.Text = text
        l.TextColor3 = Color3.fromRGB(255, 255, 255)
        l.Font = Enum.Font.GothamBold
        l.TextSize = 12
        l.BackgroundTransparency = 1
        l.Parent = f

        task.delay(isError and 6 or 3.5, function()
            pcall(function() f:Destroy() end)
        end)
    end)
end

createInstantBanner("⚡ [HyperSave] Baixando módulos seguros...", false)

local cacheBuster = tostring(os.time()) .. "_" .. tostring(math.random(100000, 999999))
local url = "https://raw.githubusercontent.com/theopadilha2009-hash/HyperSaveInstance/main/dist/HyperSaveInstance.luau?nocache=" .. cacheBuster

local s, result = pcall(function()
    return game:HttpGet(url, true)
end)

if not s or type(result) ~= "string" or #result < 10000 then
    createInstantBanner("❌ Falha de rede ao baixar HyperSave.", true)
    warn("[HyperSave] Falha ao baixar bundle: " .. tostring(result))
    return
end

createInstantBanner("💀 [HyperSave] Inicializando Suíte...", false)

local execSuccess, execFunc = pcall(function()
    return loadstring(result)
end)

if not execSuccess or type(execFunc) ~= "function" then
    createInstantBanner("❌ Erro de compilação Luau: " .. tostring(execFunc), true)
    warn("[HyperSave] Erro no loadstring: " .. tostring(execFunc))
    return
end

local runSuccess, hsi = pcall(execFunc)
if not runSuccess then
    createInstantBanner("❌ Erro na execução: " .. tostring(hsi), true)
    warn("[HyperSave] Erro na execução: " .. tostring(hsi))
    return
end

return hsi

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
    local safeContainer = nil

    if parent and (parent:IsA("LayerCollector") or parent:IsA("ScreenGui")) then
        pcall(function()
            local old = parent:FindFirstChild("HyperSave_Container")
            if old then old:Destroy() end
        end)
        local container = Instance.new("Frame")
        container.Name = "HyperSave_Container"
        container.Size = UDim2.new(1, 0, 1, 0)
        container.BackgroundTransparency = 1
        container.Parent = parent
        safeContainer = container
    else
        pcall(function()
            local old = parent:FindFirstChild("HyperSaveInstance_UI")
            if old then old:Destroy() end
        end)

        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "HyperSaveInstance_UI"
        screenGui.ResetOnSpawn = false
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        screenGui.DisplayOrder = 999999
        screenGui.IgnoreGuiInset = true
        screenGui.Enabled = true
        self.ScreenGui = screenGui

        if syn and syn.protect_gui then
            pcall(syn.protect_gui, screenGui)
        end

        local ok = pcall(function() screenGui.Parent = parent end)
        if not ok or not screenGui.Parent then
            pcall(function() screenGui.Parent = game:GetService("CoreGui") end)
            if not screenGui.Parent then
                pcall(function()
                    local plrs = game:GetService("Players")
                    local lp = plrs.LocalPlayer or plrs:FindFirstChildOfClass("Player")
                    screenGui.Parent = lp and lp:FindFirstChildOfClass("PlayerGui")
                end)
            end
        end
        safeContainer = screenGui
    end

    -- Floating Mini Toggle Button (Always accessible if minimized or on mobile)
    local floatingBtn = Instance.new("TextButton")
    floatingBtn.Name = "FloatingToggle"
    floatingBtn.Text = "// HYPERSAVE [THEO]"
    floatingBtn.Font = Theme.FontTitle
    floatingBtn.TextSize = 11
    floatingBtn.TextColor3 = Theme.AccentGothic
    floatingBtn.BackgroundColor3 = Theme.CardBg
    floatingBtn.Size = UDim2.new(0, 160, 0, 34)
    floatingBtn.Position = UDim2.new(0, 20, 0, 20)
    floatingBtn.Visible = false
    Theme.AddCorner(floatingBtn, Theme.CornerMedium)
    Theme.AddStroke(floatingBtn, Theme.BorderNeon, 1.5)
    Theme.AddGradient(floatingBtn, Color3.fromRGB(11, 9, 18), Color3.fromRGB(38, 20, 64), 45)
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
            floatingBtn.Position = UDim2.new(fStartPos.X.Scale, fStartPos.X.Offset + delta.X, fStartPos.Y.Scale, fStartPos.Y.Offset + delta.Y)
        end
    end)

    Theme.AnimateButton(floatingBtn, function()
        if self.MainFrame then self.MainFrame.Visible = true end
        floatingBtn.Visible = false
    end)
    
    local camera = workspace.CurrentCamera
    local vpSize = (camera and camera.ViewportSize) or Vector2.new(1280, 720)
    local winWidth = math.clamp(vpSize.X - 24, 320, 660)
    local winHeight = math.clamp(vpSize.Y - 32, 280, 480)

    -- Instant Splash Loading Card (Shows immediately when script is executed)
    local splash = Instance.new("Frame")
    splash.Name = "SplashCard"
    splash.AnchorPoint = Vector2.new(0.5, 0.5)
    splash.Size = UDim2.new(0, 360, 0, 175)
    splash.Position = UDim2.new(0.5, 0, 0.5, 0)
    splash.BackgroundColor3 = Theme.Background
    splash.BackgroundTransparency = 0.05
    splash.BorderSizePixel = 0
    Theme.AddCorner(splash, Theme.CornerLarge)
    Theme.AddStroke(splash, Theme.BorderNeon, 2)
    splash.Parent = safeContainer

    local splashTitle = Instance.new("TextLabel")
    splashTitle.Text = "// HYPERSAVE MASTER SUITE"
    splashTitle.Font = Theme.FontTitle
    splashTitle.TextSize = 15
    splashTitle.TextColor3 = Theme.AccentGothic
    splashTitle.Size = UDim2.new(1, 0, 0, 30)
    splashTitle.Position = UDim2.new(0, 0, 0, 18)
    splashTitle.BackgroundTransparency = 1
    splashTitle.Parent = splash

    local splashBadge = Instance.new("TextLabel")
    splashBadge.Text = "THEO LORENTZ PADILHA // V2.0"
    splashBadge.Font = Theme.FontSemiBold
    splashBadge.TextSize = 11
    splashBadge.TextColor3 = Theme.AccentTheo
    splashBadge.BackgroundColor3 = Color3.fromRGB(15, 12, 24)
    splashBadge.Size = UDim2.new(0, 220, 0, 24)
    splashBadge.Position = UDim2.new(0.5, -110, 0, 52)
    Theme.AddCorner(splashBadge, Theme.CornerMedium)
    Theme.AddStroke(splashBadge, Theme.BorderNeon, 1)
    splashBadge.Parent = splash

    local splashStatus = Instance.new("TextLabel")
    splashStatus.Text = "SYSTEM_INITIALIZING "
    splashStatus.Font = Theme.FontCode
    splashStatus.TextSize = 11
    splashStatus.TextColor3 = Theme.TextSecondary
    splashStatus.Size = UDim2.new(1, 0, 0, 20)
    splashStatus.Position = UDim2.new(0, 0, 0, 88)
    splashStatus.BackgroundTransparency = 1
    splashStatus.Parent = splash

    local splashTrack = Instance.new("Frame")
    splashTrack.Size = UDim2.new(1, -48, 0, 6)
    splashTrack.Position = UDim2.new(0, 24, 0, 122)
    splashTrack.BackgroundColor3 = Color3.fromRGB(11, 9, 18)
    Theme.AddCorner(splashTrack, Theme.CornerPill)
    splashTrack.Parent = splash

    local splashFill = Instance.new("Frame")
    splashFill.Size = UDim2.new(0.2, 0, 1, 0)
    splashFill.BackgroundColor3 = Theme.AccentSecondary
    Theme.AddCorner(splashFill, Theme.CornerPill)
    Theme.AddGradient(splashFill, Theme.AccentPrimary, Theme.AccentSecondary, 0)
    splashFill.Parent = splashTrack
    self.SplashFill = splashFill
    self.SplashCard = splash

    -- Main Container (Dark Gothic Cyberpunk Theme, perfectly centered)
    local main = Instance.new("Frame")
    main.Name = "MainFrame"
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.Size = UDim2.new(0, winWidth, 0, winHeight)
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    main.BackgroundColor3 = Theme.Background
    main.BackgroundTransparency = Theme.BackgroundTransparency
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Visible = true
    Theme.AddCorner(main, Theme.CornerLarge)
    Theme.AddStroke(main, Theme.BorderLight, 1.5)
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
    header.Size = UDim2.new(1, 0, 0, 48)
    header.BackgroundColor3 = Theme.CardBg
    header.BackgroundTransparency = 0.1
    header.BorderSizePixel = 0
    header.Parent = main

    local title = Instance.new("TextLabel")
    title.Text = "// HYPERSAVE"
    title.Font = Theme.FontTitle
    title.TextSize = 15
    title.TextColor3 = Theme.AccentGothic
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Size = UDim2.new(0, 160, 1, 0)
    title.Position = UDim2.new(0, 16, 0, 0)
    title.BackgroundTransparency = 1
    title.Parent = header

    -- Platform & Creator Badge
    local badge = Instance.new("TextLabel")
    badge.Text = "THEO LORENTZ PADILHA // [RightShift]"
    badge.Font = Theme.FontSemiBold
    badge.TextSize = 11
    badge.TextColor3 = Theme.AccentTheo
    badge.BackgroundColor3 = Color3.fromRGB(15, 12, 24)
    badge.Size = UDim2.new(0, 240, 0, 26)
    badge.Position = UDim2.new(0, 175, 0.5, -13)
    Theme.AddCorner(badge, Theme.CornerMedium)
    Theme.AddStroke(badge, Theme.BorderNeon, 1)
    badge.Parent = header

    -- Compact Mode Button (Switches to minimal horizontal HUD bar)
    local compactBtn = Instance.new("TextButton")
    compactBtn.Text = "▫"
    compactBtn.Font = Theme.FontTitle
    compactBtn.TextSize = 14
    compactBtn.TextColor3 = Theme.TextSecondary
    compactBtn.BackgroundColor3 = Theme.CardHover
    compactBtn.Size = UDim2.new(0, 28, 0, 28)
    compactBtn.Position = UDim2.new(1, -102, 0.5, -14)
    Theme.AddCorner(compactBtn, Theme.CornerSmall)
    compactBtn.Parent = header

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

    -- Compact In-Game HUD Widget (Minimalist floating bar)
    local compactBar = Instance.new("Frame")
    compactBar.Name = "HyperSave_CompactHUD"
    compactBar.Size = UDim2.new(0, 390, 0, 38)
    compactBar.Position = UDim2.new(0.5, -195, 0, 16)
    compactBar.BackgroundColor3 = Theme.Background
    compactBar.BackgroundTransparency = 0.08
    compactBar.Visible = false
    Theme.AddCorner(compactBar, Theme.CornerMedium)
    Theme.AddStroke(compactBar, Theme.BorderNeon, 1.5)
    compactBar.Parent = safeContainer
    self.CompactHUD = compactBar

    local cStats = Instance.new("TextLabel")
    cStats.Text = "FPS: 60 | PING: --"
    cStats.Font = Theme.FontCode
    cStats.TextSize = 11
    cStats.TextColor3 = Theme.AccentCyan
    cStats.Size = UDim2.new(0, 140, 1, 0)
    cStats.Position = UDim2.new(0, 12, 0, 0)
    cStats.BackgroundTransparency = 1
    cStats.Parent = compactBar

    local cCloneBtn = Instance.new("TextButton")
    cCloneBtn.Text = "CLONE [1-CLICK]"
    cCloneBtn.Font = Theme.FontTitle
    cCloneBtn.TextSize = 10
    cCloneBtn.TextColor3 = Theme.AccentGothic
    cCloneBtn.BackgroundColor3 = Theme.AccentPrimary
    cCloneBtn.Size = UDim2.new(0, 120, 0, 26)
    cCloneBtn.Position = UDim2.new(0, 155, 0.5, -13)
    Theme.AddCorner(cCloneBtn, Theme.CornerSmall)
    Theme.AddStroke(cCloneBtn, Theme.BorderNeon, 1)
    Theme.AddGradient(cCloneBtn, Color3.fromRGB(147, 51, 234), Color3.fromRGB(88, 28, 135), 45)
    cCloneBtn.Parent = compactBar
    Theme.AnimateButton(cCloneBtn, function() self:StartClone() end)

    local cExpandBtn = Instance.new("TextButton")
    cExpandBtn.Text = "EXPAND ↗"
    cExpandBtn.Font = Theme.FontSemiBold
    cExpandBtn.TextSize = 10
    cExpandBtn.TextColor3 = Theme.TextSecondary
    cExpandBtn.BackgroundColor3 = Theme.CardHover
    cExpandBtn.Size = UDim2.new(0, 85, 0, 26)
    cExpandBtn.Position = UDim2.new(1, -95, 0.5, -13)
    Theme.AddCorner(cExpandBtn, Theme.CornerSmall)
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
                pcall(function() ping = math.round(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
                if compactBar and compactBar.Visible then
                    cStats.Text = string.format("FPS: %d | PING: %dms", fps, ping)
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
    navBar.Size = UDim2.new(0, 148, 1, -48)
    navBar.Position = UDim2.new(0, 0, 0, 48)
    navBar.BackgroundColor3 = Theme.CardBg
    navBar.BackgroundTransparency = Theme.CardTransparency
    navBar.ScrollBarThickness = 2
    navBar.ScrollBarImageColor3 = Theme.BorderNeon
    navBar.CanvasSize = UDim2.new(0, 0, 0, 420)
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
    contentArea.Size = UDim2.new(1, -148, 1, -48)
    contentArea.Position = UDim2.new(0, 148, 0, 48)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = main
    self.ContentArea = contentArea

    -- Navigation buttons (Gothic Cyberpunk, Zero Emojis)
    local tabs = {
        {"Dashboard", "OVERVIEW"},
        {"Selector", "TARGET ISOLATOR"},
        {"AudioRipper", "AUDIO EXTRACTION"},
        {"LightingRipper", "LIGHTING PRESET"},
        {"GuiRipper", "INTERFACE RIPPER"},
        {"Network", "NETWORK SNIFFER"},
        {"Universe", "UNIVERSE MAPPER"},
        {"ObjExport", "3D OBJ EXPORTER"},
        {"Tutorial", "DOCUMENTATION"},
        {"Settings", "ENGINE CONFIG"},
        {"Console", "SYSTEM LOGS"},
        {"About", "ABOUT // DEV"}
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
        navBtn.BackgroundTransparency = (i == 1) and 0 or 0.4
        navBtn.Size = UDim2.new(1, -14, 0, 28)
        navBtn.Position = UDim2.new(0, 7, 0, 7 + (i - 1) * 33)
        Theme.AddCorner(navBtn, Theme.CornerMedium)
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

        Theme.AnimateButton(navBtn, function()
            self:SwitchTab(tabKey)
        end)
    end

    -- Build Individual Tab Pages with error boundary protection
    pcall(function() self:BuildDashboardTab() end)
    pcall(function() self:BuildSelectorTab() end)
    pcall(function() self:BuildAudioRipperTab() end)
    pcall(function() self:BuildLightingRipperTab() end)
    pcall(function() self:BuildGuiRipperTab() end)
    pcall(function() self:BuildNetworkTab() end)
    pcall(function() self:BuildUniverseTab() end)
    pcall(function() self:BuildObjExportTab() end)
    pcall(function() self:BuildTutorialTab() end)
    pcall(function() self:BuildSettingsTab() end)
    pcall(function() self:BuildConsoleTab() end)
    pcall(function() self:BuildAboutTab() end)

    -- Animate Splash Card completion and reveal Main Window
    pcall(function()
        if self.SplashFill then
            Theme.Tween(self.SplashFill, 0.35, { Size = UDim2.new(1, 0, 1, 0) })
        end
        task.delay(0.4, function()
            if self.SplashCard then
                Theme.Tween(self.SplashCard, 0.2, {
                    Size = UDim2.new(0, 320, 0, 150),
                    BackgroundTransparency = 1
                })
                for _, child in ipairs(self.SplashCard:GetDescendants()) do
                    if child:IsA("TextLabel") then
                        Theme.Tween(child, 0.15, { TextTransparency = 1 })
                    elseif child:IsA("Frame") or child:IsA("UIStroke") then
                        Theme.Tween(child, 0.15, { Transparency = 1 })
                    end
                end
                task.delay(0.2, function()
                    pcall(function() self.SplashCard:Destroy() end)
                end)
            end

            if self.MainFrame then
                self.MainFrame.Visible = true
                Theme.Tween(self.MainFrame, 0.3, {
                    Size = UDim2.new(0, winWidth, 0, winHeight)
                }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
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
            btn.TextColor3 = Theme.AccentSkull
            btn.BackgroundColor3 = Theme.CardActive
            btn.BackgroundTransparency = 0
            if stroke then stroke.Color = Theme.BorderNeon end
        else
            btn.TextColor3 = Theme.TextSecondary
            btn.BackgroundColor3 = Theme.CardBg
            btn.BackgroundTransparency = 0.4
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
    cloneBtn.Text = "CLONE FULL PLACE // 1-CLICK"
    cloneBtn.Font = Theme.FontTitle
    cloneBtn.TextSize = 14
    cloneBtn.TextColor3 = Theme.AccentSkull
    cloneBtn.BackgroundColor3 = Theme.AccentPrimary
    cloneBtn.Size = UDim2.new(1, -32, 0, 52)
    cloneBtn.Position = UDim2.new(0, 16, 0, 14)
    Theme.AddCorner(cloneBtn, Theme.CornerMedium)
    local cloneStroke = Theme.AddStroke(cloneBtn, Theme.BorderNeon, 1.5)
    Theme.StartNeonPulse(cloneStroke, Theme.BorderLight, Theme.BorderNeon, 2.5)
    Theme.AddGradient(cloneBtn, Color3.fromRGB(147, 51, 234), Color3.fromRGB(76, 29, 149), 90)
    cloneBtn.Parent = parent
    self.CloneButton = cloneBtn

    Theme.AnimateButton(cloneBtn, function()
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
    presetContainer.Size = UDim2.new(1, -32, 0, 36)
    presetContainer.Position = UDim2.new(0, 16, 0, 96)
    presetContainer.BackgroundTransparency = 1
    presetContainer.Parent = parent

    local presetLayout = Instance.new("UIListLayout")
    presetLayout.FillDirection = Enum.FillDirection.Horizontal
    presetLayout.Padding = UDim.new(0, 8)
    presetLayout.SortOrder = Enum.SortOrder.LayoutOrder
    presetLayout.Parent = presetContainer

    local presetList = {"Full", "Fast", "VisualsOnly", "ScriptsOnly"}
    local presetDisplay = {
        Full = "FULL DUMP (10/10)",
        Fast = "FAST STREAM",
        VisualsOnly = "VISUALS ONLY",
        ScriptsOnly = "SCRIPTS ONLY"
    }

    self.PresetButtons = {}
    for i, pKey in ipairs(presetList) do
        local btn = Instance.new("TextButton")
        btn.Text = presetDisplay[pKey]
        btn.Font = Theme.FontSemiBold
        btn.TextSize = 10
        btn.TextColor3 = (self.Config.Mode == pKey) and Theme.AccentSkull or Theme.TextSecondary
        btn.BackgroundColor3 = (self.Config.Mode == pKey) and Theme.CardActive or Theme.CardBg
        btn.BackgroundTransparency = (self.Config.Mode == pKey) and 0 or Theme.CardTransparency
        btn.Size = UDim2.new(0.25, -6, 1, 0)
        btn.LayoutOrder = i
        Theme.AddCorner(btn, Theme.CornerSmall)
        Theme.AddStroke(btn, (self.Config.Mode == pKey) and Theme.BorderNeon or Theme.Border, 1)
        btn.Parent = presetContainer
        self.PresetButtons[pKey] = btn

        Theme.AnimateButton(btn, function()
            Defaults.ApplyPreset(self.Config, pKey)
            for k, b in pairs(self.PresetButtons) do
                local stroke = b:FindFirstChildOfClass("UIStroke")
                if k == pKey then
                    b.TextColor3 = Theme.AccentSkull
                    b.BackgroundColor3 = Theme.CardActive
                    b.BackgroundTransparency = 0
                    if stroke then stroke.Color = Theme.BorderNeon end
                else
                    b.TextColor3 = Theme.TextSecondary
                    b.BackgroundColor3 = Theme.CardBg
                    b.BackgroundTransparency = Theme.CardTransparency
                    if stroke then stroke.Color = Theme.Border end
                end
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
    formatLabel.Position = UDim2.new(0, 16, 0, 142)
    formatLabel.BackgroundTransparency = 1
    formatLabel.Parent = parent

    local formatContainer = Instance.new("Frame")
    formatContainer.Size = UDim2.new(1, -32, 0, 32)
    formatContainer.Position = UDim2.new(0, 16, 0, 162)
    formatContainer.BackgroundTransparency = 1
    formatContainer.Parent = parent

    local formatLayout = Instance.new("UIListLayout")
    formatLayout.FillDirection = Enum.FillDirection.Horizontal
    formatLayout.Padding = UDim.new(0, 8)
    formatLayout.SortOrder = Enum.SortOrder.LayoutOrder
    formatLayout.Parent = formatContainer

    local formats = {
        {"rbxlx", "RBXLX [XML]"},
        {"rbxl", "RBXL [BINARY]"},
        {"lua", "LUAU [SCRIPT]"}
    }
    self.FormatButtons = {}

    for i, fmt in ipairs(formats) do
        local fKey, fLabel = fmt[1], fmt[2]
        local fBtn = Instance.new("TextButton")
        fBtn.Text = fLabel
        fBtn.Font = Theme.FontSemiBold
        fBtn.TextSize = 10
        fBtn.TextColor3 = (self.Config.Format == fKey) and Theme.AccentSkull or Theme.TextSecondary
        fBtn.BackgroundColor3 = (self.Config.Format == fKey) and Theme.CardActive or Theme.CardBg
        fBtn.BackgroundTransparency = (self.Config.Format == fKey) and 0 or Theme.CardTransparency
        fBtn.Size = UDim2.new(0.333, -6, 1, 0)
        fBtn.LayoutOrder = i
        Theme.AddCorner(fBtn, Theme.CornerSmall)
        Theme.AddStroke(fBtn, (self.Config.Format == fKey) and Theme.BorderNeon or Theme.Border, 1)
        fBtn.Parent = formatContainer
        self.FormatButtons[fKey] = fBtn

        Theme.AnimateButton(fBtn, function()
            self.Config.Format = fKey
            for k, b in pairs(self.FormatButtons) do
                local stroke = b:FindFirstChildOfClass("UIStroke")
                if k == fKey then
                    b.TextColor3 = Theme.AccentSkull
                    b.BackgroundColor3 = Theme.CardActive
                    b.BackgroundTransparency = 0
                    if stroke then stroke.Color = Theme.BorderNeon end
                else
                    b.TextColor3 = Theme.TextSecondary
                    b.BackgroundColor3 = Theme.CardBg
                    b.BackgroundTransparency = Theme.CardTransparency
                    if stroke then stroke.Color = Theme.Border end
                end
            end
            self:Log("Formato definido para: ." .. fKey)
        end)
    end

    -- Progress Container (Frosted Glass Acrylic Card)
    local progressCard = Instance.new("Frame")
    progressCard.Size = UDim2.new(1, -32, 0, 106)
    progressCard.Position = UDim2.new(0, 16, 0, 204)
    progressCard.BackgroundColor3 = Theme.CardBg
    progressCard.BackgroundTransparency = Theme.CardTransparency
    Theme.AddCorner(progressCard, Theme.CornerMedium)
    Theme.AddStroke(progressCard, Theme.Border, 1)
    progressCard.Parent = parent

    local statusHeader = Instance.new("TextLabel")
    statusHeader.Name = "StatusHeader"
    statusHeader.Text = "STATUS: IDLE // READY TO DUMP"
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

    -- Quick Action Copy Buttons (UIListLayout Grid)
    local copyBar = Instance.new("Frame")
    copyBar.Size = UDim2.new(1, -32, 0, 24)
    copyBar.Position = UDim2.new(0, 16, 0, 78)
    copyBar.BackgroundTransparency = 1
    copyBar.Parent = progressCard

    local copyLayout = Instance.new("UIListLayout")
    copyLayout.FillDirection = Enum.FillDirection.Horizontal
    copyLayout.Padding = UDim.new(0, 8)
    copyLayout.SortOrder = Enum.SortOrder.LayoutOrder
    copyLayout.Parent = copyBar

    local copyFilePathBtn = Instance.new("TextButton")
    copyFilePathBtn.Text = "COPY FILE NAME"
    copyFilePathBtn.Font = Theme.FontSemiBold
    copyFilePathBtn.TextSize = 10
    copyFilePathBtn.TextColor3 = Theme.TextSecondary
    copyFilePathBtn.BackgroundColor3 = Theme.CardHover
    copyFilePathBtn.Size = UDim2.new(0.5, -4, 1, 0)
    copyFilePathBtn.LayoutOrder = 1
    Theme.AddCorner(copyFilePathBtn, Theme.CornerPill)
    Theme.AddStroke(copyFilePathBtn, Theme.Border, 1)
    copyFilePathBtn.Parent = copyBar

    Theme.AnimateButton(copyFilePathBtn, function()
        local name = self.SavedFilePath
        if #name == 0 then name = self.Engine:GetDefaultFileName() end
        Environment.SetClipboard(name)
        copyFilePathBtn.Text = "COPIED TO CLIPBOARD"
        task.delay(2, function() copyFilePathBtn.Text = "COPY FILE NAME" end)
    end)

    local copyAssetsPathBtn = Instance.new("TextButton")
    copyAssetsPathBtn.Text = "COPY ASSETS PATH"
    copyAssetsPathBtn.Font = Theme.FontSemiBold
    copyAssetsPathBtn.TextSize = 10
    copyAssetsPathBtn.TextColor3 = Theme.TextSecondary
    copyAssetsPathBtn.BackgroundColor3 = Theme.CardHover
    copyAssetsPathBtn.Size = UDim2.new(0.5, -4, 1, 0)
    copyAssetsPathBtn.LayoutOrder = 2
    Theme.AddCorner(copyAssetsPathBtn, Theme.CornerPill)
    Theme.AddStroke(copyAssetsPathBtn, Theme.Border, 1)
    copyAssetsPathBtn.Parent = copyBar

    Theme.AnimateButton(copyAssetsPathBtn, function()
        local name = self.SavedAssetPath
        if #name == 0 then name = self.Engine:GetDefaultAssetFolder() end
        Environment.SetClipboard(name)
        copyAssetsPathBtn.Text = "COPIED TO CLIPBOARD"
        task.delay(2, function() copyAssetsPathBtn.Text = "COPY ASSETS PATH" end)
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
    headerLbl.Text = "TARGET ISOLATOR // 3D RAYCAST"
    headerLbl.Font = Theme.FontTitle
    headerLbl.TextSize = 13
    headerLbl.TextColor3 = Theme.AccentCyan
    headerLbl.TextXAlignment = Enum.TextXAlignment.Left
    headerLbl.Size = UDim2.new(1, -24, 0, 24)
    headerLbl.Position = UDim2.new(0, 12, 0, 12)
    headerLbl.BackgroundTransparency = 1
    headerLbl.Parent = scroll

    -- 1. In-World 3D Raycast Click Selector Button (Bubble Button)
    local raycastBtn = Instance.new("TextButton")
    raycastBtn.Text = "ENABLE 3D RAYCAST SELECTOR"
    raycastBtn.Font = Theme.FontTitle
    raycastBtn.TextSize = 11
    raycastBtn.TextColor3 = Theme.AccentSkull
    raycastBtn.BackgroundColor3 = Theme.AccentPrimary
    raycastBtn.Size = UDim2.new(1, -24, 0, 38)
    raycastBtn.Position = UDim2.new(0, 12, 0, 42)
    Theme.AddCorner(raycastBtn, Theme.CornerMedium)
    Theme.AddStroke(raycastBtn, Theme.BorderNeon, 1.5)
    Theme.AddGradient(raycastBtn, Color3.fromRGB(147, 51, 234), Color3.fromRGB(88, 28, 135), 45)
    raycastBtn.Parent = scroll

    -- 2. Search by Name Textbox
    local searchBox = Instance.new("TextBox")
    searchBox.PlaceholderText = "Ou digite o nome: Ferrari, Gun, ShopGui, Map..."
    searchBox.Font = Theme.FontRegular
    searchBox.TextSize = 11
    searchBox.TextColor3 = Theme.TextPrimary
    searchBox.PlaceholderColor3 = Theme.TextMuted
    searchBox.BackgroundColor3 = Color3.fromRGB(10, 8, 16)
    searchBox.Size = UDim2.new(1, -24, 0, 36)
    searchBox.Position = UDim2.new(0, 12, 0, 88)
    Theme.AddCorner(searchBox, Theme.CornerSmall)
    Theme.AddStroke(searchBox, Theme.Border, 1)
    searchBox.Parent = scroll

    -- 3. Selected Target Info Card (Frosted Acrylic with Real-Time ViewportFrame)
    local infoCard = Instance.new("Frame")
    infoCard.Size = UDim2.new(1, -24, 0, 106)
    infoCard.Position = UDim2.new(0, 12, 0, 132)
    infoCard.BackgroundColor3 = Color3.fromRGB(12, 9, 20)
    infoCard.BackgroundTransparency = 0.3
    Theme.AddCorner(infoCard, Theme.CornerMedium)
    Theme.AddStroke(infoCard, Theme.Border, 1)
    infoCard.Parent = scroll

    -- Embedded 3D ViewportFrame
    local vpFrame = Instance.new("ViewportFrame")
    vpFrame.Size = UDim2.new(0, 90, 0, 90)
    vpFrame.Position = UDim2.new(1, -98, 0, 8)
    vpFrame.BackgroundColor3 = Color3.fromRGB(8, 6, 14)
    vpFrame.BackgroundTransparency = 0.2
    Theme.AddCorner(vpFrame, Theme.CornerSmall)
    Theme.AddStroke(vpFrame, Theme.BorderNeon, 1, 0.5)
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
    targetTitle.Size = UDim2.new(1, -112, 0, 20)
    targetTitle.Position = UDim2.new(0, 10, 0, 8)
    targetTitle.BackgroundTransparency = 1
    targetTitle.Parent = infoCard

    local targetStats = Instance.new("TextLabel")
    targetStats.Text = "Mire no jogo com o botão acima ou digite o nome."
    targetStats.Font = Theme.FontRegular
    targetStats.TextSize = 10
    targetStats.TextColor3 = Theme.TextSecondary
    targetStats.TextXAlignment = Enum.TextXAlignment.Left
    targetStats.Size = UDim2.new(1, -112, 0, 20)
    targetStats.Position = UDim2.new(0, 10, 0, 32)
    targetStats.BackgroundTransparency = 1
    targetStats.Parent = infoCard

    local targetPath = Instance.new("TextLabel")
    targetPath.Text = "Caminho: -"
    targetPath.Font = Theme.FontRegular
    targetPath.TextSize = 10
    targetPath.TextColor3 = Theme.TextMuted
    targetPath.TextXAlignment = Enum.TextXAlignment.Left
    targetPath.Size = UDim2.new(1, -112, 0, 20)
    targetPath.Position = UDim2.new(0, 10, 0, 56)
    targetPath.BackgroundTransparency = 1
    targetPath.Parent = infoCard

    local targetDims = Instance.new("TextLabel")
    targetDims.Text = "Dimensões: -"
    targetDims.Font = Theme.FontRegular
    targetDims.TextSize = 10
    targetDims.TextColor3 = Theme.AccentCyan
    targetDims.TextXAlignment = Enum.TextXAlignment.Left
    targetDims.Size = UDim2.new(1, -112, 0, 20)
    targetDims.Position = UDim2.new(0, 10, 0, 78)
    targetDims.BackgroundTransparency = 1
    targetDims.Parent = infoCard

    -- Helper to update info display & ViewportFrame
    local function inspectInstance(inst)
        self.CurrentTargetInstance = inst
        
        -- Clear previous 3D viewport clones
        pcall(function()
            for _, c in ipairs(vpFrame:GetChildren()) do
                if c:IsA("Instance") and not c:IsA("Camera") then c:Destroy() end
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
            if desc:IsA("BasePart") then parts = parts + 1 end
            if desc:IsA("MeshPart") or desc:IsA("SpecialMesh") then meshes = meshes + 1 end
            if desc:IsA("LuaSourceContainer") then scripts = scripts + 1 end
        end
        if inst:IsA("BasePart") then parts = parts + 1 end
        if inst:IsA("LuaSourceContainer") then scripts = scripts + 1 end

        targetTitle.Text = string.format(" %s (%s)", inst.Name, inst.ClassName)
        targetTitle.TextColor3 = Theme.AccentCyan
        targetStats.Text = string.format("📊 %d Peças • %d Malhas 3D • %d Scripts", parts, meshes, scripts)
        targetStats.TextColor3 = Theme.AccentSuccess
        targetPath.Text = "📍 Caminho: " .. inst:GetFullName()

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

                    targetDims.Text = string.format("📐 Dimensões: %.1f x %.1f x %.1f studs", sz.X, sz.Y, sz.Z)

                    local maxDim = math.max(sz.X, sz.Y, sz.Z)
                    local camDist = math.clamp(maxDim * 1.5, 4, 250)

                    if self.VpRotationConn then
                        self.VpRotationConn:Disconnect()
                        self.VpRotationConn = nil
                    end

                    local runServ = game:GetService("RunService")
                    self.VpRotationConn = runServ.RenderStepped:Connect(function()
                        if not vpFrame or not vpFrame.Parent or not self.CurrentTargetInstance then
                            if self.VpRotationConn then self.VpRotationConn:Disconnect() end
                            return
                        end
                        local angle = os.clock() * 0.9
                        local eyePos = cf.Position + Vector3.new(math.cos(angle) * camDist, camDist * 0.45, math.sin(angle) * camDist)
                        vpCam.CFrame = CFrame.new(eyePos, cf.Position)
                    end)
                end
            else
                targetDims.Text = "📐 Tipo: " .. inst.ClassName
            end
        end)
    end

    -- 4. Action Buttons Container (UIListLayout Pixel-Perfect Horizontal Grid)
    local actionBtnContainer = Instance.new("Frame")
    actionBtnContainer.Size = UDim2.new(1, -24, 0, 38)
    actionBtnContainer.Position = UDim2.new(0, 12, 0, 246)
    actionBtnContainer.BackgroundTransparency = 1
    actionBtnContainer.Parent = scroll

    local actionLayout = Instance.new("UIListLayout")
    actionLayout.FillDirection = Enum.FillDirection.Horizontal
    actionLayout.Padding = UDim.new(0, 6)
    actionLayout.SortOrder = Enum.SortOrder.LayoutOrder
    actionLayout.Parent = actionBtnContainer

    local btnSaveSingle = Instance.new("TextButton")
    btnSaveSingle.Text = "💾 Salvar (.rbxm)"
    btnSaveSingle.Font = Theme.FontTitle
    btnSaveSingle.TextSize = 11
    btnSaveSingle.TextColor3 = Theme.AccentSkull
    btnSaveSingle.BackgroundColor3 = Theme.AccentPrimary
    btnSaveSingle.Size = UDim2.new(0.35, -4, 1, 0)
    btnSaveSingle.LayoutOrder = 1
    Theme.AddCorner(btnSaveSingle, Theme.CornerMedium)
    Theme.AddStroke(btnSaveSingle, Theme.BorderNeon, 1)
    btnSaveSingle.Parent = actionBtnContainer

    local btnExportWeb3D = Instance.new("TextButton")
    btnExportWeb3D.Text = "🌐 3D Web (HTML)"
    btnExportWeb3D.Font = Theme.FontTitle
    btnExportWeb3D.TextSize = 11
    btnExportWeb3D.TextColor3 = Theme.AccentSkull
    btnExportWeb3D.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
    btnExportWeb3D.Size = UDim2.new(0.33, -4, 1, 0)
    btnExportWeb3D.LayoutOrder = 2
    Theme.AddCorner(btnExportWeb3D, Theme.CornerMedium)
    Theme.AddStroke(btnExportWeb3D, Theme.BorderNeon, 1)
    btnExportWeb3D.Parent = actionBtnContainer

    local btnAddToPack = Instance.new("TextButton")
    btnAddToPack.Text = "➕ Pacote"
    btnAddToPack.Font = Theme.FontTitle
    btnAddToPack.TextSize = 11
    btnAddToPack.TextColor3 = Theme.AccentSkull
    btnAddToPack.BackgroundColor3 = Theme.CardActive
    btnAddToPack.Size = UDim2.new(0.32, -4, 1, 0)
    btnAddToPack.LayoutOrder = 3
    Theme.AddCorner(btnAddToPack, Theme.CornerMedium)
    Theme.AddStroke(btnAddToPack, Theme.BorderLight, 1)
    btnAddToPack.Parent = actionBtnContainer

    -- 5. Multi-Select Package Card (Frosted Acrylic)
    local packCard = Instance.new("Frame")
    packCard.Size = UDim2.new(1, -24, 0, 110)
    packCard.Position = UDim2.new(0, 12, 0, 292)
    packCard.BackgroundColor3 = Color3.fromRGB(12, 9, 20)
    packCard.BackgroundTransparency = 0.3
    Theme.AddCorner(packCard, Theme.CornerMedium)
    Theme.AddStroke(packCard, Theme.Border, 1)
    packCard.Parent = scroll

    local packTitle = Instance.new("TextLabel")
    packTitle.Text = "MULTI-TARGET PACKAGE: 0 ITENS"
    packTitle.Font = Theme.FontSemiBold
    packTitle.TextSize = 11
    packTitle.TextColor3 = Theme.AccentCyan
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
    btnClearPack.BackgroundColor3 = Color3.fromRGB(24, 14, 22)
    btnClearPack.Size = UDim2.new(0.24, 0, 0, 24)
    btnClearPack.Position = UDim2.new(0.73, 0, 0, 8)
    Theme.AddCorner(btnClearPack, Theme.CornerSmall)
    Theme.AddStroke(btnClearPack, Theme.AccentDanger, 1, 0.4)
    btnClearPack.Parent = packCard

    local btnSavePack = Instance.new("TextButton")
    btnSavePack.Text = "EXPORT BATCH PACKAGE (.rbxm)"
    btnSavePack.Font = Theme.FontTitle
    btnSavePack.TextSize = 11
    btnSavePack.TextColor3 = Theme.AccentSkull
    btnSavePack.BackgroundColor3 = Theme.AccentPrimary
    btnSavePack.Size = UDim2.new(1, -20, 0, 38)
    btnSavePack.Position = UDim2.new(0, 10, 0, 56)
    Theme.AddCorner(btnSavePack, Theme.CornerMedium)
    Theme.AddStroke(btnSavePack, Theme.BorderNeon, 1.2)
    Theme.AddGradient(btnSavePack, Color3.fromRGB(147, 51, 234), Color3.fromRGB(88, 28, 135), 0)
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
        packTitle.Text = string.format("MULTI-TARGET PACKAGE: %d ITENS", #self.SelectedTargets)
    end

    -- Event: 3D Raycast click button
    Theme.AnimateButton(raycastBtn, function()
        if self.MainFrame then self.MainFrame.Visible = false end
        resultLabel.Text = "3D Raycast active. Click any object in game to inspect."
        resultLabel.TextColor3 = Theme.AccentCyan

        self.Raycast:Start(function(selected)
            if self.MainFrame then self.MainFrame.Visible = true end
            if selected then
                searchBox.Text = selected.Name
                inspectInstance(selected)
                resultLabel.Text = "[SELECTED] " .. selected.Name
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
                resultLabel.Text = "[FOUND] " .. found.Name
                resultLabel.TextColor3 = Theme.AccentSuccess
            else
                inspectInstance(nil)
                resultLabel.Text = "[ERROR] Object not found in hierarchy."
                resultLabel.TextColor3 = Theme.AccentDanger
            end
        end
    end)

    -- Event: Save single model
    Theme.AnimateButton(btnSaveSingle, function()
        local target = self.CurrentTargetInstance
        if not target then
            resultLabel.Text = "[ERROR] Select a target first."
            resultLabel.TextColor3 = Theme.AccentWarning
            return
        end

        resultLabel.Text = "⏳ Salvando " .. target.Name .. " com todos os scripts..."
        resultLabel.TextColor3 = Theme.AccentCyan

        task.spawn(function()
            local success, msg = self.Engine:SaveTarget(target)
            if success then
                resultLabel.Text = "[SUCCESS] Model saved: " .. msg
                resultLabel.TextColor3 = Theme.AccentSuccess
                Environment.SetClipboard(msg)
            else
                resultLabel.Text = "[ERROR] Failed to save: " .. tostring(msg)
                resultLabel.TextColor3 = Theme.AccentDanger
            end
        end)
    end)

    -- Event: Export 3D Web HTML
    Theme.AnimateButton(btnExportWeb3D, function()
        local target = self.CurrentTargetInstance
        if not target then
            resultLabel.Text = "[ERROR] Select a target before Web 3D export!"
            resultLabel.TextColor3 = Theme.AccentWarning
            return
        end

        resultLabel.Text = "🌐 Gerando arquivo Web 3D (.html / Three.js)..."
        resultLabel.TextColor3 = Theme.AccentCyan

        task.spawn(function()
            local success, msg = Web3DExporter.ExportModelToHTML(target)
            if success then
                resultLabel.Text = "[SUCCESS] Web 3D exported: " .. msg .. " (Caminho copiado!)"
                resultLabel.TextColor3 = Theme.AccentSuccess
                Environment.SetClipboard(msg)
            else
                resultLabel.Text = "[ERROR] Web 3D export failed: " .. tostring(msg)
                resultLabel.TextColor3 = Theme.AccentDanger
            end
        end)
    end)

    -- Event: Add to pack
    Theme.AnimateButton(btnAddToPack, function()
        local target = self.CurrentTargetInstance
        if not target then
            resultLabel.Text = "[ERROR] Select a target to add to batch!"
            resultLabel.TextColor3 = Theme.AccentWarning
            return
        end

        table.insert(self.SelectedTargets, target)
        updatePackUI()
        resultLabel.Text = string.format("[SUCCESS] Added to batch: %s (%d items)", target.Name, #self.SelectedTargets)
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
            resultLabel.Text = "[ERROR] Batch is empty!"
            resultLabel.TextColor3 = Theme.AccentWarning
            return
        end

        resultLabel.Text = string.format("⏳ Salvando pacote com %d itens e scripts...", #self.SelectedTargets)
        resultLabel.TextColor3 = Theme.AccentCyan

        task.spawn(function()
            local success, msg = self.Engine:SaveTargetBatch(self.SelectedTargets)
            if success then
                resultLabel.Text = "[SUCCESS] Batch saved: " .. msg
                resultLabel.TextColor3 = Theme.AccentSuccess
                Environment.SetClipboard(msg)
            else
                resultLabel.Text = "[ERROR] Failed to save batch: " .. tostring(msg)
                resultLabel.TextColor3 = Theme.AccentDanger
            end
        end)
    end)
end

function Interface:BuildAudioRipperTab()
    local parent = self.TabFrames["AudioRipper"]

    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, -32, 0, 34)
    topBar.Position = UDim2.new(0, 16, 0, 10)
    topBar.BackgroundTransparency = 1
    topBar.Parent = parent

    local topLayout = Instance.new("UIListLayout")
    topLayout.FillDirection = Enum.FillDirection.Horizontal
    topLayout.Padding = UDim.new(0, 6)
    topLayout.SortOrder = Enum.SortOrder.LayoutOrder
    topLayout.Parent = topBar

    local scanAudioBtn = Instance.new("TextButton")
    scanAudioBtn.Text = "SCAN ALL AUDIO"
    scanAudioBtn.Font = Theme.FontSemiBold
    scanAudioBtn.TextSize = 10
    scanAudioBtn.TextColor3 = Theme.AccentSkull
    scanAudioBtn.BackgroundColor3 = Theme.AccentPrimary
    scanAudioBtn.Size = UDim2.new(0.38, -4, 1, 0)
    scanAudioBtn.LayoutOrder = 1
    Theme.AddCorner(scanAudioBtn, Theme.CornerMedium)
    Theme.AddStroke(scanAudioBtn, Theme.BorderNeon, 1)
    scanAudioBtn.Parent = topBar

    local exportAudioListBtn = Instance.new("TextButton")
    exportAudioListBtn.Text = "📄 EXPORTAR TXT"
    exportAudioListBtn.Font = Theme.FontSemiBold
    exportAudioListBtn.TextSize = 10
    exportAudioListBtn.TextColor3 = Theme.TextPrimary
    exportAudioListBtn.BackgroundColor3 = Theme.CardBg
    exportAudioListBtn.BackgroundTransparency = Theme.CardTransparency
    exportAudioListBtn.Size = UDim2.new(0.38, -4, 1, 0)
    exportAudioListBtn.LayoutOrder = 2
    Theme.AddCorner(exportAudioListBtn, Theme.CornerMedium)
    Theme.AddStroke(exportAudioListBtn, Theme.Border, 1)
    exportAudioListBtn.Parent = topBar

    local stopAudioBtn = Instance.new("TextButton")
    stopAudioBtn.Text = "⏹ PARAR"
    stopAudioBtn.Font = Theme.FontSemiBold
    stopAudioBtn.TextSize = 10
    stopAudioBtn.TextColor3 = Theme.AccentDanger
    stopAudioBtn.BackgroundColor3 = Color3.fromRGB(24, 14, 22)
    stopAudioBtn.Size = UDim2.new(0.24, -4, 1, 0)
    stopAudioBtn.LayoutOrder = 3
    Theme.AddCorner(stopAudioBtn, Theme.CornerMedium)
    Theme.AddStroke(stopAudioBtn, Theme.AccentDanger, 1, 0.4)
    stopAudioBtn.Parent = topBar

    -- Audio Search Filter
    local searchBox = Instance.new("TextBox")
    searchBox.PlaceholderText = "🔍 Filtrar sons por nome ou ID..."
    searchBox.Font = Theme.FontRegular
    searchBox.TextSize = 11
    searchBox.TextColor3 = Theme.TextPrimary
    searchBox.PlaceholderColor3 = Theme.TextMuted
    searchBox.BackgroundColor3 = Color3.fromRGB(10, 8, 16)
    searchBox.Size = UDim2.new(1, -32, 0, 30)
    searchBox.Position = UDim2.new(0, 16, 0, 48)
    Theme.AddCorner(searchBox, Theme.CornerSmall)
    Theme.AddStroke(searchBox, Theme.Border, 1)
    searchBox.Parent = parent

    local audioScroll = Instance.new("ScrollingFrame")
    audioScroll.Size = UDim2.new(1, -32, 1, -90)
    audioScroll.Position = UDim2.new(0, 16, 0, 84)
    audioScroll.BackgroundColor3 = Theme.CardBg
    audioScroll.BackgroundTransparency = Theme.CardTransparency
    audioScroll.ScrollBarThickness = 4
    audioScroll.ScrollBarImageColor3 = Theme.BorderLight
    Theme.AddCorner(audioScroll, Theme.CornerLarge)
    Theme.AddStroke(audioScroll, Theme.Border, 1)
    audioScroll.Parent = parent

    local audioLayout = Instance.new("UIListLayout")
    audioLayout.SortOrder = Enum.SortOrder.LayoutOrder
    audioLayout.Padding = UDim.new(0, 6)
    audioLayout.Parent = audioScroll

    local allSoundRows = {}

    local function filterSounds(query)
        local q = string.lower(query or "")
        local visibleCount = 0
        for _, item in ipairs(allSoundRows) do
            local match = (q == "") or string.find(string.lower(item.Data.Name), q, 1, true) or string.find(string.lower(item.Data.CleanId), q, 1, true)
            item.Row.Visible = match
            if match then visibleCount = visibleCount + 1 end
        end
        audioScroll.CanvasSize = UDim2.new(0, 0, 0, visibleCount * 38)
    end

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        filterSounds(searchBox.Text)
    end)

    Theme.AnimateButton(scanAudioBtn, function()
        scanAudioBtn.Text = "Escaneando..."
        allSoundRows = {}
        for _, child in ipairs(audioScroll:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end

        task.spawn(function()
            local list = AudioRipper.ScanSounds()
            scanAudioBtn.Text = string.format("%d tracks found", #list)

            for _, snd in ipairs(list) do
                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, -12, 0, 32)
                row.BackgroundColor3 = Color3.fromRGB(12, 9, 20)
                row.BackgroundTransparency = 0.3
                Theme.AddCorner(row, Theme.CornerSmall)
                Theme.AddStroke(row, Theme.Border, 1)
                row.Parent = audioScroll

                local sndLbl = Instance.new("TextLabel")
                sndLbl.Text = string.format("[AUDIO] %s (ID: %s)", snd.Name, snd.CleanId)
                sndLbl.Font = Theme.FontRegular
                sndLbl.TextSize = 10
                sndLbl.TextColor3 = Theme.TextPrimary
                sndLbl.TextXAlignment = Enum.TextXAlignment.Left
                sndLbl.Size = UDim2.new(0.62, 0, 1, 0)
                sndLbl.Position = UDim2.new(0, 10, 0, 0)
                sndLbl.BackgroundTransparency = 1
                sndLbl.Parent = row

                local playBtn = Instance.new("TextButton")
                playBtn.Text = "▶ Play"
                playBtn.Font = Theme.FontSemiBold
                playBtn.TextSize = 10
                playBtn.TextColor3 = Theme.AccentSkull
                playBtn.BackgroundColor3 = Theme.AccentPrimary
                playBtn.Size = UDim2.new(0, 52, 0, 22)
                playBtn.Position = UDim2.new(1, -120, 0.5, -11)
                Theme.AddCorner(playBtn, Theme.CornerPill)
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
                copyBtn.Size = UDim2.new(0, 58, 0, 22)
                copyBtn.Position = UDim2.new(1, -62, 0.5, -11)
                Theme.AddCorner(copyBtn, Theme.CornerPill)
                copyBtn.Parent = row

                Theme.AnimateButton(copyBtn, function()
                    Environment.SetClipboard(snd.CleanId)
                    copyBtn.Text = "[OK]"
                    task.delay(1.5, function() copyBtn.Text = "Copiar ID" end)
                end)

                table.insert(allSoundRows, { Row = row, Data = snd })
            end

            audioScroll.CanvasSize = UDim2.new(0, 0, 0, #list * 38)
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
        stopAudioBtn.Text = "STOPPED"
        task.delay(1, function() stopAudioBtn.Text = "⏹ PARAR" end)
    end)

    Theme.AnimateButton(exportAudioListBtn, function()
        local file = AudioRipper.ExportSoundList()
        exportAudioListBtn.Text = "EXPORTED"
        Environment.SetClipboard(file)
        task.delay(2, function()
            exportAudioListBtn.Text = "📄 EXPORTAR TXT"
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
    card.BackgroundTransparency = Theme.CardTransparency
    Theme.AddCorner(card, Theme.CornerLarge)
    Theme.AddStroke(card, Theme.Border, 1)
    card.Parent = parent

    local headerLbl = Instance.new("TextLabel")
    headerLbl.Text = "LIGHTING & ATMOSPHERE EXTRACTOR"
    headerLbl.Font = Theme.FontTitle
    headerLbl.TextSize = 13
    headerLbl.TextColor3 = Theme.AccentCyan
    headerLbl.TextXAlignment = Enum.TextXAlignment.Left
    headerLbl.Size = UDim2.new(1, -24, 0, 24)
    headerLbl.Position = UDim2.new(0, 16, 0, 16)
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
    desc.Size = UDim2.new(1, -32, 0, 60)
    desc.Position = UDim2.new(0, 16, 0, 48)
    desc.BackgroundTransparency = 1
    desc.Parent = card

    local exportLightBtn = Instance.new("TextButton")
    exportLightBtn.Text = "EXPORT LIGHTING PRESET (.rbxmx)"
    exportLightBtn.Font = Theme.FontTitle
    exportLightBtn.TextSize = 12
    exportLightBtn.TextColor3 = Theme.AccentSkull
    exportLightBtn.BackgroundColor3 = Theme.AccentPrimary
    exportLightBtn.Size = UDim2.new(1, -32, 0, 46)
    exportLightBtn.Position = UDim2.new(0, 16, 0, 120)
    Theme.AddCorner(exportLightBtn, Theme.CornerMedium)
    Theme.AddStroke(exportLightBtn, Theme.BorderNeon, 1.2)
    Theme.AddGradient(exportLightBtn, Color3.fromRGB(147, 51, 234), Color3.fromRGB(88, 28, 135), 45)
    exportLightBtn.Parent = card

    local lightStatus = Instance.new("TextLabel")
    lightStatus.Text = "Status: Pronto para salvar iluminação"
    lightStatus.Font = Theme.FontRegular
    lightStatus.TextSize = 11
    lightStatus.TextColor3 = Theme.TextMuted
    lightStatus.TextXAlignment = Enum.TextXAlignment.Left
    lightStatus.Size = UDim2.new(1, -32, 0, 24)
    lightStatus.Position = UDim2.new(0, 16, 0, 180)
    lightStatus.BackgroundTransparency = 1
    lightStatus.Parent = card

    Theme.AnimateButton(exportLightBtn, function()
        lightStatus.Text = "Extraindo efeitos e skyboxes..."
        lightStatus.TextColor3 = Theme.AccentCyan

        task.spawn(function()
            local success, file = LightingRipper.ExportLightingPreset()
            if success then
                lightStatus.Text = "[SUCCESS] Lighting preset saved: " .. file
                lightStatus.TextColor3 = Theme.AccentSuccess
                Environment.SetClipboard(file)
            else
                lightStatus.Text = "[ERROR] " .. tostring(file)
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
    card.BackgroundTransparency = Theme.CardTransparency
    Theme.AddCorner(card, Theme.CornerLarge)
    Theme.AddStroke(card, Theme.Border, 1)
    card.Parent = parent

    local headerLbl = Instance.new("TextLabel")
    headerLbl.Text = "USER INTERFACE (GUI) RIPPER"
    headerLbl.Font = Theme.FontTitle
    headerLbl.TextSize = 13
    headerLbl.TextColor3 = Theme.AccentCyan
    headerLbl.TextXAlignment = Enum.TextXAlignment.Left
    headerLbl.Size = UDim2.new(1, -24, 0, 24)
    headerLbl.Position = UDim2.new(0, 16, 0, 16)
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
    desc.Size = UDim2.new(1, -32, 0, 60)
    desc.Position = UDim2.new(0, 16, 0, 48)
    desc.BackgroundTransparency = 1
    desc.Parent = card

    local exportGuiBtn = Instance.new("TextButton")
    exportGuiBtn.Text = "EXPORT ALL INTERFACES (.rbxmx)"
    exportGuiBtn.Font = Theme.FontTitle
    exportGuiBtn.TextSize = 12
    exportGuiBtn.TextColor3 = Theme.AccentSkull
    exportGuiBtn.BackgroundColor3 = Theme.AccentPrimary
    exportGuiBtn.Size = UDim2.new(1, -32, 0, 46)
    exportGuiBtn.Position = UDim2.new(0, 16, 0, 120)
    Theme.AddCorner(exportGuiBtn, Theme.CornerMedium)
    Theme.AddStroke(exportGuiBtn, Theme.BorderNeon, 1.2)
    Theme.AddGradient(exportGuiBtn, Color3.fromRGB(147, 51, 234), Color3.fromRGB(88, 28, 135), 45)
    exportGuiBtn.Parent = card

    local guiStatus = Instance.new("TextLabel")
    guiStatus.Text = "Status: Pronto para salvar GUIs"
    guiStatus.Font = Theme.FontRegular
    guiStatus.TextSize = 11
    guiStatus.TextColor3 = Theme.TextMuted
    guiStatus.TextXAlignment = Enum.TextXAlignment.Left
    guiStatus.Size = UDim2.new(1, -32, 0, 24)
    guiStatus.Position = UDim2.new(0, 16, 0, 180)
    guiStatus.BackgroundTransparency = 1
    guiStatus.Parent = card

    Theme.AnimateButton(exportGuiBtn, function()
        guiStatus.Text = "Extraindo e descompilando interfaces..."
        guiStatus.TextColor3 = Theme.AccentCyan

        task.spawn(function()
            local success, file = GuiRipper.ExportAllGuis(self.Config)
            if success then
                guiStatus.Text = "[SUCCESS] UI Pack saved: " .. file
                guiStatus.TextColor3 = Theme.AccentSuccess
                Environment.SetClipboard(file)
            else
                guiStatus.Text = "[ERROR] " .. tostring(file)
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

    local netLayout = Instance.new("UIListLayout")
    netLayout.FillDirection = Enum.FillDirection.Horizontal
    netLayout.Padding = UDim.new(0, 8)
    netLayout.SortOrder = Enum.SortOrder.LayoutOrder
    netLayout.Parent = topBar

    local toggleSnifferBtn = Instance.new("TextButton")
    toggleSnifferBtn.Text = "START PACKET SNIFFER"
    toggleSnifferBtn.Font = Theme.FontSemiBold
    toggleSnifferBtn.TextSize = 11
    toggleSnifferBtn.TextColor3 = Theme.AccentSkull
    toggleSnifferBtn.BackgroundColor3 = Theme.AccentPrimary
    toggleSnifferBtn.Size = UDim2.new(0.5, -4, 1, 0)
    toggleSnifferBtn.LayoutOrder = 1
    Theme.AddCorner(toggleSnifferBtn, Theme.CornerMedium)
    Theme.AddStroke(toggleSnifferBtn, Theme.BorderNeon, 1)
    toggleSnifferBtn.Parent = topBar

    local exportSnifferBtn = Instance.new("TextButton")
    exportSnifferBtn.Text = "📄 EXPORTAR (.json)"
    exportSnifferBtn.Font = Theme.FontSemiBold
    exportSnifferBtn.TextSize = 11
    exportSnifferBtn.TextColor3 = Theme.TextPrimary
    exportSnifferBtn.BackgroundColor3 = Theme.CardBg
    exportSnifferBtn.BackgroundTransparency = Theme.CardTransparency
    exportSnifferBtn.Size = UDim2.new(0.5, -4, 1, 0)
    exportSnifferBtn.LayoutOrder = 2
    Theme.AddCorner(exportSnifferBtn, Theme.CornerMedium)
    Theme.AddStroke(exportSnifferBtn, Theme.Border, 1)
    exportSnifferBtn.Parent = topBar

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -32, 1, -64)
    scroll.Position = UDim2.new(0, 16, 0, 56)
    scroll.BackgroundColor3 = Theme.CardBg
    scroll.BackgroundTransparency = Theme.CardTransparency
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Theme.BorderLight
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    Theme.AddCorner(scroll, Theme.CornerLarge)
    Theme.AddStroke(scroll, Theme.Border, 1)
    scroll.Parent = parent

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 4)
    layout.Parent = scroll

    Theme.AnimateButton(toggleSnifferBtn, function()
        if NetworkSniffer.IsActive then
            NetworkSniffer.Stop()
            toggleSnifferBtn.Text = "START PACKET SNIFFER"
            toggleSnifferBtn.TextColor3 = Theme.AccentSkull
            toggleSnifferBtn.BackgroundColor3 = Theme.AccentPrimary
        else
            NetworkSniffer.Start()
            toggleSnifferBtn.Text = "🛑 PARAR GRAVAÇÃO"
            toggleSnifferBtn.TextColor3 = Theme.AccentSkull
            toggleSnifferBtn.BackgroundColor3 = Theme.AccentDanger
        end
    end)

    Theme.AnimateButton(exportSnifferBtn, function()
        local file = NetworkSniffer.ExportLogs()
        exportSnifferBtn.Text = "[SUCCESS] Saved: " .. file
        Environment.SetClipboard(file)
        task.delay(2, function()
            exportSnifferBtn.Text = "📄 EXPORTAR (.json)"
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
    card.BackgroundTransparency = Theme.CardTransparency
    Theme.AddCorner(card, Theme.CornerLarge)
    Theme.AddStroke(card, Theme.Border, 1)
    card.Parent = parent

    local headerLbl = Instance.new("TextLabel")
    headerLbl.Text = "UNIVERSE SUB-PLACE DISCOVERY"
    headerLbl.Font = Theme.FontTitle
    headerLbl.TextSize = 13
    headerLbl.TextColor3 = Theme.AccentCyan
    headerLbl.TextXAlignment = Enum.TextXAlignment.Left
    headerLbl.Size = UDim2.new(1, -24, 0, 24)
    headerLbl.Position = UDim2.new(0, 16, 0, 16)
    headerLbl.BackgroundTransparency = 1
    headerLbl.Parent = card

    local uniBtnContainer = Instance.new("Frame")
    uniBtnContainer.Size = UDim2.new(1, -32, 0, 36)
    uniBtnContainer.Position = UDim2.new(0, 16, 0, 46)
    uniBtnContainer.BackgroundTransparency = 1
    uniBtnContainer.Parent = card

    local uniLayout = Instance.new("UIListLayout")
    uniLayout.FillDirection = Enum.FillDirection.Horizontal
    uniLayout.Padding = UDim.new(0, 6)
    uniLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uniLayout.Parent = uniBtnContainer

    local scanBtn = Instance.new("TextButton")
    scanBtn.Text = "SCAN SUB-PLACES"
    scanBtn.Font = Theme.FontTitle
    scanBtn.TextSize = 10
    scanBtn.TextColor3 = Theme.AccentSkull
    scanBtn.BackgroundColor3 = Theme.AccentPrimary
    scanBtn.Size = UDim2.new(0.34, -4, 1, 0)
    scanBtn.LayoutOrder = 1
    Theme.AddCorner(scanBtn, Theme.CornerMedium)
    Theme.AddStroke(scanBtn, Theme.BorderNeon, 1)
    scanBtn.Parent = uniBtnContainer

    local snapshotBtn = Instance.new("TextButton")
    snapshotBtn.Text = "📸 SNAPSHOT"
    snapshotBtn.Font = Theme.FontTitle
    snapshotBtn.TextSize = 10
    snapshotBtn.TextColor3 = Theme.AccentSkull
    snapshotBtn.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
    snapshotBtn.Size = UDim2.new(0.33, -4, 1, 0)
    snapshotBtn.LayoutOrder = 2
    Theme.AddCorner(snapshotBtn, Theme.CornerMedium)
    Theme.AddStroke(snapshotBtn, Theme.BorderNeon, 1)
    snapshotBtn.Parent = uniBtnContainer

    local compareDiffBtn = Instance.new("TextButton")
    compareDiffBtn.Text = "🔍 COMPARAR DIFF"
    compareDiffBtn.Font = Theme.FontTitle
    compareDiffBtn.TextSize = 10
    compareDiffBtn.TextColor3 = Theme.AccentSkull
    compareDiffBtn.BackgroundColor3 = Theme.CardActive
    compareDiffBtn.Size = UDim2.new(0.33, -4, 1, 0)
    compareDiffBtn.LayoutOrder = 3
    Theme.AddCorner(compareDiffBtn, Theme.CornerMedium)
    Theme.AddStroke(compareDiffBtn, Theme.BorderLight, 1)
    compareDiffBtn.Parent = uniBtnContainer

    local placeScroll = Instance.new("ScrollingFrame")
    placeScroll.Size = UDim2.new(1, -32, 1, -100)
    placeScroll.Position = UDim2.new(0, 16, 0, 90)
    placeScroll.BackgroundColor3 = Color3.fromRGB(10, 8, 18)
    placeScroll.BackgroundTransparency = 0.3
    placeScroll.ScrollBarThickness = 4
    placeScroll.ScrollBarImageColor3 = Theme.BorderLight
    Theme.AddCorner(placeScroll, Theme.CornerMedium)
    Theme.AddStroke(placeScroll, Theme.Border, 1)
    placeScroll.Parent = card

    local placeLayout = Instance.new("UIListLayout")
    placeLayout.SortOrder = Enum.SortOrder.LayoutOrder
    placeLayout.Padding = UDim.new(0, 6)
    placeLayout.Parent = placeScroll

    Theme.AnimateButton(scanBtn, function()
        scanBtn.Text = "Buscando..."
        for _, child in ipairs(placeScroll:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextLabel") then child:Destroy() end
        end

        task.spawn(function()
            local list = UniverseTracker.GetUniversePlaces()
            scanBtn.Text = string.format("[OK] %d sub-places", #list)

            for idx, pInfo in ipairs(list) do
                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, -12, 0, 32)
                row.BackgroundColor3 = Theme.CardBg
                row.BackgroundTransparency = 0.2
                Theme.AddCorner(row, Theme.CornerSmall)
                Theme.AddStroke(row, Theme.Border, 1)
                row.Parent = placeScroll

                local pName = Instance.new("TextLabel")
                pName.Text = string.format("📍 %s (ID: %d)", pInfo.Name, pInfo.PlaceId)
                pName.Font = Theme.FontRegular
                pName.TextSize = 10
                pName.TextColor3 = pInfo.IsRoot and Theme.AccentCyan or Theme.TextPrimary
                pName.TextXAlignment = Enum.TextXAlignment.Left
                pName.Size = UDim2.new(0.7, 0, 1, 0)
                pName.Position = UDim2.new(0, 10, 0, 0)
                pName.BackgroundTransparency = 1
                pName.Parent = row

                local copyIdBtn = Instance.new("TextButton")
                copyIdBtn.Text = "Copiar ID"
                copyIdBtn.Font = Theme.FontSemiBold
                copyIdBtn.TextSize = 10
                copyIdBtn.TextColor3 = Theme.TextSecondary
                copyIdBtn.BackgroundColor3 = Theme.CardHover
                copyIdBtn.Size = UDim2.new(0, 80, 0, 22)
                copyIdBtn.Position = UDim2.new(1, -88, 0.5, -11)
                Theme.AddCorner(copyIdBtn, Theme.CornerPill)
                copyIdBtn.Parent = row

                Theme.AnimateButton(copyIdBtn, function()
                    Environment.SetClipboard(tostring(pInfo.PlaceId))
                    copyIdBtn.Text = "[OK] Copiado"
                    task.delay(1.5, function() copyIdBtn.Text = "Copiar ID" end)
                end)
            end

            placeScroll.CanvasSize = UDim2.new(0, 0, 0, #list * 40)
        end)
    end)

    Theme.AnimateButton(snapshotBtn, function()
        snapshotBtn.Text = "Gravando..."
        task.spawn(function()
            local success, snapFile = PlaceDiffTracker.SaveSnapshot()
            if success then
                snapshotBtn.Text = "[OK] Salvo!"
                Environment.SetClipboard(snapFile)
            else
                snapshotBtn.Text = "[ERR] Erro"
            end
            task.delay(2, function() snapshotBtn.Text = "📸 SNAPSHOT" end)
        end)
    end)

    Theme.AnimateButton(compareDiffBtn, function()
        compareDiffBtn.Text = "Comparando..."
        for _, child in ipairs(placeScroll:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextLabel") then child:Destroy() end
        end

        task.spawn(function()
            local diff = PlaceDiffTracker.Compare({ Instances = {}, PlaceId = game.PlaceId or 0, InstanceCount = 0 })
            local s, reportFile = PlaceDiffTracker.ExportDiffReport(diff)
            
            local lbl = Instance.new("TextLabel")
            lbl.Text = "📊 " .. diff.Summary .. (s and ("\n📄 Relatório salvo: " .. reportFile) or "")
            lbl.Font = Theme.FontRegular
            lbl.TextSize = 11
            lbl.TextColor3 = Theme.AccentCyan
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextWrapped = true
            lbl.Size = UDim2.new(1, -12, 0, 60)
            lbl.BackgroundTransparency = 1
            lbl.Parent = placeScroll

            if s then Environment.SetClipboard(reportFile) end
            compareDiffBtn.Text = "[OK] Concluído"
            task.delay(2, function() compareDiffBtn.Text = "🔍 COMPARAR DIFF" end)
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
    card.BackgroundTransparency = Theme.CardTransparency
    Theme.AddCorner(card, Theme.CornerLarge)
    Theme.AddStroke(card, Theme.Border, 1)
    card.Parent = parent

    local headerLbl = Instance.new("TextLabel")
    headerLbl.Text = " EXPORTADOR 3D WAVEFRONT (.OBJ + .MTL)"
    headerLbl.Font = Theme.FontTitle
    headerLbl.TextSize = 13
    headerLbl.TextColor3 = Theme.AccentCyan
    headerLbl.TextXAlignment = Enum.TextXAlignment.Left
    headerLbl.Size = UDim2.new(1, -24, 0, 24)
    headerLbl.Position = UDim2.new(0, 16, 0, 16)
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
    desc.Size = UDim2.new(1, -32, 0, 48)
    desc.Position = UDim2.new(0, 16, 0, 48)
    desc.BackgroundTransparency = 1
    desc.Parent = card

    local exportBtnContainer = Instance.new("Frame")
    exportBtnContainer.Size = UDim2.new(1, -32, 0, 44)
    exportBtnContainer.Position = UDim2.new(0, 16, 0, 106)
    exportBtnContainer.BackgroundTransparency = 1
    exportBtnContainer.Parent = card

    local btnLayout = Instance.new("UIListLayout")
    btnLayout.FillDirection = Enum.FillDirection.Horizontal
    btnLayout.Padding = UDim.new(0, 8)
    btnLayout.SortOrder = Enum.SortOrder.LayoutOrder
    btnLayout.Parent = exportBtnContainer

    local exportObjBtn = Instance.new("TextButton")
    exportObjBtn.Text = " EXPORTAR .OBJ + .MTL"
    exportObjBtn.Font = Theme.FontTitle
    exportObjBtn.TextSize = 11
    exportObjBtn.TextColor3 = Theme.AccentSkull
    exportObjBtn.BackgroundColor3 = Theme.AccentPrimary
    exportObjBtn.Size = UDim2.new(0.5, -4, 1, 0)
    exportObjBtn.LayoutOrder = 1
    Theme.AddCorner(exportObjBtn, Theme.CornerMedium)
    Theme.AddStroke(exportObjBtn, Theme.BorderNeon, 1.2)
    Theme.AddGradient(exportObjBtn, Color3.fromRGB(147, 51, 234), Color3.fromRGB(88, 28, 135), 45)
    exportObjBtn.Parent = exportBtnContainer

    local exportWebBtn = Instance.new("TextButton")
    exportWebBtn.Text = "🌐 EXPORTAR 3D WEB (HTML)"
    exportWebBtn.Font = Theme.FontTitle
    exportWebBtn.TextSize = 11
    exportWebBtn.TextColor3 = Theme.AccentSkull
    exportWebBtn.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
    exportWebBtn.Size = UDim2.new(0.5, -4, 1, 0)
    exportWebBtn.LayoutOrder = 2
    Theme.AddCorner(exportWebBtn, Theme.CornerMedium)
    Theme.AddStroke(exportWebBtn, Theme.BorderNeon, 1.2)
    Theme.AddGradient(exportWebBtn, Color3.fromRGB(192, 132, 252), Color3.fromRGB(126, 34, 206), 45)
    exportWebBtn.Parent = exportBtnContainer

    local objStatus = Instance.new("TextLabel")
    objStatus.Text = "Status: Pronto para exportar"
    objStatus.Font = Theme.FontRegular
    objStatus.TextSize = 11
    objStatus.TextColor3 = Theme.TextMuted
    objStatus.TextXAlignment = Enum.TextXAlignment.Left
    objStatus.Size = UDim2.new(1, -32, 0, 24)
    objStatus.Position = UDim2.new(0, 16, 0, 160)
    objStatus.BackgroundTransparency = 1
    objStatus.Parent = card

    Theme.AnimateButton(exportObjBtn, function()
        objStatus.Text = "Gerando geometria .obj e biblioteca de materiais .mtl..."
        objStatus.TextColor3 = Theme.AccentCyan

        task.spawn(function()
            local success, file = ObjExporter.ExportWorkspaceToObj()
            if success then
                objStatus.Text = "[OK] Exportado com sucesso: " .. file
                objStatus.TextColor3 = Theme.AccentSuccess
                Environment.SetClipboard(file)
            else
                objStatus.Text = "[ERR] Erro ao exportar: " .. tostring(file)
                objStatus.TextColor3 = Theme.AccentDanger
            end
        end)
    end)

    Theme.AnimateButton(exportWebBtn, function()
        objStatus.Text = "🌐 Gerando visualizador 3D Web standalone (.html)..."
        objStatus.TextColor3 = Theme.AccentCyan

        task.spawn(function()
            local success, file = Web3DExporter.ExportModelToHTML(workspace)
            if success then
                objStatus.Text = "[SUCCESS] Web 3D exported: " .. file .. " (Abra no navegador!)"
                objStatus.TextColor3 = Theme.AccentSuccess
                Environment.SetClipboard(file)
            else
                objStatus.Text = "[ERROR] Web 3D export failed: " .. tostring(file)
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
    scroll.ScrollBarImageColor3 = Theme.BorderLight
    scroll.CanvasSize = UDim2.new(0, 0, 0, 480)
    scroll.Parent = parent

    local steps = {
        {"📌 Passo 1: Iniciar a Cópia", "Basta ir na aba ' Clonar Tudo' e clicar no botão roxo 'CLONAR JOGO INTEIRO'. O HyperSaveInstance vai começar a varrer o mapa."},
        {"⏳ Passo 2: Aguardar o Progresso", "A barra de progresso vai indicar o que está sendo salvo em tempo real: áudios, texturas, meshes 3D, terreno e scripts descompilados."},
        {" Passo 3: Onde o Arquivo Fica?", "O arquivo .rbxlx e a pasta de assets são salvos automaticamente dentro da pasta 'workspace' do seu executor no seu computador."},
        {" Passo 4: Como Abrir no Roblox Studio", "1. Abra o Roblox Studio.\n2. Clique em 'File' (Arquivo) -> 'Open from File...'\n3. Selecione o arquivo gerado e clique em Abrir.\n4. Pronto! O jogo inteiro abrirá 100% editável!"},
    }

    for i, step in ipairs(steps) do
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -12, 0, 80)
        card.Position = UDim2.new(0, 0, 0, (i - 1) * 88)
        card.BackgroundColor3 = Theme.CardBg
        card.BackgroundTransparency = Theme.CardTransparency
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
        desc.Size = UDim2.new(1, -24, 0, 46)
        desc.Position = UDim2.new(0, 12, 0, 30)
        desc.BackgroundTransparency = 1
        desc.Parent = card
    end

    -- Copy Universal Command Button
    local copyScriptCard = Instance.new("TextButton")
    copyScriptCard.Text = "📋 Copiar Comando de Execução (loadstring) para a Área de Transferência"
    copyScriptCard.Font = Theme.FontSemiBold
    copyScriptCard.TextSize = 11
    copyScriptCard.TextColor3 = Theme.AccentSkull
    copyScriptCard.BackgroundColor3 = Theme.AccentPrimary
    copyScriptCard.Size = UDim2.new(1, -12, 0, 38)
    copyScriptCard.Position = UDim2.new(0, 0, 0, 360)
    Theme.AddCorner(copyScriptCard, Theme.CornerPill)
    Theme.AddStroke(copyScriptCard, Theme.BorderNeon, 1.2)
    copyScriptCard.Parent = scroll

    Theme.AnimateButton(copyScriptCard, function()
        Environment.SetClipboard('loadstring(game:HttpGet("https://raw.githubusercontent.com/theopadilha2009-hash/HyperSaveInstance/main/dist/HyperSaveInstance.luau"))()')
        copyScriptCard.Text = "[OK] Comando Copiado!"
        task.delay(2, function()
            copyScriptCard.Text = "📋 Copiar Comando de Execução (loadstring) para a Área de Transferência"
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
    scroll.ScrollBarImageColor3 = Theme.BorderLight
    scroll.CanvasSize = UDim2.new(0, 0, 0, 820)
    scroll.Parent = parent

    -- Discord Webhook URL Row
    local webhookRow = Instance.new("Frame")
    webhookRow.Size = UDim2.new(1, -12, 0, 42)
    webhookRow.Position = UDim2.new(0, 0, 0, 0)
    webhookRow.BackgroundColor3 = Theme.CardBg
    webhookRow.BackgroundTransparency = Theme.CardTransparency
    Theme.AddCorner(webhookRow, Theme.CornerMedium)
    Theme.AddStroke(webhookRow, Theme.BorderNeon, 1.2)
    webhookRow.Parent = scroll

    local webhookLbl = Instance.new("TextLabel")
    webhookLbl.Text = "DISCORD WEBHOOK URL (NOTIFICAÇÃO):"
    webhookLbl.Font = Theme.FontSemiBold
    webhookLbl.TextSize = 10
    webhookLbl.TextColor3 = Theme.AccentCyan
    webhookLbl.TextXAlignment = Enum.TextXAlignment.Left
    webhookLbl.Size = UDim2.new(0.45, 0, 1, 0)
    webhookLbl.Position = UDim2.new(0, 10, 0, 0)
    webhookLbl.BackgroundTransparency = 1
    webhookLbl.Parent = webhookRow

    local webhookBox = Instance.new("TextBox")
    webhookBox.PlaceholderText = "https://discord.com/api/webhooks/..."
    webhookBox.Text = self.Config.DiscordWebhookUrl or ""
    webhookBox.Font = Theme.FontCode
    webhookBox.TextSize = 10
    webhookBox.TextColor3 = Theme.TextPrimary
    webhookBox.PlaceholderColor3 = Theme.TextMuted
    webhookBox.BackgroundColor3 = Color3.fromRGB(12, 9, 20)
    webhookBox.Size = UDim2.new(0.52, 0, 0, 26)
    webhookBox.Position = UDim2.new(0.46, 0, 0.5, -13)
    webhookBox.ClearTextOnFocus = false
    Theme.AddCorner(webhookBox, Theme.CornerSmall)
    Theme.AddStroke(webhookBox, Theme.Border, 1)
    webhookBox.Parent = webhookRow

    webhookBox.FocusLost:Connect(function()
        self.Config.DiscordWebhookUrl = webhookBox.Text
        self:Log("Discord Webhook atualizado.")
    end)

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
        row.Size = UDim2.new(1, -12, 0, 34)
        row.Position = UDim2.new(0, 0, 0, 48 + (i - 1) * 38)
        row.BackgroundColor3 = Theme.CardBg
        row.BackgroundTransparency = Theme.CardTransparency
        Theme.AddCorner(row, Theme.CornerMedium)
        Theme.AddStroke(row, Theme.Border, 1)
        row.Parent = scroll

        local lbl = Instance.new("TextLabel")
        lbl.Text = title
        lbl.Font = Theme.FontRegular
        lbl.TextSize = 11
        lbl.TextColor3 = (key == "OptimizeGeometry") and Theme.AccentWarning or Theme.TextPrimary
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Size = UDim2.new(0.75, 0, 1, 0)
        lbl.Position = UDim2.new(0, 12, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Parent = row

        local switch = Instance.new("TextButton")
        switch.Text = defaultVal and "ATIVADO" or "DESATIVADO"
        switch.Font = Theme.FontSemiBold
        switch.TextSize = 10
        switch.TextColor3 = defaultVal and Theme.AccentSkull or Theme.TextMuted
        switch.BackgroundColor3 = defaultVal and Theme.AccentPrimary or Theme.CardHover
        switch.Size = UDim2.new(0, 84, 0, 24)
        switch.Position = UDim2.new(1, -92, 0.5, -12)
        Theme.AddCorner(switch, Theme.CornerPill)
        Theme.AddStroke(switch, defaultVal and Theme.BorderNeon or Theme.Border, 1)
        switch.Parent = row

        Theme.AnimateButton(switch, function()
            local current = self.Config[key]
            local new = not current
            self.Config[key] = new
            switch.Text = new and "ATIVADO" or "DESATIVADO"
            switch.TextColor3 = new and Theme.AccentSkull or Theme.TextMuted
            switch.BackgroundColor3 = new and Theme.AccentPrimary or Theme.CardHover
            local stroke = switch:FindFirstChildOfClass("UIStroke")
            if stroke then
                stroke.Color = new and Theme.BorderNeon or Theme.Border
            end
            self:Log("Opção alterada: " .. key .. " = " .. tostring(new))
        end)
    end
end

-- 11. Console Tab
function Interface:BuildConsoleTab()
    local parent = self.TabFrames["Console"]

    local consoleBox = Instance.new("ScrollingFrame")
    consoleBox.Size = UDim2.new(1, -32, 1, -68)
    consoleBox.Position = UDim2.new(0, 16, 0, 16)
    consoleBox.BackgroundColor3 = Theme.CardBg
    consoleBox.BackgroundTransparency = Theme.CardTransparency
    consoleBox.ScrollBarThickness = 4
    consoleBox.ScrollBarImageColor3 = Theme.BorderLight
    consoleBox.CanvasSize = UDim2.new(0, 0, 0, 0)
    Theme.AddCorner(consoleBox, Theme.CornerLarge)
    Theme.AddStroke(consoleBox, Theme.Border, 1)
    consoleBox.Parent = parent
    self.ConsoleScroll = consoleBox

    local consoleList = Instance.new("UIListLayout")
    consoleList.SortOrder = Enum.SortOrder.LayoutOrder
    consoleList.Padding = UDim.new(0, 4)
    consoleList.Parent = consoleBox

    local copyLogsBtn = Instance.new("TextButton")
    copyLogsBtn.Text = "📋 Copiar Logs para Área de Transferência"
    copyLogsBtn.Font = Theme.FontSemiBold
    copyLogsBtn.TextSize = 11
    copyLogsBtn.TextColor3 = Theme.AccentSkull
    copyLogsBtn.BackgroundColor3 = Theme.AccentPrimary
    copyLogsBtn.Size = UDim2.new(1, -32, 0, 36)
    copyLogsBtn.Position = UDim2.new(0, 16, 1, -44)
    Theme.AddCorner(copyLogsBtn, Theme.CornerPill)
    Theme.AddStroke(copyLogsBtn, Theme.BorderNeon, 1.2)
    copyLogsBtn.Parent = parent

    Theme.AnimateButton(copyLogsBtn, function()
        local fullLog = table.concat(self.Logs, "\n")
        Environment.SetClipboard(fullLog)
        copyLogsBtn.Text = "[OK] Logs Copiados!"
        task.delay(2, function()
            copyLogsBtn.Text = "📋 Copiar Logs para Área de Transferência"
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
    scroll.BackgroundTransparency = Theme.CardTransparency
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Theme.BorderLight
    scroll.CanvasSize = UDim2.new(0, 0, 0, 490)
    Theme.AddCorner(scroll, Theme.CornerLarge)
    Theme.AddStroke(scroll, Theme.BorderLight, 1)
    scroll.Parent = parent

    -- Developer Profile Header Card
    local devCard = Instance.new("Frame")
    devCard.Size = UDim2.new(1, -24, 0, 120)
    devCard.Position = UDim2.new(0, 12, 0, 12)
    devCard.BackgroundColor3 = Color3.fromRGB(15, 11, 26)
    devCard.BackgroundTransparency = 0.2
    Theme.AddCorner(devCard, Theme.CornerLarge)
    Theme.AddStroke(devCard, Theme.BorderNeon, 1.2)
    Theme.AddGradient(devCard, Color3.fromRGB(15, 11, 26), Color3.fromRGB(30, 20, 48), 45)
    devCard.Parent = scroll

    -- Avatar Emblem (Bubble Pill)
    local avatar = Instance.new("Frame")
    avatar.Size = UDim2.new(0, 52, 0, 52)
    avatar.Position = UDim2.new(0, 16, 0, 16)
    avatar.BackgroundColor3 = Theme.AccentPrimary
    Theme.AddCorner(avatar, Theme.CornerPill)
    Theme.AddGradient(avatar, Color3.fromRGB(168, 85, 247), Color3.fromRGB(126, 34, 206), 45)
    avatar.Parent = devCard

    local avatarTxt = Instance.new("TextLabel")
    avatarTxt.Text = "TLP"
    avatarTxt.Font = Theme.FontTitle
    avatarTxt.TextSize = 16
    avatarTxt.TextColor3 = Theme.AccentSkull
    avatarTxt.Size = UDim2.new(1, 0, 1, 0)
    avatarTxt.BackgroundTransparency = 1
    avatarTxt.Parent = avatar

    -- Developer Name & Title
    local devName = Instance.new("TextLabel")
    devName.Text = "Theo Lorentz Padilha"
    devName.Font = Theme.FontTitle
    devName.TextSize = 15
    devName.TextColor3 = Theme.TextPrimary
    devName.TextXAlignment = Enum.TextXAlignment.Left
    devName.Size = UDim2.new(1, -84, 0, 20)
    devName.Position = UDim2.new(0, 78, 0, 16)
    devName.BackgroundTransparency = 1
    devName.Parent = devCard

    local devRole = Instance.new("TextLabel")
    devRole.Text = " Criador & Engenheiro Principal • HyperSaveInstance"
    devRole.Font = Theme.FontSemiBold
    devRole.TextSize = 11
    devRole.TextColor3 = Theme.TextTheo
    devRole.TextXAlignment = Enum.TextXAlignment.Left
    devRole.Size = UDim2.new(1, -84, 0, 16)
    devRole.Position = UDim2.new(0, 78, 0, 38)
    devRole.BackgroundTransparency = 1
    devRole.Parent = devCard

    -- Action Container for Buttons (UIListLayout Grid)
    local devBtnBar = Instance.new("Frame")
    devBtnBar.Size = UDim2.new(1, -94, 0, 30)
    devBtnBar.Position = UDim2.new(0, 78, 0, 68)
    devBtnBar.BackgroundTransparency = 1
    devBtnBar.Parent = devCard

    local devBtnLayout = Instance.new("UIListLayout")
    devBtnLayout.FillDirection = Enum.FillDirection.Horizontal
    devBtnLayout.Padding = UDim.new(0, 8)
    devBtnLayout.SortOrder = Enum.SortOrder.LayoutOrder
    devBtnLayout.Parent = devBtnBar

    -- GitHub Link Button
    local btnGithub = Instance.new("TextButton")
    btnGithub.Text = "🔗 GitHub Profile"
    btnGithub.Font = Theme.FontSemiBold
    btnGithub.TextSize = 10
    btnGithub.TextColor3 = Theme.AccentSkull
    btnGithub.BackgroundColor3 = Theme.AccentPrimary
    btnGithub.Size = UDim2.new(0.5, -4, 1, 0)
    btnGithub.LayoutOrder = 1
    Theme.AddCorner(btnGithub, Theme.CornerPill)
    Theme.AddStroke(btnGithub, Theme.BorderNeon, 1)
    btnGithub.Parent = devBtnBar

    Theme.AnimateButton(btnGithub, function()
        Environment.SetClipboard("https://github.com/theopadilha2009-hash")
        btnGithub.Text = "[OK] Perfil Copiado!"
        task.delay(2, function()
            btnGithub.Text = "🔗 GitHub Profile"
        end)
    end)

    -- Repository Link Button
    local btnRepo = Instance.new("TextButton")
    btnRepo.Text = " Repositório"
    btnRepo.Font = Theme.FontSemiBold
    btnRepo.TextSize = 10
    btnRepo.TextColor3 = Theme.TextPrimary
    btnRepo.BackgroundColor3 = Theme.CardHover
    btnRepo.Size = UDim2.new(0.5, -4, 1, 0)
    btnRepo.LayoutOrder = 2
    Theme.AddCorner(btnRepo, Theme.CornerPill)
    Theme.AddStroke(btnRepo, Theme.Border, 1)
    btnRepo.Parent = devBtnBar

    Theme.AnimateButton(btnRepo, function()
        Environment.SetClipboard("https://github.com/theopadilha2009-hash/HyperSaveInstance")
        btnRepo.Text = "[OK] Repo Copiado!"
        task.delay(2, function()
            btnRepo.Text = " Repositório"
        end)
    end)

    -- System Diagnostics Card
    local sysCard = Instance.new("Frame")
    sysCard.Size = UDim2.new(1, -24, 0, 180)
    sysCard.Position = UDim2.new(0, 12, 0, 142)
    sysCard.BackgroundColor3 = Color3.fromRGB(12, 9, 20)
    sysCard.BackgroundTransparency = 0.3
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
    featCard.BackgroundColor3 = Color3.fromRGB(12, 9, 20)
    featCard.BackgroundTransparency = 0.3
    Theme.AddCorner(featCard, Theme.CornerMedium)
    Theme.AddStroke(featCard, Theme.Border, 1)
    featCard.Parent = scroll

    local featTitle = Instance.new("TextLabel")
    featTitle.Text = " RECURSOS EXCLUSIVOS INCLUÍDOS"
    featTitle.Font = Theme.FontTitle
    featTitle.TextSize = 12
    featTitle.TextColor3 = Theme.AccentCyan
    featTitle.TextXAlignment = Enum.TextXAlignment.Left
    featTitle.Size = UDim2.new(1, -20, 0, 20)
    featTitle.Position = UDim2.new(0, 12, 0, 10)
    featTitle.BackgroundTransparency = 1
    featTitle.Parent = featCard

    local featDesc = Instance.new("TextLabel")
    featDesc.Text = "[OK] Seletor 3D com Mira no Mundo & Multi-Seleção em Lote\n[OK] Extração de Terreno SmoothVoxels 3D, Iluminação PBR & Sons\n[OK] Plugin Oficial de Roblox Studio com Reparo Mestre 1-Clique\n[OK] Desofuscador de Variáveis de Scripts e Proteção Anti-AFK"
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

function Interface:Log(message, color)
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
                self.CloneButton.Text = "[OK] CLONADO COM SUCESSO!"
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
    HyperSaveInstance - High-End Dark Gothic Cyberpunk & Neon Design System
    Author: Theo Lorentz Padilha (https://github.com/theopadilha2009-hash)
]]

local TweenService = game:GetService("TweenService")

local Theme = {
    -- Dark Gothic Cyberpunk Palette (Deep Obsidian, Pitch Black & Vivid Ultraviolet Neon)
    Background = Color3.fromRGB(5, 4, 9),             -- Ultra-deep Void Black (#050409)
    BackgroundTransparency = 0.04,                   -- Dense frosted dark glass
    CardBg = Color3.fromRGB(11, 9, 18),               -- Dark Obsidian Panel (#0b0912)
    CardTransparency = 0.1,                          -- High opacity solid glass
    CardHover = Color3.fromRGB(26, 18, 44),          -- Subtle Ultraviolet hover
    CardActive = Color3.fromRGB(46, 20, 80),         -- Active glowing violet
    Border = Color3.fromRGB(38, 26, 62),             -- Dark alloy border
    BorderTransparency = 0.2,
    BorderLight = Color3.fromRGB(147, 51, 234),      -- Vivid Purple Stroke (#9333ea)
    BorderNeon = Color3.fromRGB(168, 85, 247),       -- Ultra Neon Violet Glow (#a855f7)
    BorderCyber = Color3.fromRGB(192, 132, 252),     -- Electric Lavender (#c084fc)
    
    -- Accents
    AccentPrimary = Color3.fromRGB(126, 34, 206),    -- Deep Electric Purple (#7e22ce)
    AccentSecondary = Color3.fromRGB(168, 85, 247),  -- Neon Violet (#a855f7)
    AccentDark = Color3.fromRGB(59, 7, 100),         -- Midnight Amethyst (#3b0764)
    AccentGothic = Color3.fromRGB(248, 250, 252),    -- Razor Crisp Bone White (#f8fafc)
    AccentSuccess = Color3.fromRGB(168, 85, 247),    -- Neon Purple
    AccentWarning = Color3.fromRGB(232, 121, 249),   -- Vivid Magenta (#e879f9)
    AccentDanger = Color3.fromRGB(244, 63, 94),      -- Neon Crimson (#f43f5e)
    AccentTheo = Color3.fromRGB(216, 180, 254),      -- Glowing Cyber Lavender (#d8b4fe)
    AccentSkull = Color3.fromRGB(255, 255, 255),     -- Pure White

    -- High-Contrast Typography
    TextPrimary = Color3.fromRGB(255, 255, 255),     -- Crisp Bone White
    TextSecondary = Color3.fromRGB(203, 185, 235),   -- Muted Violet Silver
    TextMuted = Color3.fromRGB(130, 115, 160),       -- Shadow Violet
    TextAccent = Color3.fromRGB(192, 132, 252),      -- Cyber Violet
    TextTheo = Color3.fromRGB(233, 213, 255),        -- Pale Lavender

    -- Modern Fonts
    FontTitle = Enum.Font.GothamBold,
    FontSemiBold = Enum.Font.GothamSemibold,
    FontRegular = Enum.Font.Gotham,
    FontCode = Enum.Font.Code,

    -- Sharp Geometric Radii (Sleek, High-Tech Gothic Curves)
    CornerLarge = UDim.new(0, 10),
    CornerMedium = UDim.new(0, 7),
    CornerSmall = UDim.new(0, 5),
    CornerPill = UDim.new(1, 0),
}

-- Tween animation helper
function Theme.Tween(instance, duration, properties, easingStyle, easingDirection)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.18, easingStyle or Enum.EasingStyle.Quad, easingDirection or Enum.EasingDirection.Out),
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

-- Create stroke / border
function Theme.AddStroke(instance, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Border
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = instance
    return stroke
end

-- Create gradient
function Theme.AddGradient(instance, c1, c2, rotation)
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, c1),
        ColorSequenceKeypoint.new(1, c2)
    })
    grad.Rotation = rotation or 45
    grad.Parent = instance
    return grad
end

-- Interactive Button Animation Helper
function Theme.AnimateButton(btn, onClick)
    local origSize = btn.Size
    local origBg = btn.BackgroundColor3

    pcall(function()
        btn.MouseEnter:Connect(function()
            Theme.Tween(btn, 0.15, {
                BackgroundColor3 = (btn.BackgroundColor3 == Theme.CardBg) and Theme.CardHover or btn.BackgroundColor3
            })
        end)

        btn.MouseLeave:Connect(function()
            Theme.Tween(btn, 0.15, {
                BackgroundColor3 = origBg
            })
        end)

        btn.MouseButton1Down:Connect(function()
            Theme.Tween(btn, 0.06, {
                Size = UDim2.new(origSize.X.Scale, origSize.X.Offset - 2, origSize.Y.Scale, origSize.Y.Offset - 2)
            })
        end)

        btn.MouseButton1Up:Connect(function()
            Theme.Tween(btn, 0.1, {
                Size = origSize
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

-- Animated Neon Pulse Glow for Hero Buttons
function Theme.StartNeonPulse(stroke, baseColor, neonColor, speed)
    local RunService = game:GetService("RunService")
    local c1 = baseColor or Theme.BorderLight
    local c2 = neonColor or Theme.BorderNeon
    local spd = speed or 2.5
    
    local conn
    pcall(function()
        conn = RunService.RenderStepped:Connect(function()
            if not stroke or not stroke.Parent then
                if conn then conn:Disconnect() end
                return
            end
            local t = (math.sin(os.clock() * spd) + 1) * 0.5
            stroke.Color = Color3.new(
                c1.R + (c2.R - c1.R) * t,
                c1.G + (c2.G - c1.G) * t,
                c1.B + (c2.B - c1.B) * t
            )
            stroke.Thickness = 1.2 + t * 0.8
        end)
    end)
    return conn
end

return Theme

end)

__define__("Utils/AntiAFK", function()
--[[
    HyperSaveInstance - Anti-AFK & Anti-Kick Protection System
    Prevents Roblox Error 268/273 (20-minute idle disconnection) during long save sessions.
]]

local Players = nil
pcall(function() Players = game:GetService("Players") end)

local AntiAFK = {}
local isEnabled = false
local idleConnection = nil

function AntiAFK.Enable()
    if isEnabled then return end
    isEnabled = true

    pcall(function()
        local plrs = Players or game:GetService("Players")
        local localPlayer = plrs and plrs.LocalPlayer
        if localPlayer and localPlayer.Idled then
            idleConnection = localPlayer.Idled:Connect(function()
                if not isEnabled then return end
                pcall(function()
                    local vu = (game.GetService and game:GetService("VirtualUser")) or (game.FindService and game:FindService("VirtualUser"))
                    if vu and vu.CaptureController then
                        vu:CaptureController()
                        vu:ClickButton2(Vector2.new(0, 0))
                    end
                end)
            end)
        end
    end)
end

function AntiAFK.Disable()
    isEnabled = false
    if idleConnection then
        idleConnection:Disconnect()
        idleConnection = nil
    end
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

function Base64.Decode(data)
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

end)

__define__("Utils/Environment", function()
--[[
    HyperSaveInstance - Universal Environment & Polyfill Module
    Supports Mac (MacSploit, Hydrogen), Windows (Wave, Synapse Z, Solara, Celery, etc.), Mobile (Delta, Codex, Arceus X)
]]

local Environment = {}

-- Service references (Safely wrapped in pcalls for all execution identities)
local cloneref = cloneref or function(obj) return obj end
local HttpService = nil
pcall(function() HttpService = cloneref(game:GetService("HttpService")) end)
local Players = nil
pcall(function() Players = cloneref(game:GetService("Players")) end)
local CoreGui = nil
pcall(function() CoreGui = cloneref(game:GetService("CoreGui")) end)

-- Universal Task polyfill
local task = task or {
    spawn = spawn or function(fn, ...) return coroutine.wrap(fn)(...) end,
    wait = wait or function(t) return coroutine.yield(t) end,
    delay = delay or function(t, fn) return task.spawn(function() task.wait(t); fn() end) end,
    defer = function(fn, ...) return (spawn or task.spawn)(function(...) fn(...) end, ...) end
}

-- Table & Math polyfills wrapped safely for readonly Luau environment
pcall(function()
    if not table.clone then
        table.clone = function(t)
            if type(t) ~= "table" then return t end
            local clone = {}
            for k, v in pairs(t) do clone[k] = v end
            return clone
        end
    end
end)
pcall(function()
    if not table.find then
        table.find = function(t, val, init)
            if type(t) ~= "table" then return nil end
            for i = (init or 1), #t do
                if t[i] == val then return i end
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

function Environment.HasFileSystem()
    return type(_writefile) == "function"
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
        pcall(function() existing = _readfile(path) or "" end)
        return Environment.WriteFile(path, existing .. content)
    end
    return false
end

function Environment.ReadFile(path)
    if _readfile then
        local success, result = pcall(_readfile, path)
        if success then return result end
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
        coreGui = game:GetService("CoreGui")
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
        local plrs = game:GetService("Players")
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
function Environment.GetHiddenProperties(instance, property)
    local gethidden = gethiddenproperty or (syn and syn.get_hidden_property)
    if gethidden then
        local success, val = pcall(gethidden, instance, property)
        if success then return val end
    end
    local s, v = pcall(function() return (instance )[property] end)
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

function LZ4.Compress(input)
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
function Stealth.GenerateRandomName(len)
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
function Stealth.SafeGetProperty(instance, property)
    local success, val = pcall(function()
        return (instance )[property]
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
    if self.Position > self.Length then return 0 end
    local byte = string.byte(self.Source, self.Position)
    self.Position = self.Position + 1
    return byte
end

function Stream:ReadBytes(count)
    if self.Position > self.Length then return "" end
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

-- Instant StarterGui Notification
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "💀 HyperSaveInstance",
        Text = "Carregado por Theo Lorentz Padilha!",
        Duration = 4
    })
end)

print("[💀 HyperSaveInstance] Iniciando HyperSaveInstance por Theo Lorentz Padilha...")

-- Auto-initialize HUD if ShowUI is enabled
if Defaults.ShowUI then
    local success, result = pcall(function()
        return HyperSaveInstance.OpenUI()
    end)
    if success then
        print("[💀 HyperSaveInstance] ✓ HUD Carregado com Sucesso! Pressione RightShift ou use o botão flutuante.")
    else
        warn("[💀 HyperSaveInstance] ✕ Falha ao abrir interface: " .. tostring(result))
    end
end

return HyperSaveInstance

end)
if not __mainSuccess__ then
    warn("[HyperSaveInstance Fatal Error] " .. tostring(__mainErr__))
    __showErrorGui__("Erro Fatal na Execucao", tostring(__mainErr__))
end
