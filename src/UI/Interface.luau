--[[
    HyperSaveInstance - Modern Glassmorphic HUD & Master In-Game Suite
    Includes 1-Click Clone, Audio Ripper, Lighting Ripper, GUI Ripper, Target Selector, Network Sniffer, Universe Tracker, 3D OBJ Exporter, Tutorial and Settings.
]]

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Theme = require(script.Parent.Theme)
local Environment = require(script.Parent.Parent.Utils.Environment)
local Defaults = require(script.Parent.Parent.Config.Defaults)
local AudioRipper = require(script.Parent.Parent.Core.AudioRipper)
local LightingRipper = require(script.Parent.Parent.Core.LightingRipper)
local GuiRipper = require(script.Parent.Parent.Core.GuiRipper)
local NetworkSniffer = require(script.Parent.Parent.Core.NetworkSniffer)
local UniverseTracker = require(script.Parent.Parent.Core.UniverseTracker)
local ObjExporter = require(script.Parent.Parent.Core.ObjExporter)
local RaycastSelector = require(script.Parent.Parent.Core.RaycastSelector)
local PlaceDiffTracker = require(script.Parent.Parent.Core.PlaceDiffTracker)
local Web3DExporter = require(script.Parent.Parent.Core.Web3DExporter)
local LicenseManager = require(script.Parent.Parent.Utils.LicenseManager)
local Stealth = require(script.Parent.Parent.Utils.Stealth)

-- Attempt auto-load of saved enterprise key
pcall(function()
    local fn = Environment.GetReadFileFunction()
    if fn then
        local content = fn("HyperSave_License.key")
        if content and #content > 0 then
            LicenseManager.ApplyKey(content)
        end
    end
end)

local Interface = {}
Interface.__index = Interface

function Interface.new(engine: any)
    local self = setmetatable({}, Interface)
    self.Engine = engine
    self.Config = engine.Config
    self.Logs = {}
    self.ActiveTab = "Dashboard"
    self.IsMinimized = false
    self.SavedFilePath = ""
    self.SavedAssetPath = ""
    self.Raycast = RaycastSelector.new()
    self.SelectedTargets = {}
    self.CurrentTargetInstance = nil

    self:BuildUI()
    self:BindEngineEvents()
    self:BindKeybinds()
    return self
end

function Interface:BindKeybinds()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == (self.Config.ToggleKeybind or Enum.KeyCode.RightShift) then
            if self.MainFrame then
                self.MainFrame.Visible = not self.MainFrame.Visible
                if self.FloatingToggle then
                    self.FloatingToggle.Visible = not self.MainFrame.Visible
                end
            end
        end
    end)
end

