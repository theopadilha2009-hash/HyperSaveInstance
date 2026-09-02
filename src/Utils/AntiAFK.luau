--[[
    HyperSaveInstance - Anti-AFK & Anti-Kick Protection System
    Prevents Roblox Error 268/273 (20-minute idle disconnection) during long save sessions.
]]

local Players = nil
pcall(function() Players = game:GetService("Players") end)

local AntiAFK = {}
local isEnabled = false
local idleConnection = nil

function AntiAFK.Enable()
    if isEnabled then return end
    isEnabled = true

    pcall(function()
        local plrs = Players or game:GetService("Players")
        local localPlayer = plrs and plrs.LocalPlayer
        if localPlayer and localPlayer.Idled then
            idleConnection = localPlayer.Idled:Connect(function()
                if not isEnabled then return end
                -- 1. Try safe virtual user input without aggressive controller captures
                local triggered = false
                pcall(function()
                    local vu = (game.GetService and game:GetService("VirtualUser")) or (game.FindService and game:FindService("VirtualUser"))
                    if vu then
                        if vu.Button2Down and vu.Button2Up then
                            vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera and workspace.CurrentCamera.CFrame or CFrame.new())
                            task.wait(0.05)
                            vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera and workspace.CurrentCamera.CFrame or CFrame.new())
                            triggered = true
                        elseif vu.ClickButton2 then
                            vu:ClickButton2(Vector2.new(0, 0))
                            triggered = true
                        end
                    end
                end)

                -- 2. Fallback: Micro camera oscillation if VirtualUser is hooked/blocked
                if not triggered then
                    pcall(function()
                        local cam = workspace.CurrentCamera
                        if cam then
                            cam.CFrame = cam.CFrame * CFrame.Angles(0, 0.0001, 0)
                            task.wait(0.05)
                            cam.CFrame = cam.CFrame * CFrame.Angles(0, -0.0001, 0)
                        end
                    end)
                end
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
