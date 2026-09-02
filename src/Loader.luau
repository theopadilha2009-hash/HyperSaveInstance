--[[
    HyperSaveInstance - Universal Smart Bootstrapper & Multi-CDN Resilient Loader
    Author: Theo Lorentz Padilha (https://github.com/theopadilha2009-hash)
    Auto-detects environment, provides instant visual feedback, and loads real-time raw bundle.
]]

local isSilent = false
pcall(function()
    local genv = (getgenv and getgenv()) or _G
    if genv then
        isSilent = (genv.HyperSave_Silent == true) or (genv.SilentMode == true) or (genv.HyperSave_Ghost == true)
    end
end)

local function createInstantBanner(text, isError)
    if isSilent then return end

    pcall(function()
        local rawParent = (gethui and gethui())
        if not rawParent then
            local plrs = game:GetService("Players")
            local lp = plrs.LocalPlayer or plrs:FindFirstChildOfClass("Player")
            rawParent = (lp and lp:FindFirstChildOfClass("PlayerGui")) or game:GetService("CoreGui")
        end
        if not rawParent then return end

        local container = nil
        if rawParent:IsA("LayerCollector") or rawParent:IsA("ScreenGui") then
            container = rawParent
        else
            local old = rawParent:FindFirstChild("HSI_BootBanner")
            if old then old:Destroy() end

            local sg = Instance.new("ScreenGui")
            sg.Name = "HSI_BootBanner"
            sg.DisplayOrder = 9999999
            sg.ResetOnSpawn = false
            sg.Enabled = true
            pcall(function()
                if syn and syn.protect_gui then
                    syn.protect_gui(sg)
                end
            end)
            sg.Parent = rawParent
            container = sg
        end

        local oldF = container:FindFirstChild("HSI_BannerFrame")
        if oldF then oldF:Destroy() end

        local f = Instance.new("Frame")
        f.Name = "HSI_BannerFrame"
        f.Size = UDim2.new(0, 340, 0, 48)
        f.Position = UDim2.new(0.5, -170, 0, 24)
        f.BackgroundColor3 = isError and Color3.fromRGB(40, 10, 20) or Color3.fromRGB(16, 12, 28)
        f.BorderSizePixel = 0
        f.Parent = container

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 10)
        c.Parent = f

        local s = Instance.new("UIStroke")
        s.Color = isError and Color3.fromRGB(244, 63, 94) or Color3.fromRGB(168, 85, 247)
        s.Thickness = 1.5
        s.Parent = f

        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, -20, 1, 0)
        l.Position = UDim2.new(0, 10, 0, 0)
        l.Text = text
        l.TextColor3 = Color3.fromRGB(255, 255, 255)
        l.Font = Enum.Font.GothamBold
        l.TextSize = 12
        l.BackgroundTransparency = 1
        l.Parent = f

        task.delay(isError and 6 or 3.5, function()
            pcall(function() f:Destroy() end)
        end)
    end)
end

createInstantBanner("⚡ [HyperSave] Baixando módulos seguros...", false)

local cacheBuster = tostring(os.time()) .. "_" .. tostring(math.random(100000, 999999))
local url = "https://raw.githubusercontent.com/theopadilha2009-hash/HyperSaveInstance/main/dist/HyperSaveInstance.luau?nocache=" .. cacheBuster

local s, result = pcall(function()
    return game:HttpGet(url, true)
end)

if not s or type(result) ~= "string" or #result < 10000 then
    createInstantBanner("❌ Falha de rede ao baixar HyperSave.", true)
    warn("[HyperSave] Falha ao baixar bundle: " .. tostring(result))
    return
end

createInstantBanner("💀 [HyperSave] Inicializando Suíte...", false)

local execSuccess, execFunc = pcall(function()
    return loadstring(result)
end)

if not execSuccess or type(execFunc) ~= "function" then
    createInstantBanner("❌ Erro de compilação Luau: " .. tostring(execFunc), true)
    warn("[HyperSave] Erro no loadstring: " .. tostring(execFunc))
    return
end

local runSuccess, hsi = pcall(execFunc)
if not runSuccess then
    createInstantBanner("❌ Erro na execução: " .. tostring(hsi), true)
    warn("[HyperSave] Erro na execução: " .. tostring(hsi))
    return
end

return hsi
