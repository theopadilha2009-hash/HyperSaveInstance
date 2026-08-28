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

    local old = parent:FindFirstChild("HyperSaveInstance_UI")
    if old then old:Destroy() end

    -- ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HyperSaveInstance_UI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui = screenGui

    -- Floating Mini Toggle Button (Always accessible if minimized or on mobile)
    local floatingBtn = Instance.new("TextButton")
    floatingBtn.Name = "FloatingToggle"
    floatingBtn.Text = "💀 HYPERSAVE • THEO"
    floatingBtn.Font = Theme.FontTitle
    floatingBtn.TextSize = 11
    floatingBtn.TextColor3 = Theme.TextPrimary
    floatingBtn.BackgroundColor3 = Theme.CardBg
    floatingBtn.Size = UDim2.new(0, 154, 0, 34)
    floatingBtn.Position = UDim2.new(0, 20, 0, 20)
    floatingBtn.Visible = false
    Theme.AddCorner(floatingBtn, Theme.CornerPill)
    Theme.AddStroke(floatingBtn, Theme.BorderNeon, 1.5)
    Theme.AddGradient(floatingBtn, Color3.fromRGB(15, 12, 24), Color3.fromRGB(35, 20, 55), 45)
    floatingBtn.Parent = screenGui
    self.FloatingToggle = floatingBtn

    -- Main Container (Obsidian Gothic Theme)
    local main = Instance.new("Frame")
    main.Name = "MainFrame"
    main.Size = UDim2.new(0, 660, 0, 480)
    main.Position = UDim2.new(0.5, -330, 0.5, -240)
    main.BackgroundColor3 = Theme.Background
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    Theme.AddCorner(main, Theme.CornerLarge)
    Theme.AddStroke(main, Theme.BorderLight, 1.5)
    main.Parent = screenGui
    self.MainFrame = main

    floatingBtn.MouseButton1Click:Connect(function()
        main.Visible = true
        floatingBtn.Visible = false
    end)

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

    -- Top Header Bar
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 48)
    header.BackgroundColor3 = Theme.CardBg
    header.BorderSizePixel = 0
    header.Parent = main

    local headerLine = Instance.new("Frame")
    headerLine.Size = UDim2.new(1, 0, 0, 1)
    headerLine.Position = UDim2.new(0, 0, 1, -1)
    headerLine.BackgroundColor3 = Theme.Border
    headerLine.BorderSizePixel = 0
    headerLine.Parent = header

    -- Title & Skull Logo
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = "💀 HyperSaveInstance"
    titleLabel.Font = Theme.FontTitle
    titleLabel.TextSize = 15
    titleLabel.TextColor3 = Theme.TextPrimary
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Size = UDim2.new(0, 185, 1, 0)
    titleLabel.Position = UDim2.new(0, 16, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Parent = header

    -- Platform & Creator Badge
    local badge = Instance.new("TextLabel")
    badge.Text = "por Theo Lorentz Padilha • [RightShift]"
    badge.Font = Theme.FontSemiBold
    badge.TextSize = 11
    badge.TextColor3 = Theme.AccentTheo
    badge.BackgroundColor3 = Color3.fromRGB(18, 14, 28)
    badge.Size = UDim2.new(0, 230, 0, 26)
    badge.Position = UDim2.new(0, 205, 0.5, -13)
    Theme.AddCorner(badge, Theme.CornerPill)
    Theme.AddStroke(badge, Theme.BorderNeon, 1)
    badge.Parent = header

    -- Minimize Button
    local minBtn = Instance.new("TextButton")
    minBtn.Text = "–"
    minBtn.Font = Theme.FontTitle
    minBtn.TextSize = 14
    minBtn.TextColor3 = Theme.TextSecondary
    minBtn.BackgroundColor3 = Theme.CardHover
    minBtn.Size = UDim2.new(0, 28, 0, 28)
    minBtn.Position = UDim2.new(1, -70, 0.5, -14)
    Theme.AddCorner(minBtn, Theme.CornerSmall)
    minBtn.Parent = header
    minBtn.MouseButton1Click:Connect(function()
        main.Visible = false
        floatingBtn.Visible = true
    end)

    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "✕"
    closeBtn.Font = Theme.FontTitle
    closeBtn.TextSize = 14
    closeBtn.TextColor3 = Theme.TextSecondary
    closeBtn.BackgroundColor3 = Theme.CardHover
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -38, 0.5, -14)
    Theme.AddCorner(closeBtn, Theme.CornerSmall)
    closeBtn.Parent = header
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    -- Tab Navigation Bar (Scrollable for all master tools)
    local navBar = Instance.new("ScrollingFrame")
    navBar.Name = "NavBar"
    navBar.Size = UDim2.new(0, 144, 1, -48)
    navBar.Position = UDim2.new(0, 0, 0, 48)
    navBar.BackgroundColor3 = Theme.CardBg
    navBar.ScrollBarThickness = 3
    navBar.ScrollBarImageColor3 = Theme.Border
    navBar.CanvasSize = UDim2.new(0, 0, 0, 380)
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
    contentArea.Size = UDim2.new(1, -144, 1, -48)
    contentArea.Position = UDim2.new(0, 144, 0, 48)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = main
    self.ContentArea = contentArea

    -- Navigation buttons
    local tabs = {
        {"Dashboard", " Clonar Tudo"},
        {"Selector", " Salvar Modelo"},
        {"AudioRipper", " Músicas & Sons"},
        {"LightingRipper", " Iluminação"},
        {"GuiRipper", " Interfaces (UI)"},
        {"Network", " Rede / Remotes"},
        {"Universe", " Universo"},
        {"ObjExport", " Exportar 3D"},
        {"Tutorial", " Como Usar"},
        {"Settings", " Configurações"},
        {"Console", " Console"},
        {"About", " Informações"}
    }

    self.TabFrames = {}
    self.NavButtons = {}

    for i, tabInfo in ipairs(tabs) do
        local tabKey, tabLabel = tabInfo[1], tabInfo[2]

        local navBtn = Instance.new("TextButton")
        navBtn.Text = tabLabel
        navBtn.Font = Theme.FontSemiBold
        navBtn.TextSize = 10
        navBtn.TextColor3 = (i == 1) and Theme.AccentSkull or Theme.TextSecondary
        navBtn.BackgroundColor3 = (i == 1) and Theme.CardActive or Theme.CardBg
        navBtn.Size = UDim2.new(1, -12, 0, 26)
        navBtn.Position = UDim2.new(0, 6, 0, 6 + (i - 1) * 30)
        Theme.AddCorner(navBtn, Theme.CornerSmall)
        Theme.AddStroke(navBtn, (i == 1) and Theme.BorderNeon or Theme.Border, 1)
        navBtn.Parent = navBar
        self.NavButtons[tabKey] = navBtn

        local tabFrame = Instance.new("Frame")
        tabFrame.Name = tabKey .. "Tab"
        tabFrame.Size = UDim2.new(1, 0, 1, 0)
        tabFrame.BackgroundTransparency = 1
        tabFrame.Visible = (i == 1)
        tabFrame.Parent = contentArea
        self.TabFrames[tabKey] = tabFrame

        navBtn.MouseButton1Click:Connect(function()
            self:SwitchTab(tabKey)
        end)
    end

    -- Build Individual Tab Pages
    self:BuildDashboardTab()
    self:BuildSelectorTab()
    self:BuildAudioRipperTab()
    self:BuildLightingRipperTab()
    self:BuildGuiRipperTab()
    self:BuildNetworkTab()
    self:BuildUniverseTab()
    self:BuildObjExportTab()
    self:BuildTutorialTab()
    self:BuildSettingsTab()
    self:BuildConsoleTab()
    self:BuildAboutTab()

    screenGui.Parent = parent
end

function Interface:SwitchTab(targetTab: string)
    self.ActiveTab = targetTab
    for k, frame in pairs(self.TabFrames) do
        frame.Visible = (k == targetTab)
    end
    for k, btn in pairs(self.NavButtons) do
        local stroke = btn:FindFirstChildOfClass("UIStroke")
        if k == targetTab then
            btn.TextColor3 = Theme.AccentSkull
            btn.BackgroundColor3 = Theme.CardActive
            if stroke then stroke.Color = Theme.BorderNeon end
        else
            btn.TextColor3 = Theme.TextSecondary
            btn.BackgroundColor3 = Theme.CardBg
            if stroke then stroke.Color = Theme.Border end
        end
    end
end