function Interface:BuildUI()
    local parent = Environment.GetSafeGuiParent()
    local safeContainer = nil

    local isRandom = self.Config.RandomizeGuiName
    local guiName = self.Config.GuiName or (isRandom and Stealth.GenerateRandomName(14) or "HyperSaveInstance_UI")
    local containerName = isRandom and Stealth.GenerateRandomName(12) or "HyperSave_Container"

    if parent and (parent:IsA("LayerCollector") or parent:IsA("ScreenGui")) then
        pcall(function()
            local old = parent:FindFirstChild(containerName)
            if old then old:Destroy() end
        end)
        local container = Instance.new("Frame")
        container.Name = containerName
        container.Size = UDim2.new(1, 0, 1, 0)
        container.BackgroundTransparency = 1
        container.Parent = parent
        safeContainer = container
    else
        pcall(function()
            local old = parent:FindFirstChild(guiName) or parent:FindFirstChild("HyperSaveInstance_UI")
            if old then old:Destroy() end
        end)

        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = guiName
        screenGui.ResetOnSpawn = false
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        screenGui.DisplayOrder = 999999
        screenGui.IgnoreGuiInset = true
        screenGui.Enabled = true
        self.ScreenGui = screenGui

        Stealth.ProtectGui(screenGui)

        local ok = pcall(function() screenGui.Parent = parent end)
        if not ok or not screenGui.Parent then
            pcall(function() screenGui.Parent = game:GetService("CoreGui") end)
            if not screenGui.Parent and not self.Config.StealthMode then
                pcall(function()
                    local plrs = game:GetService("Players")
                    local lp = plrs.LocalPlayer or plrs:FindFirstChildOfClass("Player")
                    screenGui.Parent = lp and lp:FindFirstChildOfClass("PlayerGui")
                end)
            end
        end
        safeContainer = screenGui
    end

    if self.Engine and self.Engine.Config then
        self.Engine.Config.IgnoredGui = safeContainer
    end

    -- Floating Mini Toggle Button
    local floatingBtn = Instance.new("TextButton")
    floatingBtn.Name = isRandom and Stealth.GenerateRandomName(8) or "FloatingToggle"
    floatingBtn.Text = isRandom and "[HSI]" or "HyperSaveInstance"
    floatingBtn.Font = Theme.FontSemiBold
    floatingBtn.TextSize = 11
    floatingBtn.TextColor3 = Theme.TextPrimary
    floatingBtn.BackgroundColor3 = Theme.AccentPrimary
    floatingBtn.Size = UDim2.new(0, 150, 0, 32)
    floatingBtn.Position = UDim2.new(0, 20, 0, 20)
    floatingBtn.Visible = false
    Theme.AddCorner(floatingBtn, Theme.CornerMedium)
    Theme.AddStroke(floatingBtn, Theme.BorderLight, 1)
    floatingBtn.Parent = safeContainer
    self.FloatingToggle = floatingBtn

    -- Make floating button draggable on touchscreen / mobile
    local fDragging, fDragStart, fStartPos
    floatingBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            fDragging = true
            fDragStart = input.Position
            fStartPos = floatingBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    fDragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and fDragging then
            local delta = input.Position - fDragStart
            floatingBtn.Position = UDim2.new(fStartPos.X.Scale, fStartPos.X.Offset + delta.X, fStartPos.Y.Scale, fStartPos.Y.Offset + delta.Y)
        end
    end)

    Theme.AnimateButton(floatingBtn, function()
        if self.MainFrame then self.MainFrame.Visible = true end
        floatingBtn.Visible = false
    end)
    
    local camera = workspace.CurrentCamera
    local vpSize = (camera and camera.ViewportSize) or Vector2.new(1280, 720)
    local winWidth = math.clamp(vpSize.X - 24, 320, 670)
    local winHeight = math.clamp(vpSize.Y - 32, 280, 480)

    -- Instant Splash Loading Card (Shows immediately when script is executed)
    local splash = Instance.new("Frame")
    splash.Name = "SplashCard"
    splash.AnchorPoint = Vector2.new(0.5, 0.5)
    splash.Size = UDim2.new(0, 340, 0, 140)
    splash.Position = UDim2.new(0.5, 0, 0.5, 0)
    splash.BackgroundColor3 = Theme.Background
    splash.BorderSizePixel = 0
    Theme.AddCorner(splash, Theme.CornerLarge)
    Theme.AddStroke(splash, Theme.Border, 1)
    splash.Parent = safeContainer

    local splashTitle = Instance.new("TextLabel")
    splashTitle.Text = "HyperSaveInstance"
    splashTitle.Font = Theme.FontTitle
    splashTitle.TextSize = 15
    splashTitle.TextColor3 = Theme.TextPrimary
    splashTitle.Size = UDim2.new(1, 0, 0, 26)
    splashTitle.Position = UDim2.new(0, 0, 0, 16)
    splashTitle.BackgroundTransparency = 1
    splashTitle.Parent = splash

    local splashBadge = Instance.new("TextLabel")
    splashBadge.Text = "Por Theo Lorentz Padilha"
    splashBadge.Font = Theme.FontRegular
    splashBadge.TextSize = 11
    splashBadge.TextColor3 = Theme.TextSecondary
    splashBadge.BackgroundColor3 = Theme.CardBg
    splashBadge.Size = UDim2.new(0, 220, 0, 22)
    splashBadge.Position = UDim2.new(0.5, -110, 0, 46)
    Theme.AddCorner(splashBadge, Theme.CornerSmall)
    Theme.AddStroke(splashBadge, Theme.Border, 1)
    splashBadge.Parent = splash

    local splashStatus = Instance.new("TextLabel")
    splashStatus.Text = "Carregando interface..."
    splashStatus.Font = Theme.FontRegular
    splashStatus.TextSize = 11
    splashStatus.TextColor3 = Theme.TextMuted
    splashStatus.Size = UDim2.new(1, 0, 0, 20)
    splashStatus.Position = UDim2.new(0, 0, 0, 76)
    splashStatus.BackgroundTransparency = 1
    splashStatus.Parent = splash

    local splashTrack = Instance.new("Frame")
    splashTrack.Size = UDim2.new(1, -48, 0, 4)
    splashTrack.Position = UDim2.new(0, 24, 0, 108)
    splashTrack.BackgroundColor3 = Theme.CardBg
    Theme.AddCorner(splashTrack, Theme.CornerPill)
    splashTrack.Parent = splash

    local splashFill = Instance.new("Frame")
    splashFill.Size = UDim2.new(0.2, 0, 1, 0)
    splashFill.BackgroundColor3 = Theme.AccentPrimary
    Theme.AddCorner(splashFill, Theme.CornerPill)
    splashFill.Parent = splashTrack
    self.SplashFill = splashFill
    self.SplashCard = splash

    -- Main Container (Clean, Solid, High-Contrast Modern Theme)
    local main = Instance.new("Frame")
    main.Name = "MainFrame"
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.Size = UDim2.new(0, winWidth, 0, winHeight)
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    main.BackgroundColor3 = Theme.Background
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Visible = true
    Theme.AddCorner(main, Theme.CornerLarge)
    Theme.AddStroke(main, Theme.Border, 1)
    main.Parent = safeContainer
    self.MainFrame = main

    -- Dragging logic
    local dragging, dragInput, dragStart, startPos
    main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    main.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Window Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 44)
    header.BackgroundColor3 = Theme.CardBg
    header.BorderSizePixel = 0
    header.Parent = main

    local headerLine = Instance.new("Frame")
    headerLine.Size = UDim2.new(1, 0, 0, 1)
    headerLine.Position = UDim2.new(0, 0, 1, -1)
    headerLine.BackgroundColor3 = Theme.Border
    headerLine.BorderSizePixel = 0
    headerLine.Parent = header

    local title = Instance.new("TextLabel")
    title.Text = "HyperSaveInstance"
    title.Font = Theme.FontTitle
    title.TextSize = 13
    title.TextColor3 = Theme.TextPrimary
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Size = UDim2.new(0, 160, 1, 0)
    title.Position = UDim2.new(0, 14, 0, 0)
    title.BackgroundTransparency = 1
    title.Parent = header

    -- Platform & License Badge
    local badge = Instance.new("TextButton")
    local isEnt = LicenseManager.IsEnterprise()
    badge.Text = isEnt and "Enterprise" or "Ativar Licença"
    badge.Font = Theme.FontSemiBold
    badge.TextSize = 10
    badge.TextColor3 = isEnt and Theme.AccentSuccess or Theme.TextSecondary
    badge.BackgroundColor3 = Theme.Background
    badge.Size = UDim2.new(0, 120, 0, 24)
    badge.Position = UDim2.new(0, 175, 0.5, -12)
    Theme.AddCorner(badge, Theme.CornerSmall)
    local bStroke = Theme.AddStroke(badge, isEnt and Theme.AccentSuccess or Theme.Border, 1)
    badge.Parent = header

    -- License Activation Modal Dialog
    local keyModal = Instance.new("Frame")
    keyModal.Size = UDim2.new(1, 0, 1, 0)
    keyModal.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    keyModal.BackgroundTransparency = 0.4
    keyModal.Visible = false
    keyModal.ZIndex = 50
    keyModal.Parent = main

    local keyCard = Instance.new("Frame")
    keyCard.Size = UDim2.new(0, 340, 0, 160)
    keyCard.Position = UDim2.new(0.5, -170, 0.5, -80)
    keyCard.BackgroundColor3 = Theme.Background
    keyCard.ZIndex = 51
    Theme.AddCorner(keyCard, Theme.CornerMedium)
    Theme.AddStroke(keyCard, Theme.Border, 1)
    keyCard.Parent = keyModal

    local kTitle = Instance.new("TextLabel")
    kTitle.Text = "Ativação de Licença"
    kTitle.Font = Theme.FontTitle
    kTitle.TextSize = 12
    kTitle.TextColor3 = Theme.TextPrimary
    kTitle.Size = UDim2.new(1, -24, 0, 22)
    kTitle.Position = UDim2.new(0, 12, 0, 12)
    kTitle.BackgroundTransparency = 1
    kTitle.ZIndex = 52
    kTitle.Parent = keyCard

    local kDesc = Instance.new("TextLabel")
    kDesc.Text = "Insira sua chave de licença:"
    kDesc.Font = Theme.FontRegular
    kDesc.TextSize = 10
    kDesc.TextColor3 = Theme.TextSecondary
    kDesc.Size = UDim2.new(1, -24, 0, 16)
    kDesc.Position = UDim2.new(0, 12, 0, 36)
    kDesc.BackgroundTransparency = 1
    kDesc.ZIndex = 52
    kDesc.Parent = keyCard

    local kInput = Instance.new("TextBox")
    kInput.PlaceholderText = "Cole sua chave aqui..."
    kInput.Font = Theme.FontRegular
    kInput.TextSize = 11
    kInput.TextColor3 = Theme.TextPrimary
    kInput.PlaceholderColor3 = Theme.TextMuted
    kInput.BackgroundColor3 = Theme.InputBg
    kInput.Size = UDim2.new(1, -24, 0, 30)
    kInput.Position = UDim2.new(0, 12, 0, 58)
    kInput.ZIndex = 52
    Theme.AddCorner(kInput, Theme.CornerSmall)
    Theme.AddStroke(kInput, Theme.Border, 1)
    kInput.Parent = keyCard

    local kStatus = Instance.new("TextLabel")
    kStatus.Text = ""
    kStatus.Font = Theme.FontSemiBold
    kStatus.TextSize = 10
    kStatus.Size = UDim2.new(1, -24, 0, 16)
    kStatus.Position = UDim2.new(0, 12, 0, 92)
    kStatus.BackgroundTransparency = 1
    kStatus.ZIndex = 52
    kStatus.Parent = keyCard

    local kSubmit = Instance.new("TextButton")
    kSubmit.Text = "Ativar Chave"
    kSubmit.Font = Theme.FontSemiBold
    kSubmit.TextSize = 10
    kSubmit.TextColor3 = Theme.TextPrimary
    kSubmit.BackgroundColor3 = Theme.AccentPrimary
    kSubmit.Size = UDim2.new(0.5, -16, 0, 28)
    kSubmit.Position = UDim2.new(0, 12, 0, 116)
    kSubmit.ZIndex = 52
    Theme.AddCorner(kSubmit, Theme.CornerSmall)
    kSubmit.Parent = keyCard

    local kClose = Instance.new("TextButton")
    kClose.Text = "Cancelar"
    kClose.Font = Theme.FontSemiBold
    kClose.TextSize = 10
    kClose.TextColor3 = Theme.TextSecondary
    kClose.BackgroundColor3 = Theme.CardBg
    kClose.Size = UDim2.new(0.5, -16, 0, 28)
    kClose.Position = UDim2.new(0.5, 4, 0, 116)
    kClose.ZIndex = 52
    Theme.AddCorner(kClose, Theme.CornerSmall)
    Theme.AddStroke(kClose, Theme.Border, 1)
    kClose.Parent = keyCard

    Theme.AnimateButton(badge, function()
        keyModal.Visible = true
        kStatus.Text = ""
    end)

    Theme.AnimateButton(kClose, function()
        keyModal.Visible = false
    end)

    Theme.AnimateButton(kSubmit, function()
        local success, msg = LicenseManager.ApplyKey(kInput.Text)
        if success then
            kStatus.Text = "✓ " .. msg
            kStatus.TextColor3 = Theme.AccentSuccess
            badge.Text = "Enterprise Ativo"
            badge.TextColor3 = Theme.AccentSuccess
            bStroke.Color = Theme.AccentSuccess
            
            pcall(function()
                Environment.WriteFile("HyperSave_License.key", kInput.Text)
            end)

            task.delay(1.5, function()
                keyModal.Visible = false
            end)
        else
            kStatus.Text = "✕ " .. msg
            kStatus.TextColor3 = Theme.AccentDanger
        end
    end)

    -- Compact Mode Button (Switches to minimal horizontal HUD bar)
    local compactBtn = Instance.new("TextButton")
    compactBtn.Text = "▫"
    compactBtn.Font = Theme.FontTitle
    compactBtn.TextSize = 14
    compactBtn.TextColor3 = Theme.TextSecondary
    compactBtn.BackgroundColor3 = Theme.CardBg
    compactBtn.Size = UDim2.new(0, 26, 0, 26)
    compactBtn.Position = UDim2.new(1, -94, 0.5, -13)
    Theme.AddCorner(compactBtn, Theme.CornerSmall)
    Theme.AddStroke(compactBtn, Theme.Border, 1)
    compactBtn.Parent = header

    -- Minimize Button
    local minBtn = Instance.new("TextButton")
    minBtn.Text = "–"
    minBtn.Font = Theme.FontTitle
    minBtn.TextSize = 14
    minBtn.TextColor3 = Theme.TextSecondary
    minBtn.BackgroundColor3 = Theme.CardBg
    minBtn.Size = UDim2.new(0, 26, 0, 26)
    minBtn.Position = UDim2.new(1, -64, 0.5, -13)
    Theme.AddCorner(minBtn, Theme.CornerSmall)
    Theme.AddStroke(minBtn, Theme.Border, 1)
    minBtn.Parent = header

    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "✕"
    closeBtn.Font = Theme.FontTitle
    closeBtn.TextSize = 14
    closeBtn.TextColor3 = Theme.TextSecondary
    closeBtn.BackgroundColor3 = Theme.CardBg
    closeBtn.Size = UDim2.new(0, 26, 0, 26)
    closeBtn.Position = UDim2.new(1, -34, 0.5, -13)
    Theme.AddCorner(closeBtn, Theme.CornerSmall)
    Theme.AddStroke(closeBtn, Theme.Border, 1)
    closeBtn.Parent = header

    -- Compact In-Game HUD Widget (Minimalist floating bar)
    local compactBar = Instance.new("Frame")
    compactBar.Name = isRandom and Stealth.GenerateRandomName(12) or "CompactHUD"
    compactBar.Size = UDim2.new(0, 380, 0, 34)
    compactBar.Position = UDim2.new(0.5, -190, 0, 14)
    compactBar.BackgroundColor3 = Theme.Background
    compactBar.Visible = false
    Theme.AddCorner(compactBar, Theme.CornerMedium)
    Theme.AddStroke(compactBar, Theme.Border, 1)
    compactBar.Parent = safeContainer
    self.CompactHUD = compactBar

    local cStats = Instance.new("TextLabel")
    cStats.Text = "FPS: 60 • Ping: --ms"
    cStats.Font = Theme.FontRegular
    cStats.TextSize = 11
    cStats.TextColor3 = Theme.TextSecondary
    cStats.Size = UDim2.new(0, 160, 1, 0)
    cStats.Position = UDim2.new(0, 12, 0, 0)
    cStats.BackgroundTransparency = 1
    cStats.Parent = compactBar

    local cCloneBtn = Instance.new("TextButton")
    cCloneBtn.Text = "Salvar Mapa"
    cCloneBtn.Font = Theme.FontSemiBold
    cCloneBtn.TextSize = 10
    cCloneBtn.TextColor3 = Theme.TextPrimary
    cCloneBtn.BackgroundColor3 = Theme.AccentPrimary
    cCloneBtn.Size = UDim2.new(0, 110, 0, 22)
    cCloneBtn.Position = UDim2.new(0, 175, 0.5, -11)
    Theme.AddCorner(cCloneBtn, Theme.CornerSmall)
    cCloneBtn.Parent = compactBar
    Theme.AnimateButton(cCloneBtn, function() self:StartClone() end)

    local cExpandBtn = Instance.new("TextButton")
    cExpandBtn.Text = "Expandir ↗"
    cExpandBtn.Font = Theme.FontSemiBold
    cExpandBtn.TextSize = 10
    cExpandBtn.TextColor3 = Theme.TextSecondary
    cExpandBtn.BackgroundColor3 = Theme.CardBg
    cExpandBtn.Size = UDim2.new(0, 74, 0, 22)
    cExpandBtn.Position = UDim2.new(1, -82, 0.5, -11)
    Theme.AddCorner(cExpandBtn, Theme.CornerSmall)
    Theme.AddStroke(cExpandBtn, Theme.Border, 1)
    cExpandBtn.Parent = compactBar
    Theme.AnimateButton(cExpandBtn, function()
        compactBar.Visible = false
        main.Visible = true
    end)

    -- Live FPS & Ping monitor loop
    task.spawn(function()
        local Stats = game:GetService("Stats")
        local fpsCount = 0
        local lastUpdate = os.clock()
        local runServ = game:GetService("RunService")
        runServ.RenderStepped:Connect(function()
            fpsCount = fpsCount + 1
            local now = os.clock()
            if now - lastUpdate >= 0.5 then
                local fps = math.round(fpsCount / (now - lastUpdate))
                fpsCount = 0
                lastUpdate = now
                local ping = 0
                pcall(function() ping = math.round(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
                if compactBar and compactBar.Visible then
                    cStats.Text = string.format("FPS: %d • Ping: %dms", fps, ping)
                end
            end
        end)
    end)

    Theme.AnimateButton(compactBtn, function()
        main.Visible = false
        compactBar.Visible = true
    end)

    Theme.AnimateButton(minBtn, function()
        main.Visible = false
        floatingBtn.Visible = true
    end)

    Theme.AnimateButton(closeBtn, function()
        main.Visible = false
        floatingBtn.Visible = true
    end)

    -- Tab Navigation Bar (Scrollable for all master tools)
    local navBar = Instance.new("ScrollingFrame")
    navBar.Name = "NavBar"
    navBar.Size = UDim2.new(0, 140, 1, -44)
    navBar.Position = UDim2.new(0, 0, 0, 44)
    navBar.BackgroundColor3 = Theme.CardBg
    navBar.ScrollBarThickness = 2
    navBar.ScrollBarImageColor3 = Theme.Border
    navBar.CanvasSize = UDim2.new(0, 0, 0, 390)
    navBar.BorderSizePixel = 0
    navBar.Parent = main

    local navLine = Instance.new("Frame")
    navLine.Size = UDim2.new(0, 1, 1, 0)
    navLine.Position = UDim2.new(1, -1, 0, 0)
    navLine.BackgroundColor3 = Theme.Border
    navLine.BorderSizePixel = 0
    navLine.Parent = navBar

    -- Content Area
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -140, 1, -44)
    contentArea.Position = UDim2.new(0, 140, 0, 44)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = main
    self.ContentArea = contentArea

    -- Navigation buttons (Clean, Plain Text, Zero Emojis)
    local tabs = {
        {"Dashboard", "Dashboard"},
        {"Selector", "Objetos"},
        {"AudioRipper", "Áudios"},
        {"LightingRipper", "Iluminação"},
        {"GuiRipper", "Interfaces"},
        {"Network", "Rede"},
        {"Universe", "Universos"},
        {"ObjExport", "Exportar 3D"},
        {"Tutorial", "Como Usar"},
        {"Settings", "Configurações"},
        {"Console", "Console"},
        {"About", "Sobre"}
    }

    self.TabFrames = {}
    self.NavButtons = {}

    for i, tabInfo in ipairs(tabs) do
        local tabKey, tabLabel = tabInfo[1], tabInfo[2]

        local navBtn = Instance.new("TextButton")
        navBtn.Text = tabLabel
        navBtn.Font = Theme.FontSemiBold
        navBtn.TextSize = 11
        navBtn.TextColor3 = (i == 1) and Theme.TextPrimary or Theme.TextSecondary
        navBtn.BackgroundColor3 = (i == 1) and Theme.AccentPrimary or Theme.CardBg
        navBtn.BackgroundTransparency = (i == 1) and 0 or 1
        navBtn.Size = UDim2.new(1, -12, 0, 28)
        navBtn.Position = UDim2.new(0, 6, 0, 6 + (i - 1) * 31)
        Theme.AddCorner(navBtn, Theme.CornerSmall)
        Theme.AddStroke(navBtn, (i == 1) and Theme.BorderLight or Theme.Border, 1)
        navBtn.Parent = navBar
        self.NavButtons[tabKey] = navBtn

        local tabFrame = Instance.new("Frame")
        tabFrame.Name = tabKey .. "Tab"
        tabFrame.Size = UDim2.new(1, 0, 1, 0)
        tabFrame.BackgroundTransparency = 1
        tabFrame.Visible = (i == 1)
        tabFrame.Parent = contentArea
        self.TabFrames[tabKey] = tabFrame

        Theme.AnimateButton(navBtn, function()
            self:SwitchTab(tabKey)
        end)
    end

    -- Build Individual Tab Pages with error boundary protection
    pcall(function() self:BuildDashboardTab() end)
    pcall(function() self:BuildSelectorTab() end)
    pcall(function() self:BuildAudioRipperTab() end)
    pcall(function() self:BuildLightingRipperTab() end)
    pcall(function() self:BuildGuiRipperTab() end)
    pcall(function() self:BuildNetworkTab() end)
    pcall(function() self:BuildUniverseTab() end)
    pcall(function() self:BuildObjExportTab() end)
    pcall(function() self:BuildTutorialTab() end)
    pcall(function() self:BuildSettingsTab() end)
    pcall(function() self:BuildConsoleTab() end)
    pcall(function() self:BuildAboutTab() end)

    -- Animate Splash Card completion and reveal Main Window
    pcall(function()
        if self.SplashFill then
            Theme.Tween(self.SplashFill, 0.3, { Size = UDim2.new(1, 0, 1, 0) })
        end
        task.delay(0.35, function()
            if self.SplashCard then
                Theme.Tween(self.SplashCard, 0.15, {
                    Size = UDim2.new(0, 300, 0, 120),
                    BackgroundTransparency = 1
                })
                for _, child in ipairs(self.SplashCard:GetDescendants()) do
                    if child:IsA("TextLabel") then
                        Theme.Tween(child, 0.12, { TextTransparency = 1 })
                    elseif child:IsA("Frame") or child:IsA("UIStroke") then
                        Theme.Tween(child, 0.12, { Transparency = 1 })
                    end
                end
                task.delay(0.18, function()
                    pcall(function() self.SplashCard:Destroy() end)
                end)
            end

            if self.MainFrame then
                self.MainFrame.Visible = true
                Theme.Tween(self.MainFrame, 0.25, {
                    Size = UDim2.new(0, winWidth, 0, winHeight)
                }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            end
        end)
    end)
end

function Interface:SwitchTab(targetTab: string)
    self.ActiveTab = targetTab
    for k, frame in pairs(self.TabFrames) do
        frame.Visible = (k == targetTab)
    end
    for k, btn in pairs(self.NavButtons) do
        local stroke = btn:FindFirstChildOfClass("UIStroke")
        if k == targetTab then
            btn.TextColor3 = Theme.TextPrimary
            btn.BackgroundColor3 = Theme.AccentPrimary
            btn.BackgroundTransparency = 0
            if stroke then stroke.Color = Theme.BorderLight end
        else
            btn.TextColor3 = Theme.TextSecondary
            btn.BackgroundColor3 = Theme.CardBg
            btn.BackgroundTransparency = 1
            if stroke then stroke.Color = Theme.Border end
        end
    end
end

-- 1. Dashboard Tab (Clean, Prominent 1-Click Game Cloner)
function Interface:BuildDashboardTab()
    local parent = self.TabFrames["Dashboard"]

    -- Big Action Clone Button
    local cloneBtn = Instance.new("TextButton")
    cloneBtn.Name = "CloneButton"
    cloneBtn.Text = "Salvar Mapa Completo (.rbxlx)"
    cloneBtn.Font = Theme.FontTitle
    cloneBtn.TextSize = 13
    cloneBtn.TextColor3 = Theme.TextPrimary
    cloneBtn.BackgroundColor3 = Theme.AccentPrimary
    cloneBtn.Size = UDim2.new(1, -32, 0, 42)
    cloneBtn.Position = UDim2.new(0, 16, 0, 14)
    Theme.AddCorner(cloneBtn, Theme.CornerMedium)
    Theme.AddStroke(cloneBtn, Theme.BorderLight, 1)
    cloneBtn.Parent = parent
    self.CloneButton = cloneBtn

    Theme.AnimateButton(cloneBtn, function()
        self:StartClone()
    end)

    -- Preset Selection Container
    local presetLabel = Instance.new("TextLabel")
    presetLabel.Text = "MODO DE EXTRAÇÃO:"
    presetLabel.Font = Theme.FontSemiBold
    presetLabel.TextSize = 10
    presetLabel.TextColor3 = Theme.TextSecondary
    presetLabel.TextXAlignment = Enum.TextXAlignment.Left
    presetLabel.Size = UDim2.new(1, -32, 0, 16)
    presetLabel.Position = UDim2.new(0, 16, 0, 66)
    presetLabel.BackgroundTransparency = 1
    presetLabel.Parent = parent

    local presetContainer = Instance.new("Frame")
    presetContainer.Size = UDim2.new(1, -32, 0, 30)
    presetContainer.Position = UDim2.new(0, 16, 0, 86)
    presetContainer.BackgroundTransparency = 1
    presetContainer.Parent = parent

    local presetLayout = Instance.new("UIListLayout")
    presetLayout.FillDirection = Enum.FillDirection.Horizontal
    presetLayout.Padding = UDim.new(0, 6)
    presetLayout.SortOrder = Enum.SortOrder.LayoutOrder
    presetLayout.Parent = presetContainer

    local presetList = {"Full", "Fast", "VisualsOnly", "ScriptsOnly"}
    local presetDisplay = {
        Full = "Completo",
        Fast = "Rápido",
        VisualsOnly = "Apenas Mapa",
        ScriptsOnly = "Apenas Scripts"
    }

    self.PresetButtons = {}
    for i, pKey in ipairs(presetList) do
        local btn = Instance.new("TextButton")
        btn.Text = presetDisplay[pKey]
        btn.Font = Theme.FontSemiBold
        btn.TextSize = 10
        btn.TextColor3 = (self.Config.Mode == pKey) and Theme.TextPrimary or Theme.TextSecondary
        btn.BackgroundColor3 = (self.Config.Mode == pKey) and Theme.CardActive or Theme.CardBg
        btn.Size = UDim2.new(0.25, -5, 1, 0)
        btn.LayoutOrder = i
        Theme.AddCorner(btn, Theme.CornerSmall)
        Theme.AddStroke(btn, (self.Config.Mode == pKey) and Theme.BorderLight or Theme.Border, 1)
        btn.Parent = presetContainer
        self.PresetButtons[pKey] = btn

        Theme.AnimateButton(btn, function()
            Defaults.ApplyPreset(self.Config, pKey)
            for k, b in pairs(self.PresetButtons) do
                local stroke = b:FindFirstChildOfClass("UIStroke")
                if k == pKey then
                    b.TextColor3 = Theme.TextPrimary
                    b.BackgroundColor3 = Theme.CardActive
                    if stroke then stroke.Color = Theme.BorderLight end
                else
                    b.TextColor3 = Theme.TextSecondary
                    b.BackgroundColor3 = Theme.CardBg
                    if stroke then stroke.Color = Theme.Border end
                end
            end
            self:Log("Modo selecionado: " .. pKey)
        end)
    end

    -- Format Selector Container
    local formatLabel = Instance.new("TextLabel")
    formatLabel.Text = "FORMATO DO ARQUIVO:"
    formatLabel.Font = Theme.FontSemiBold
    formatLabel.TextSize = 10
    formatLabel.TextColor3 = Theme.TextSecondary
    formatLabel.TextXAlignment = Enum.TextXAlignment.Left
    formatLabel.Size = UDim2.new(1, -32, 0, 16)
    formatLabel.Position = UDim2.new(0, 16, 0, 126)
    formatLabel.BackgroundTransparency = 1
    formatLabel.Parent = parent

    local formatContainer = Instance.new("Frame")
    formatContainer.Size = UDim2.new(1, -32, 0, 30)
    formatContainer.Position = UDim2.new(0, 16, 0, 146)
    formatContainer.BackgroundTransparency = 1
    formatContainer.Parent = parent

    local formatLayout = Instance.new("UIListLayout")
    formatLayout.FillDirection = Enum.FillDirection.Horizontal
    formatLayout.Padding = UDim.new(0, 6)
    formatLayout.SortOrder = Enum.SortOrder.LayoutOrder
    formatLayout.Parent = formatContainer

    local formats = {
        {"rbxlx", "RBXLX (XML)"},
        {"rbxl", "RBXL (Binário)"},
        {"lua", "Script Luau"}
    }
    self.FormatButtons = {}

    for i, fmt in ipairs(formats) do
        local fKey, fLabel = fmt[1], fmt[2]
        local fBtn = Instance.new("TextButton")
        fBtn.Text = fLabel
        fBtn.Font = Theme.FontSemiBold
        fBtn.TextSize = 10
        fBtn.TextColor3 = (self.Config.Format == fKey) and Theme.TextPrimary or Theme.TextSecondary
        fBtn.BackgroundColor3 = (self.Config.Format == fKey) and Theme.CardActive or Theme.CardBg
        fBtn.Size = UDim2.new(0.333, -5, 1, 0)
        fBtn.LayoutOrder = i
        Theme.AddCorner(fBtn, Theme.CornerSmall)
        Theme.AddStroke(fBtn, (self.Config.Format == fKey) and Theme.BorderLight or Theme.Border, 1)
        fBtn.Parent = formatContainer
        self.FormatButtons[fKey] = fBtn

        Theme.AnimateButton(fBtn, function()
            self.Config.Format = fKey
            for k, b in pairs(self.FormatButtons) do
                local stroke = b:FindFirstChildOfClass("UIStroke")
                if k == fKey then
                    b.TextColor3 = Theme.TextPrimary
                    b.BackgroundColor3 = Theme.CardActive
                    if stroke then stroke.Color = Theme.BorderLight end
                else
                    b.TextColor3 = Theme.TextSecondary
                    b.BackgroundColor3 = Theme.CardBg
                    if stroke then stroke.Color = Theme.Border end
                end
            end
            self:Log("Formato definido: ." .. fKey)
        end)
    end

    -- Progress Container (Clean Card)
    local progressCard = Instance.new("Frame")
    progressCard.Size = UDim2.new(1, -32, 0, 114)
    progressCard.Position = UDim2.new(0, 16, 0, 186)
    progressCard.BackgroundColor3 = Theme.CardBg
    Theme.AddCorner(progressCard, Theme.CornerMedium)
    Theme.AddStroke(progressCard, Theme.Border, 1)
    progressCard.Parent = parent

    local statusHeader = Instance.new("TextLabel")
    statusHeader.Name = "StatusHeader"
    statusHeader.Text = "Status: Pronto para salvar"
    statusHeader.Font = Theme.FontSemiBold
    statusHeader.TextSize = 12
    statusHeader.TextColor3 = Theme.AccentSuccess
    statusHeader.TextXAlignment = Enum.TextXAlignment.Left
    statusHeader.Size = UDim2.new(0.7, 0, 0, 20)
    statusHeader.Position = UDim2.new(0, 12, 0, 10)
    statusHeader.BackgroundTransparency = 1
    statusHeader.Parent = progressCard
    self.StatusHeader = statusHeader

    local pctLabel = Instance.new("TextLabel")
    pctLabel.Name = "PctLabel"
    pctLabel.Text = "0%"
    pctLabel.Font = Theme.FontTitle
    pctLabel.TextSize = 13
    pctLabel.TextColor3 = Theme.TextPrimary
    pctLabel.TextXAlignment = Enum.TextXAlignment.Right
    pctLabel.Size = UDim2.new(0.25, 0, 0, 20)
    pctLabel.Position = UDim2.new(0.72, 0, 0, 10)
    pctLabel.BackgroundTransparency = 1
    pctLabel.Parent = progressCard
    self.PctLabel = pctLabel

    -- Progress Bar Track & Fill
    local barTrack = Instance.new("Frame")
    barTrack.Size = UDim2.new(1, -24, 0, 6)
    barTrack.Position = UDim2.new(0, 12, 0, 36)
    barTrack.BackgroundColor3 = Theme.Background
    Theme.AddCorner(barTrack, Theme.CornerPill)
    barTrack.Parent = progressCard

    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(0, 0, 1, 0)
    barFill.BackgroundColor3 = Theme.AccentPrimary
    Theme.AddCorner(barFill, Theme.CornerPill)
    barFill.Parent = barTrack
    self.ProgressBarFill = barFill

    local statusDetail = Instance.new("TextLabel")
    statusDetail.Name = "StatusDetail"
    statusDetail.Text = "Clique no botão acima para salvar o jogo."
    statusDetail.Font = Theme.FontRegular
    statusDetail.TextSize = 11
    statusDetail.TextColor3 = Theme.TextMuted
    statusDetail.TextXAlignment = Enum.TextXAlignment.Left
    statusDetail.Size = UDim2.new(1, -24, 0, 18)
    statusDetail.Position = UDim2.new(0, 12, 0, 48)
    statusDetail.BackgroundTransparency = 1
    statusDetail.Parent = progressCard
    self.StatusDetail = statusDetail

    -- Quick Action Copy Buttons
    local copyBar = Instance.new("Frame")
    copyBar.Size = UDim2.new(1, -24, 0, 26)
    copyBar.Position = UDim2.new(0, 12, 0, 76)
    copyBar.BackgroundTransparency = 1
    copyBar.Parent = progressCard

    local copyLayout = Instance.new("UIListLayout")
    copyLayout.FillDirection = Enum.FillDirection.Horizontal
    copyLayout.Padding = UDim.new(0, 6)
    copyLayout.SortOrder = Enum.SortOrder.LayoutOrder
    copyLayout.Parent = copyBar

    local copyFilePathBtn = Instance.new("TextButton")
    copyFilePathBtn.Text = "Copiar Caminho do Arquivo"
    copyFilePathBtn.Font = Theme.FontSemiBold
    copyFilePathBtn.TextSize = 10
    copyFilePathBtn.TextColor3 = Theme.TextPrimary
    copyFilePathBtn.BackgroundColor3 = Theme.CardHover
    copyFilePathBtn.Size = UDim2.new(0.5, -3, 1, 0)
    copyFilePathBtn.LayoutOrder = 1
    Theme.AddCorner(copyFilePathBtn, Theme.CornerSmall)
    Theme.AddStroke(copyFilePathBtn, Theme.Border, 1)
    copyFilePathBtn.Parent = copyBar

    Theme.AnimateButton(copyFilePathBtn, function()
        local name = self.SavedFilePath
        if #name == 0 then name = self.Engine:GetDefaultFileName() end
        Environment.SetClipboard(name)
        copyFilePathBtn.Text = "✓ Copiado!"
        task.delay(2, function() copyFilePathBtn.Text = "Copiar Caminho do Arquivo" end)
    end)

    local copyAssetsPathBtn = Instance.new("TextButton")
    copyAssetsPathBtn.Text = "Copiar Pasta de Assets"
    copyAssetsPathBtn.Font = Theme.FontSemiBold
    copyAssetsPathBtn.TextSize = 10
    copyAssetsPathBtn.TextColor3 = Theme.TextPrimary
    copyAssetsPathBtn.BackgroundColor3 = Theme.CardHover
    copyAssetsPathBtn.Size = UDim2.new(0.5, -3, 1, 0)
    copyAssetsPathBtn.LayoutOrder = 2
    Theme.AddCorner(copyAssetsPathBtn, Theme.CornerSmall)
    Theme.AddStroke(copyAssetsPathBtn, Theme.Border, 1)
    copyAssetsPathBtn.Parent = copyBar

    Theme.AnimateButton(copyAssetsPathBtn, function()
        local name = self.SavedAssetPath
        if #name == 0 then name = self.Engine:GetDefaultAssetFolder() end
        Environment.SetClipboard(name)
        copyAssetsPathBtn.Text = "✓ Copiado!"
        task.delay(2, function() copyAssetsPathBtn.Text = "Copiar Pasta de Assets" end)
    end)

    -- Live Telemetry Stats Row
    local telemetryCard = Instance.new("Frame")
    telemetryCard.Size = UDim2.new(1, -32, 0, 46)
    telemetryCard.Position = UDim2.new(0, 16, 0, 310)
    telemetryCard.BackgroundColor3 = Theme.CardBg
    Theme.AddCorner(telemetryCard, Theme.CornerMedium)
    Theme.AddStroke(telemetryCard, Theme.Border, 1)
    telemetryCard.Parent = parent

    local tLayout = Instance.new("UIListLayout")
    tLayout.FillDirection = Enum.FillDirection.Horizontal
    tLayout.Padding = UDim.new(0, 0)
    tLayout.Parent = telemetryCard

    local function createTelemetryItem(label: string, defaultVal: string, widthRatio: number)
        local itemFrame = Instance.new("Frame")
        itemFrame.Size = UDim2.new(widthRatio, 0, 1, 0)
        itemFrame.BackgroundTransparency = 1
        itemFrame.Parent = telemetryCard

        local valLbl = Instance.new("TextLabel")
        valLbl.Text = defaultVal
        valLbl.Font = Theme.FontTitle
        valLbl.TextSize = 12
        valLbl.TextColor3 = Theme.TextPrimary
        valLbl.Size = UDim2.new(1, 0, 0, 18)
        valLbl.Position = UDim2.new(0, 0, 0, 6)
        valLbl.BackgroundTransparency = 1
        valLbl.Parent = itemFrame

        local tagLbl = Instance.new("TextLabel")
        tagLbl.Text = label
        tagLbl.Font = Theme.FontRegular
        tagLbl.TextSize = 9
        tagLbl.TextColor3 = Theme.TextSecondary
        tagLbl.Size = UDim2.new(1, 0, 0, 14)
        tagLbl.Position = UDim2.new(0, 0, 0, 24)
        tagLbl.BackgroundTransparency = 1
        tagLbl.Parent = itemFrame

        return valLbl
    end

    local fpsValLbl = createTelemetryItem("FPS DO JOGO", "60", 0.333)
    local pingValLbl = createTelemetryItem("PING DE REDE", "-- ms", 0.333)
    local ramValLbl = createTelemetryItem("MEMÓRIA CLIENT", "-- MB", 0.334)

    task.spawn(function()
        local Stats = game:GetService("Stats")
        local fpsCount = 0
        local lastUpdate = os.clock()
        local runServ = game:GetService("RunService")
        runServ.RenderStepped:Connect(function()
            fpsCount = fpsCount + 1
            local now = os.clock()
            if now - lastUpdate >= 0.5 then
                local fps = math.round(fpsCount / (now - lastUpdate))
                fpsCount = 0
                lastUpdate = now
                local ping = 0
                pcall(function() ping = math.round(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
                local mem = 0
                pcall(function() mem = math.round(Stats:GetTotalMemoryUsageMb()) end)

                if fpsValLbl and fpsValLbl.Parent then
                    fpsValLbl.Text = tostring(fps)
                    fpsValLbl.TextColor3 = (fps >= 45) and Theme.AccentSuccess or Theme.AccentWarning
                end
                if pingValLbl and pingValLbl.Parent then
                    pingValLbl.Text = tostring(ping) .. " ms"
                    pingValLbl.TextColor3 = (ping < 120) and Theme.AccentSuccess or Theme.AccentWarning
                end
                if ramValLbl and ramValLbl.Parent then
                    ramValLbl.Text = tostring(mem) .. " MB"
                end
            end
        end)
    end)
end

-- 2. Target Selector Tab (Save Individual Model / Folder / 3D Raycast / Multi-Select)
function Interface:BuildSelectorTab()
    local parent = self.TabFrames["Selector"]

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -32, 1, -32)
    scroll.Position = UDim2.new(0, 16, 0, 16)
    scroll.BackgroundColor3 = Theme.CardBg
    scroll.BackgroundTransparency = Theme.CardTransparency
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Theme.BorderLight
    scroll.CanvasSize = UDim2.new(0, 0, 0, 520)
    Theme.AddCorner(scroll, Theme.CornerLarge)
    Theme.AddStroke(scroll, Theme.Border, 1)
    scroll.Parent = parent

    local headerLbl = Instance.new("TextLabel")
    headerLbl.Text = "Seletor de Objetos 3D"
    headerLbl.Font = Theme.FontTitle
    headerLbl.TextSize = 13
    headerLbl.TextColor3 = Theme.TextPrimary
    headerLbl.TextXAlignment = Enum.TextXAlignment.Left
    headerLbl.Size = UDim2.new(1, -24, 0, 22)
    headerLbl.Position = UDim2.new(0, 12, 0, 12)
    headerLbl.BackgroundTransparency = 1
    headerLbl.Parent = scroll

    -- 1. In-World 3D Raycast Click Selector Button
    local raycastBtn = Instance.new("TextButton")
    raycastBtn.Text = "Ativar Mira 3D no Mapa"
    raycastBtn.Font = Theme.FontSemiBold
    raycastBtn.TextSize = 11
    raycastBtn.TextColor3 = Theme.TextPrimary
    raycastBtn.BackgroundColor3 = Theme.AccentPrimary
    raycastBtn.Size = UDim2.new(1, -24, 0, 34)
    raycastBtn.Position = UDim2.new(0, 12, 0, 40)
    Theme.AddCorner(raycastBtn, Theme.CornerMedium)
    Theme.AddStroke(raycastBtn, Theme.BorderLight, 1)
    raycastBtn.Parent = scroll

    -- 2. Search by Name Textbox
    local searchBox = Instance.new("TextBox")
    searchBox.PlaceholderText = "Ou digite o nome do objeto (ex: Carro, Arma, Map)..."
    searchBox.Font = Theme.FontRegular
    searchBox.TextSize = 11
    searchBox.TextColor3 = Theme.TextPrimary
    searchBox.PlaceholderColor3 = Theme.TextMuted
    searchBox.BackgroundColor3 = Theme.InputBg
    searchBox.Size = UDim2.new(1, -24, 0, 32)
    searchBox.Position = UDim2.new(0, 12, 0, 82)
    Theme.AddCorner(searchBox, Theme.CornerSmall)
    Theme.AddStroke(searchBox, Theme.Border, 1)
    searchBox.Parent = scroll

    -- 3. Selected Target Info Card
    local infoCard = Instance.new("Frame")
    infoCard.Size = UDim2.new(1, -24, 0, 100)
    infoCard.Position = UDim2.new(0, 12, 0, 122)
    infoCard.BackgroundColor3 = Theme.CardBg
    Theme.AddCorner(infoCard, Theme.CornerMedium)
    Theme.AddStroke(infoCard, Theme.Border, 1)
    infoCard.Parent = scroll

    -- Embedded 3D ViewportFrame
    local vpFrame = Instance.new("ViewportFrame")
    vpFrame.Size = UDim2.new(0, 84, 0, 84)
    vpFrame.Position = UDim2.new(1, -92, 0, 8)
    vpFrame.BackgroundColor3 = Theme.Background
    Theme.AddCorner(vpFrame, Theme.CornerSmall)
    Theme.AddStroke(vpFrame, Theme.Border, 1)
    vpFrame.Parent = infoCard

    local vpCam = Instance.new("Camera")
    vpCam.Parent = vpFrame
    vpFrame.CurrentCamera = vpCam

    local targetTitle = Instance.new("TextLabel")
    targetTitle.Text = "Nenhum objeto selecionado"
    targetTitle.Font = Theme.FontSemiBold
    targetTitle.TextSize = 11
    targetTitle.TextColor3 = Theme.TextPrimary
    targetTitle.TextXAlignment = Enum.TextXAlignment.Left
    targetTitle.Size = UDim2.new(1, -106, 0, 18)
    targetTitle.Position = UDim2.new(0, 10, 0, 8)
    targetTitle.BackgroundTransparency = 1
    targetTitle.Parent = infoCard

    local targetStats = Instance.new("TextLabel")
    targetStats.Text = "Mire no jogo com o botão acima ou digite o nome."
    targetStats.Font = Theme.FontRegular
    targetStats.TextSize = 10
    targetStats.TextColor3 = Theme.TextSecondary
    targetStats.TextXAlignment = Enum.TextXAlignment.Left
    targetStats.Size = UDim2.new(1, -106, 0, 18)
    targetStats.Position = UDim2.new(0, 10, 0, 28)
    targetStats.BackgroundTransparency = 1
    targetStats.Parent = infoCard

    local targetPath = Instance.new("TextLabel")
    targetPath.Text = "Caminho: -"
    targetPath.Font = Theme.FontRegular
    targetPath.TextSize = 10
    targetPath.TextColor3 = Theme.TextMuted
    targetPath.TextXAlignment = Enum.TextXAlignment.Left
    targetPath.Size = UDim2.new(1, -106, 0, 18)
    targetPath.Position = UDim2.new(0, 10, 0, 48)
    targetPath.BackgroundTransparency = 1
    targetPath.Parent = infoCard

    local targetDims = Instance.new("TextLabel")
    targetDims.Text = "Dimensões: -"
    targetDims.Font = Theme.FontRegular
    targetDims.TextSize = 10
    targetDims.TextColor3 = Theme.TextSecondary
    targetDims.TextXAlignment = Enum.TextXAlignment.Left
    targetDims.Size = UDim2.new(1, -106, 0, 18)
    targetDims.Position = UDim2.new(0, 10, 0, 68)
    targetDims.BackgroundTransparency = 1
    targetDims.Parent = infoCard

    -- Helper to update info display & ViewportFrame
    local function inspectInstance(inst: Instance?)
        self.CurrentTargetInstance = inst
        
        -- Clear previous 3D viewport clones
        pcall(function()
            for _, c in ipairs(vpFrame:GetChildren()) do
                if c:IsA("Instance") and not c:IsA("Camera") then c:Destroy() end
            end
        end)

        if not inst then
            targetTitle.Text = "Nenhum objeto selecionado"
            targetTitle.TextColor3 = Theme.TextMuted
            targetStats.Text = "Use o botão 3D ou digite o nome acima."
            targetPath.Text = "Caminho: -"
            targetDims.Text = "Dimensões: -"
            return
        end

        local parts = 0
        local scripts = 0
        local meshes = 0

        for _, desc in ipairs(inst:GetDescendants()) do
            if desc:IsA("BasePart") then parts = parts + 1 end
            if desc:IsA("MeshPart") or desc:IsA("SpecialMesh") then meshes = meshes + 1 end
            if desc:IsA("LuaSourceContainer") then scripts = scripts + 1 end
        end
        if inst:IsA("BasePart") then parts = parts + 1 end
        if inst:IsA("LuaSourceContainer") then scripts = scripts + 1 end

        targetTitle.Text = string.format("Alvo: %s (%s)", inst.Name, inst.ClassName)
        targetTitle.TextColor3 = Theme.TextPrimary
        targetStats.Text = string.format("%d Peças • %d Malhas • %d Scripts", parts, meshes, scripts)
        targetStats.TextColor3 = Theme.AccentSuccess
        targetPath.Text = "Caminho: " .. inst:GetFullName()

        -- In-game visual neon bounding highlight
        pcall(function()
            if self.CurrentHighlight then
                self.CurrentHighlight:Destroy()
                self.CurrentHighlight = nil
            end
            if inst:IsA("Model") or inst:IsA("BasePart") then
                local h = Instance.new("Highlight")
                h.Name = Stealth.GenerateRandomName(16)
                h.FillColor = Theme.AccentPrimary
                h.FillTransparency = 0.65
                h.OutlineColor = Theme.BorderLight
                h.OutlineTransparency = 0.1
                h.Adornee = inst
                h.Parent = safeContainer
                self.CurrentHighlight = h
            end
        end)

        -- Populate ViewportFrame with 3D model clone
        pcall(function()
            if inst:IsA("Model") or inst:IsA("BasePart") then
                local clone = inst:Clone()
                if clone then
                    clone.Parent = vpFrame
                    local cf = CFrame.new()
                    local sz = Vector3.new(4, 4, 4)

                    if clone:IsA("Model") then
                        cf = clone:GetBoundingBox()
                        sz = clone:GetExtentsSize()
                    elseif clone:IsA("BasePart") then
                        cf = clone.CFrame
                        sz = clone.Size
                    end

                    targetDims.Text = string.format("Tamanho: %.1f x %.1f x %.1f studs", sz.X, sz.Y, sz.Z)

                    local maxDim = math.max(sz.X, sz.Y, sz.Z)
                    local camDist = math.clamp(maxDim * 1.5, 4, 250)

                    if self.VpRotationConn then
                        self.VpRotationConn:Disconnect()
                        self.VpRotationConn = nil
                    end

                    local runServ = game:GetService("RunService")
                    self.VpRotationConn = runServ.RenderStepped:Connect(function()
                        if not vpFrame or not vpFrame.Parent or not self.CurrentTargetInstance then
                            if self.VpRotationConn then self.VpRotationConn:Disconnect() end
                            return
                        end
                        local angle = os.clock() * 0.9
                        local eyePos = cf.Position + Vector3.new(math.cos(angle) * camDist, camDist * 0.45, math.sin(angle) * camDist)
                        vpCam.CFrame = CFrame.new(eyePos, cf.Position)
                    end)
                end
            else
                targetDims.Text = "Tipo: " .. inst.ClassName
            end
        end)
    end

    -- 4. Action Buttons Container
    local actionBtnContainer = Instance.new("Frame")
    actionBtnContainer.Size = UDim2.new(1, -24, 0, 32)
    actionBtnContainer.Position = UDim2.new(0, 12, 0, 230)
    actionBtnContainer.BackgroundTransparency = 1
    actionBtnContainer.Parent = scroll

    local actionLayout = Instance.new("UIListLayout")
    actionLayout.FillDirection = Enum.FillDirection.Horizontal
    actionLayout.Padding = UDim.new(0, 6)
    actionLayout.SortOrder = Enum.SortOrder.LayoutOrder
    actionLayout.Parent = actionBtnContainer

    local btnSaveSingle = Instance.new("TextButton")
    btnSaveSingle.Text = "Salvar Modelo (.rbxm)"
    btnSaveSingle.Font = Theme.FontSemiBold
    btnSaveSingle.TextSize = 10
    btnSaveSingle.TextColor3 = Theme.TextPrimary
    btnSaveSingle.BackgroundColor3 = Theme.AccentPrimary
    btnSaveSingle.Size = UDim2.new(0.35, -4, 1, 0)
    btnSaveSingle.LayoutOrder = 1
    Theme.AddCorner(btnSaveSingle, Theme.CornerSmall)
    Theme.AddStroke(btnSaveSingle, Theme.BorderLight, 1)
    btnSaveSingle.Parent = actionBtnContainer

    local btnExportWeb3D = Instance.new("TextButton")
    btnExportWeb3D.Text = "Visualizar 3D (Web)"
    btnExportWeb3D.Font = Theme.FontSemiBold
    btnExportWeb3D.TextSize = 10
    btnExportWeb3D.TextColor3 = Theme.TextPrimary
    btnExportWeb3D.BackgroundColor3 = Theme.CardHover
    btnExportWeb3D.Size = UDim2.new(0.35, -4, 1, 0)
    btnExportWeb3D.LayoutOrder = 2
    Theme.AddCorner(btnExportWeb3D, Theme.CornerSmall)
    Theme.AddStroke(btnExportWeb3D, Theme.Border, 1)
    btnExportWeb3D.Parent = actionBtnContainer

    local btnAddToPack = Instance.new("TextButton")
    btnAddToPack.Text = "Adicionar ao Pacote"
    btnAddToPack.Font = Theme.FontSemiBold
    btnAddToPack.TextSize = 10
    btnAddToPack.TextColor3 = Theme.TextPrimary
    btnAddToPack.BackgroundColor3 = Theme.CardActive
    btnAddToPack.Size = UDim2.new(0.3, -4, 1, 0)
    btnAddToPack.LayoutOrder = 3
    Theme.AddCorner(btnAddToPack, Theme.CornerSmall)
    Theme.AddStroke(btnAddToPack, Theme.Border, 1)
    btnAddToPack.Parent = actionBtnContainer

    -- 5. Multi-Select Package Card
    local packCard = Instance.new("Frame")
    packCard.Size = UDim2.new(1, -24, 0, 96)
    packCard.Position = UDim2.new(0, 12, 0, 270)
    packCard.BackgroundColor3 = Theme.CardBg
    Theme.AddCorner(packCard, Theme.CornerMedium)
    Theme.AddStroke(packCard, Theme.Border, 1)
    packCard.Parent = scroll

    local packTitle = Instance.new("TextLabel")
    packTitle.Text = "Pacote de Objetos: 0 itens"
    packTitle.Font = Theme.FontSemiBold
    packTitle.TextSize = 11
    packTitle.TextColor3 = Theme.TextPrimary
    packTitle.TextXAlignment = Enum.TextXAlignment.Left
    packTitle.Size = UDim2.new(0.7, 0, 0, 20)
    packTitle.Position = UDim2.new(0, 10, 0, 10)
    packTitle.BackgroundTransparency = 1
    packTitle.Parent = packCard

    local btnClearPack = Instance.new("TextButton")
    btnClearPack.Text = "Limpar"
    btnClearPack.Font = Theme.FontSemiBold
    btnClearPack.TextSize = 10
    btnClearPack.TextColor3 = Theme.AccentDanger
    btnClearPack.BackgroundColor3 = Theme.Background
    btnClearPack.Size = UDim2.new(0.24, 0, 0, 22)
    btnClearPack.Position = UDim2.new(0.73, 0, 0, 9)
    Theme.AddCorner(btnClearPack, Theme.CornerSmall)
    Theme.AddStroke(btnClearPack, Theme.AccentDanger, 1, 0.5)
    btnClearPack.Parent = packCard

    local btnSavePack = Instance.new("TextButton")
    btnSavePack.Text = "Exportar Pacote Selecionado (.rbxm)"
    btnSavePack.Font = Theme.FontSemiBold
    btnSavePack.TextSize = 10
    btnSavePack.TextColor3 = Theme.TextPrimary
    btnSavePack.BackgroundColor3 = Theme.AccentSecondary
    btnSavePack.Size = UDim2.new(1, -20, 0, 32)
    btnSavePack.Position = UDim2.new(0, 10, 0, 50)
    Theme.AddCorner(btnSavePack, Theme.CornerSmall)
    Theme.AddStroke(btnSavePack, Theme.BorderLight, 1)
    btnSavePack.Parent = packCard

    -- 6. Result & Status Label
    local resultLabel = Instance.new("TextLabel")
    resultLabel.Text = "Status: Pronto para selecionar."
    resultLabel.Font = Theme.FontRegular
    resultLabel.TextSize = 11
    resultLabel.TextColor3 = Theme.TextMuted
    resultLabel.TextXAlignment = Enum.TextXAlignment.Left
    resultLabel.Size = UDim2.new(1, -24, 0, 30)
    resultLabel.Position = UDim2.new(0, 12, 0, 376)
    resultLabel.TextWrapped = true
    resultLabel.BackgroundTransparency = 1
    resultLabel.Parent = scroll

    -- Update pack counter UI
    local function updatePackUI()
        packTitle.Text = string.format("Pacote de Objetos: %d itens", #self.SelectedTargets)
    end

    -- Event: 3D Raycast click button
    Theme.AnimateButton(raycastBtn, function()
        if self.MainFrame then self.MainFrame.Visible = false end
        resultLabel.Text = "Mira 3D ativa. Clique em qualquer objeto no jogo para selecionar."
        resultLabel.TextColor3 = Theme.TextPrimary

        self.Raycast:Start(function(selected)
            if self.MainFrame then self.MainFrame.Visible = true end
            if selected then
                searchBox.Text = selected.Name
                inspectInstance(selected)
                resultLabel.Text = "Objeto selecionado: " .. selected.Name
                resultLabel.TextColor3 = Theme.AccentSuccess
            end
        end)
    end)

    -- Event: Search box text change
    searchBox.FocusLost:Connect(function(enterPressed)
        local text = searchBox.Text
        if #text > 0 then
            local found = workspace:FindFirstChild(text, true) or game:GetService("ReplicatedStorage"):FindFirstChild(text, true)
            if found then
                inspectInstance(found)
                resultLabel.Text = "Encontrado: " .. found.Name
                resultLabel.TextColor3 = Theme.AccentSuccess
            else
                inspectInstance(nil)
                resultLabel.Text = "Objeto não encontrado na hierarquia."
                resultLabel.TextColor3 = Theme.AccentDanger
            end
        end
    end)

    -- Event: Save single model
    Theme.AnimateButton(btnSaveSingle, function()
        local target = self.CurrentTargetInstance
        if not target then
            resultLabel.Text = "Selecione um objeto primeiro."
            resultLabel.TextColor3 = Theme.AccentWarning
            return
        end

        resultLabel.Text = "Salvando " .. target.Name .. " com scripts..."
        resultLabel.TextColor3 = Theme.TextPrimary

        task.spawn(function()
            local success, msg = self.Engine:SaveTarget(target)
            if success then
                resultLabel.Text = "Modelo salvo com sucesso: " .. msg
                resultLabel.TextColor3 = Theme.AccentSuccess
                Environment.SetClipboard(msg)
            else
                resultLabel.Text = "Falha ao salvar: " .. tostring(msg)
                resultLabel.TextColor3 = Theme.AccentDanger
            end
        end)
    end)

    -- Event: Export 3D Web HTML
    Theme.AnimateButton(btnExportWeb3D, function()
        local target = self.CurrentTargetInstance
        if not target then
            resultLabel.Text = "Selecione um objeto antes de exportar."
            resultLabel.TextColor3 = Theme.AccentWarning
            return
        end

        resultLabel.Text = "Gerando visualizador 3D Web (.html)..."
        resultLabel.TextColor3 = Theme.TextPrimary

        task.spawn(function()
            local success, msg = Web3DExporter.ExportModelToHTML(target)
            if success then
                resultLabel.Text = "Visualizador Web salvo: " .. msg
                resultLabel.TextColor3 = Theme.AccentSuccess
                Environment.SetClipboard(msg)
            else
                resultLabel.Text = "Falha ao exportar Web 3D: " .. tostring(msg)
                resultLabel.TextColor3 = Theme.AccentDanger
            end
        end)
    end)

    -- Event: Add to pack
    Theme.AnimateButton(btnAddToPack, function()
        local target = self.CurrentTargetInstance
        if not target then
            resultLabel.Text = "Selecione um objeto para adicionar ao pacote."
            resultLabel.TextColor3 = Theme.AccentWarning
            return
        end

        table.insert(self.SelectedTargets, target)
        updatePackUI()
        resultLabel.Text = string.format("Adicionado ao pacote: %s (%d itens)", target.Name, #self.SelectedTargets)
        resultLabel.TextColor3 = Theme.AccentSuccess
    end)

    -- Event: Clear pack
    Theme.AnimateButton(btnClearPack, function()
        self.SelectedTargets = {}
        updatePackUI()
        resultLabel.Text = "Pacote limpo."
        resultLabel.TextColor3 = Theme.TextMuted
    end)

    -- Event: Save full multi-pack
    Theme.AnimateButton(btnSavePack, function()
        if #self.SelectedTargets == 0 then
            resultLabel.Text = "O pacote está vazio."
            resultLabel.TextColor3 = Theme.AccentWarning
            return
        end

        resultLabel.Text = string.format("Salvando pacote com %d itens...", #self.SelectedTargets)
        resultLabel.TextColor3 = Theme.TextPrimary

        task.spawn(function()
            local folder = Instance.new("Folder")
            folder.Name = "HyperSave_SelectedPack"
            for _, t in ipairs(self.SelectedTargets) do
                pcall(function()
                    local c = t:Clone()
                    if c then c.Parent = folder end
                end)
            end

            local success, msg = self.Engine:SaveTarget(folder)
            if success then
                resultLabel.Text = "Pacote salvo com sucesso: " .. msg
                resultLabel.TextColor3 = Theme.AccentSuccess
                Environment.SetClipboard(msg)
            else
                resultLabel.Text = "Falha ao salvar pacote: " .. tostring(msg)
                resultLabel.TextColor3 = Theme.AccentDanger
            end
            pcall(function() folder:Destroy() end)
        end)
    end)
end

function Interface:BuildAudioRipperTab()
    local parent = self.TabFrames["AudioRipper"]

    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, -32, 0, 32)
    topBar.Position = UDim2.new(0, 16, 0, 10)
    topBar.BackgroundTransparency = 1
    topBar.Parent = parent

    local topLayout = Instance.new("UIListLayout")
    topLayout.FillDirection = Enum.FillDirection.Horizontal
    topLayout.Padding = UDim.new(0, 6)
    topLayout.SortOrder = Enum.SortOrder.LayoutOrder
    topLayout.Parent = topBar

    local scanAudioBtn = Instance.new("TextButton")
    scanAudioBtn.Text = "Buscar Sons"
    scanAudioBtn.Font = Theme.FontSemiBold
    scanAudioBtn.TextSize = 10
    scanAudioBtn.TextColor3 = Theme.TextPrimary
    scanAudioBtn.BackgroundColor3 = Theme.AccentPrimary
    scanAudioBtn.Size = UDim2.new(0.38, -4, 1, 0)
    scanAudioBtn.LayoutOrder = 1
    Theme.AddCorner(scanAudioBtn, Theme.CornerSmall)
    Theme.AddStroke(scanAudioBtn, Theme.BorderLight, 1)
    scanAudioBtn.Parent = topBar

    local exportAudioListBtn = Instance.new("TextButton")
    exportAudioListBtn.Text = "Exportar Lista (.txt)"
    exportAudioListBtn.Font = Theme.FontSemiBold
    exportAudioListBtn.TextSize = 10
    exportAudioListBtn.TextColor3 = Theme.TextPrimary
    exportAudioListBtn.BackgroundColor3 = Theme.CardBg
    exportAudioListBtn.Size = UDim2.new(0.38, -4, 1, 0)
    exportAudioListBtn.LayoutOrder = 2
    Theme.AddCorner(exportAudioListBtn, Theme.CornerSmall)
    Theme.AddStroke(exportAudioListBtn, Theme.Border, 1)
    exportAudioListBtn.Parent = topBar

    local stopAudioBtn = Instance.new("TextButton")
    stopAudioBtn.Text = "Parar Áudio"
    stopAudioBtn.Font = Theme.FontSemiBold
    stopAudioBtn.TextSize = 10
    stopAudioBtn.TextColor3 = Theme.AccentDanger
    stopAudioBtn.BackgroundColor3 = Theme.Background
    stopAudioBtn.Size = UDim2.new(0.24, -4, 1, 0)
    stopAudioBtn.LayoutOrder = 3
    Theme.AddCorner(stopAudioBtn, Theme.CornerSmall)
    Theme.AddStroke(stopAudioBtn, Theme.AccentDanger, 1, 0.5)
    stopAudioBtn.Parent = topBar

    -- Audio Search Filter
    local searchBox = Instance.new("TextBox")
    searchBox.PlaceholderText = "Filtrar sons por nome ou ID..."
    searchBox.Font = Theme.FontRegular
    searchBox.TextSize = 11
    searchBox.TextColor3 = Theme.TextPrimary
    searchBox.PlaceholderColor3 = Theme.TextMuted
    searchBox.BackgroundColor3 = Theme.InputBg
    searchBox.Size = UDim2.new(1, -32, 0, 30)
    searchBox.Position = UDim2.new(0, 16, 0, 48)
    Theme.AddCorner(searchBox, Theme.CornerSmall)
    Theme.AddStroke(searchBox, Theme.Border, 1)
    searchBox.Parent = parent

    local audioScroll = Instance.new("ScrollingFrame")
    audioScroll.Size = UDim2.new(1, -32, 1, -88)
    audioScroll.Position = UDim2.new(0, 16, 0, 84)
    audioScroll.BackgroundColor3 = Theme.CardBg
    audioScroll.ScrollBarThickness = 3
    audioScroll.ScrollBarImageColor3 = Theme.Border
    Theme.AddCorner(audioScroll, Theme.CornerMedium)
    Theme.AddStroke(audioScroll, Theme.Border, 1)
    audioScroll.Parent = parent

    local audioLayout = Instance.new("UIListLayout")
    audioLayout.SortOrder = Enum.SortOrder.LayoutOrder
    audioLayout.Padding = UDim.new(0, 4)
    audioLayout.Parent = audioScroll

    local allSoundRows = {}

    local function filterSounds(query: string)
        local q = string.lower(query or "")
        local visibleCount = 0
        for _, item in ipairs(allSoundRows) do
            local match = (q == "") or string.find(string.lower(item.Data.Name), q, 1, true) or string.find(string.lower(item.Data.CleanId), q, 1, true)
            item.Row.Visible = match
            if match then visibleCount = visibleCount + 1 end
        end
        audioScroll.CanvasSize = UDim2.new(0, 0, 0, visibleCount * 36)
    end

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        filterSounds(searchBox.Text)
    end)

    Theme.AnimateButton(scanAudioBtn, function()
        scanAudioBtn.Text = "Buscando..."
        allSoundRows = {}
        for _, child in ipairs(audioScroll:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end

        task.spawn(function()
            local list = AudioRipper.ScanSounds()
            scanAudioBtn.Text = string.format("%d sons encontrados", #list)

            for _, snd in ipairs(list) do
                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, -12, 0, 30)
                row.BackgroundColor3 = Theme.Background
                Theme.AddCorner(row, Theme.CornerSmall)
                Theme.AddStroke(row, Theme.Border, 1)
                row.Parent = audioScroll

                local sndLbl = Instance.new("TextLabel")
                sndLbl.Text = string.format("%s (ID: %s)", snd.Name, snd.CleanId)
                sndLbl.Font = Theme.FontRegular
                sndLbl.TextSize = 10
                sndLbl.TextColor3 = Theme.TextPrimary
                sndLbl.TextXAlignment = Enum.TextXAlignment.Left
                sndLbl.Size = UDim2.new(0.62, 0, 1, 0)
                sndLbl.Position = UDim2.new(0, 8, 0, 0)
                sndLbl.BackgroundTransparency = 1
                sndLbl.Parent = row

                local playBtn = Instance.new("TextButton")
                playBtn.Text = "Tocar"
                playBtn.Font = Theme.FontSemiBold
                playBtn.TextSize = 10
                playBtn.TextColor3 = Theme.TextPrimary
                playBtn.BackgroundColor3 = Theme.AccentPrimary
                playBtn.Size = UDim2.new(0, 48, 0, 20)
                playBtn.Position = UDim2.new(1, -114, 0.5, -10)
                Theme.AddCorner(playBtn, Theme.CornerSmall)
                playBtn.Parent = row

                Theme.AnimateButton(playBtn, function()
                    AudioRipper.PlayPreview(snd.SoundId)
                end)

                local copyBtn = Instance.new("TextButton")
                copyBtn.Text = "Copiar ID"
                copyBtn.Font = Theme.FontSemiBold
                copyBtn.TextSize = 9
                copyBtn.TextColor3 = Theme.TextSecondary
                copyBtn.BackgroundColor3 = Theme.CardHover
                copyBtn.Size = UDim2.new(0, 56, 0, 20)
                copyBtn.Position = UDim2.new(1, -60, 0.5, -10)
                Theme.AddCorner(copyBtn, Theme.CornerSmall)
                Theme.AddStroke(copyBtn, Theme.Border, 1)
                copyBtn.Parent = row

                Theme.AnimateButton(copyBtn, function()
                    Environment.SetClipboard(snd.CleanId)
                    copyBtn.Text = "✓"
                    task.delay(1.5, function() copyBtn.Text = "Copiar ID" end)
                end)

                table.insert(allSoundRows, { Row = row, Data = snd })
            end

            audioScroll.CanvasSize = UDim2.new(0, 0, 0, #list * 36)
        end)
    end)

    Theme.AnimateButton(stopAudioBtn, function()
        pcall(function()
            for _, s in ipairs(game:GetService("SoundService"):GetChildren()) do
                if s:IsA("Sound") and string.find(s.Name, "Preview") then
                    s:Stop()
                    s:Destroy()
                end
            end
        end)
        stopAudioBtn.Text = "Parado"
        task.delay(1, function() stopAudioBtn.Text = "Parar Áudio" end)
    end)

    Theme.AnimateButton(exportAudioListBtn, function()
        local file = AudioRipper.ExportSoundList()
        exportAudioListBtn.Text = "✓ Exportado!"
        Environment.SetClipboard(file)
        task.delay(2, function()
            exportAudioListBtn.Text = "Exportar Lista (.txt)"
        end)
    end)
end

-- 4. Lighting & Atmosphere Ripper Tab
function Interface:BuildLightingRipperTab()
    local parent = self.TabFrames["LightingRipper"]

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -32, 1, -32)
    card.Position = UDim2.new(0, 16, 0, 16)
    card.BackgroundColor3 = Theme.CardBg
    Theme.AddCorner(card, Theme.CornerLarge)
    Theme.AddStroke(card, Theme.Border, 1)
    card.Parent = parent

    local headerLbl = Instance.new("TextLabel")
    headerLbl.Text = "Iluminação e Atmosfera"
    headerLbl.Font = Theme.FontTitle
    headerLbl.TextSize = 13
    headerLbl.TextColor3 = Theme.TextPrimary
    headerLbl.TextXAlignment = Enum.TextXAlignment.Left
    headerLbl.Size = UDim2.new(1, -24, 0, 22)
    headerLbl.Position = UDim2.new(0, 16, 0, 16)
    headerLbl.BackgroundTransparency = 1
    headerLbl.Parent = card

    local desc = Instance.new("TextLabel")
    desc.Text = "Extrai as propriedades visuais de iluminação, Skybox, Atmosphere (densidade, névoa e cores), SunRays, Bloom, Blur e ColorCorrection para um arquivo .rbxmx editável no Studio."
    desc.Font = Theme.FontRegular
    desc.TextSize = 11
    desc.TextColor3 = Theme.TextSecondary
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextYAlignment = Enum.TextYAlignment.Top
    desc.TextWrapped = true
    desc.Size = UDim2.new(1, -32, 0, 50)
    desc.Position = UDim2.new(0, 16, 0, 44)
    desc.BackgroundTransparency = 1
    desc.Parent = card

    local exportLightBtn = Instance.new("TextButton")
    exportLightBtn.Text = "Exportar Preset de Iluminação (.rbxmx)"
    exportLightBtn.Font = Theme.FontSemiBold
    exportLightBtn.TextSize = 11
    exportLightBtn.TextColor3 = Theme.TextPrimary
    exportLightBtn.BackgroundColor3 = Theme.AccentPrimary
    exportLightBtn.Size = UDim2.new(1, -32, 0, 38)
    exportLightBtn.Position = UDim2.new(0, 16, 0, 104)
    Theme.AddCorner(exportLightBtn, Theme.CornerMedium)
    Theme.AddStroke(exportLightBtn, Theme.BorderLight, 1)
    exportLightBtn.Parent = card

    local lightStatus = Instance.new("TextLabel")
    lightStatus.Text = "Status: Pronto para exportar iluminação."
    lightStatus.Font = Theme.FontRegular
    lightStatus.TextSize = 11
    lightStatus.TextColor3 = Theme.TextMuted
    lightStatus.TextXAlignment = Enum.TextXAlignment.Left
    lightStatus.Size = UDim2.new(1, -32, 0, 24)
    lightStatus.Position = UDim2.new(0, 16, 0, 154)
    lightStatus.BackgroundTransparency = 1
    lightStatus.Parent = card

    Theme.AnimateButton(exportLightBtn, function()
        lightStatus.Text = "Extraindo atmosfera e skyboxes..."
        lightStatus.TextColor3 = Theme.TextPrimary

        task.spawn(function()
            local success, file = LightingRipper.ExportLightingPreset()
            if success then
                lightStatus.Text = "Preset de iluminação salvo: " .. file
                lightStatus.TextColor3 = Theme.AccentSuccess
                Environment.SetClipboard(file)
            else
                lightStatus.Text = "Erro: " .. tostring(file)
                lightStatus.TextColor3 = Theme.AccentDanger
            end
        end)
    end)
end

-- 5. GUI & HUD Ripper Tab
function Interface:BuildGuiRipperTab()
    local parent = self.TabFrames["GuiRipper"]

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -32, 1, -32)
    card.Position = UDim2.new(0, 16, 0, 16)
    card.BackgroundColor3 = Theme.CardBg
    Theme.AddCorner(card, Theme.CornerLarge)
    Theme.AddStroke(card, Theme.Border, 1)
    card.Parent = parent

    local headerLbl = Instance.new("TextLabel")
    headerLbl.Text = "Interfaces e Menus (GUI)"
    headerLbl.Font = Theme.FontTitle
    headerLbl.TextSize = 13
    headerLbl.TextColor3 = Theme.TextPrimary
    headerLbl.TextXAlignment = Enum.TextXAlignment.Left
    headerLbl.Size = UDim2.new(1, -24, 0, 22)
    headerLbl.Position = UDim2.new(0, 16, 0, 16)
    headerLbl.BackgroundTransparency = 1
    headerLbl.Parent = card

    local desc = Instance.new("TextLabel")
    desc.Text = "Extrai todas as interfaces ativas (ScreenGuis, menus, lojas, inventários e HUDs) com seus respectivos scripts para um arquivo .rbxmx independente."
    desc.Font = Theme.FontRegular
    desc.TextSize = 11
    desc.TextColor3 = Theme.TextSecondary
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextYAlignment = Enum.TextYAlignment.Top
    desc.TextWrapped = true
    desc.Size = UDim2.new(1, -32, 0, 50)
    desc.Position = UDim2.new(0, 16, 0, 44)
    desc.BackgroundTransparency = 1
    desc.Parent = card

    local exportGuiBtn = Instance.new("TextButton")
    exportGuiBtn.Text = "Exportar Todas as Interfaces (.rbxmx)"
    exportGuiBtn.Font = Theme.FontSemiBold
    exportGuiBtn.TextSize = 11
    exportGuiBtn.TextColor3 = Theme.TextPrimary
    exportGuiBtn.BackgroundColor3 = Theme.AccentPrimary
    exportGuiBtn.Size = UDim2.new(1, -32, 0, 38)
    exportGuiBtn.Position = UDim2.new(0, 16, 0, 104)
    Theme.AddCorner(exportGuiBtn, Theme.CornerMedium)
    Theme.AddStroke(exportGuiBtn, Theme.BorderLight, 1)
    exportGuiBtn.Parent = card

    local guiStatus = Instance.new("TextLabel")
    guiStatus.Text = "Status: Pronto para exportar interfaces."
    guiStatus.Font = Theme.FontRegular
    guiStatus.TextSize = 11
    guiStatus.TextColor3 = Theme.TextMuted
    guiStatus.TextXAlignment = Enum.TextXAlignment.Left
    guiStatus.Size = UDim2.new(1, -32, 0, 24)
    guiStatus.Position = UDim2.new(0, 16, 0, 154)
    guiStatus.BackgroundTransparency = 1
    guiStatus.Parent = card

    Theme.AnimateButton(exportGuiBtn, function()
        guiStatus.Text = "Extraindo interfaces..."
        guiStatus.TextColor3 = Theme.TextPrimary

        task.spawn(function()
            local success, file = GuiRipper.ExportAllGuis(self.Config)
            if success then
                guiStatus.Text = "Pacote de UI salvo com sucesso: " .. file
                guiStatus.TextColor3 = Theme.AccentSuccess
                Environment.SetClipboard(file)
            else
                guiStatus.Text = "Erro: " .. tostring(file)
                guiStatus.TextColor3 = Theme.AccentDanger
            end
        end)
    end)
end

-- 6. Network Sniffer Tab
-- 6. Network Sniffer Tab
function Interface:BuildNetworkTab()
    local parent = self.TabFrames["Network"]

    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, -32, 0, 32)
    topBar.Position = UDim2.new(0, 16, 0, 10)
    topBar.BackgroundTransparency = 1
    topBar.Parent = parent

    local netLayout = Instance.new("UIListLayout")
    netLayout.FillDirection = Enum.FillDirection.Horizontal
    netLayout.Padding = UDim.new(0, 6)
    netLayout.SortOrder = Enum.SortOrder.LayoutOrder
    netLayout.Parent = topBar

    local toggleSnifferBtn = Instance.new("TextButton")
    toggleSnifferBtn.Text = "Iniciar Gravação de Rede"
    toggleSnifferBtn.Font = Theme.FontSemiBold
    toggleSnifferBtn.TextSize = 10
    toggleSnifferBtn.TextColor3 = Theme.TextPrimary
    toggleSnifferBtn.BackgroundColor3 = Theme.AccentPrimary
    toggleSnifferBtn.Size = UDim2.new(0.5, -3, 1, 0)
    toggleSnifferBtn.LayoutOrder = 1
    Theme.AddCorner(toggleSnifferBtn, Theme.CornerSmall)
    Theme.AddStroke(toggleSnifferBtn, Theme.BorderLight, 1)
    toggleSnifferBtn.Parent = topBar

    local exportSnifferBtn = Instance.new("TextButton")
    exportSnifferBtn.Text = "Exportar Logs (.json)"
    exportSnifferBtn.Font = Theme.FontSemiBold
    exportSnifferBtn.TextSize = 10
    exportSnifferBtn.TextColor3 = Theme.TextPrimary
    exportSnifferBtn.BackgroundColor3 = Theme.CardBg
    exportSnifferBtn.Size = UDim2.new(0.5, -3, 1, 0)
    exportSnifferBtn.LayoutOrder = 2
    Theme.AddCorner(exportSnifferBtn, Theme.CornerSmall)
    Theme.AddStroke(exportSnifferBtn, Theme.Border, 1)
    exportSnifferBtn.Parent = topBar

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -32, 1, -60)
    scroll.Position = UDim2.new(0, 16, 0, 50)
    scroll.BackgroundColor3 = Theme.CardBg
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Theme.Border
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    Theme.AddCorner(scroll, Theme.CornerMedium)
    Theme.AddStroke(scroll, Theme.Border, 1)
    scroll.Parent = parent

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 4)
    layout.Parent = scroll

    Theme.AnimateButton(toggleSnifferBtn, function()
        if NetworkSniffer.IsActive then
            NetworkSniffer.Stop()
            toggleSnifferBtn.Text = "Iniciar Gravação de Rede"
            toggleSnifferBtn.TextColor3 = Theme.TextPrimary
            toggleSnifferBtn.BackgroundColor3 = Theme.AccentPrimary
        else
            NetworkSniffer.Start()
            toggleSnifferBtn.Text = "Parar Gravação de Rede"
            toggleSnifferBtn.TextColor3 = Theme.TextPrimary
            toggleSnifferBtn.BackgroundColor3 = Theme.AccentDanger
        end
    end)

    Theme.AnimateButton(exportSnifferBtn, function()
        local file = NetworkSniffer.ExportLogs()
        exportSnifferBtn.Text = "✓ Salvo: " .. file
        Environment.SetClipboard(file)
        task.delay(2, function()
            exportSnifferBtn.Text = "Exportar Logs (.json)"
        end)
    end)

    NetworkSniffer.OnCall(function(entry)
        local row = Instance.new("TextLabel")
        row.Text = string.format("[%s] [%s] %s -> %s", entry.Timestamp, entry.Type, entry.RemoteName, entry.ArgsPreview)
        row.Font = Theme.FontRegular
        row.TextSize = 10
        row.TextColor3 = (entry.Type == "FireServer") and Theme.TextPrimary or Theme.TextSecondary
        row.TextXAlignment = Enum.TextXAlignment.Left
        row.Size = UDim2.new(1, -12, 0, 16)
        row.BackgroundTransparency = 1
        row.Parent = scroll

        scroll.CanvasSize = UDim2.new(0, 0, 0, #NetworkSniffer.CapturedLogs * 18)
        scroll.CanvasPosition = Vector2.new(0, scroll.CanvasSize.Y.Offset)
    end)
end

-- 7. Universe Tab (Multi-Place Tracker)
function Interface:BuildUniverseTab()
    local parent = self.TabFrames["Universe"]

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -32, 1, -32)
    card.Position = UDim2.new(0, 16, 0, 16)
    card.BackgroundColor3 = Theme.CardBg
    Theme.AddCorner(card, Theme.CornerLarge)
    Theme.AddStroke(card, Theme.Border, 1)
    card.Parent = parent

    local headerLbl = Instance.new("TextLabel")
    headerLbl.Text = "Sub-Lugares do Universo"
    headerLbl.Font = Theme.FontTitle
    headerLbl.TextSize = 13
    headerLbl.TextColor3 = Theme.TextPrimary
    headerLbl.TextXAlignment = Enum.TextXAlignment.Left
    headerLbl.Size = UDim2.new(1, -24, 0, 22)
    headerLbl.Position = UDim2.new(0, 16, 0, 16)
    headerLbl.BackgroundTransparency = 1
    headerLbl.Parent = card

    local uniBtnContainer = Instance.new("Frame")
    uniBtnContainer.Size = UDim2.new(1, -32, 0, 30)
    uniBtnContainer.Position = UDim2.new(0, 16, 0, 44)
    uniBtnContainer.BackgroundTransparency = 1
    uniBtnContainer.Parent = card

    local uniLayout = Instance.new("UIListLayout")
    uniLayout.FillDirection = Enum.FillDirection.Horizontal
    uniLayout.Padding = UDim.new(0, 6)
    uniLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uniLayout.Parent = uniBtnContainer

    local scanBtn = Instance.new("TextButton")
    scanBtn.Text = "Buscar Lugares"
    scanBtn.Font = Theme.FontSemiBold
    scanBtn.TextSize = 10
    scanBtn.TextColor3 = Theme.TextPrimary
    scanBtn.BackgroundColor3 = Theme.AccentPrimary
    scanBtn.Size = UDim2.new(0.34, -4, 1, 0)
    scanBtn.LayoutOrder = 1
    Theme.AddCorner(scanBtn, Theme.CornerSmall)
    Theme.AddStroke(scanBtn, Theme.BorderLight, 1)
    scanBtn.Parent = uniBtnContainer

    local snapshotBtn = Instance.new("TextButton")
    snapshotBtn.Text = "Salvar Snapshot"
    snapshotBtn.Font = Theme.FontSemiBold
    snapshotBtn.TextSize = 10
    snapshotBtn.TextColor3 = Theme.TextPrimary
    snapshotBtn.BackgroundColor3 = Theme.CardBg
    snapshotBtn.Size = UDim2.new(0.33, -4, 1, 0)
    snapshotBtn.LayoutOrder = 2
    Theme.AddCorner(snapshotBtn, Theme.CornerSmall)
    Theme.AddStroke(snapshotBtn, Theme.Border, 1)
    snapshotBtn.Parent = uniBtnContainer

    local compareDiffBtn = Instance.new("TextButton")
    compareDiffBtn.Text = "Comparar Diff"
    compareDiffBtn.Font = Theme.FontSemiBold
    compareDiffBtn.TextSize = 10
    compareDiffBtn.TextColor3 = Theme.TextPrimary
    compareDiffBtn.BackgroundColor3 = Theme.CardHover
    compareDiffBtn.Size = UDim2.new(0.33, -4, 1, 0)
    compareDiffBtn.LayoutOrder = 3
    Theme.AddCorner(compareDiffBtn, Theme.CornerSmall)
    Theme.AddStroke(compareDiffBtn, Theme.Border, 1)
    compareDiffBtn.Parent = uniBtnContainer

    local placeScroll = Instance.new("ScrollingFrame")
    placeScroll.Size = UDim2.new(1, -32, 1, -94)
    placeScroll.Position = UDim2.new(0, 16, 0, 84)
    placeScroll.BackgroundColor3 = Theme.Background
    placeScroll.ScrollBarThickness = 3
    placeScroll.ScrollBarImageColor3 = Theme.Border
    Theme.AddCorner(placeScroll, Theme.CornerMedium)
    Theme.AddStroke(placeScroll, Theme.Border, 1)
    placeScroll.Parent = card

    local placeLayout = Instance.new("UIListLayout")
    placeLayout.SortOrder = Enum.SortOrder.LayoutOrder
    placeLayout.Padding = UDim.new(0, 4)
    placeLayout.Parent = placeScroll

    Theme.AnimateButton(scanBtn, function()
        scanBtn.Text = "Buscando..."
        for _, child in ipairs(placeScroll:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextLabel") then child:Destroy() end
        end

        task.spawn(function()
            local list = UniverseTracker.GetUniversePlaces()
            scanBtn.Text = string.format("%d lugares encontrados", #list)

            for idx, pInfo in ipairs(list) do
                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, -12, 0, 30)
                row.BackgroundColor3 = Theme.CardBg
                Theme.AddCorner(row, Theme.CornerSmall)
                Theme.AddStroke(row, Theme.Border, 1)
                row.Parent = placeScroll

                local pName = Instance.new("TextLabel")
                pName.Text = string.format("%s (ID: %d)", pInfo.Name, pInfo.PlaceId)
                pName.Font = Theme.FontRegular
                pName.TextSize = 10
                pName.TextColor3 = pInfo.IsRoot and Theme.TextAccent or Theme.TextPrimary
                pName.TextXAlignment = Enum.TextXAlignment.Left
                pName.Size = UDim2.new(0.55, 0, 1, 0)
                pName.Position = UDim2.new(0, 8, 0, 0)
                pName.BackgroundTransparency = 1
                pName.Parent = row

                local tpBtn = Instance.new("TextButton")
                tpBtn.Text = "Teleportar"
                tpBtn.Font = Theme.FontSemiBold
                tpBtn.TextSize = 10
                tpBtn.TextColor3 = Theme.TextPrimary
                tpBtn.BackgroundColor3 = Theme.AccentPrimary
                tpBtn.Size = UDim2.new(0, 72, 0, 20)
                tpBtn.Position = UDim2.new(1, -148, 0.5, -10)
                Theme.AddCorner(tpBtn, Theme.CornerSmall)
                tpBtn.Parent = row

                Theme.AnimateButton(tpBtn, function()
                    tpBtn.Text = "Teleportando..."
                    pcall(function()
                        local TeleportService = game:GetService("TeleportService")
                        local Players = game:GetService("Players")
                        TeleportService:Teleport(pInfo.PlaceId, Players.LocalPlayer)
                    end)
                end)

                local copyIdBtn = Instance.new("TextButton")
                copyIdBtn.Text = "Copiar ID"
                copyIdBtn.Font = Theme.FontSemiBold
                copyIdBtn.TextSize = 10
                copyIdBtn.TextColor3 = Theme.TextSecondary
                copyIdBtn.BackgroundColor3 = Theme.CardHover
                copyIdBtn.Size = UDim2.new(0, 68, 0, 20)
                copyIdBtn.Position = UDim2.new(1, -72, 0.5, -10)
                Theme.AddCorner(copyIdBtn, Theme.CornerSmall)
                Theme.AddStroke(copyIdBtn, Theme.Border, 1)
                copyIdBtn.Parent = row

                Theme.AnimateButton(copyIdBtn, function()
                    Environment.SetClipboard(tostring(pInfo.PlaceId))
                    copyIdBtn.Text = "✓"
                    task.delay(1.5, function() copyIdBtn.Text = "Copiar ID" end)
                end)
            end

            placeScroll.CanvasSize = UDim2.new(0, 0, 0, #list * 36)
        end)
    end)

    Theme.AnimateButton(snapshotBtn, function()
        snapshotBtn.Text = "Gravando..."
        task.spawn(function()
            local success, snapFile = PlaceDiffTracker.SaveSnapshot()
            if success then
                snapshotBtn.Text = "✓ Salvo!"
                Environment.SetClipboard(snapFile)
            else
                snapshotBtn.Text = "Erro"
            end
            task.delay(2, function() snapshotBtn.Text = "Salvar Snapshot" end)
        end)
    end)

    Theme.AnimateButton(compareDiffBtn, function()
        compareDiffBtn.Text = "Comparando..."
        for _, child in ipairs(placeScroll:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextLabel") then child:Destroy() end
        end

        task.spawn(function()
            local diff = PlaceDiffTracker.Compare({ Instances = {}, PlaceId = game.PlaceId or 0, InstanceCount = 0 })
            local s, reportFile = PlaceDiffTracker.ExportDiffReport(diff)
            
            local lbl = Instance.new("TextLabel")
            lbl.Text = diff.Summary .. (s and ("\nRelatório salvo: " .. reportFile) or "")
            lbl.Font = Theme.FontRegular
            lbl.TextSize = 11
            lbl.TextColor3 = Theme.TextPrimary
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextWrapped = true
            lbl.Size = UDim2.new(1, -12, 0, 60)
            lbl.BackgroundTransparency = 1
            lbl.Parent = placeScroll

            if s then Environment.SetClipboard(reportFile) end
            compareDiffBtn.Text = "✓ Concluído"
            task.delay(2, function() compareDiffBtn.Text = "Comparar Diff" end)
        end)
    end)
end

-- 8. OBJ Export Tab (Blender / Unity 3D)
function Interface:BuildObjExportTab()
    local parent = self.TabFrames["ObjExport"]

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -32, 1, -32)
    card.Position = UDim2.new(0, 16, 0, 16)
    card.BackgroundColor3 = Theme.CardBg
    Theme.AddCorner(card, Theme.CornerLarge)
    Theme.AddStroke(card, Theme.Border, 1)
    card.Parent = parent

    local headerLbl = Instance.new("TextLabel")
    headerLbl.Text = "Exportador de Malhas 3D"
    headerLbl.Font = Theme.FontTitle
    headerLbl.TextSize = 13
    headerLbl.TextColor3 = Theme.TextPrimary
    headerLbl.TextXAlignment = Enum.TextXAlignment.Left
    headerLbl.Size = UDim2.new(1, -24, 0, 22)
    headerLbl.Position = UDim2.new(0, 16, 0, 16)
    headerLbl.BackgroundTransparency = 1
    headerLbl.Parent = card

    local desc = Instance.new("TextLabel")
    desc.Text = "Converte os modelos e peças do mapa para arquivos .obj e .mtl com materiais prontos para Blender, Maya, Unity ou Unreal Engine."
    desc.Font = Theme.FontRegular
    desc.TextSize = 11
    desc.TextColor3 = Theme.TextSecondary
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextYAlignment = Enum.TextYAlignment.Top
    desc.TextWrapped = true
    desc.Size = UDim2.new(1, -32, 0, 48)
    desc.Position = UDim2.new(0, 16, 0, 44)
    desc.BackgroundTransparency = 1
    desc.Parent = card

    local exportBtnContainer = Instance.new("Frame")
    exportBtnContainer.Size = UDim2.new(1, -32, 0, 38)
    exportBtnContainer.Position = UDim2.new(0, 16, 0, 98)
    exportBtnContainer.BackgroundTransparency = 1
    exportBtnContainer.Parent = card

    local btnLayout = Instance.new("UIListLayout")
    btnLayout.FillDirection = Enum.FillDirection.Horizontal
    btnLayout.Padding = UDim.new(0, 6)
    btnLayout.SortOrder = Enum.SortOrder.LayoutOrder
    btnLayout.Parent = exportBtnContainer

    local exportObjBtn = Instance.new("TextButton")
    exportObjBtn.Text = "Exportar .OBJ + .MTL"
    exportObjBtn.Font = Theme.FontSemiBold
    exportObjBtn.TextSize = 11
    exportObjBtn.TextColor3 = Theme.TextPrimary
    exportObjBtn.BackgroundColor3 = Theme.AccentPrimary
    exportObjBtn.Size = UDim2.new(0.5, -3, 1, 0)
    exportObjBtn.LayoutOrder = 1
    Theme.AddCorner(exportObjBtn, Theme.CornerSmall)
    Theme.AddStroke(exportObjBtn, Theme.BorderLight, 1)
    exportObjBtn.Parent = exportBtnContainer

    local exportWebBtn = Instance.new("TextButton")
    exportWebBtn.Text = "Exportar Visualizador Web (.html)"
    exportWebBtn.Font = Theme.FontSemiBold
    exportWebBtn.TextSize = 11
    exportWebBtn.TextColor3 = Theme.TextPrimary
    exportWebBtn.BackgroundColor3 = Theme.CardHover
    exportWebBtn.Size = UDim2.new(0.5, -3, 1, 0)
    exportWebBtn.LayoutOrder = 2
    Theme.AddCorner(exportWebBtn, Theme.CornerSmall)
    Theme.AddStroke(exportWebBtn, Theme.Border, 1)
    exportWebBtn.Parent = exportBtnContainer

    local objStatus = Instance.new("TextLabel")
    objStatus.Text = "Status: Pronto para exportar."
    objStatus.Font = Theme.FontRegular
    objStatus.TextSize = 11
    objStatus.TextColor3 = Theme.TextMuted
    objStatus.TextXAlignment = Enum.TextXAlignment.Left
    objStatus.Size = UDim2.new(1, -32, 0, 24)
    objStatus.Position = UDim2.new(0, 16, 0, 148)
    objStatus.BackgroundTransparency = 1
    objStatus.Parent = card

    Theme.AnimateButton(exportObjBtn, function()
        objStatus.Text = "Gerando arquivos .obj e .mtl..."
        objStatus.TextColor3 = Theme.TextPrimary

        task.spawn(function()
            local success, file = ObjExporter.ExportWorkspaceToObj()
            if success then
                objStatus.Text = "Exportado com sucesso: " .. file
                objStatus.TextColor3 = Theme.AccentSuccess
                Environment.SetClipboard(file)
            else
                objStatus.Text = "Erro ao exportar: " .. tostring(file)
                objStatus.TextColor3 = Theme.AccentDanger
            end
        end)
    end)

    Theme.AnimateButton(exportWebBtn, function()
        objStatus.Text = "Gerando visualizador 3D Web (.html)..."
        objStatus.TextColor3 = Theme.TextPrimary

        task.spawn(function()
            local success, file = Web3DExporter.ExportModelToHTML(workspace)
            if success then
                objStatus.Text = "Arquivo Web 3D salvo: " .. file
                objStatus.TextColor3 = Theme.AccentSuccess
                Environment.SetClipboard(file)
            else
                objStatus.Text = "Falha ao exportar Web 3D: " .. tostring(file)
                objStatus.TextColor3 = Theme.AccentDanger
            end
        end)
    end)
end

-- 9. Tutorial Tab (Built-in Step-by-Step Guide)
function Interface:BuildTutorialTab()
    local parent = self.TabFrames["Tutorial"]

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -32, 1, -32)
    scroll.Position = UDim2.new(0, 16, 0, 16)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Theme.Border
    scroll.CanvasSize = UDim2.new(0, 0, 0, 420)
    scroll.Parent = parent

    local steps = {
        {"Passo 1: Iniciar a Cópia", "Acesse a aba 'Dashboard' e clique no botão azul 'Salvar Mapa Completo'. O processo começará a extrair todas as instâncias do jogo."},
        {"Passo 2: Aguardar o Processamento", "A barra de progresso acompanhará o download de texturas, sons, modelos 3D, terreno e scripts do mapa."},
        {"Passo 3: Localização dos Arquivos", "O arquivo gerado (.rbxlx ou .rbxl) é salvo diretamente na pasta 'workspace' do seu executor no computador."},
        {"Passo 4: Abrir no Roblox Studio", "1. Abra o Roblox Studio.\n2. Clique em 'File' -> 'Open from File...'\n3. Selecione o arquivo gerado e clique em Abrir.\n4. O mapa estará 100% carregado e pronto para edição."},
    }

    for i, step in ipairs(steps) do
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -12, 0, 74)
        card.Position = UDim2.new(0, 0, 0, (i - 1) * 80)
        card.BackgroundColor3 = Theme.CardBg
        Theme.AddCorner(card, Theme.CornerMedium)
        Theme.AddStroke(card, Theme.Border, 1)
        card.Parent = scroll

        local title = Instance.new("TextLabel")
        title.Text = step[1]
        title.Font = Theme.FontSemiBold
        title.TextSize = 11
        title.TextColor3 = Theme.TextPrimary
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Size = UDim2.new(1, -20, 0, 18)
        title.Position = UDim2.new(0, 12, 0, 8)
        title.BackgroundTransparency = 1
        title.Parent = card

        local desc = Instance.new("TextLabel")
        desc.Text = step[2]
        desc.Font = Theme.FontRegular
        desc.TextSize = 10
        desc.TextColor3 = Theme.TextSecondary
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.TextYAlignment = Enum.TextYAlignment.Top
        desc.TextWrapped = true
        desc.Size = UDim2.new(1, -24, 0, 42)
        desc.Position = UDim2.new(0, 12, 0, 26)
        desc.BackgroundTransparency = 1
        desc.Parent = card
    end

    -- Copy Universal Command Button
    local copyScriptCard = Instance.new("TextButton")
    copyScriptCard.Text = "Copiar Comando de Execução (loadstring)"
    copyScriptCard.Font = Theme.FontSemiBold
    copyScriptCard.TextSize = 11
    copyScriptCard.TextColor3 = Theme.TextPrimary
    copyScriptCard.BackgroundColor3 = Theme.AccentPrimary
    copyScriptCard.Size = UDim2.new(1, -12, 0, 36)
    copyScriptCard.Position = UDim2.new(0, 0, 0, 330)
    Theme.AddCorner(copyScriptCard, Theme.CornerSmall)
    Theme.AddStroke(copyScriptCard, Theme.BorderLight, 1)
    copyScriptCard.Parent = scroll

    Theme.AnimateButton(copyScriptCard, function()
        Environment.SetClipboard('loadstring(game:HttpGet("https://raw.githubusercontent.com/theopadilha2009-hash/HyperSaveInstance/main/dist/HyperSaveInstance.luau"))()')
        copyScriptCard.Text = "✓ Comando Copiado!"
        task.delay(2, function()
            copyScriptCard.Text = "Copiar Comando de Execução (loadstring)"
        end)
    end)
end

-- 10. Settings Tab
function Interface:BuildSettingsTab()
    local parent = self.TabFrames["Settings"]

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -32, 1, -32)
    scroll.Position = UDim2.new(0, 16, 0, 16)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Theme.Border
    scroll.CanvasSize = UDim2.new(0, 0, 0, 780)
    scroll.Parent = parent

    -- Discord Webhook URL Row
    local webhookRow = Instance.new("Frame")
    webhookRow.Size = UDim2.new(1, -12, 0, 36)
    webhookRow.Position = UDim2.new(0, 0, 0, 0)
    webhookRow.BackgroundColor3 = Theme.CardBg
    Theme.AddCorner(webhookRow, Theme.CornerSmall)
    Theme.AddStroke(webhookRow, Theme.Border, 1)
    webhookRow.Parent = scroll

    local webhookLbl = Instance.new("TextLabel")
    webhookLbl.Text = "Webhook do Discord:"
    webhookLbl.Font = Theme.FontSemiBold
    webhookLbl.TextSize = 10
    webhookLbl.TextColor3 = Theme.TextSecondary
    webhookLbl.TextXAlignment = Enum.TextXAlignment.Left
    webhookLbl.Size = UDim2.new(0.38, 0, 1, 0)
    webhookLbl.Position = UDim2.new(0, 10, 0, 0)
    webhookLbl.BackgroundTransparency = 1
    webhookLbl.Parent = webhookRow

    local webhookBox = Instance.new("TextBox")
    webhookBox.PlaceholderText = "https://discord.com/api/webhooks/..."
    webhookBox.Text = self.Config.DiscordWebhookUrl or ""
    webhookBox.Font = Theme.FontRegular
    webhookBox.TextSize = 10
    webhookBox.TextColor3 = Theme.TextPrimary
    webhookBox.PlaceholderColor3 = Theme.TextMuted
    webhookBox.BackgroundColor3 = Theme.InputBg
    webhookBox.Size = UDim2.new(0.58, 0, 0, 24)
    webhookBox.Position = UDim2.new(0.40, 0, 0.5, -12)
    webhookBox.ClearTextOnFocus = false
    Theme.AddCorner(webhookBox, Theme.CornerSmall)
    Theme.AddStroke(webhookBox, Theme.Border, 1)
    webhookBox.Parent = webhookRow

    webhookBox.FocusLost:Connect(function()
        self.Config.DiscordWebhookUrl = webhookBox.Text
        self:Log("Discord Webhook atualizado.")
    end)

    local toggles = {
        {"AutoAntiAFK", "Anti-AFK Automático (Evita desconexão por inatividade)", self.Config.AutoAntiAFK},
        {"AutoExploreStreaming", "Carregador Espacial (StreamingEnabled)", self.Config.AutoExploreStreaming},
        {"StealthMode", "Modo Stealth (Evasão de Anti-Cheat)", self.Config.StealthMode},
        {"SaveAnimations", "Capturar e Salvar Animações (KeyframeSequences)", self.Config.SaveAnimations},
        {"SafeAssetDownload", "Proteção de Ping (Pausa se Ping > 180ms)", self.Config.SafeAssetDownload},
        {"DownloadRawAssets", "Baixar Assets Brutos (.mp3, .png, .mesh)", self.Config.DownloadRawAssets},
        {"OptimizeGeometry", "Otimizador de Geometria (Deduplicação de Malhas)", self.Config.OptimizeGeometry},
        {"SaveTerrain", "Salvar Terreno Completo (Propriedades e Materiais)", self.Config.SaveTerrain},
        {"SaveTerrainVoxels", "Extrair SmoothVoxels do Terreno (Chunks 3D)", self.Config.SaveTerrainVoxels},
        {"SaveLighting", "Preservar Iluminação e Efeitos Atmosféricos", self.Config.SaveLighting},
        {"SaveSounds", "Preservar Sons e Efeitos Sonoros", self.Config.SaveSounds},
        {"SaveUnions", "Preservar Uniões CSG e NegateOperations", self.Config.SaveUnions},
        {"SaveSurfaceAppearance", "Preservar Texturas PBR e SurfaceAppearances", self.Config.SaveSurfaceAppearance},
        {"DecompileScripts", "Descompilar Scripts (LocalScripts e ModuleScripts)", self.Config.DecompileScripts},
        {"IsolateStarterPlayer", "Isolar Scripts do Player para StarterPlayer/StarterGui", self.Config.IsolateStarterPlayer},
        {"SaveServerScriptPlaceholders", "Reconstrução Inteligente de Server Scripts", self.Config.SaveServerScriptPlaceholders},
        {"SynthesizeServer", "Sintetizador Automático de Backend para Remotes", self.Config.SynthesizeServer},
        {"SaveNilInstances", "Salvar Instâncias Isoladas (Nil Instances)", self.Config.SaveNilInstances},
        {"SaveAttributes", "Salvar Atributos Modernos de Instâncias", self.Config.SaveAttributes},
        {"SaveTags", "Salvar Tags do CollectionService", self.Config.SaveTags},
    }

    for i, item in ipairs(toggles) do
        local key, title, defaultVal = item[1], item[2], item[3]

        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -12, 0, 32)
        row.Position = UDim2.new(0, 0, 0, 42 + (i - 1) * 36)
        row.BackgroundColor3 = Theme.CardBg
        Theme.AddCorner(row, Theme.CornerSmall)
        Theme.AddStroke(row, Theme.Border, 1)
        row.Parent = scroll

        local lbl = Instance.new("TextLabel")
        lbl.Text = title
        lbl.Font = Theme.FontRegular
        lbl.TextSize = 10
        lbl.TextColor3 = Theme.TextPrimary
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Size = UDim2.new(0.74, 0, 1, 0)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Parent = row

        local switch = Instance.new("TextButton")
        switch.Text = defaultVal and "ATIVADO" or "DESATIVADO"
        switch.Font = Theme.FontSemiBold
        switch.TextSize = 9
        switch.TextColor3 = defaultVal and Theme.TextPrimary or Theme.TextMuted
        switch.BackgroundColor3 = defaultVal and Theme.AccentPrimary or Theme.Background
        switch.Size = UDim2.new(0, 80, 0, 22)
        switch.Position = UDim2.new(1, -88, 0.5, -11)
        Theme.AddCorner(switch, Theme.CornerSmall)
        Theme.AddStroke(switch, defaultVal and Theme.BorderLight or Theme.Border, 1)
        switch.Parent = row

        Theme.AnimateButton(switch, function()
            local current = self.Config[key]
            local new = not current
            self.Config[key] = new
            switch.Text = new and "ATIVADO" or "DESATIVADO"
            switch.TextColor3 = new and Theme.TextPrimary or Theme.TextMuted
            switch.BackgroundColor3 = new and Theme.AccentPrimary or Theme.Background
            local stroke = switch:FindFirstChildOfClass("UIStroke")
            if stroke then
                stroke.Color = new and Theme.BorderLight or Theme.Border
            end
            self:Log("Opção alterada: " .. key .. " = " .. tostring(new))
        end)
    end

    local animExportBtn = Instance.new("TextButton")
    animExportBtn.Text = "Exportar Animações Capturadas (.rbxm)"
    animExportBtn.Font = Theme.FontSemiBold
    animExportBtn.TextSize = 11
    animExportBtn.TextColor3 = Theme.TextPrimary
    animExportBtn.BackgroundColor3 = Theme.AccentPrimary
    animExportBtn.Size = UDim2.new(1, -12, 0, 36)
    animExportBtn.Position = UDim2.new(0, 0, 0, 42 + #toggles * 36)
    Theme.AddCorner(animExportBtn, Theme.CornerSmall)
    Theme.AddStroke(animExportBtn, Theme.BorderLight, 1)
    animExportBtn.Parent = scroll

    Theme.AnimateButton(animExportBtn, function()
        animExportBtn.Text = "Exportando animações..."
        task.spawn(function()
            local AnimationRecorder = require("../Core/AnimationRecorder")
            local success, file = AnimationRecorder.ExportRecordedAnimations()
            if success then
                animExportBtn.Text = "✓ Salvo: " .. tostring(file)
                Environment.SetClipboard(tostring(file))
            else
                animExportBtn.Text = "Erro ao exportar"
            end
            task.delay(2.5, function()
                animExportBtn.Text = "Exportar Animações Capturadas (.rbxm)"
            end)
        end)
    end)
end

-- 11. Console Tab
function Interface:BuildConsoleTab()
    local parent = self.TabFrames["Console"]

    local consoleBox = Instance.new("ScrollingFrame")
    consoleBox.Size = UDim2.new(1, -32, 1, -64)
    consoleBox.Position = UDim2.new(0, 16, 0, 14)
    consoleBox.BackgroundColor3 = Theme.CardBg
    consoleBox.ScrollBarThickness = 3
    consoleBox.ScrollBarImageColor3 = Theme.Border
    consoleBox.CanvasSize = UDim2.new(0, 0, 0, 0)
    Theme.AddCorner(consoleBox, Theme.CornerMedium)
    Theme.AddStroke(consoleBox, Theme.Border, 1)
    consoleBox.Parent = parent
    self.ConsoleScroll = consoleBox

    local consoleList = Instance.new("UIListLayout")
    consoleList.SortOrder = Enum.SortOrder.LayoutOrder
    consoleList.Padding = UDim.new(0, 3)
    consoleList.Parent = consoleBox

    local copyLogsBtn = Instance.new("TextButton")
    copyLogsBtn.Text = "Copiar Todos os Logs"
    copyLogsBtn.Font = Theme.FontSemiBold
    copyLogsBtn.TextSize = 11
    copyLogsBtn.TextColor3 = Theme.TextPrimary
    copyLogsBtn.BackgroundColor3 = Theme.AccentPrimary
    copyLogsBtn.Size = UDim2.new(1, -32, 0, 34)
    copyLogsBtn.Position = UDim2.new(0, 16, 1, -42)
    Theme.AddCorner(copyLogsBtn, Theme.CornerSmall)
    Theme.AddStroke(copyLogsBtn, Theme.BorderLight, 1)
    copyLogsBtn.Parent = parent

    Theme.AnimateButton(copyLogsBtn, function()
        local fullLog = table.concat(self.Logs, "\n")
        Environment.SetClipboard(fullLog)
        copyLogsBtn.Text = "✓ Logs Copiados!"
        task.delay(2, function()
            copyLogsBtn.Text = "Copiar Todos os Logs"
        end)
    end)
end

-- 12. About Tab
function Interface:BuildAboutTab()
    local parent = self.TabFrames["About"]

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -32, 1, -32)
    scroll.Position = UDim2.new(0, 16, 0, 16)
    scroll.BackgroundColor3 = Theme.CardBg
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = Theme.Border
    scroll.CanvasSize = UDim2.new(0, 0, 0, 440)
    Theme.AddCorner(scroll, Theme.CornerLarge)
    Theme.AddStroke(scroll, Theme.Border, 1)
    scroll.Parent = parent

    -- Developer Profile Header Card
    local devCard = Instance.new("Frame")
    devCard.Size = UDim2.new(1, -24, 0, 110)
    devCard.Position = UDim2.new(0, 12, 0, 12)
    devCard.BackgroundColor3 = Theme.Background
    Theme.AddCorner(devCard, Theme.CornerMedium)
    Theme.AddStroke(devCard, Theme.Border, 1)
    devCard.Parent = scroll

    -- Avatar Emblem
    local avatar = Instance.new("Frame")
    avatar.Size = UDim2.new(0, 48, 0, 48)
    avatar.Position = UDim2.new(0, 14, 0, 14)
    avatar.BackgroundColor3 = Theme.AccentPrimary
    Theme.AddCorner(avatar, Theme.CornerPill)
    avatar.Parent = devCard

    local avatarTxt = Instance.new("TextLabel")
    avatarTxt.Text = "TLP"
    avatarTxt.Font = Theme.FontTitle
    avatarTxt.TextSize = 14
    avatarTxt.TextColor3 = Theme.TextPrimary
    avatarTxt.Size = UDim2.new(1, 0, 1, 0)
    avatarTxt.BackgroundTransparency = 1
    avatarTxt.Parent = avatar

    -- Developer Name & Title
    local devName = Instance.new("TextLabel")
    devName.Text = "Theo Lorentz Padilha"
    devName.Font = Theme.FontTitle
    devName.TextSize = 14
    devName.TextColor3 = Theme.TextPrimary
    devName.TextXAlignment = Enum.TextXAlignment.Left
    devName.Size = UDim2.new(1, -74, 0, 20)
    devName.Position = UDim2.new(0, 70, 0, 14)
    devName.BackgroundTransparency = 1
    devName.Parent = devCard

    local devRole = Instance.new("TextLabel")
    devRole.Text = "Desenvolvedor Principal • HyperSaveInstance"
    devRole.Font = Theme.FontRegular
    devRole.TextSize = 11
    devRole.TextColor3 = Theme.TextSecondary
    devRole.TextXAlignment = Enum.TextXAlignment.Left
    devRole.Size = UDim2.new(1, -74, 0, 16)
    devRole.Position = UDim2.new(0, 70, 0, 34)
    devRole.BackgroundTransparency = 1
    devRole.Parent = devCard

    -- Action Container for Buttons (UIListLayout Grid)
    local devBtnBar = Instance.new("Frame")
    devBtnBar.Size = UDim2.new(1, -84, 0, 26)
    devBtnBar.Position = UDim2.new(0, 70, 0, 64)
    devBtnBar.BackgroundTransparency = 1
    devBtnBar.Parent = devCard

    local devBtnLayout = Instance.new("UIListLayout")
    devBtnLayout.FillDirection = Enum.FillDirection.Horizontal
    devBtnLayout.Padding = UDim.new(0, 6)
    devBtnLayout.SortOrder = Enum.SortOrder.LayoutOrder
    devBtnLayout.Parent = devBtnBar

    -- GitHub Link Button
    local btnGithub = Instance.new("TextButton")
    btnGithub.Text = "GitHub"
    btnGithub.Font = Theme.FontSemiBold
    btnGithub.TextSize = 10
    btnGithub.TextColor3 = Theme.TextPrimary
    btnGithub.BackgroundColor3 = Theme.CardHover
    btnGithub.Size = UDim2.new(0.25, -4, 1, 0)
    btnGithub.LayoutOrder = 1
    Theme.AddCorner(btnGithub, Theme.CornerSmall)
    Theme.AddStroke(btnGithub, Theme.Border, 1)
    btnGithub.Parent = devBtnBar

    Theme.AnimateButton(btnGithub, function()
        Environment.SetClipboard("https://github.com/theopadilha2009-hash")
        btnGithub.Text = "✓ Copiado!"
        task.delay(2, function() btnGithub.Text = "GitHub" end)
    end)

    -- LinkedIn Profile Button
    local btnLinkedIn = Instance.new("TextButton")
    btnLinkedIn.Text = "LinkedIn"
    btnLinkedIn.Font = Theme.FontSemiBold
    btnLinkedIn.TextSize = 10
    btnLinkedIn.TextColor3 = Theme.TextPrimary
    btnLinkedIn.BackgroundColor3 = Theme.CardHover
    btnLinkedIn.Size = UDim2.new(0.25, -4, 1, 0)
    btnLinkedIn.LayoutOrder = 2
    Theme.AddCorner(btnLinkedIn, Theme.CornerSmall)
    Theme.AddStroke(btnLinkedIn, Theme.Border, 1)
    btnLinkedIn.Parent = devBtnBar

    Theme.AnimateButton(btnLinkedIn, function()
        Environment.SetClipboard("https://www.linkedin.com/in/theo-lorentz-padilha-0b9b99287/")
        btnLinkedIn.Text = "✓ Copiado!"
        task.delay(2, function() btnLinkedIn.Text = "LinkedIn" end)
    end)

    -- Repository Link Button
    local btnRepo = Instance.new("TextButton")
    btnRepo.Text = "Repositório"
    btnRepo.Font = Theme.FontSemiBold
    btnRepo.TextSize = 10
    btnRepo.TextColor3 = Theme.TextPrimary
    btnRepo.BackgroundColor3 = Theme.CardHover
    btnRepo.Size = UDim2.new(0.25, -4, 1, 0)
    btnRepo.LayoutOrder = 3
    Theme.AddCorner(btnRepo, Theme.CornerSmall)
    Theme.AddStroke(btnRepo, Theme.Border, 1)
    btnRepo.Parent = devBtnBar

    Theme.AnimateButton(btnRepo, function()
        Environment.SetClipboard("https://github.com/theopadilha2009-hash/HyperSaveInstance")
        btnRepo.Text = "✓ Copiado!"
        task.delay(2, function() btnRepo.Text = "Repositório" end)
    end)

    -- Discord Server Button
    local btnDiscord = Instance.new("TextButton")
    btnDiscord.Text = "Discord"
    btnDiscord.Font = Theme.FontSemiBold
    btnDiscord.TextSize = 10
    btnDiscord.TextColor3 = Theme.TextPrimary
    btnDiscord.BackgroundColor3 = Theme.AccentPrimary
    btnDiscord.Size = UDim2.new(0.25, -4, 1, 0)
    btnDiscord.LayoutOrder = 4
    Theme.AddCorner(btnDiscord, Theme.CornerSmall)
    btnDiscord.Parent = devBtnBar

    Theme.AnimateButton(btnDiscord, function()
        Environment.SetClipboard("https://discord.gg/Tk5zyA83UZ")
        btnDiscord.Text = "✓ Copiado!"
        task.delay(2, function() btnDiscord.Text = "Discord" end)
    end)

    -- System Diagnostics Card
    local sysCard = Instance.new("Frame")
    sysCard.Size = UDim2.new(1, -24, 0, 170)
    sysCard.Position = UDim2.new(0, 12, 0, 130)
    sysCard.BackgroundColor3 = Theme.Background
    Theme.AddCorner(sysCard, Theme.CornerMedium)
    Theme.AddStroke(sysCard, Theme.Border, 1)
    sysCard.Parent = scroll

    local sysTitle = Instance.new("TextLabel")
    sysTitle.Text = "Diagnóstico do Sistema & Ambiente"
    sysTitle.Font = Theme.FontTitle
    sysTitle.TextSize = 12
    sysTitle.TextColor3 = Theme.TextPrimary
    sysTitle.TextXAlignment = Enum.TextXAlignment.Left
    sysTitle.Size = UDim2.new(1, -20, 0, 20)
    sysTitle.Position = UDim2.new(0, 12, 0, 8)
    sysTitle.BackgroundTransparency = 1
    sysTitle.Parent = sysCard

    local diagItems = {
        {"Plataforma:", Environment.GetPlatform()},
        {"Executor:", Environment.GetExecutorName()},
        {"Escrita de Arquivo (writefile):", Environment.HasFileSystem() and "Ativo (Totalmente Suportado)" or "Indisponível"},
        {"Descompilador Luau:", Environment.HasDecompiler() and "Ativo (Descompilação Completa)" or "Modo Bytecode / Fallback"},
        {"Bypass de StreamingEnabled:", "Ativo (StreamExplorer Espacial)"},
        {"Emulador de DataStore & VIP:", "Ativo (1.000.000 Coins / VIP Liberado)"},
        {"Atalho de Teclado (HUD):", "[RightShift] ou Botão Flutuante"},
    }

    for i, item in ipairs(diagItems) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -24, 0, 18)
        row.Position = UDim2.new(0, 12, 0, 30 + (i - 1) * 19)
        row.BackgroundTransparency = 1
        row.Parent = sysCard

        local lblKey = Instance.new("TextLabel")
        lblKey.Text = "• " .. item[1]
        lblKey.Font = Theme.FontSemiBold
        lblKey.TextSize = 10
        lblKey.TextColor3 = Theme.TextSecondary
        lblKey.TextXAlignment = Enum.TextXAlignment.Left
        lblKey.Size = UDim2.new(0.5, 0, 1, 0)
        lblKey.BackgroundTransparency = 1
        lblKey.Parent = row

        local lblVal = Instance.new("TextLabel")
        lblVal.Text = item[2]
        lblVal.Font = Theme.FontRegular
        lblVal.TextSize = 10
        lblVal.TextColor3 = (string.find(item[2], "Ativo") or string.find(item[2], "Suportado")) and Theme.AccentSuccess or Theme.TextPrimary
        lblVal.TextXAlignment = Enum.TextXAlignment.Right
        lblVal.Size = UDim2.new(0.5, 0, 1, 0)
        lblVal.Position = UDim2.new(0.5, 0, 0, 0)
        lblVal.BackgroundTransparency = 1
        lblVal.Parent = row
    end

    -- Suite Capabilities Summary Card
    local featCard = Instance.new("Frame")
    featCard.Size = UDim2.new(1, -24, 0, 105)
    featCard.Position = UDim2.new(0, 12, 0, 308)
    featCard.BackgroundColor3 = Theme.Background
    Theme.AddCorner(featCard, Theme.CornerMedium)
    Theme.AddStroke(featCard, Theme.Border, 1)
    featCard.Parent = scroll

    local featTitle = Instance.new("TextLabel")
    featTitle.Text = "Recursos e Módulos Integrados"
    featTitle.Font = Theme.FontTitle
    featTitle.TextSize = 12
    featTitle.TextColor3 = Theme.TextPrimary
    featTitle.TextXAlignment = Enum.TextXAlignment.Left
    featTitle.Size = UDim2.new(1, -20, 0, 20)
    featTitle.Position = UDim2.new(0, 12, 0, 8)
    featTitle.BackgroundTransparency = 1
    featTitle.Parent = featCard

    local featDesc = Instance.new("TextLabel")
    featDesc.Text = "• Seletor de Alvos 3D com Raycast e Multi-Seleção\n• Terreno SmoothVoxels 3D, Iluminação PBR e Áudios\n• Importador Oficial para Roblox Studio com Master Fix\n• Descompilador Luau Integrado e Proteção Anti-AFK"
    featDesc.Font = Theme.FontRegular
    featDesc.TextSize = 10
    featDesc.TextColor3 = Theme.TextSecondary
    featDesc.TextXAlignment = Enum.TextXAlignment.Left
    featDesc.TextYAlignment = Enum.TextYAlignment.Top
    featDesc.Size = UDim2.new(1, -24, 0, 68)
    featDesc.Position = UDim2.new(0, 12, 0, 30)
    featDesc.BackgroundTransparency = 1
    featDesc.Parent = featCard
