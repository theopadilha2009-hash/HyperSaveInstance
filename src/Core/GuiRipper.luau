--[[
    HyperSaveInstance - GUI & HUD Ripper
    Extracts all ScreenGuis, Menus, Inventories, Health Bars, and HUDs to a standalone UI Pack.
]]

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local Environment = require(script.Parent.Parent.Utils.Environment)
local SerializerXml = require(script.Parent.SerializerXml)
local Decompiler = require(script.Parent.Decompiler)

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
