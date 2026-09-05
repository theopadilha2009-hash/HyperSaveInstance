--[[
    HyperSaveInstance - Anti-AFK & Anti-Kick Protection System
    Prevents Roblox Error 268/273 (20-minute idle disconnection) during long save sessions.
]]

local clonerefFn = cloneref or function(obj)
    return obj
end
local Players = nil
pcall(function()
    Players = clonerefFn(game:GetService("Players"))
end)

local AntiAFK = {}
local isEnabled = false
local idleConnection = nil

function AntiAFK.Enable()
    if isEnabled then
        return
    end
    isEnabled = true

    pcall(function()
        local plrs = Players or game:GetService("Players")
        local localPlayer = plrs and (plrs.LocalPlayer or plrs:FindFirstChildOfClass("Player"))
        if localPlayer and localPlayer.Idled then
            idleConnection = localPlayer.Idled:Connect(function()
                if not isEnabled then
                    return
                end

                -- 1. Primary stealth method: Natural camera micro-oscillation
                local handled = false
                pcall(function()
                    local cam = workspace.CurrentCamera
                    if cam then
                        local jitter = (math.random() > 0.5 and 0.0001 or -0.0001)
                        cam.CFrame = cam.CFrame * CFrame.Angles(0, jitter, 0)
                        task.wait(0.04)
                        cam.CFrame = cam.CFrame * CFrame.Angles(0, -jitter, 0)
                        handled = true
                    end
                end)

                -- 2. Secondary fallback: VirtualInputManager micro-event
                if not handled then
                    pcall(function()
                        local vim = clonerefFn(game:GetService("VirtualInputManager"))
                        if vim and vim.SendMouseButtonEvent then
                            local rx = math.random(10, 50)
                            local ry = math.random(10, 50)
                            vim:SendMouseButtonEvent(rx, ry, 0, true, game, 0)
                            task.wait(0.03)
                            vim:SendMouseButtonEvent(rx, ry, 0, false, game, 0)
                            handled = true
                        end
                    end)
                end

                -- 3. Last resort fallback: VirtualUser
                if not handled then
                    pcall(function()
                        local vu = (game.GetService and game:GetService("VirtualUser"))
                            or (game.FindService and game:FindService("VirtualUser"))
                        if vu and vu.ClickButton2 then
                            vu:ClickButton2(Vector2.new(math.random(10, 50), math.random(10, 50)))
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