end

function Interface:Log(message: string, color: Color3?)
    local timestamp = os.date("%H:%M:%S")
    local line = string.format("[%s] %s", timestamp, message)
    table.insert(self.Logs, line)

    if self.ConsoleScroll then
        local lbl = Instance.new("TextLabel")
        lbl.Text = line
        lbl.Font = Theme.FontRegular
        lbl.TextSize = 10
        lbl.TextColor3 = color or Theme.TextSecondary
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Size = UDim2.new(1, -12, 0, 16)
        lbl.BackgroundTransparency = 1
        lbl.Parent = self.ConsoleScroll

        self.ConsoleScroll.CanvasSize = UDim2.new(0, 0, 0, #self.Logs * 18)
        self.ConsoleScroll.CanvasPosition = Vector2.new(0, self.ConsoleScroll.CanvasSize.Y.Offset)
    end
end

function Interface:BindEngineEvents()
    self.Engine:OnProgress(function(prog)
        if self.StatusHeader then
            self.StatusHeader.Text = "Status: " .. prog.Stage
        end
        if self.PctLabel then
            self.PctLabel.Text = tostring(prog.Percentage) .. "%"
        end
        if self.StatusDetail then
            self.StatusDetail.Text = prog.Message
        end
        if self.ProgressBarFill then
            Theme.Tween(self.ProgressBarFill, 0.2, {
                Size = UDim2.new(math.clamp(prog.Percentage / 100, 0, 1), 0, 1, 0)
            })
        end

        local color = Theme.TextSecondary
        if prog.Stage == "Done" then
            color = Theme.AccentSuccess
            if prog.SavedFile then self.SavedFilePath = prog.SavedFile end
            if prog.AssetsFolder then self.SavedAssetPath = prog.AssetsFolder end

            if self.CloneButton then
                self.CloneButton.Text = "✓ Salvo com sucesso!"
                task.delay(4, function()
                    self.CloneButton.Text = "Salvar Mapa Completo (.rbxlx)"
                end)
            end
        elseif prog.Stage == "Error" then
            color = Theme.AccentDanger
        elseif prog.Stage == "Exploring" then
            color = Theme.TextPrimary
        elseif prog.Stage == "Assets" then
            color = Theme.TextPrimary
        elseif prog.Stage == "Decompiling" then
            color = Theme.TextPrimary
        end

        self:Log(prog.Message, color)
    end)
end

function Interface:StartClone()
    if self.Engine.IsRunning then
        return
    end

    if self.CloneButton then
        self.CloneButton.Text = "Salvando mapa..."
    end

    task.spawn(function()
        local success, result = self.Engine:Start()
        if not success then
            self:Log("Erro ao salvar: " .. tostring(result), Theme.AccentDanger)
        end
    end)
end

return Interface
