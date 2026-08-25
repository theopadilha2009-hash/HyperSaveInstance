--[[
    HyperSaveInstance v2.0 - Universal Roblox Game Cloner & SaveInstance Engine
    Author: theopadilha2009-hash
    Combines USSI, UltraSmartSaveInstance, rbx-dom & rbx-instance-serializer.
]]

local Engine = require(script.Core.Engine)
local Interface = require(script.UI.Interface)
local Defaults = require(script.Config.Defaults)
local Environment = require(script.Utils.Environment)

local HyperSaveInstance = {
    Version = "2.0.0",
    Defaults = Defaults,
    Environment = Environment,
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

-- Auto-initialize if executed directly
if Defaults.ShowUI then
    task.spawn(function()
        HyperSaveInstance.OpenUI()
    end)
end

return HyperSaveInstance
