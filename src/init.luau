--[[
    HyperSaveInstance v2.0 (Ultimate Master Suite) - Universal Roblox Game Cloner & Reverse-Engineering Suite
    Author: Theo Lorentz Padilha (https://github.com/theopadilha2009-hash)
    Combines USSI, UltraSmartSaveInstance, rbx-dom, rbx-instance-serializer & Studio Plugin.
]]

local Engine = require(script.Core.Engine)
local Interface = require(script.UI.Interface)
local Defaults = require(script.Config.Defaults)
local Environment = require(script.Utils.Environment)
local AntiAFK = require(script.Utils.AntiAFK)
local StreamExplorer = require(script.Core.StreamExplorer)
local NetworkSniffer = require(script.Core.NetworkSniffer)
local UniverseTracker = require(script.Core.UniverseTracker)
local ObjExporter = require(script.Core.ObjExporter)
local Optimizer = require(script.Core.Optimizer)
local AudioRipper = require(script.Core.AudioRipper)
local LightingRipper = require(script.Core.LightingRipper)
local GuiRipper = require(script.Core.GuiRipper)
local PlaceDiffTracker = require(script.Core.PlaceDiffTracker)
local Web3DExporter = require(script.Core.Web3DExporter)

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
function HyperSaveInstance.OpenUI(customConfig: table?)
    local engine = Engine.new(customConfig)
    local ui = Interface.new(engine)
    return ui, engine
end

-- Export Standalone Web 3D HTML Viewer (Three.js)
function HyperSaveInstance.ExportWeb3D(targetRoot: Instance?, options: table?): (boolean, string)
    return Web3DExporter.ExportModelToHTML(targetRoot, options)
end

-- Snapshot and Track Update Diff
function HyperSaveInstance.Snapshot(name: string?, root: Instance?): (boolean, string)
    return PlaceDiffTracker.SaveSnapshot(name, root)
end

function HyperSaveInstance.CompareDiff(snapshotFile: string): table
    return PlaceDiffTracker.Compare(snapshotFile)
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

-- Save specific model directly as .rbxm package
function HyperSaveInstance.SaveModelToRbxm(targetInstance: Instance, customConfig: table?): (boolean, string)
    local cfg = table.clone(customConfig or {})
    cfg.Format = "rbxm"
    local engine = Engine.new(cfg)
    return engine:SaveTarget(targetInstance, cfg)
end

-- Save multiple instances into a single .rbxm package
function HyperSaveInstance.SaveBatchToRbxm(targets: {Instance}, customConfig: table?): (boolean, string)
    local cfg = table.clone(customConfig or {})
    cfg.Format = "rbxm"
    local engine = Engine.new(cfg)
    return engine:SaveTargetBatch(targets, cfg)
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

function HyperSaveInstance.SaveSilent(customConfig: table?)
    local cfg = table.clone(customConfig or {})
    Defaults.ApplyPreset(cfg, "Ghost")
    cfg.SilentMode = true
    cfg.ShowUI = false
    cfg.VerboseLogs = false
    cfg.PlaySoundOnComplete = false
    return HyperSaveInstance.Save(cfg)
end

function HyperSaveInstance.SaveGhost(customConfig: table?)
    return HyperSaveInstance.SaveSilent(customConfig)
end

function HyperSaveInstance.SaveOnlyMap(customConfig: table?)
    local cfg = table.clone(customConfig or {})
    Defaults.ApplyPreset(cfg, "OnlyMap")
    return HyperSaveInstance.Save(cfg)
end

function HyperSaveInstance.SaveUIOnly(customConfig: table?)
    local cfg = table.clone(customConfig or {})
    Defaults.ApplyPreset(cfg, "UIOnly")
    return HyperSaveInstance.Save(cfg)
end

function HyperSaveInstance.SaveBeeSwarm(customConfig: table?)
    local cfg = table.clone(customConfig or {})
    Defaults.ApplyPreset(cfg, "BeeSwarm")
    return HyperSaveInstance.Save(cfg)
end

function HyperSaveInstance.SaveBloxFruits(customConfig: table?)
    local cfg = table.clone(customConfig or {})
    Defaults.ApplyPreset(cfg, "BloxFruits")
    return HyperSaveInstance.Save(cfg)
end

function HyperSaveInstance.SavePetSimulator(customConfig: table?)
    local cfg = table.clone(customConfig or {})
    Defaults.ApplyPreset(cfg, "PetSimulator99")
    return HyperSaveInstance.Save(cfg)
end

function HyperSaveInstance.SaveArsenal(customConfig: table?)
    local cfg = table.clone(customConfig or {})
    Defaults.ApplyPreset(cfg, "Arsenal")
    return HyperSaveInstance.Save(cfg)
end

function HyperSaveInstance.SaveDoors(customConfig: table?)
    local cfg = table.clone(customConfig or {})
    Defaults.ApplyPreset(cfg, "Doors")
    return HyperSaveInstance.Save(cfg)
end

function HyperSaveInstance.SaveTowerDefense(customConfig: table?)
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
local isSilent = Defaults.SilentMode or (getgenv and (getgenv().HyperSave_Silent or getgenv().SilentMode)) or (_G and (_G.HyperSave_Silent or _G.SilentMode))

-- Instant StarterGui Notification (Only in non-silent mode)
if not isSilent and Defaults.ShowUI then
    pcall(function()
        local clonerefFn = cloneref or function(obj) return obj end
        local sg = clonerefFn(game:GetService("StarterGui"))
        sg:SetCore("SendNotification", {
            Title = "HyperSaveInstance",
            Text = "Carregado por Theo Lorentz Padilha!",
            Duration = 4
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
