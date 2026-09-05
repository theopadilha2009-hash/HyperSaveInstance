--[[
    HyperSaveInstance - Master Engine Orchestrator
    Coordinates scanning, raw asset downloading, terrain voxel extraction, script decompilation, Anti-AFK and file export.
]]

local SoundService = nil
pcall(function()
    SoundService = game:GetService("SoundService")
end)

local Environment = require(script.Parent.Parent.Utils.Environment)
local AntiAFK = require(script.Parent.Parent.Utils.AntiAFK)
local Stealth = require(script.Parent.Parent.Utils.Stealth)
local Defaults = require(script.Parent.Parent.Config.Defaults)
local ClassBlacklist = require(script.Parent.Parent.Config.ClassBlacklist)
local TerrainSerializer = require(script.Parent.TerrainSerializer)
local StreamExplorer = require(script.Parent.StreamExplorer)
local Decompiler = require(script.Parent.Decompiler)
local AssetDownloader = require(script.Parent.AssetDownloader)
local SerializerXml = require(script.Parent.SerializerXml)
local SerializerBinary = require(script.Parent.SerializerBinary)
local SerializerScript = require(script.Parent.SerializerScript)
local ServerSynthesizer = require(script.Parent.ServerSynthesizer)

local Engine = {}
Engine.__index = Engine

-- Status types
export type SaveProgress = {
    Stage: string, -- "Idle" | "Scanning" | "Preloading" | "Exploring" | "Assets" | "Terrain" | "Decompiling" | "Serializing" | "Writing" | "Done" | "Error"
    Current: number,
    Total: number,
    Percentage: number,
    Message: string,
    SavedFile: string?,
    AssetsFolder: string?,
}

function Engine.NormalizeOptions(rawOptions: table?): table
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

function Engine.new(customConfig: table?)
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
    placeName = Environment.SanitizeFileName(placeName)
    local ext = string.lower(self.Config.Format or "rbxlx")
    return string.format("HyperSave_%s_%d.%s", placeName, placeId, ext)
end

function Engine:GetDefaultAssetFolder(): string
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
function Engine:ShouldSaveInstance(inst: Instance): boolean
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
function Engine:SaveTarget(target: Instance, customConfig: table?): (boolean, string)
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

    local function scan(inst: Instance)
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
function Engine:SaveTargetBatch(targets: { Instance }, customConfig: table?): (boolean, string)
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

    local function scan(inst: Instance)
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
    local rootInstances: { Instance } = {}
    local allInstances: { Instance } = {}
    local scriptInstances: { LuaSourceContainer } = {}

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

    local function scan(inst: Instance)
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

    for _, root in ipairs(rootInstances) do
        scan(root)
    end

    -- Process any accumulated streaming instances preserved from stream-out chunks
    local accumulated = StreamExplorer.GetAccumulatedInstances()
    for _, accInst in ipairs(accumulated) do
        if not visited[accInst] and self:ShouldSaveInstance(accInst) then
            scan(accInst)
        end
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
    local scriptSources: { [LuaSourceContainer]: string } = {}
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
