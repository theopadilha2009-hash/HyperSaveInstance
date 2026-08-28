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
