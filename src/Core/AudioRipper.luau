--[[
    HyperSaveInstance - Audio Ripper & In-Game Soundboard
    Scans, previews, plays and extracts all music tracks and sound effects in the game.
]]

local clonerefFn = cloneref or function(obj) return obj end
local SoundService = nil
pcall(function() SoundService = clonerefFn(game:GetService("SoundService")) end)
local Environment = require(script.Parent.Parent.Utils.Environment)

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

    for _, sName in ipairs({"Workspace", "SoundService", "ReplicatedStorage", "Lighting", "StarterGui", "StarterPack", "StarterPlayer", "Chat", "MaterialService"}) do
        local s, service = pcall(function() return clonerefFn(game:GetService(sName)) end)
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