-- 1. Dashboard Tab (Clean, Prominent 1-Click Game Cloner)
function Interface:BuildDashboardTab()
    local parent = self.TabFrames["Dashboard"]

    -- Big Action Clone Button (1-Click Purple & Black)
    local cloneBtn = Instance.new("TextButton")
    cloneBtn.Name = "CloneButton"
    cloneBtn.Text = "💀 CLONAR JOGO INTEIRO (1-CLIQUE)"
    cloneBtn.Font = Theme.FontTitle
    cloneBtn.TextSize = 14
    cloneBtn.TextColor3 = Theme.AccentSkull
    cloneBtn.BackgroundColor3 = Theme.AccentPrimary
    cloneBtn.Size = UDim2.new(1, -32, 0, 52)
    cloneBtn.Position = UDim2.new(0, 16, 0, 14)
    Theme.AddCorner(cloneBtn, Theme.CornerMedium)
    Theme.AddStroke(cloneBtn, Theme.BorderNeon, 1.5)
    Theme.AddGradient(cloneBtn, Color3.fromRGB(147, 51, 234), Color3.fromRGB(76, 29, 149), 90)
    cloneBtn.Parent = parent
    self.CloneButton = cloneBtn

    cloneBtn.MouseButton1Click:Connect(function()
        self:StartClone()
    end)

    -- Preset Selection Container
    local presetLabel = Instance.new("TextLabel")
    presetLabel.Text = "MODO DE CLONAGEM:"
    presetLabel.Font = Theme.FontSemiBold
    presetLabel.TextSize = 11
    presetLabel.TextColor3 = Theme.TextMuted
    presetLabel.TextXAlignment = Enum.TextXAlignment.Left
    presetLabel.Size = UDim2.new(1, -32, 0, 18)
    presetLabel.Position = UDim2.new(0, 16, 0, 76)
    presetLabel.BackgroundTransparency = 1
    presetLabel.Parent = parent

    local presetContainer = Instance.new("Frame")
    presetContainer.Size = UDim2.new(1, -32, 0, 34)
    presetContainer.Position = UDim2.new(0, 16, 0, 96)
    presetContainer.BackgroundTransparency = 1
    presetContainer.Parent = parent

    local presetList = {"Full", "Fast", "VisualsOnly", "ScriptsOnly"}
    local presetDisplay = {
        Full = " Completo 10/10",
        Fast = " Rápido",
        VisualsOnly = " Apenas Visual",
        ScriptsOnly = " Apenas Scripts"
    }

    self.PresetButtons = {}
    for i, pKey in ipairs(presetList) do
        local btn = Instance.new("TextButton")
        btn.Text = presetDisplay[pKey]
        btn.Font = Theme.FontSemiBold
        btn.TextSize = 11
        btn.TextColor3 = (self.Config.Mode == pKey) and Theme.AccentCyan or Theme.TextSecondary
        btn.BackgroundColor3 = Theme.CardBg
        btn.Size = UDim2.new(0.235, 0, 1, 0)
        btn.Position = UDim2.new((i - 1) * 0.255, 0, 0, 0)
        Theme.AddCorner(btn, Theme.CornerSmall)
        Theme.AddStroke(btn, (self.Config.Mode == pKey) and Theme.AccentCyan or Theme.Border, 1)
        btn.Parent = presetContainer
        self.PresetButtons[pKey] = btn

        btn.MouseButton1Click:Connect(function()
            Defaults.ApplyPreset(self.Config, pKey)
            for k, b in pairs(self.PresetButtons) do
                b.TextColor3 = (k == pKey) and Theme.AccentCyan or Theme.TextSecondary
                b:FindFirstChildOfClass("UIStroke").Color = (k == pKey) and Theme.AccentCyan or Theme.Border
            end
            self:Log("Modo selecionado: " .. pKey)
        end)
    end

    -- Format Selector Container
    local formatLabel = Instance.new("TextLabel")
    formatLabel.Text = "FORMATO DE ARQUIVO:"
    formatLabel.Font = Theme.FontSemiBold
    formatLabel.TextSize = 11
    formatLabel.TextColor3 = Theme.TextMuted
    formatLabel.TextXAlignment = Enum.TextXAlignment.Left
    formatLabel.Size = UDim2.new(1, -32, 0, 18)
    formatLabel.Position = UDim2.new(0, 16, 0, 140)
    formatLabel.BackgroundTransparency = 1
    formatLabel.Parent = parent

    local formatContainer = Instance.new("Frame")
    formatContainer.Size = UDim2.new(1, -32, 0, 30)
    formatContainer.Position = UDim2.new(0, 16, 0, 160)
    formatContainer.BackgroundTransparency = 1
    formatContainer.Parent = parent

    local formats = {
        {"rbxlx", "Roblox XML (.rbxlx)"},
        {"rbxl", "Roblox Binário (.rbxl)"},
        {"lua", "Script Studio (.lua)"}
    }
    self.FormatButtons = {}

    for i, fmt in ipairs(formats) do
        local fKey, fLabel = fmt[1], fmt[2]
        local fBtn = Instance.new("TextButton")
        fBtn.Text = fLabel
        fBtn.Font = Theme.FontSemiBold
        fBtn.TextSize = 11
        fBtn.TextColor3 = (self.Config.Format == fKey) and Theme.AccentSuccess or Theme.TextSecondary
        fBtn.BackgroundColor3 = Theme.CardBg
        fBtn.Size = UDim2.new(0.31, 0, 1, 0)
        fBtn.Position = UDim2.new((i - 1) * 0.34, 0, 0, 0)
        Theme.AddCorner(fBtn, Theme.CornerSmall)
        Theme.AddStroke(fBtn, (self.Config.Format == fKey) and Theme.AccentSuccess or Theme.Border, 1)
        fBtn.Parent = formatContainer
        self.FormatButtons[fKey] = fBtn

        fBtn.MouseButton1Click:Connect(function()
            self.Config.Format = fKey
            for k, b in pairs(self.FormatButtons) do
                b.TextColor3 = (k == fKey) and Theme.AccentSuccess or Theme.TextSecondary
                b:FindFirstChildOfClass("UIStroke").Color = (k == fKey) and Theme.AccentSuccess or Theme.Border
            end
            self:Log("Formato definido para: ." .. fKey)
        end)
    end

    -- Progress Container
    local progressCard = Instance.new("Frame")
    progressCard.Size = UDim2.new(1, -32, 0, 106)
    progressCard.Position = UDim2.new(0, 16, 0, 204)
    progressCard.BackgroundColor3 = Theme.CardBg
    Theme.AddCorner(progressCard, Theme.CornerMedium)
    Theme.AddStroke(progressCard, Theme.Border, 1)
    progressCard.Parent = parent

    local statusHeader = Instance.new("TextLabel")
    statusHeader.Name = "StatusHeader"
    statusHeader.Text = "Status: Anti-AFK Ativo • Pronto para clonar"
    statusHeader.Font = Theme.FontSemiBold
    statusHeader.TextSize = 12
    statusHeader.TextColor3 = Theme.TextPrimary
    statusHeader.TextXAlignment = Enum.TextXAlignment.Left
    statusHeader.Size = UDim2.new(0.7, 0, 0, 20)
    statusHeader.Position = UDim2.new(0, 16, 0, 12)
    statusHeader.BackgroundTransparency = 1
    statusHeader.Parent = progressCard
    self.StatusHeader = statusHeader

    local pctLabel = Instance.new("TextLabel")
    pctLabel.Name = "PctLabel"
    pctLabel.Text = "0%"
    pctLabel.Font = Theme.FontTitle
    pctLabel.TextSize = 14
    pctLabel.TextColor3 = Theme.AccentCyan
    pctLabel.TextXAlignment = Enum.TextXAlignment.Right
    pctLabel.Size = UDim2.new(0.25, 0, 0, 20)
    pctLabel.Position = UDim2.new(0.72, 0, 0, 12)
    pctLabel.BackgroundTransparency = 1
    pctLabel.Parent = progressCard
    self.PctLabel = pctLabel

    -- Progress Bar Track & Fill
    local barTrack = Instance.new("Frame")
    barTrack.Size = UDim2.new(1, -32, 0, 8)
    barTrack.Position = UDim2.new(0, 16, 0, 40)
    barTrack.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
    Theme.AddCorner(barTrack, Theme.CornerPill)
    barTrack.Parent = progressCard

    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(0, 0, 1, 0)
    barFill.BackgroundColor3 = Theme.AccentCyan
    Theme.AddCorner(barFill, Theme.CornerPill)
    Theme.AddGradient(barFill, Theme.AccentCyan, Theme.AccentPrimary, 0)
    barFill.Parent = barTrack
    self.ProgressBarFill = barFill

    local statusDetail = Instance.new("TextLabel")
    statusDetail.Name = "StatusDetail"
    statusDetail.Text = "Basta dar 1 clique no botão roxo acima para salvar o jogo inteiro."
    statusDetail.Font = Theme.FontRegular
    statusDetail.TextSize = 11
    statusDetail.TextColor3 = Theme.TextMuted
    statusDetail.TextXAlignment = Enum.TextXAlignment.Left
    statusDetail.Size = UDim2.new(1, -32, 0, 20)
    statusDetail.Position = UDim2.new(0, 16, 0, 58)
    statusDetail.BackgroundTransparency = 1
    statusDetail.Parent = progressCard
    self.StatusDetail = statusDetail

    -- Quick Action Copy Buttons
    local copyBar = Instance.new("Frame")
    copyBar.Size = UDim2.new(1, -32, 0, 24)
    copyBar.Position = UDim2.new(0, 16, 0, 78)
    copyBar.BackgroundTransparency = 1
    copyBar.Parent = progressCard

    local copyFilePathBtn = Instance.new("TextButton")
    copyFilePathBtn.Text = " Copiar Nome do Arquivo"
    copyFilePathBtn.Font = Theme.FontSemiBold
    copyFilePathBtn.TextSize = 10
    copyFilePathBtn.TextColor3 = Theme.TextSecondary
    copyFilePathBtn.BackgroundColor3 = Theme.CardHover
    copyFilePathBtn.Size = UDim2.new(0.48, 0, 1, 0)
    copyFilePathBtn.Position = UDim2.new(0, 0, 0, 0)
    Theme.AddCorner(copyFilePathBtn, Theme.CornerSmall)
    copyFilePathBtn.Parent = copyBar

    copyFilePathBtn.MouseButton1Click:Connect(function()
        local name = self.SavedFilePath
        if #name == 0 then name = self.Engine:GetDefaultFileName() end
        Environment.SetClipboard(name)
        copyFilePathBtn.Text = "✓ Nome Copiado!"
        task.delay(2, function() copyFilePathBtn.Text = " Copiar Nome do Arquivo" end)
    end)

    local copyAssetsPathBtn = Instance.new("TextButton")
    copyAssetsPathBtn.Text = " Copiar Pasta de Assets"
    copyAssetsPathBtn.Font = Theme.FontSemiBold
    copyAssetsPathBtn.TextSize = 10
    copyAssetsPathBtn.TextColor3 = Theme.TextSecondary
    copyAssetsPathBtn.BackgroundColor3 = Theme.CardHover
    copyAssetsPathBtn.Size = UDim2.new(0.48, 0, 1, 0)
    copyAssetsPathBtn.Position = UDim2.new(0.52, 0, 0, 0)
    Theme.AddCorner(copyAssetsPathBtn, Theme.CornerSmall)
    copyAssetsPathBtn.Parent = copyBar

    copyAssetsPathBtn.MouseButton1Click:Connect(function()
        local name = self.SavedAssetPath
        if #name == 0 then name = self.Engine:GetDefaultAssetFolder() end
        Environment.SetClipboard(name)
        copyAssetsPathBtn.Text = "✓ Pasta Copiada!"
        task.delay(2, function() copyAssetsPathBtn.Text = " Copiar Pasta de Assets" end)
    end)
