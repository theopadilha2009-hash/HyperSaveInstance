--[[
    HyperSaveInstance - Lighting & Atmosphere Preset Ripper
    Extracts realistic Skyboxes, Atmospheres, ColorCorrections, SunRays, and Post-Processing to a standalone preset.
]]

local clonerefFn = cloneref or function(obj) return obj end
local Lighting = nil
pcall(function() Lighting = clonerefFn(game:GetService("Lighting")) end)
local Environment = require(script.Parent.Parent.Utils.Environment)
local SerializerXml = require(script.Parent.SerializerXml)

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
