--[[
    HyperSaveInstance - Anti-AFK & Anti-Kick Protection System
    Prevents Roblox Error 268/273 (20-minute idle disconnection) during long save sessions.
]]

local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")

local AntiAFK = {}
local isEnabled = false
local idleConnection = nil

function AntiAFK.Enable()
    if isEnabled then return end
    isEnabled = true

    pcall(function()
        local localPlayer = Players.LocalPlayer
        if localPlayer and localPlayer.Idled then
            idleConnection = localPlayer.Idled:Connect(function()
                if not isEnabled then return end
                pcall(function()
                    local vu = game:GetService("VirtualUser")
                    vu:CaptureController()
                    vu:ClickButton2(Vector2.new(0, 0))
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

function AntiAFK.IsEnabled(): boolean
    return isEnabled
end

return AntiAFK