end

-- 2. Target Selector Tab (Save Individual Model / Folder / 3D Raycast / Multi-Select)
function Interface:BuildSelectorTab()
    local parent = self.TabFrames["Selector"]

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -32, 1, -32)
    scroll.Position = UDim2.new(0, 16, 0, 16)
    scroll.BackgroundColor3 = Theme.CardBg
    scroll.ScrollBarThickness = 5
    scroll.CanvasSize = UDim2.new(0, 0, 0, 520)
    Theme.AddCorner(scroll, Theme.CornerMedium)
    Theme.AddStroke(scroll, Theme.Border, 1)
    scroll.Parent = parent

    local headerLbl = Instance.new("TextLabel")
    headerLbl.Text = "🎯 SELETOR DE MODELOS, ARMAS & MULTI-SELEÇÃO"
    headerLbl.Font = Theme.FontTitle
    headerLbl.TextSize = 13
    headerLbl.TextColor3 = Theme.AccentCyan
    headerLbl.TextXAlignment = Enum.TextXAlignment.Left
    headerLbl.Size = UDim2.new(1, -24, 0, 24)
    headerLbl.Position = UDim2.new(0, 12, 0, 12)
    headerLbl.BackgroundTransparency = 1
    headerLbl.Parent = scroll

    -- 1. In-World 3D Raycast Click Selector Button
    local raycastBtn = Instance.new("TextButton")
    raycastBtn.Text = "🎯 CLICAR NO OBJETO NO MUNDO 3D (SELETOR VISUAL)"
    raycastBtn.Font = Theme.FontTitle
    raycastBtn.TextSize = 12
    raycastBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    raycastBtn.BackgroundColor3 = Theme.AccentCyan
    raycastBtn.Size = UDim2.new(1, -24, 0, 38)
    raycastBtn.Position = UDim2.new(0, 12, 0, 42)
    Theme.AddCorner(raycastBtn, Theme.CornerSmall)
    Theme.AddGradient(raycastBtn, Theme.AccentCyan, Theme.AccentPrimary, 0)
    raycastBtn.Parent = scroll

    -- 2. Search by Name Textbox
    local searchBox = Instance.new("TextBox")
    searchBox.PlaceholderText = "Ou digite o nome: Ferrari, Gun, ShopGui, Map..."
    searchBox.Font = Theme.FontRegular
    searchBox.TextSize = 12
    searchBox.TextColor3 = Theme.TextPrimary
    searchBox.PlaceholderColor3 = Theme.TextMuted
    searchBox.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
    searchBox.Size = UDim2.new(1, -24, 0, 36)
    searchBox.Position = UDim2.new(0, 12, 0, 88)
    Theme.AddCorner(searchBox, Theme.CornerSmall)
    Theme.AddStroke(searchBox, Theme.Border, 1)
    searchBox.Parent = scroll

    -- 3. Selected Target Info Card
    local infoCard = Instance.new("Frame")
    infoCard.Size = UDim2.new(1, -24, 0, 90)
    infoCard.Position = UDim2.new(0, 12, 0, 132)
    infoCard.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
    Theme.AddCorner(infoCard, Theme.CornerSmall)
    Theme.AddStroke(infoCard, Theme.Border, 1)
    infoCard.Parent = scroll

    local targetTitle = Instance.new("TextLabel")
    targetTitle.Text = "Nenhum objeto selecionado no momento"
    targetTitle.Font = Theme.FontSemiBold
    targetTitle.TextSize = 12
    targetTitle.TextColor3 = Theme.TextPrimary
    targetTitle.TextXAlignment = Enum.TextXAlignment.Left
    targetTitle.Size = UDim2.new(1, -16, 0, 20)
    targetTitle.Position = UDim2.new(0, 10, 0, 8)
    targetTitle.BackgroundTransparency = 1
    targetTitle.Parent = infoCard

    local targetStats = Instance.new("TextLabel")
    targetStats.Text = "Mire no jogo com o botão acima ou digite o nome para inspecionar."
    targetStats.Font = Theme.FontRegular
    targetStats.TextSize = 11
    targetStats.TextColor3 = Theme.TextSecondary
    targetStats.TextXAlignment = Enum.TextXAlignment.Left
    targetStats.Size = UDim2.new(1, -16, 0, 20)
    targetStats.Position = UDim2.new(0, 10, 0, 32)
    targetStats.BackgroundTransparency = 1
    targetStats.Parent = infoCard

    local targetPath = Instance.new("TextLabel")
    targetPath.Text = "Caminho: -"
    targetPath.Font = Theme.FontRegular
    targetPath.TextSize = 10
    targetPath.TextColor3 = Theme.TextMuted
    targetPath.TextXAlignment = Enum.TextXAlignment.Left
    targetPath.Size = UDim2.new(1, -16, 0, 20)
    targetPath.Position = UDim2.new(0, 10, 0, 56)
    targetPath.BackgroundTransparency = 1
    targetPath.Parent = infoCard

    -- Helper to update info display
    local function inspectInstance(inst: Instance?)
        self.CurrentTargetInstance = inst
        if not inst then
            targetTitle.Text = "Nenhum objeto selecionado"
            targetTitle.TextColor3 = Theme.TextMuted
            targetStats.Text = "Use o botão 3D ou digite o nome acima."
            targetPath.Text = "Caminho: -"
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

        targetTitle.Text = string.format("📦 %s (%s)", inst.Name, inst.ClassName)
        targetTitle.TextColor3 = Theme.AccentCyan
        targetStats.Text = string.format("📊 %d Peças • %d Malhas 3D • %d Scripts Descompiláveis", parts, meshes, scripts)
        targetStats.TextColor3 = Theme.AccentSuccess
        targetPath.Text = "📍 Caminho: " .. inst:GetFullName()
    end

    -- 4. Action Buttons (Save Single / Add to Pack)
    local btnSaveSingle = Instance.new("TextButton")
    btnSaveSingle.Text = "💾 SALVAR ESTE MODELO (.rbxm)"
    btnSaveSingle.Font = Theme.FontTitle
    btnSaveSingle.TextSize = 12
    btnSaveSingle.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnSaveSingle.BackgroundColor3 = Theme.AccentSuccess
    btnSaveSingle.Size = UDim2.new(0.48, 0, 0, 38)
    btnSaveSingle.Position = UDim2.new(0, 12, 0, 230)
    Theme.AddCorner(btnSaveSingle, Theme.CornerSmall)
    btnSaveSingle.Parent = scroll

    local btnAddToPack = Instance.new("TextButton")
    btnAddToPack.Text = "➕ ADICIONAR AO PACOTE"
    btnAddToPack.Font = Theme.FontTitle
    btnAddToPack.TextSize = 12
    btnAddToPack.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnAddToPack.BackgroundColor3 = Theme.AccentPurple
    btnAddToPack.Size = UDim2.new(0.48, 0, 0, 38)
    btnAddToPack.Position = UDim2.new(0.52, 0, 0, 230)
    Theme.AddCorner(btnAddToPack, Theme.CornerSmall)
    btnAddToPack.Parent = scroll

    -- 5. Multi-Select Package Card
    local packCard = Instance.new("Frame")
    packCard.Size = UDim2.new(1, -24, 0, 110)
    packCard.Position = UDim2.new(0, 12, 0, 276)
    packCard.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
    Theme.AddCorner(packCard, Theme.CornerSmall)
    Theme.AddStroke(packCard, Theme.Border, 1)
    packCard.Parent = scroll

    local packTitle = Instance.new("TextLabel")
    packTitle.Text = "📦 PACOTE MULTI-SELEÇÃO: 0 ITENS"
    packTitle.Font = Theme.FontSemiBold
    packTitle.TextSize = 12
    packTitle.TextColor3 = Theme.AccentPurple
    packTitle.TextXAlignment = Enum.TextXAlignment.Left
    packTitle.Size = UDim2.new(0.7, 0, 0, 20)
    packTitle.Position = UDim2.new(0, 10, 0, 10)
    packTitle.BackgroundTransparency = 1
    packTitle.Parent = packCard

    local btnClearPack = Instance.new("TextButton")
    btnClearPack.Text = "Limpar"
    btnClearPack.Font = Theme.FontSemiBold
    btnClearPack.TextSize = 11
    btnClearPack.TextColor3 = Theme.AccentDanger
    btnClearPack.BackgroundColor3 = Color3.fromRGB(30, 20, 25)
    btnClearPack.Size = UDim2.new(0.24, 0, 0, 24)
    btnClearPack.Position = UDim2.new(0.73, 0, 0, 8)
    Theme.AddCorner(btnClearPack, Theme.CornerSmall)
    btnClearPack.Parent = packCard

    local btnSavePack = Instance.new("TextButton")
    btnSavePack.Text = "🚀 BAIXAR PACOTE COMPLETO (.rbxm)"
    btnSavePack.Font = Theme.FontTitle
    btnSavePack.TextSize = 12
    btnSavePack.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnSavePack.BackgroundColor3 = Theme.AccentPurple
    btnSavePack.Size = UDim2.new(1, -20, 0, 38)
    btnSavePack.Position = UDim2.new(0, 10, 0, 56)
    Theme.AddCorner(btnSavePack, Theme.CornerSmall)
    Theme.AddGradient(btnSavePack, Theme.AccentPurple, Theme.AccentCyan, 0)
    btnSavePack.Parent = packCard

    -- 6. Result & Status Label
    local resultLabel = Instance.new("TextLabel")
    resultLabel.Text = "Status: Pronto para selecionar."
    resultLabel.Font = Theme.FontRegular
    resultLabel.TextSize = 11
    resultLabel.TextColor3 = Theme.TextMuted
    resultLabel.TextXAlignment = Enum.TextXAlignment.Left
    resultLabel.Size = UDim2.new(1, -24, 0, 36)
    resultLabel.Position = UDim2.new(0, 12, 0, 396)
    resultLabel.TextWrapped = true
    resultLabel.BackgroundTransparency = 1
    resultLabel.Parent = scroll

    -- Update pack counter UI
    local function updatePackUI()
        packTitle.Text = string.format("📦 PACOTE MULTI-SELEÇÃO: %d ITENS", #self.SelectedTargets)
    end

    -- Event: 3D Raycast click button
    raycastBtn.MouseButton1Click:Connect(function()
        if self.MainFrame then self.MainFrame.Visible = false end
        resultLabel.Text = "🎯 Modo 3D ativo! Clique em qualquer objeto no mundo para selecionar."
        resultLabel.TextColor3 = Theme.AccentCyan

        self.Raycast:Start(function(selected)
            if self.MainFrame then self.MainFrame.Visible = true end
            if selected then
                searchBox.Text = selected.Name
                inspectInstance(selected)
                resultLabel.Text = "✓ Objeto selecionado: " .. selected.Name
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
                resultLabel.Text = "✓ Objeto encontrado: " .. found.Name
                resultLabel.TextColor3 = Theme.AccentSuccess
            else
                inspectInstance(nil)
                resultLabel.Text = "❌ Objeto não encontrado no jogo!"
                resultLabel.TextColor3 = Theme.AccentDanger
            end
        end
    end)

    -- Event: Save single model
    btnSaveSingle.MouseButton1Click:Connect(function()
        local target = self.CurrentTargetInstance
        if not target then
            resultLabel.Text = "❌ Selecione um modelo antes de salvar!"
            resultLabel.TextColor3 = Theme.AccentWarning
            return
        end

        resultLabel.Text = "⏳ Salvando " .. target.Name .. " com todos os scripts..."
        resultLabel.TextColor3 = Theme.AccentCyan

        task.spawn(function()
            local success, msg = self.Engine:SaveTarget(target)
            if success then
                resultLabel.Text = "✓ Modelo salvo com sucesso: " .. msg
                resultLabel.TextColor3 = Theme.AccentSuccess
                Environment.SetClipboard(msg)
            else
                resultLabel.Text = "❌ Erro ao salvar: " .. tostring(msg)
                resultLabel.TextColor3 = Theme.AccentDanger
            end
        end)
    end)

    -- Event: Add to pack
    btnAddToPack.MouseButton1Click:Connect(function()
        local target = self.CurrentTargetInstance
        if not target then
            resultLabel.Text = "❌ Selecione um modelo para adicionar ao pacote!"
            resultLabel.TextColor3 = Theme.AccentWarning
            return
        end

        table.insert(self.SelectedTargets, target)
        updatePackUI()
        resultLabel.Text = string.format("✓ '%s' adicionado ao pacote (%d no total)!", target.Name, #self.SelectedTargets)
        resultLabel.TextColor3 = Theme.AccentSuccess
    end)

    -- Event: Clear pack
    btnClearPack.MouseButton1Click:Connect(function()
        self.SelectedTargets = {}
        updatePackUI()
        resultLabel.Text = "Pacote limpo."
        resultLabel.TextColor3 = Theme.TextMuted
    end)

    -- Event: Save full multi-pack
    btnSavePack.MouseButton1Click:Connect(function()
        if #self.SelectedTargets == 0 then
            resultLabel.Text = "❌ O pacote está vazio! Adicione itens primeiro."
            resultLabel.TextColor3 = Theme.AccentWarning
            return
        end

        resultLabel.Text = string.format("⏳ Salvando pacote com %d itens e scripts...", #self.SelectedTargets)
        resultLabel.TextColor3 = Theme.AccentCyan

        task.spawn(function()
            local success, msg = self.Engine:SaveTargetBatch(self.SelectedTargets)
            if success then
                resultLabel.Text = "✓ Pacote salvo com sucesso: " .. msg
                resultLabel.TextColor3 = Theme.AccentSuccess
                Environment.SetClipboard(msg)
            else
                resultLabel.Text = "❌ Erro ao salvar pacote: " .. tostring(msg)
                resultLabel.TextColor3 = Theme.AccentDanger
            end
        end)
    end)
end

-- 3. Audio Ripper & Soundboard Tab
function Interface:BuildAudioRipperTab()
    local parent = self.TabFrames["AudioRipper"]

    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, -32, 0, 36)
    topBar.Position = UDim2.new(0, 16, 0, 12)
    topBar.BackgroundTransparency = 1
    topBar.Parent = parent

    local scanAudioBtn = Instance.new("TextButton")
    scanAudioBtn.Text = " ESCANEAR SONS DO JOGO"
    scanAudioBtn.Font = Theme.FontSemiBold
    scanAudioBtn.TextSize = 11
    scanAudioBtn.TextColor3 = Theme.AccentCyan
    scanAudioBtn.BackgroundColor3 = Theme.CardBg
    scanAudioBtn.Size = UDim2.new(0.48, 0, 1, 0)
    Theme.AddCorner(scanAudioBtn, Theme.CornerSmall)
    Theme.AddStroke(scanAudioBtn, Theme.Border, 1)
    scanAudioBtn.Parent = topBar

    local exportAudioListBtn = Instance.new("TextButton")
    exportAudioListBtn.Text = " EXPORTAR LISTA DE ÁUDIOS (.txt)"
    exportAudioListBtn.Font = Theme.FontSemiBold
    exportAudioListBtn.TextSize = 11
    exportAudioListBtn.TextColor3 = Theme.TextPrimary
    exportAudioListBtn.BackgroundColor3 = Theme.CardBg
    exportAudioListBtn.Size = UDim2.new(0.48, 0, 1, 0)
    exportAudioListBtn.Position = UDim2.new(0.52, 0, 0, 0)
    Theme.AddCorner(exportAudioListBtn, Theme.CornerSmall)
    Theme.AddStroke(exportAudioListBtn, Theme.Border, 1)
    exportAudioListBtn.Parent = topBar

    local audioScroll = Instance.new("ScrollingFrame")
    audioScroll.Size = UDim2.new(1, -32, 1, -64)
    audioScroll.Position = UDim2.new(0, 16, 0, 56)
    audioScroll.BackgroundColor3 = Color3.fromRGB(8, 10, 14)
    audioScroll.ScrollBarThickness = 4
    audioScroll.ScrollBarImageColor3 = Theme.Border
    Theme.AddCorner(audioScroll, Theme.CornerMedium)
    Theme.AddStroke(audioScroll, Theme.Border, 1)
    audioScroll.Parent = parent

    local audioLayout = Instance.new("UIListLayout")
    audioLayout.SortOrder = Enum.SortOrder.LayoutOrder
    audioLayout.Padding = UDim.new(0, 4)
    audioLayout.Parent = audioScroll

    scanAudioBtn.MouseButton1Click:Connect(function()
        scanAudioBtn.Text = " Escaneando..."
        for _, child in ipairs(audioScroll:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end

        task.spawn(function()
            local list = AudioRipper.ScanSounds()
            scanAudioBtn.Text = string.format("✓ %d sons encontrados", #list)

            for _, snd in ipairs(list) do
                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, -12, 0, 28)
                row.BackgroundColor3 = Theme.CardBg
                Theme.AddCorner(row, Theme.CornerSmall)
                row.Parent = audioScroll

                local sndLbl = Instance.new("TextLabel")
                sndLbl.Text = string.format(" %s (ID: %s)", snd.Name, snd.CleanId)
                sndLbl.Font = Theme.FontRegular
                sndLbl.TextSize = 10
                sndLbl.TextColor3 = Theme.TextPrimary
                sndLbl.TextXAlignment = Enum.TextXAlignment.Left
                sndLbl.Size = UDim2.new(0.65, 0, 1, 0)
                sndLbl.Position = UDim2.new(0, 8, 0, 0)
                sndLbl.BackgroundTransparency = 1
                sndLbl.Parent = row

                local playBtn = Instance.new("TextButton")
                playBtn.Text = " Play"
                playBtn.Font = Theme.FontSemiBold
                playBtn.TextSize = 10
                playBtn.TextColor3 = Theme.AccentSuccess
                playBtn.BackgroundColor3 = Theme.CardHover
                playBtn.Size = UDim2.new(0, 48, 0, 20)
                playBtn.Position = UDim2.new(1, -110, 0.5, -10)
                Theme.AddCorner(playBtn, Theme.CornerPill)
                playBtn.Parent = row

                playBtn.MouseButton1Click:Connect(function()
                    AudioRipper.PlayPreview(snd.SoundId)
                end)

                local copyBtn = Instance.new("TextButton")
                copyBtn.Text = "Copiar ID"
                copyBtn.Font = Theme.FontSemiBold
                copyBtn.TextSize = 9
                copyBtn.TextColor3 = Theme.TextSecondary
                copyBtn.BackgroundColor3 = Theme.CardHover
                copyBtn.Size = UDim2.new(0, 54, 0, 20)
                copyBtn.Position = UDim2.new(1, -58, 0.5, -10)
                Theme.AddCorner(copyBtn, Theme.CornerPill)
                copyBtn.Parent = row

                copyBtn.MouseButton1Click:Connect(function()
                    Environment.SetClipboard(snd.CleanId)
                    copyBtn.Text = "✓"
                    task.delay(1.5, function() copyBtn.Text = "Copiar ID" end)
                end)
            end

            audioScroll.CanvasSize = UDim2.new(0, 0, 0, #list * 32)
        end)
    end)

    exportAudioListBtn.MouseButton1Click:Connect(function()
        local file = AudioRipper.ExportSoundList()
        exportAudioListBtn.Text = "✓ Lista Exportada: " .. file
        Environment.SetClipboard(file)
        task.delay(2, function()
            exportAudioListBtn.Text = " EXPORTAR LISTA DE ÁUDIOS (.txt)"
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
    Theme.AddCorner(card, Theme.CornerMedium)
    Theme.AddStroke(card, Theme.Border, 1)
    card.Parent = parent

    local headerLbl = Instance.new("TextLabel")
    headerLbl.Text = " EXTRATOR DE ILUMINAÇÃO & ATMOSFERA"
    headerLbl.Font = Theme.FontTitle
    headerLbl.TextSize = 13
    headerLbl.TextColor3 = Theme.AccentCyan
    headerLbl.TextXAlignment = Enum.TextXAlignment.Left
    headerLbl.Size = UDim2.new(1, -24, 0, 24)
    headerLbl.Position = UDim2.new(0, 12, 0, 12)
    headerLbl.BackgroundTransparency = 1
    headerLbl.Parent = card

    local desc = Instance.new("TextLabel")
    desc.Text = "Extrai instantaneamente todas as propriedades visuais de iluminação, Skybox (todas as 6 texturas), Atmosphere (densidade, névoa e cores), SunRays, Bloom, Blur, ColorCorrection e DepthOfField para um arquivo separado (.rbxmx) que você pode colar em qualquer jogo seu!"
    desc.Font = Theme.FontRegular
    desc.TextSize = 11
    desc.TextColor3 = Theme.TextSecondary
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextYAlignment = Enum.TextYAlignment.Top
    desc.TextWrapped = true
    desc.Size = UDim2.new(1, -24, 0, 60)
    desc.Position = UDim2.new(0, 12, 0, 42)
    desc.BackgroundTransparency = 1
    desc.Parent = card

    local exportLightBtn = Instance.new("TextButton")
    exportLightBtn.Text = " SALVAR PRESET DE ILUMINAÇÃO (.rbxmx)"
    exportLightBtn.Font = Theme.FontTitle
    exportLightBtn.TextSize = 13
    exportLightBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    exportLightBtn.BackgroundColor3 = Theme.AccentCyan
    exportLightBtn.Size = UDim2.new(1, -24, 0, 48)
    exportLightBtn.Position = UDim2.new(0, 12, 0, 116)
    Theme.AddCorner(exportLightBtn, Theme.CornerMedium)
    Theme.AddGradient(exportLightBtn, Theme.AccentCyan, Theme.AccentPrimary, 90)
    exportLightBtn.Parent = card

    local lightStatus = Instance.new("TextLabel")
    lightStatus.Text = "Status: Pronto para salvar iluminação"
    lightStatus.Font = Theme.FontRegular
    lightStatus.TextSize = 11
    lightStatus.TextColor3 = Theme.TextMuted
    lightStatus.TextXAlignment = Enum.TextXAlignment.Left
    lightStatus.Size = UDim2.new(1, -24, 0, 24)
    lightStatus.Position = UDim2.new(0, 12, 0, 176)
    lightStatus.BackgroundTransparency = 1
    lightStatus.Parent = card

    exportLightBtn.MouseButton1Click:Connect(function()
        lightStatus.Text = " Extraindo efeitos e skyboxes..."
        lightStatus.TextColor3 = Theme.AccentCyan

        task.spawn(function()
            local success, file = LightingRipper.ExportLightingPreset()
            if success then
                lightStatus.Text = "✓ Iluminação salva com sucesso: " .. file
                lightStatus.TextColor3 = Theme.AccentSuccess
                Environment.SetClipboard(file)
            else
                lightStatus.Text = " Erro: " .. tostring(file)
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
    Theme.AddCorner(card, Theme.CornerMedium)
    Theme.AddStroke(card, Theme.Border, 1)
    card.Parent = parent

    local headerLbl = Instance.new("TextLabel")
    headerLbl.Text = " EXTRATOR DE INTERFACES (GUIs & HUDs)"
    headerLbl.Font = Theme.FontTitle
    headerLbl.TextSize = 13
    headerLbl.TextColor3 = Theme.AccentSecondary
    headerLbl.TextXAlignment = Enum.TextXAlignment.Left
    headerLbl.Size = UDim2.new(1, -24, 0, 24)
    headerLbl.Position = UDim2.new(0, 12, 0, 12)
    headerLbl.BackgroundTransparency = 1
    headerLbl.Parent = card

    local desc = Instance.new("TextLabel")
    desc.Text = "Extrai todas as ScreenGuis, Menus, Lojas, Inventários, Barras de Vida e HUDs com seus respectivos cantos arredondados (UICorner), gradientes (UIGradient) e scripts de interface para um pacote de UI independente (.rbxmx)!"
    desc.Font = Theme.FontRegular
    desc.TextSize = 11
    desc.TextColor3 = Theme.TextSecondary
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextYAlignment = Enum.TextYAlignment.Top
    desc.TextWrapped = true
    desc.Size = UDim2.new(1, -24, 0, 60)
    desc.Position = UDim2.new(0, 12, 0, 42)
    desc.BackgroundTransparency = 1
    desc.Parent = card

    local exportGuiBtn = Instance.new("TextButton")
    exportGuiBtn.Text = " SALVAR TODAS AS GUIs (.rbxmx)"
    exportGuiBtn.Font = Theme.FontTitle
    exportGuiBtn.TextSize = 13
    exportGuiBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    exportGuiBtn.BackgroundColor3 = Theme.AccentSecondary
    exportGuiBtn.Size = UDim2.new(1, -24, 0, 48)
    exportGuiBtn.Position = UDim2.new(0, 12, 0, 116)
    Theme.AddCorner(exportGuiBtn, Theme.CornerMedium)
    Theme.AddGradient(exportGuiBtn, Theme.AccentSecondary, Theme.AccentPrimary, 90)
    exportGuiBtn.Parent = card

    local guiStatus = Instance.new("TextLabel")
    guiStatus.Text = "Status: Pronto para salvar GUIs"
    guiStatus.Font = Theme.FontRegular
    guiStatus.TextSize = 11
    guiStatus.TextColor3 = Theme.TextMuted
    guiStatus.TextXAlignment = Enum.TextXAlignment.Left
    guiStatus.Size = UDim2.new(1, -24, 0, 24)
    guiStatus.Position = UDim2.new(0, 12, 0, 176)
    guiStatus.BackgroundTransparency = 1
    guiStatus.Parent = card

    exportGuiBtn.MouseButton1Click:Connect(function()
        guiStatus.Text = " Extraindo e descompilando interfaces..."
        guiStatus.TextColor3 = Theme.AccentCyan

        task.spawn(function()
            local success, file = GuiRipper.ExportAllGuis(self.Config)
            if success then
                guiStatus.Text = "✓ Pacote de GUIs salvo com sucesso: " .. file
                guiStatus.TextColor3 = Theme.AccentSuccess
                Environment.SetClipboard(file)
            else
                guiStatus.Text = " Erro: " .. tostring(file)
                guiStatus.TextColor3 = Theme.AccentDanger
            end
        end)
    end)
end

-- 6. Network Sniffer Tab
function Interface:BuildNetworkTab()
    local parent = self.TabFrames["Network"]

    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, -32, 0, 36)
    topBar.Position = UDim2.new(0, 16, 0, 12)
    topBar.BackgroundTransparency = 1
    topBar.Parent = parent

    local toggleSnifferBtn = Instance.new("TextButton")
    toggleSnifferBtn.Text = " INICIAR GRAVAÇÃO DE REDE"
    toggleSnifferBtn.Font = Theme.FontSemiBold
    toggleSnifferBtn.TextSize = 11
    toggleSnifferBtn.TextColor3 = Theme.AccentSuccess
    toggleSnifferBtn.BackgroundColor3 = Theme.CardBg
    toggleSnifferBtn.Size = UDim2.new(0.48, 0, 1, 0)
    Theme.AddCorner(toggleSnifferBtn, Theme.CornerSmall)
    Theme.AddStroke(toggleSnifferBtn, Theme.Border, 1)
    toggleSnifferBtn.Parent = topBar

    local exportSnifferBtn = Instance.new("TextButton")
    exportSnifferBtn.Text = " EXPORTAR PROTOCOLO (.json)"
    exportSnifferBtn.Font = Theme.FontSemiBold
    exportSnifferBtn.TextSize = 11
    exportSnifferBtn.TextColor3 = Theme.TextPrimary
    exportSnifferBtn.BackgroundColor3 = Theme.CardBg
    exportSnifferBtn.Size = UDim2.new(0.48, 0, 1, 0)
    exportSnifferBtn.Position = UDim2.new(0.52, 0, 0, 0)
    Theme.AddCorner(exportSnifferBtn, Theme.CornerSmall)
    Theme.AddStroke(exportSnifferBtn, Theme.Border, 1)
    exportSnifferBtn.Parent = topBar

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -32, 1, -64)
    scroll.Position = UDim2.new(0, 16, 0, 56)
    scroll.BackgroundColor3 = Color3.fromRGB(8, 10, 14)
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Theme.Border
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    Theme.AddCorner(scroll, Theme.CornerMedium)
    Theme.AddStroke(scroll, Theme.Border, 1)
    scroll.Parent = parent

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 4)
    layout.Parent = scroll

    toggleSnifferBtn.MouseButton1Click:Connect(function()
        if NetworkSniffer.IsActive then
            NetworkSniffer.Stop()
            toggleSnifferBtn.Text = " INICIAR GRAVAÇÃO DE REDE"
            toggleSnifferBtn.TextColor3 = Theme.AccentSuccess
        else
            NetworkSniffer.Start()
            toggleSnifferBtn.Text = " PARAR GRAVAÇÃO"
            toggleSnifferBtn.TextColor3 = Theme.AccentDanger
        end
    end)

    exportSnifferBtn.MouseButton1Click:Connect(function()
        local file = NetworkSniffer.ExportLogs()
        exportSnifferBtn.Text = "✓ Salvo: " .. file
        Environment.SetClipboard(file)
        task.delay(2, function()
            exportSnifferBtn.Text = " EXPORTAR PROTOCOLO (.json)"
        end)
    end)

    NetworkSniffer.OnCall(function(entry)
        local row = Instance.new("TextLabel")
        row.Text = string.format("[%s] [%s] %s -> %s", entry.Timestamp, entry.Type, entry.RemoteName, entry.ArgsPreview)
        row.Font = Theme.FontCode
        row.TextSize = 10
        row.TextColor3 = (entry.Type == "FireServer") and Theme.AccentCyan or Theme.AccentSecondary
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
    Theme.AddCorner(card, Theme.CornerMedium)
    Theme.AddStroke(card, Theme.Border, 1)
    card.Parent = parent

    local headerLbl = Instance.new("TextLabel")
    headerLbl.Text = " RASTREADOR DE UNIVERSO (MULTI-PLACES)"
    headerLbl.Font = Theme.FontTitle
    headerLbl.TextSize = 13
    headerLbl.TextColor3 = Theme.AccentSecondary
    headerLbl.TextXAlignment = Enum.TextXAlignment.Left
    headerLbl.Size = UDim2.new(1, -24, 0, 24)
    headerLbl.Position = UDim2.new(0, 12, 0, 12)
    headerLbl.BackgroundTransparency = 1
    headerLbl.Parent = card

    local scanBtn = Instance.new("TextButton")
    scanBtn.Text = " BUSCAR SUB-PLACES DO UNIVERSO"
    scanBtn.Font = Theme.FontSemiBold
    scanBtn.TextSize = 11
    scanBtn.TextColor3 = Theme.TextPrimary
    scanBtn.BackgroundColor3 = Theme.CardHover
    scanBtn.Size = UDim2.new(1, -24, 0, 34)
    scanBtn.Position = UDim2.new(0, 12, 0, 42)
    Theme.AddCorner(scanBtn, Theme.CornerSmall)
    Theme.AddStroke(scanBtn, Theme.Border, 1)
    scanBtn.Parent = card

    local placeScroll = Instance.new("ScrollingFrame")
    placeScroll.Size = UDim2.new(1, -24, 1, -94)
    placeScroll.Position = UDim2.new(0, 12, 0, 84)
    placeScroll.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
    placeScroll.ScrollBarThickness = 4
    placeScroll.ScrollBarImageColor3 = Theme.Border
    Theme.AddCorner(placeScroll, Theme.CornerSmall)
    Theme.AddStroke(placeScroll, Theme.Border, 1)
    placeScroll.Parent = card

    local placeLayout = Instance.new("UIListLayout")
    placeLayout.SortOrder = Enum.SortOrder.LayoutOrder
    placeLayout.Padding = UDim.new(0, 4)
    placeLayout.Parent = placeScroll

    scanBtn.MouseButton1Click:Connect(function()
        scanBtn.Text = " Buscando lugares do universo..."
        for _, child in ipairs(placeScroll:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end

        task.spawn(function()
            local list = UniverseTracker.GetUniversePlaces()
            scanBtn.Text = string.format("✓ %d lugares encontrados no Universo", #list)

            for idx, pInfo in ipairs(list) do
                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, -12, 0, 28)
                row.BackgroundColor3 = Theme.CardBg
                Theme.AddCorner(row, Theme.CornerSmall)
                row.Parent = placeScroll

                local pName = Instance.new("TextLabel")
                pName.Text = string.format("%s (ID: %d)", pInfo.Name, pInfo.PlaceId)
                pName.Font = Theme.FontRegular
                pName.TextSize = 11
                pName.TextColor3 = pInfo.IsRoot and Theme.AccentCyan or Theme.TextPrimary
                pName.TextXAlignment = Enum.TextXAlignment.Left
                pName.Size = UDim2.new(0.7, 0, 1, 0)
                pName.Position = UDim2.new(0, 8, 0, 0)
                pName.BackgroundTransparency = 1
                pName.Parent = row

                local copyIdBtn = Instance.new("TextButton")
                copyIdBtn.Text = "Copiar ID"
                copyIdBtn.Font = Theme.FontSemiBold
                copyIdBtn.TextSize = 10
                copyIdBtn.TextColor3 = Theme.TextSecondary
                copyIdBtn.BackgroundColor3 = Theme.CardHover
                copyIdBtn.Size = UDim2.new(0, 80, 0, 20)
                copyIdBtn.Position = UDim2.new(1, -88, 0.5, -10)
                Theme.AddCorner(copyIdBtn, Theme.CornerPill)
                copyIdBtn.Parent = row

                copyIdBtn.MouseButton1Click:Connect(function()
                    Environment.SetClipboard(tostring(pInfo.PlaceId))
                    copyIdBtn.Text = "✓ Copiado"
                    task.delay(1.5, function() copyIdBtn.Text = "Copiar ID" end)
                end)
            end

            placeScroll.CanvasSize = UDim2.new(0, 0, 0, #list * 34)
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
    Theme.AddCorner(card, Theme.CornerMedium)
    Theme.AddStroke(card, Theme.Border, 1)
    card.Parent = parent

    local headerLbl = Instance.new("TextLabel")
    headerLbl.Text = " EXPORTADOR 3D WAVEFRONT (.OBJ + .MTL)"
    headerLbl.Font = Theme.FontTitle
    headerLbl.TextSize = 13
    headerLbl.TextColor3 = Theme.AccentCyan
    headerLbl.TextXAlignment = Enum.TextXAlignment.Left
    headerLbl.Size = UDim2.new(1, -24, 0, 24)
    headerLbl.Position = UDim2.new(0, 12, 0, 12)
    headerLbl.BackgroundTransparency = 1
    headerLbl.Parent = card

    local desc = Instance.new("TextLabel")
    desc.Text = "Converte todos os blocos e modelos do mapa diretamente para arquivos .obj e .mtl com cores e materiais prontos para abrir no Blender, Cinema 4D, Maya, Unity ou Unreal Engine."
    desc.Font = Theme.FontRegular
    desc.TextSize = 11
    desc.TextColor3 = Theme.TextSecondary
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextYAlignment = Enum.TextYAlignment.Top
    desc.TextWrapped = true
    desc.Size = UDim2.new(1, -24, 0, 48)
    desc.Position = UDim2.new(0, 12, 0, 42)
    desc.BackgroundTransparency = 1
    desc.Parent = card

    local exportObjBtn = Instance.new("TextButton")
    exportObjBtn.Text = " EXPORTAR MAPA 3D (.OBJ + .MTL)"
    exportObjBtn.Font = Theme.FontTitle
    exportObjBtn.TextSize = 13
    exportObjBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    exportObjBtn.BackgroundColor3 = Theme.AccentCyan
    exportObjBtn.Size = UDim2.new(1, -24, 0, 48)
    exportObjBtn.Position = UDim2.new(0, 12, 0, 100)
    Theme.AddCorner(exportObjBtn, Theme.CornerMedium)
    Theme.AddGradient(exportObjBtn, Theme.AccentCyan, Theme.AccentPrimary, 90)
    exportObjBtn.Parent = card

    local objStatus = Instance.new("TextLabel")
    objStatus.Text = "Status: Pronto para exportar"
    objStatus.Font = Theme.FontRegular
    objStatus.TextSize = 11
    objStatus.TextColor3 = Theme.TextMuted
    objStatus.TextXAlignment = Enum.TextXAlignment.Left
    objStatus.Size = UDim2.new(1, -24, 0, 24)
    objStatus.Position = UDim2.new(0, 12, 0, 160)
    objStatus.BackgroundTransparency = 1
    objStatus.Parent = card

    exportObjBtn.MouseButton1Click:Connect(function()
        objStatus.Text = " Gerando geometria .obj e biblioteca de materiais .mtl..."
        objStatus.TextColor3 = Theme.AccentCyan

        task.spawn(function()
            local success, file = ObjExporter.Export(workspace)
            if success then
                objStatus.Text = "✓ Mapa 3D exportado com sucesso: " .. file
                objStatus.TextColor3 = Theme.AccentSuccess
                Environment.SetClipboard(file)
            else
                objStatus.Text = " Erro ao exportar 3D: " .. tostring(file)
                objStatus.TextColor3 = Theme.AccentDanger
            end
        end)
    end)
end

-- 9. Tutorial Tab (Built-in Step-by-Step Guide)
function Interface:BuildTutorialTab()
    local parent = self.TabFrames["Tutorial"]

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -24, 1, -24)
    scroll.Position = UDim2.new(0, 12, 0, 12)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Theme.Border
    scroll.CanvasSize = UDim2.new(0, 0, 0, 480)
    scroll.Parent = parent

    local steps = {
        {" Passo 1: Iniciar a Cópia", "Basta ir na aba ' Clonar Tudo' e clicar no botão roxo 'CLONAR JOGO INTEIRO'. O HyperSaveInstance vai começar a varrer o mapa."},
        {" Passo 2: Aguardar o Progresso", "A barra de progresso vai indicar o que está sendo salvo em tempo real: áudios, texturas, meshes 3D, terreno e scripts descompilados."},
        {" Passo 3: Onde o Arquivo Fica?", "O arquivo .rbxlx e a pasta de assets são salvos automaticamente dentro da pasta 'workspace' do seu executor no seu computador."},
        {" Passo 4: Como Abrir no Roblox Studio", "1. Abra o Roblox Studio.\n2. Clique em 'File' (Arquivo) -> 'Open from File...'\n3. Selecione o arquivo gerado e clique em Abrir.\n4. Pronto! O jogo inteiro abrirá 100% editável!"},
    }

    for i, step in ipairs(steps) do
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -12, 0, 80)
        card.Position = UDim2.new(0, 0, 0, (i - 1) * 88)
        card.BackgroundColor3 = Theme.CardBg
        Theme.AddCorner(card, Theme.CornerMedium)
        Theme.AddStroke(card, Theme.Border, 1)
        card.Parent = scroll

        local title = Instance.new("TextLabel")
        title.Text = step[1]
        title.Font = Theme.FontSemiBold
        title.TextSize = 12
        title.TextColor3 = Theme.AccentCyan
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Size = UDim2.new(1, -20, 0, 20)
        title.Position = UDim2.new(0, 10, 0, 8)
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
        desc.Size = UDim2.new(1, -20, 0, 46)
        desc.Position = UDim2.new(0, 10, 0, 30)
        desc.BackgroundTransparency = 1
        desc.Parent = card
    end

    -- Copy Universal Command Button
    local copyScriptCard = Instance.new("TextButton")
    copyScriptCard.Text = " Copiar Comando de Execução (loadstring) para a Área de Transferência"
    copyScriptCard.Font = Theme.FontSemiBold
    copyScriptCard.TextSize = 11
    copyScriptCard.TextColor3 = Theme.TextPrimary
    copyScriptCard.BackgroundColor3 = Theme.CardHover
    copyScriptCard.Size = UDim2.new(1, -12, 0, 36)
    copyScriptCard.Position = UDim2.new(0, 0, 0, 360)
    Theme.AddCorner(copyScriptCard, Theme.CornerSmall)
    Theme.AddStroke(copyScriptCard, Theme.AccentPrimary, 1)
    copyScriptCard.Parent = scroll

    copyScriptCard.MouseButton1Click:Connect(function()
        Environment.SetClipboard('loadstring(game:HttpGet("https://raw.githubusercontent.com/theopadilha2009-hash/HyperSaveInstance/main/dist/HyperSaveInstance.luau"))()')
        copyScriptCard.Text = "✓ Comando Copiado!"
        task.delay(2, function()
            copyScriptCard.Text = " Copiar Comando de Execução (loadstring) para a Área de Transferência"
        end)
    end)
end

-- 10. Settings Tab
function Interface:BuildSettingsTab()
    local parent = self.TabFrames["Settings"]

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -24, 1, -24)
    scroll.Position = UDim2.new(0, 12, 0, 12)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Theme.Border
    scroll.CanvasSize = UDim2.new(0, 0, 0, 720)
    scroll.Parent = parent

    local toggles = {
        {"AutoAntiAFK", "Proteção Anti-AFK (Evita Desconexão por Inatividade)", self.Config.AutoAntiAFK},
        {"AutoExploreStreaming", "Varrer Mapa Inteiro (Bypass de StreamingEnabled)", self.Config.AutoExploreStreaming},
        {"StealthMode", "Modo Furtivo (Proteção contra Anti-Cheats do Jogo)", self.Config.StealthMode},
        {"DownloadRawAssets", "Baixar Assets Brutos (.mp3, .png, .mesh) para Pasta Local", self.Config.DownloadRawAssets},
        {"OptimizeGeometry", "Otimizador de Arquivo (Deduplicação de Estruturas - Opcional)", self.Config.OptimizeGeometry},
        {"SaveTerrain", "Preservar Terreno Completo (Propriedades & Água)", self.Config.SaveTerrain},
        {"SaveTerrainVoxels", "Extrair SmoothVoxels do Terreno (3D Voxel Chunks)", self.Config.SaveTerrainVoxels},
        {"SaveLighting", "Preservar Iluminação, Céu & Efeitos de Atmosfera", self.Config.SaveLighting},
        {"SaveSounds", "Preservar Efeitos de Áudio, Reverbs & SoundGroups", self.Config.SaveSounds},
        {"SaveUnions", "Preservar CSG Unions & NegateOperations (Physics & ChildData)", self.Config.SaveUnions},
        {"SaveSurfaceAppearance", "Preservar Texturas PBR & SurfaceAppearances", self.Config.SaveSurfaceAppearance},
        {"DecompileScripts", "Descompilar Scripts (LocalScripts & ModuleScripts)", self.Config.DecompileScripts},
        {"IsolateStarterPlayer", "Extrair Scripts & GUIs Ativos do Jogador para o StarterPlayer/StarterGui", self.Config.IsolateStarterPlayer},
        {"SaveServerScriptPlaceholders", "Reconstrução Inteligente de Backend para Scripts de Servidor", self.Config.SaveServerScriptPlaceholders},
        {"SynthesizeServer", "Sintetizador Automático de Backend para Remotes", self.Config.SynthesizeServer},
        {"SaveNilInstances", "Salvar Instâncias Isoladas (Nil Instances)", self.Config.SaveNilInstances},
        {"SaveAttributes", "Salvar Atributos Modernos de Instância", self.Config.SaveAttributes},
        {"SaveTags", "Salvar Tags de CollectionService", self.Config.SaveTags},
    }

    for i, item in ipairs(toggles) do
        local key, title, defaultVal = item[1], item[2], item[3]

        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -12, 0, 32)
        row.Position = UDim2.new(0, 0, 0, (i - 1) * 38)
        row.BackgroundColor3 = Theme.CardBg
        Theme.AddCorner(row, Theme.CornerSmall)
        row.Parent = scroll

        local lbl = Instance.new("TextLabel")
        lbl.Text = title
        lbl.Font = Theme.FontRegular
        lbl.TextSize = 11
        lbl.TextColor3 = (key == "OptimizeGeometry") and Theme.AccentWarning or Theme.TextPrimary
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Size = UDim2.new(0.8, 0, 1, 0)
        lbl.Position = UDim2.new(0, 12, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Parent = row

        local switch = Instance.new("TextButton")
        switch.Text = defaultVal and "ATIVADO" or "DESATIVADO"
        switch.Font = Theme.FontSemiBold
        switch.TextSize = 10
        switch.TextColor3 = defaultVal and Theme.AccentSuccess or Theme.TextMuted
        switch.BackgroundColor3 = defaultVal and Color3.fromRGB(15, 45, 30) or Color3.fromRGB(30, 35, 45)
        switch.Size = UDim2.new(0, 80, 0, 22)
        switch.Position = UDim2.new(1, -90, 0.5, -11)
        Theme.AddCorner(switch, Theme.CornerPill)
        Theme.AddStroke(switch, defaultVal and Theme.AccentSuccess or Theme.Border, 1)
        switch.Parent = row

        switch.MouseButton1Click:Connect(function()
            local current = self.Config[key]
            local new = not current
            self.Config[key] = new
            switch.Text = new and "ATIVADO" or "DESATIVADO"
            switch.TextColor3 = new and Theme.AccentSuccess or Theme.TextMuted
            switch.BackgroundColor3 = new and Color3.fromRGB(15, 45, 30) or Color3.fromRGB(30, 35, 45)
            switch:FindFirstChildOfClass("UIStroke").Color = new and Theme.AccentSuccess or Theme.Border
            self:Log("Opção alterada: " .. key .. " = " .. tostring(new))
        end)
    end
end

-- 11. Console Tab
function Interface:BuildConsoleTab()
    local parent = self.TabFrames["Console"]

    local consoleBox = Instance.new("ScrollingFrame")
    consoleBox.Size = UDim2.new(1, -32, 1, -64)
    consoleBox.Position = UDim2.new(0, 16, 0, 16)
    consoleBox.BackgroundColor3 = Color3.fromRGB(8, 10, 14)
    consoleBox.ScrollBarThickness = 4
    consoleBox.ScrollBarImageColor3 = Theme.Border
    consoleBox.CanvasSize = UDim2.new(0, 0, 0, 0)
    Theme.AddCorner(consoleBox, Theme.CornerMedium)
    Theme.AddStroke(consoleBox, Theme.Border, 1)
    consoleBox.Parent = parent
    self.ConsoleScroll = consoleBox

    local consoleList = Instance.new("UIListLayout")
    consoleList.SortOrder = Enum.SortOrder.LayoutOrder
    consoleList.Padding = UDim.new(0, 4)
    consoleList.Parent = consoleBox

    local copyLogsBtn = Instance.new("TextButton")
    copyLogsBtn.Text = " Copiar Logs para Área de Transferência"
    copyLogsBtn.Font = Theme.FontSemiBold
    copyLogsBtn.TextSize = 11
    copyLogsBtn.TextColor3 = Theme.TextPrimary
    copyLogsBtn.BackgroundColor3 = Theme.CardBg
    copyLogsBtn.Size = UDim2.new(1, -32, 0, 32)
    copyLogsBtn.Position = UDim2.new(0, 16, 1, -40)
    Theme.AddCorner(copyLogsBtn, Theme.CornerSmall)
    Theme.AddStroke(copyLogsBtn, Theme.Border, 1)
    copyLogsBtn.Parent = parent

    copyLogsBtn.MouseButton1Click:Connect(function()
        local fullLog = table.concat(self.Logs, "\n")
        Environment.SetClipboard(fullLog)
        copyLogsBtn.Text = "✓ Logs Copiados!"
        task.delay(2, function()
            copyLogsBtn.Text = " Copiar Logs para Área de Transferência"
        end)
    end)
end

-- 12. About Tab
function Interface:BuildAboutTab()
    local parent = self.TabFrames["About"]

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -32, 1, -32)
    scroll.Position = UDim2.new(0, 16, 0, 16)
    scroll.BackgroundColor3 = Theme.BackgroundGlass
    scroll.ScrollBarThickness = 5
    scroll.CanvasSize = UDim2.new(0, 0, 0, 480)
    Theme.AddCorner(scroll, Theme.CornerMedium)
    Theme.AddStroke(scroll, Theme.BorderLight, 1)
    scroll.Parent = parent

    -- Developer Profile Header Card
    local devCard = Instance.new("Frame")
    devCard.Size = UDim2.new(1, -24, 0, 120)
    devCard.Position = UDim2.new(0, 12, 0, 12)
    devCard.BackgroundColor3 = Theme.CardBg
    Theme.AddCorner(devCard, Theme.CornerMedium)
    Theme.AddStroke(devCard, Theme.BorderNeon, 1.2)
    Theme.AddGradient(devCard, Theme.CardBg, Color3.fromRGB(24, 18, 38), 45)
    devCard.Parent = scroll

    -- Avatar Emblem
    local avatar = Instance.new("Frame")
    avatar.Size = UDim2.new(0, 56, 0, 56)
    avatar.Position = UDim2.new(0, 16, 0, 16)
    avatar.BackgroundColor3 = Theme.AccentPrimary
    Theme.AddCorner(avatar, Theme.CornerPill)
    Theme.AddGradient(avatar, Theme.AccentCyan, Theme.AccentTheo, 45)
    avatar.Parent = devCard

    local avatarTxt = Instance.new("TextLabel")
    avatarTxt.Text = "TLP"
    avatarTxt.Font = Theme.FontTitle
    avatarTxt.TextSize = 18
    avatarTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
    avatarTxt.Size = UDim2.new(1, 0, 1, 0)
    avatarTxt.BackgroundTransparency = 1
    avatarTxt.Parent = avatar

    -- Developer Name & Title
    local devName = Instance.new("TextLabel")
    devName.Text = "Theo Lorentz Padilha"
    devName.Font = Theme.FontTitle
    devName.TextSize = 16
    devName.TextColor3 = Theme.TextPrimary
    devName.TextXAlignment = Enum.TextXAlignment.Left
    devName.Size = UDim2.new(1, -96, 0, 22)
    devName.Position = UDim2.new(0, 84, 0, 16)
    devName.BackgroundTransparency = 1
    devName.Parent = devCard

    local devRole = Instance.new("TextLabel")
    devRole.Text = "⭐ Criador & Engenheiro Principal do HyperSaveInstance Suite"
    devRole.Font = Theme.FontSemiBold
    devRole.TextSize = 11
    devRole.TextColor3 = Theme.TextTheo
    devRole.TextXAlignment = Enum.TextXAlignment.Left
    devRole.Size = UDim2.new(1, -96, 0, 18)
    devRole.Position = UDim2.new(0, 84, 0, 38)
    devRole.BackgroundTransparency = 1
    devRole.Parent = devCard

    -- GitHub Link Button
    local btnGithub = Instance.new("TextButton")
    btnGithub.Text = "🔗 Copiar Perfil GitHub (github.com/theopadilha2009-hash)"
    btnGithub.Font = Theme.FontSemiBold
    btnGithub.TextSize = 11
    btnGithub.TextColor3 = Theme.TextPrimary
    btnGithub.BackgroundColor3 = Color3.fromRGB(16, 20, 32)
    btnGithub.Size = UDim2.new(0.58, 0, 0, 30)
    btnGithub.Position = UDim2.new(0, 84, 0, 68)
    Theme.AddCorner(btnGithub, Theme.CornerSmall)
    Theme.AddStroke(btnGithub, Theme.BorderNeon, 1)
    btnGithub.Parent = devCard

    btnGithub.MouseButton1Click:Connect(function()
        Environment.SetClipboard("https://github.com/theopadilha2009-hash")
        btnGithub.Text = "✓ Link do GitHub Copiado!"
        btnGithub.TextColor3 = Theme.AccentSuccess
        task.delay(2.5, function()
            btnGithub.Text = "🔗 Copiar Perfil GitHub (github.com/theopadilha2009-hash)"
            btnGithub.TextColor3 = Theme.TextPrimary
        end)
    end)

    -- Repository Link Button
    local btnRepo = Instance.new("TextButton")
    btnRepo.Text = "⭐ Repositório Oficial"
    btnRepo.Font = Theme.FontSemiBold
    btnRepo.TextSize = 11
    btnRepo.TextColor3 = Theme.TextPrimary
    btnRepo.BackgroundColor3 = Color3.fromRGB(16, 20, 32)
    btnRepo.Size = UDim2.new(0.35, -4, 0, 30)
    btnRepo.Position = UDim2.new(0.62, 2, 0, 68)
    Theme.AddCorner(btnRepo, Theme.CornerSmall)
    Theme.AddStroke(btnRepo, Theme.AccentPrimary, 1)
    btnRepo.Parent = devCard

    btnRepo.MouseButton1Click:Connect(function()
        Environment.SetClipboard("https://github.com/theopadilha2009-hash/HyperSaveInstance")
        btnRepo.Text = "✓ Link do Repo Copiado!"
        btnRepo.TextColor3 = Theme.AccentSuccess
        task.delay(2.5, function()
            btnRepo.Text = "⭐ Repositório Oficial"
            btnRepo.TextColor3 = Theme.TextPrimary
        end)
    end)

    -- System Diagnostics Card
    local sysCard = Instance.new("Frame")
    sysCard.Size = UDim2.new(1, -24, 0, 180)
    sysCard.Position = UDim2.new(0, 12, 0, 142)
    sysCard.BackgroundColor3 = Theme.CardBg
    Theme.AddCorner(sysCard, Theme.CornerMedium)
    Theme.AddStroke(sysCard, Theme.Border, 1)
    sysCard.Parent = scroll

    local sysTitle = Instance.new("TextLabel")
    sysTitle.Text = "📊 DIAGNÓSTICO DO SISTEMA & AMBIENTE"
    sysTitle.Font = Theme.FontTitle
    sysTitle.TextSize = 12
    sysTitle.TextColor3 = Theme.AccentCyan
    sysTitle.TextXAlignment = Enum.TextXAlignment.Left
    sysTitle.Size = UDim2.new(1, -20, 0, 20)
    sysTitle.Position = UDim2.new(0, 12, 0, 10)
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
        row.Position = UDim2.new(0, 12, 0, 32 + (i - 1) * 20)
        row.BackgroundTransparency = 1
        row.Parent = sysCard

        local lblKey = Instance.new("TextLabel")
        lblKey.Text = "• " .. item[1]
        lblKey.Font = Theme.FontSemiBold
        lblKey.TextSize = 11
        lblKey.TextColor3 = Theme.TextSecondary
        lblKey.TextXAlignment = Enum.TextXAlignment.Left
        lblKey.Size = UDim2.new(0.5, 0, 1, 0)
        lblKey.BackgroundTransparency = 1
        lblKey.Parent = row

        local lblVal = Instance.new("TextLabel")
        lblVal.Text = item[2]
        lblVal.Font = Theme.FontRegular
        lblVal.TextSize = 11
        lblVal.TextColor3 = (string.find(item[2], "Ativo") or string.find(item[2], "Suportado")) and Theme.AccentSuccess or Theme.TextPrimary
        lblVal.TextXAlignment = Enum.TextXAlignment.Right
        lblVal.Size = UDim2.new(0.5, 0, 1, 0)
        lblVal.Position = UDim2.new(0.5, 0, 0, 0)
        lblVal.BackgroundTransparency = 1
        lblVal.Parent = row
    end

    -- Suite Capabilities Summary Card
    local featCard = Instance.new("Frame")
    featCard.Size = UDim2.new(1, -24, 0, 120)
    featCard.Position = UDim2.new(0, 12, 0, 332)
    featCard.BackgroundColor3 = Theme.CardBg
    Theme.AddCorner(featCard, Theme.CornerMedium)
    Theme.AddStroke(featCard, Theme.Border, 1)
    featCard.Parent = scroll

    local featTitle = Instance.new("TextLabel")
    featTitle.Text = "⚡ RECURSOS EXCLUSIVOS INCLUÍDOS"
    featTitle.Font = Theme.FontTitle
    featTitle.TextSize = 12
    featTitle.TextColor3 = Theme.AccentPurple
    featTitle.TextXAlignment = Enum.TextXAlignment.Left
    featTitle.Size = UDim2.new(1, -20, 0, 20)
    featTitle.Position = UDim2.new(0, 12, 0, 10)
    featTitle.BackgroundTransparency = 1
    featTitle.Parent = featCard

    local featDesc = Instance.new("TextLabel")
    featDesc.Text = "✓ Seletor 3D com Mira no Mundo & Multi-Seleção em Lote\n✓ Extração de Terreno SmoothVoxels 3D, Iluminação PBR & Sons\n✓ Plugin Oficial de Roblox Studio com Reparo Mestre 1-Clique\n✓ Desofuscador de Variáveis de Scripts e Proteção Anti-AFK"
    featDesc.Font = Theme.FontRegular
    featDesc.TextSize = 11
    featDesc.TextColor3 = Theme.TextSecondary
    featDesc.TextXAlignment = Enum.TextXAlignment.Left
    featDesc.TextYAlignment = Enum.TextYAlignment.Top
    featDesc.Size = UDim2.new(1, -24, 0, 75)
    featDesc.Position = UDim2.new(0, 12, 0, 34)
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
        lbl.Font = Theme.FontCode
        lbl.TextSize = 11
        lbl.TextColor3 = color or Theme.TextSecondary
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Size = UDim2.new(1, -12, 0, 16)
        lbl.BackgroundTransparency = 1
        lbl.Parent = self.ConsoleScroll

        self.ConsoleScroll.CanvasSize = UDim2.new(0, 0, 0, #self.Logs * 20)
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
                self.CloneButton.Text = "✓ CLONADO COM SUCESSO!"
                Theme.AddGradient(self.CloneButton, Theme.AccentSuccess, Color3.fromRGB(16, 185, 129), 90)
                task.delay(4, function()
                    self.CloneButton.Text = " CLONAR JOGO INTEIRO (1-CLIQUE)"
                    Theme.AddGradient(self.CloneButton, Theme.AccentPrimary, Theme.AccentSecondary, 90)
                end)
            end
        elseif prog.Stage == "Error" then
            color = Theme.AccentDanger
        elseif prog.Stage == "Exploring" then
            color = Theme.AccentWarning
        elseif prog.Stage == "Assets" then
            color = Theme.AccentWarning
        elseif prog.Stage == "Decompiling" then
            color = Theme.AccentCyan
        end

        self:Log(prog.Message, color)
    end)
end

function Interface:StartClone()
    if self.Engine.IsRunning then
        return
    end

    if self.CloneButton then
        self.CloneButton.Text = " CLONANDO JOGO..."
    end

    task.spawn(function()
        local success, result = self.Engine:Start()
        if not success then
            self:Log("Erro ao salvar: " .. tostring(result), Theme.AccentDanger)
        end
    end)
end

return Interface
