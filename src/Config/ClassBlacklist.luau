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
