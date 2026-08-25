--[[
    HyperSaveInstance - Master Engine Orchestrator
    Coordinates instance scanning, terrain extraction, script decompilation and file export.
]]

local Environment = require(script.Parent.Parent.Utils.Environment)
local Defaults = require(script.Parent.Parent.Config.Defaults)
local ClassBlacklist = require(script.Parent.Parent.Config.ClassBlacklist)
local TerrainSerializer = require(script.Parent.TerrainSerializer)
local Decompiler = require(script.Parent.Decompiler)
local SerializerXml = require(script.Parent.SerializerXml)
local SerializerBinary = require(script.Parent.SerializerBinary)
local SerializerScript = require(script.Parent.SerializerScript)

local Engine = {}
Engine.__index = Engine

-- Status types
export type SaveProgress = {
    Stage: string,              -- "Idle" | "Scanning" | "Preloading" | "Terrain" | "Decompiling" | "Serializing" | "Writing" | "Done" | "Error"
    Current: number,
    Total: number,
    Percentage: number,
    Message: string,
    SavedFile: string?,
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

-- Check if instance should be saved
function Engine:ShouldSaveInstance(inst: Instance): boolean
    local cName = inst.ClassName
    if ClassBlacklist.Classes[cName] then return false end
    if ClassBlacklist.Names[inst.Name] then return false end

    -- Check if it's our own UI
    if inst.Name == "HyperSaveInstance_UI" or inst.Name == "HyperSaveGUI" then return false end

    return true
end

-- Preload chunks around map if StreamingEnabled is active
function Engine:PreloadStreaming()
    if not workspace.StreamingEnabled or not self.Config.PreloadStreaming then
        return
    end

    self:EmitProgress({
        Stage = "Preloading",
        Current = 0,
        Total = 100,
        Percentage = 5,
        Message = "StreamingEnabled active: Preloading map chunks...",
    })

    local player = game:GetService("Players").LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = player.Character.HumanoidRootPart
        local originalPos = hrp.CFrame
        -- Wait small interval for stream in
        task.wait(0.5)
    end
end

-- Main Save Process
function Engine:Start(): (boolean, string)
    if self.IsRunning then
        return false, "Save is already in progress!"
    end

    self.IsRunning = true
    self.CancelRequested = false
    local startTime = os.clock()

    self:EmitProgress({
        Stage = "Scanning",
        Current = 0,
        Total = 100,
        Percentage = 0,
        Message = "Initializing HyperSaveInstance...",
    })

    -- Step 1: Preload Streaming if needed
    self:PreloadStreaming()

    -- Step 2: Collect Root Services to save
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

    -- Scan hierarchy & scripts
    self:EmitProgress({
        Stage = "Scanning",
        Current = 0,
        Total = #rootInstances,
        Percentage = 10,
        Message = "Scanning place hierarchy...",
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

    local totalInstances = #allInstances
    local totalScripts = #scriptInstances

    -- Step 3: Extract Terrain
    local terrainData = nil
    if self.Config.SaveTerrain then
        self:EmitProgress({
            Stage = "Terrain",
            Current = 0,
            Total = 1,
            Percentage = 25,
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
            Percentage = 35,
            Message = string.format("Decompiling %d scripts with parallel workers...", totalScripts),
        })

        scriptSources = Decompiler.DecompileBatch(scriptInstances, self.Config, function(cur, tot, sInst)
            local pct = 35 + math.floor((cur / tot) * 45)
            self:EmitProgress({
                Stage = "Decompiling",
                Current = cur,
                Total = tot,
                Percentage = pct,
                Message = string.format("Decompiling scripts: %d/%d (%s)", cur, tot, sInst.Name),
            })
        end)
    else
        -- Provide fallback headers/stubs for scripts
        for _, sInst in ipairs(scriptInstances) do
            scriptSources[sInst] = Decompiler.DecompileSingle(sInst, self.Config)
        end
    end

    -- Step 5: Serialize Output
    self:EmitProgress({
        Stage = "Serializing",
        Current = 0,
        Total = totalInstances,
        Percentage = 85,
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
        Percentage = 95,
        Message = "Saving file to disk...",
    })

    local targetFileName = self.Config.FilePath
    if not targetFileName or #targetFileName == 0 then
        targetFileName = self:GetDefaultFileName()
    end

    local writeSuccess = Environment.WriteFile(targetFileName, outputContent)
    local elapsed = os.clock() - startTime

    if writeSuccess then
        local successMsg = string.format("Done! Successfully saved %d instances & %d scripts in %.2fs to: %s",
            totalInstances, totalScripts, elapsed, targetFileName)

        self:EmitProgress({
            Stage = "Done",
            Current = totalInstances,
            Total = totalInstances,
            Percentage = 100,
            Message = successMsg,
            SavedFile = targetFileName,
        })

        if self.Config.CopyToClipboardOnComplete then
            Environment.SetClipboard(targetFileName)
        end

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
