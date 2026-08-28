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
    floatingBtn.TextColor3 = Theme.AccentSkull
    floatingBtn.BackgroundColor3 = Theme.CardBg
    floatingBtn.Size = UDim2.new(0, 154, 0, 36)
    floatingBtn.Position = UDim2.new(0, 20, 0, 20)
    floatingBtn.Visible = false
    Theme.AddCorner(floatingBtn, Theme.CornerPill)
    Theme.AddStroke(floatingBtn, Theme.BorderNeon, 1.5)
    Theme.AddGradient(floatingBtn, Color3.fromRGB(16, 12, 28), Color3.fromRGB(48, 28, 78), 45)
    floatingBtn.Parent = screenGui
    self.FloatingToggle = floatingBtn

    Theme.AnimateButton(floatingBtn, function()
        if self.MainFrame then self.MainFrame.Visible = true end
        floatingBtn.Visible = false
    end)

    -- Main Container (Translucent Acrylic Bubble Theme)
    local main = Instance.new("Frame")
    main.Name = "MainFrame"
    main.Size = UDim2.new(0, 660, 0, 480)
    main.Position = UDim2.new(0.5, -330, 0.5, -240)
    main.BackgroundColor3 = Theme.Background
    main.BackgroundTransparency = Theme.BackgroundTransparency
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    Theme.AddCorner(main, Theme.CornerLarge)
    Theme.AddStroke(main, Theme.BorderLight, 1.5)
    main.Parent = screenGui
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

    -- Top Header Bar
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 48)
    header.BackgroundColor3 = Theme.CardBg
    header.BackgroundTransparency = Theme.CardTransparency
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
    titleLabel.TextSize = 14
    titleLabel.TextColor3 = Theme.AccentSkull
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Size = UDim2.new(0, 175, 1, 0)
    titleLabel.Position = UDim2.new(0, 16, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Parent = header

    -- Platform & Creator Badge (Pill Badge)
    local badge = Instance.new("TextLabel")
    badge.Text = "por Theo Lorentz Padilha • [RightShift]"
    badge.Font = Theme.FontSemiBold
    badge.TextSize = 11
    badge.TextColor3 = Theme.AccentTheo
    badge.BackgroundColor3 = Color3.fromRGB(20, 15, 34)
    badge.Size = UDim2.new(0, 230, 0, 26)
    badge.Position = UDim2.new(0, 195, 0.5, -13)
    Theme.AddCorner(badge, Theme.CornerPill)
    Theme.AddStroke(badge, Theme.BorderNeon, 1)
    badge.Parent = header

    -- Minimize Button (Bubble Pill)
    local minBtn = Instance.new("TextButton")
    minBtn.Text = "–"
    minBtn.Font = Theme.FontTitle
    minBtn.TextSize = 14
    minBtn.TextColor3 = Theme.TextSecondary
    minBtn.BackgroundColor3 = Theme.CardHover
    minBtn.Size = UDim2.new(0, 28, 0, 28)
    minBtn.Position = UDim2.new(1, -70, 0.5, -14)
    Theme.AddCorner(minBtn, Theme.CornerPill)
    minBtn.Parent = header

    Theme.AnimateButton(minBtn, function()
        main.Visible = false
        floatingBtn.Visible = true
    end)

    -- Close Button (Bubble Pill)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "✕"
    closeBtn.Font = Theme.FontTitle
    closeBtn.TextSize = 14
    closeBtn.TextColor3 = Theme.TextSecondary
    closeBtn.BackgroundColor3 = Theme.CardHover
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -38, 0.5, -14)
    Theme.AddCorner(closeBtn, Theme.CornerPill)
    closeBtn.Parent = header

    Theme.AnimateButton(closeBtn, function()
        screenGui:Destroy()
    end)

    -- Tab Navigation Bar (Scrollable for all master tools)
    local navBar = Instance.new("ScrollingFrame")
    navBar.Name = "NavBar"
    navBar.Size = UDim2.new(0, 148, 1, -48)
    navBar.Position = UDim2.new(0, 0, 0, 48)
    navBar.BackgroundColor3 = Theme.CardBg
    navBar.BackgroundTransparency = Theme.CardTransparency
    navBar.ScrollBarThickness = 3
    navBar.ScrollBarImageColor3 = Theme.BorderLight
    navBar.CanvasSize = UDim2.new(0, 0, 0, 420)
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
    contentArea.Size = UDim2.new(1, -148, 1, -48)
    contentArea.Position = UDim2.new(0, 148, 0, 48)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = main
    self.ContentArea = contentArea

    -- Navigation buttons
    local tabs = {
        {"Dashboard", "🚀 Clonar Tudo"},
        {"Selector", "🎯 Salvar Modelo"},
        {"AudioRipper", "🎵 Músicas & Sons"},
        {"LightingRipper", "✨ Iluminação"},
        {"GuiRipper", "🖥️ Interfaces (UI)"},
        {"Network", "📡 Rede / Remotes"},
        {"Universe", "🌌 Universo"},
        {"ObjExport", "🧊 Exportar 3D"},
        {"Tutorial", "📖 Como Usar"},
        {"Settings", "⚙️ Configurações"},
        {"Console", "💻 Console"},
        {"About", "👑 Informações"}
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
        navBtn.BackgroundTransparency = (i == 1) and 0 or 0.4
        navBtn.Size = UDim2.new(1, -14, 0, 28)
        navBtn.Position = UDim2.new(0, 7, 0, 7 + (i - 1) * 33)
        Theme.AddCorner(navBtn, Theme.CornerMedium)
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

        Theme.AnimateButton(navBtn, function()
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
            btn.BackgroundTransparency = 0
            if stroke then stroke.Color = Theme.BorderNeon end
        else
            btn.TextColor3 = Theme.TextSecondary
            btn.BackgroundColor3 = Theme.CardBg
            btn.BackgroundTransparency = 0.4
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
    presetContainer.Size = UDim2.new(1, -32, 0, 36)
    presetContainer.Position = UDim2.new(0, 16, 0, 96)
    presetContainer.BackgroundTransparency = 1
    presetContainer.Parent = parent

    local presetLayout = Instance.new("UIListLayout")
    presetLayout.FillDirection = Enum.FillDirection.Horizontal
    presetLayout.Padding = UDim.new(0, 8)
    presetLayout.SortOrder = Enum.SortOrder.LayoutOrder
    presetLayout.Parent = presetContainer

    local presetList = {"Full", "Fast", "VisualsOnly", "ScriptsOnly"}
    local presetDisplay = {
        Full = "⭐ Completo 10/10",
        Fast = "⚡ Rápido",
        VisualsOnly = "🎨 Apenas Visual",
        ScriptsOnly = "📜 Apenas Scripts"
    }

    self.PresetButtons = {}
    for i, pKey in ipairs(presetList) do
        local btn = Instance.new("TextButton")
        btn.Text = presetDisplay[pKey]
        btn.Font = Theme.FontSemiBold
        btn.TextSize = 10
        btn.TextColor3 = (self.Config.Mode == pKey) and Theme.AccentSkull or Theme.TextSecondary
        btn.BackgroundColor3 = (self.Config.Mode == pKey) and Theme.CardActive or Theme.CardBg
        btn.BackgroundTransparency = (self.Config.Mode == pKey) and 0 or Theme.CardTransparency
        btn.Size = UDim2.new(0.25, -6, 1, 0)
        btn.LayoutOrder = i
        Theme.AddCorner(btn, Theme.CornerSmall)
        Theme.AddStroke(btn, (self.Config.Mode == pKey) and Theme.BorderNeon or Theme.Border, 1)
        btn.Parent = presetContainer
        self.PresetButtons[pKey] = btn

        Theme.AnimateButton(btn, function()
            Defaults.ApplyPreset(self.Config, pKey)
            for k, b in pairs(self.PresetButtons) do
                local stroke = b:FindFirstChildOfClass("UIStroke")
                if k == pKey then
                    b.TextColor3 = Theme.AccentSkull
                    b.BackgroundColor3 = Theme.CardActive
                    b.BackgroundTransparency = 0
                    if stroke then stroke.Color = Theme.BorderNeon end
                else
                    b.TextColor3 = Theme.TextSecondary
                    b.BackgroundColor3 = Theme.CardBg
                    b.BackgroundTransparency = Theme.CardTransparency
                    if stroke then stroke.Color = Theme.Border end
                end
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
    formatLabel.Position = UDim2.new(0, 16, 0, 142)
    formatLabel.BackgroundTransparency = 1
    formatLabel.Parent = parent

    local formatContainer = Instance.new("Frame")
    formatContainer.Size = UDim2.new(1, -32, 0, 32)
    formatContainer.Position = UDim2.new(0, 16, 0, 162)
    formatContainer.BackgroundTransparency = 1
    formatContainer.Parent = parent

    local formatLayout = Instance.new("UIListLayout")
    formatLayout.FillDirection = Enum.FillDirection.Horizontal
    formatLayout.Padding = UDim.new(0, 8)
    formatLayout.SortOrder = Enum.SortOrder.LayoutOrder
    formatLayout.Parent = formatContainer

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
        fBtn.TextSize = 10
        fBtn.TextColor3 = (self.Config.Format == fKey) and Theme.AccentSkull or Theme.TextSecondary
        fBtn.BackgroundColor3 = (self.Config.Format == fKey) and Theme.CardActive or Theme.CardBg
        fBtn.BackgroundTransparency = (self.Config.Format == fKey) and 0 or Theme.CardTransparency
        fBtn.Size = UDim2.new(0.333, -6, 1, 0)
        fBtn.LayoutOrder = i
        Theme.AddCorner(fBtn, Theme.CornerSmall)
        Theme.AddStroke(fBtn, (self.Config.Format == fKey) and Theme.BorderNeon or Theme.Border, 1)
        fBtn.Parent = formatContainer
        self.FormatButtons[fKey] = fBtn

        Theme.AnimateButton(fBtn, function()
            self.Config.Format = fKey
            for k, b in pairs(self.FormatButtons) do
                local stroke = b:FindFirstChildOfClass("UIStroke")
                if k == fKey then
                    b.TextColor3 = Theme.AccentSkull
                    b.BackgroundColor3 = Theme.CardActive
                    b.BackgroundTransparency = 0
                    if stroke then stroke.Color = Theme.BorderNeon end
                else
                    b.TextColor3 = Theme.TextSecondary
                    b.BackgroundColor3 = Theme.CardBg
                    b.BackgroundTransparency = Theme.CardTransparency
                    if stroke then stroke.Color = Theme.Border end
                end
            end
            self:Log("Formato definido para: ." .. fKey)
        end)
    end

    -- Progress Container (Frosted Glass Acrylic Card)
    local progressCard = Instance.new("Frame")
    progressCard.Size = UDim2.new(1, -32, 0, 106)
    progressCard.Position = UDim2.new(0, 16, 0, 204)
    progressCard.BackgroundColor3 = Theme.CardBg
    progressCard.BackgroundTransparency = Theme.CardTransparency
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
    scroll.BackgroundTransparency = Theme.CardTransparency
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Theme.BorderLight
    scroll.CanvasSize = UDim2.new(0, 0, 0, 520)
    Theme.AddCorner(scroll, Theme.CornerLarge)
    Theme.AddStroke(scroll, Theme.Border, 1)
    scroll.Parent = parent

    local headerLbl = Instance.new("TextLabel")
    headerLbl.Text = "🎯 SELETOR DE MODELOS & MULTI-SELEÇÃO"
    headerLbl.Font = Theme.FontTitle
    headerLbl.TextSize = 13
    headerLbl.TextColor3 = Theme.AccentCyan
    headerLbl.TextXAlignment = Enum.TextXAlignment.Left
    headerLbl.Size = UDim2.new(1, -24, 0, 24)
    headerLbl.Position = UDim2.new(0, 12, 0, 12)
    headerLbl.BackgroundTransparency = 1
    headerLbl.Parent = scroll

    -- 1. In-World 3D Raycast Click Selector Button (Bubble Button)
    local raycastBtn = Instance.new("TextButton")
    raycastBtn.Text = "🎯 CLICAR NO OBJETO NO MUNDO 3D (SELETOR VISUAL)"
    raycastBtn.Font = Theme.FontTitle
    raycastBtn.TextSize = 11
    raycastBtn.TextColor3 = Theme.AccentSkull
    raycastBtn.BackgroundColor3 = Theme.AccentPrimary
    raycastBtn.Size = UDim2.new(1, -24, 0, 38)
    raycastBtn.Position = UDim2.new(0, 12, 0, 42)
    Theme.AddCorner(raycastBtn, Theme.CornerMedium)
    Theme.AddStroke(raycastBtn, Theme.BorderNeon, 1.5)
    Theme.AddGradient(raycastBtn, Color3.fromRGB(147, 51, 234), Color3.fromRGB(88, 28, 135), 45)
    raycastBtn.Parent = scroll

    -- 2. Search by Name Textbox
    local searchBox = Instance.new("TextBox")
    searchBox.PlaceholderText = "Ou digite o nome: Ferrari, Gun, ShopGui, Map..."
    searchBox.Font = Theme.FontRegular
    searchBox.TextSize = 11
    searchBox.TextColor3 = Theme.TextPrimary
    searchBox.PlaceholderColor3 = Theme.TextMuted
    searchBox.BackgroundColor3 = Color3.fromRGB(10, 8, 16)
    searchBox.Size = UDim2.new(1, -24, 0, 36)
    searchBox.Position = UDim2.new(0, 12, 0, 88)
    Theme.AddCorner(searchBox, Theme.CornerSmall)
    Theme.AddStroke(searchBox, Theme.Border, 1)
    searchBox.Parent = scroll

    -- 3. Selected Target Info Card (Frosted Acrylic)
    local infoCard = Instance.new("Frame")
    infoCard.Size = UDim2.new(1, -24, 0, 88)
    infoCard.Position = UDim2.new(0, 12, 0, 132)
    infoCard.BackgroundColor3 = Color3.fromRGB(12, 9, 20)
    infoCard.BackgroundTransparency = 0.3
    Theme.AddCorner(infoCard, Theme.CornerMedium)
    Theme.AddStroke(infoCard, Theme.Border, 1)
    infoCard.Parent = scroll

    local targetTitle = Instance.new("TextLabel")
    targetTitle.Text = "Nenhum objeto selecionado no momento"
    targetTitle.Font = Theme.FontSemiBold
    targetTitle.TextSize = 11
    targetTitle.TextColor3 = Theme.TextPrimary
    targetTitle.TextXAlignment = Enum.TextXAlignment.Left
    targetTitle.Size = UDim2.new(1, -20, 0, 20)
    targetTitle.Position = UDim2.new(0, 10, 0, 8)
    targetTitle.BackgroundTransparency = 1
    targetTitle.Parent = infoCard

    local targetStats = Instance.new("TextLabel")
    targetStats.Text = "Mire no jogo com o botão acima ou digite o nome para inspecionar."
    targetStats.Font = Theme.FontRegular
    targetStats.TextSize = 10
    targetStats.TextColor3 = Theme.TextSecondary
    targetStats.TextXAlignment = Enum.TextXAlignment.Left
    targetStats.Size = UDim2.new(1, -20, 0, 20)
    targetStats.Position = UDim2.new(0, 10, 0, 32)
    targetStats.BackgroundTransparency = 1
    targetStats.Parent = infoCard

    local targetPath = Instance.new("TextLabel")
    targetPath.Text = "Caminho: -"
    targetPath.Font = Theme.FontRegular
    targetPath.TextSize = 10
    targetPath.TextColor3 = Theme.TextMuted
    targetPath.TextXAlignment = Enum.TextXAlignment.Left
    targetPath.Size = UDim2.new(1, -20, 0, 20)
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

    -- 4. Action Buttons Container (UIListLayout Pixel-Perfect Horizontal Grid)
    local actionBtnContainer = Instance.new("Frame")
    actionBtnContainer.Size = UDim2.new(1, -24, 0, 38)
    actionBtnContainer.Position = UDim2.new(0, 12, 0, 228)
    actionBtnContainer.BackgroundTransparency = 1
    actionBtnContainer.Parent = scroll

    local actionLayout = Instance.new("UIListLayout")
    actionLayout.FillDirection = Enum.FillDirection.Horizontal
    actionLayout.Padding = UDim.new(0, 8)
    actionLayout.SortOrder = Enum.SortOrder.LayoutOrder
    actionLayout.Parent = actionBtnContainer

    local btnSaveSingle = Instance.new("TextButton")
    btnSaveSingle.Text = "💾 SALVAR ESTE MODELO (.rbxm)"
    btnSaveSingle.Font = Theme.FontTitle
    btnSaveSingle.TextSize = 11
    btnSaveSingle.TextColor3 = Theme.AccentSkull
    btnSaveSingle.BackgroundColor3 = Theme.AccentPrimary
    btnSaveSingle.Size = UDim2.new(0.5, -4, 1, 0)
    btnSaveSingle.LayoutOrder = 1
    Theme.AddCorner(btnSaveSingle, Theme.CornerMedium)
    Theme.AddStroke(btnSaveSingle, Theme.BorderNeon, 1)
    btnSaveSingle.Parent = actionBtnContainer

    local btnAddToPack = Instance.new("TextButton")
    btnAddToPack.Text = "➕ ADICIONAR AO PACOTE"
    btnAddToPack.Font = Theme.FontTitle
    btnAddToPack.TextSize = 11
    btnAddToPack.TextColor3 = Theme.AccentSkull
    btnAddToPack.BackgroundColor3 = Theme.CardActive
    btnAddToPack.Size = UDim2.new(0.5, -4, 1, 0)
    btnAddToPack.LayoutOrder = 2
    Theme.AddCorner(btnAddToPack, Theme.CornerMedium)
    Theme.AddStroke(btnAddToPack, Theme.BorderLight, 1)
    btnAddToPack.Parent = actionBtnContainer

    -- 5. Multi-Select Package Card (Frosted Acrylic)
    local packCard = Instance.new("Frame")
    packCard.Size = UDim2.new(1, -24, 0, 110)
    packCard.Position = UDim2.new(0, 12, 0, 274)
    packCard.BackgroundColor3 = Color3.fromRGB(12, 9, 20)
    packCard.BackgroundTransparency = 0.3
    Theme.AddCorner(packCard, Theme.CornerMedium)
    Theme.AddStroke(packCard, Theme.Border, 1)
    packCard.Parent = scroll

    local packTitle = Instance.new("TextLabel")
    packTitle.Text = "📦 PACOTE MULTI-SELEÇÃO: 0 ITENS"
    packTitle.Font = Theme.FontSemiBold
    packTitle.TextSize = 11
    packTitle.TextColor3 = Theme.AccentCyan
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
    btnClearPack.BackgroundColor3 = Color3.fromRGB(24, 14, 22)
    btnClearPack.Size = UDim2.new(0.24, 0, 0, 24)
    btnClearPack.Position = UDim2.new(0.73, 0, 0, 8)
    Theme.AddCorner(btnClearPack, Theme.CornerSmall)
    Theme.AddStroke(btnClearPack, Theme.AccentDanger, 1, 0.4)
    btnClearPack.Parent = packCard

    local btnSavePack = Instance.new("TextButton")
    btnSavePack.Text = "🚀 BAIXAR PACOTE COMPLETO (.rbxm)"
    btnSavePack.Font = Theme.FontTitle
    btnSavePack.TextSize = 11
    btnSavePack.TextColor3 = Theme.AccentSkull
    btnSavePack.BackgroundColor3 = Theme.AccentPrimary
    btnSavePack.Size = UDim2.new(1, -20, 0, 38)
    btnSavePack.Position = UDim2.new(0, 10, 0, 56)
    Theme.AddCorner(btnSavePack, Theme.CornerMedium)
    Theme.AddStroke(btnSavePack, Theme.BorderNeon, 1.2)
    Theme.AddGradient(btnSavePack, Color3.fromRGB(147, 51, 234), Color3.fromRGB(88, 28, 135), 0)
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
    Theme.AnimateButton(raycastBtn, function()
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
    Theme.AnimateButton(btnSaveSingle, function()
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
    Theme.AnimateButton(btnAddToPack, function()
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
    Theme.AnimateButton(btnClearPack, function()
        self.SelectedTargets = {}
        updatePackUI()
        resultLabel.Text = "Pacote limpo."
        resultLabel.TextColor3 = Theme.TextMuted
    end)

    -- Event: Save full multi-pack
    Theme.AnimateButton(btnSavePack, function()
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
                resultfunction Interface:BuildAudioRipperTab()
    local parent = self.TabFrames["AudioRipper"]

    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, -32, 0, 36)
    topBar.Position = UDim2.new(0, 16, 0, 12)
    topBar.BackgroundTransparency = 1
    topBar.Parent = parent

    local topLayout = Instance.new("UIListLayout")
    topLayout.FillDirection = Enum.FillDirection.Horizontal
    topLayout.Padding = UDim.new(0, 8)
    topLayout.SortOrder = Enum.SortOrder.LayoutOrder
    topLayout.Parent = topBar

    local scanAudioBtn = Instance.new("TextButton")
    scanAudioBtn.Text = "🎵 ESCANEAR SONS DO JOGO"
    scanAudioBtn.Font = Theme.FontSemiBold
    scanAudioBtn.TextSize = 11
    scanAudioBtn.TextColor3 = Theme.AccentSkull
    scanAudioBtn.BackgroundColor3 = Theme.AccentPrimary
    scanAudioBtn.Size = UDim2.new(0.5, -4, 1, 0)
    scanAudioBtn.LayoutOrder = 1
    Theme.AddCorner(scanAudioBtn, Theme.CornerMedium)
    Theme.AddStroke(scanAudioBtn, Theme.BorderNeon, 1)
    scanAudioBtn.Parent = topBar

    local exportAudioListBtn = Instance.new("TextButton")
    exportAudioListBtn.Text = "📄 EXPORTAR LISTA (.txt)"
    exportAudioListBtn.Font = Theme.FontSemiBold
    exportAudioListBtn.TextSize = 11
    exportAudioListBtn.TextColor3 = Theme.TextPrimary
    exportAudioListBtn.BackgroundColor3 = Theme.CardBg
    exportAudioListBtn.BackgroundTransparency = Theme.CardTransparency
    exportAudioListBtn.Size = UDim2.new(0.5, -4, 1, 0)
    exportAudioListBtn.LayoutOrder = 2
    Theme.AddCorner(exportAudioListBtn, Theme.CornerMedium)
    Theme.AddStroke(exportAudioListBtn, Theme.Border, 1)
    exportAudioListBtn.Parent = topBar

    local audioScroll = Instance.new("ScrollingFrame")
    audioScroll.Size = UDim2.new(1, -32, 1, -64)
    audioScroll.Position = UDim2.new(0, 16, 0, 56)
    audioScroll.BackgroundColor3 = Theme.CardBg
    audioScroll.BackgroundTransparency = Theme.CardTransparency
    audioScroll.ScrollBarThickness = 4
    audioScroll.ScrollBarImageColor3 = Theme.BorderLight
    Theme.AddCorner(audioScroll, Theme.CornerLarge)
    Theme.AddStroke(audioScroll, Theme.Border, 1)
    audioScroll.Parent = parent

    local audioLayout = Instance.new("UIListLayout")
    audioLayout.SortOrder = Enum.SortOrder.LayoutOrder
    audioLayout.Padding = UDim.new(0, 6)
    audioLayout.Parent = audioScroll

    Theme.AnimateButton(scanAudioBtn, function()
        scanAudioBtn.Text = "Escaneando sons..."
        for _, child in ipairs(audioScroll:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end

        task.spawn(function()
            local list = AudioRipper.ScanSounds()
            scanAudioBtn.Text = string.format("✓ %d sons encontrados", #list)

            for _, snd in ipairs(list) do
                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, -12, 0, 32)
                row.BackgroundColor3 = Color3.fromRGB(12, 9, 20)
                row.BackgroundTransparency = 0.3
                Theme.AddCorner(row, Theme.CornerSmall)
                Theme.AddStroke(row, Theme.Border, 1)
                row.Parent = audioScroll

                local sndLbl = Instance.new("TextLabel")
                sndLbl.Text = string.format("🎵 %s (ID: %s)", snd.Name, snd.CleanId)
                sndLbl.Font = Theme.FontRegular
                sndLbl.TextSize = 10
                sndLbl.TextColor3 = Theme.TextPrimary
                sndLbl.TextXAlignment = Enum.TextXAlignment.Left
                sndLbl.Size = UDim2.new(0.65, 0, 1, 0)
                sndLbl.Position = UDim2.new(0, 10, 0, 0)
                sndLbl.BackgroundTransparency = 1
                sndLbl.Parent = row

                local playBtn = Instance.new("TextButton")
                playBtn.Text = "▶ Play"
                playBtn.Font = Theme.FontSemiBold
                playBtn.TextSize = 10
                playBtn.TextColor3 = Theme.AccentSkull
                playBtn.BackgroundColor3 = Theme.AccentPrimary
                playBtn.Size = UDim2.new(0, 52, 0, 22)
                playBtn.Position = UDim2.new(1, -120, 0.5, -11)
                Theme.AddCorner(playBtn, Theme.CornerPill)
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
                copyBtn.Size = UDim2.new(0, 58, 0, 22)
                copyBtn.Position = UDim2.new(1, -62, 0.5, -11)
                Theme.AddCorner(copyBtn, Theme.CornerPill)
                copyBtn.Parent = row

                Theme.AnimateButton(copyBtn, function()
                    Environment.SetClipboard(snd.CleanId)
                    copyBtn.Text = "✓"
                    task.delay(1.5, function() copyBtn.Text = "Copiar ID" end)
                end)
            end

            audioScroll.CanvasSize = UDim2.new(0, 0, 0, #list * 38)
        end)
    end)

    Theme.AnimateButton(exportAudioListBtn, function()
        local file = AudioRipper.ExportSoundList()
        exportAudioListBtn.Text = "✓ Lista Exportada!"
        Environment.SetClipboard(file)
        task.delay(2, function()
            exportAudioListBtn.Text = "📄 EXPORTAR LISTA (.txt)"
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
    card.BackgroundTransparency = Theme.CardTransparency
    Theme.AddCorner(card, Theme.CornerLarge)
    Theme.AddStroke(card, Theme.Border, 1)
    card.Parent = parent

    local headerLbl = Instance.new("TextLabel")
    headerLbl.Text = "✨ EXTRATOR DE ILUMINAÇÃO & ATMOSFERA"
    headerLbl.Font = Theme.FontTitle
    headerLbl.TextSize = 13
    headerLbl.TextColor3 = Theme.AccentCyan
    headerLbl.TextXAlignment = Enum.TextXAlignment.Left
    headerLbl.Size = UDim2.new(1, -24, 0, 24)
    headerLbl.Position = UDim2.new(0, 16, 0, 16)
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
    desc.Size = UDim2.new(1, -32, 0, 60)
    desc.Position = UDim2.new(0, 16, 0, 48)
    desc.BackgroundTransparency = 1
    desc.Parent = card

    local exportLightBtn = Instance.new("TextButton")
    exportLightBtn.Text = "✨ SALVAR PRESET DE ILUMINAÇÃO (.rbxmx)"
    exportLightBtn.Font = Theme.FontTitle
    exportLightBtn.TextSize = 12
    exportLightBtn.TextColor3 = Theme.AccentSkull
    exportLightBtn.BackgroundColor3 = Theme.AccentPrimary
    exportLightBtn.Size = UDim2.new(1, -32, 0, 46)
    exportLightBtn.Position = UDim2.new(0, 16, 0, 120)
    Theme.AddCorner(exportLightBtn, Theme.CornerMedium)
    Theme.AddStroke(exportLightBtn, Theme.BorderNeon, 1.2)
    Theme.AddGradient(exportLightBtn, Color3.fromRGB(147, 51, 234), Color3.fromRGB(88, 28, 135), 45)
    exportLightBtn.Parent = card

    local lightStatus = Instance.new("TextLabel")
    lightStatus.Text = "Status: Pronto para salvar iluminação"
    lightStatus.Font = Theme.FontRegular
    lightStatus.TextSize = 11
    lightStatus.TextColor3 = Theme.TextMuted
    lightStatus.TextXAlignment = Enum.TextXAlignment.Left
    lightStatus.Size = UDim2.new(1, -32, 0, 24)
    lightStatus.Position = UDim2.new(0, 16, 0, 180)
    lightStatus.BackgroundTransparency = 1
    lightStatus.Parent = card

    Theme.AnimateButton(exportLightBtn, function()
        lightStatus.Text = "Extraindo efeitos e skyboxes..."
        lightStatus.TextColor3 = Theme.AccentCyan

        task.spawn(function()
            local success, file = LightingRipper.ExportLightingPreset()
            if success then
                lightStatus.Text = "✓ Iluminação salva com sucesso: " .. file
                lightStatus.TextColor3 = Theme.AccentSuccess
                Environment.SetClipboard(file)
            else
                lightStatus.Text = "❌ Erro: " .. tostring(file)
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
    card.BackgroundTransparency = Theme.CardTransparency
    Theme.AddCorner(card, Theme.CornerLarge)
    Theme.AddStroke(card, Theme.Border, 1)
    card.Parent = parent

    local headerLbl = Instance.new("TextLabel")
    headerLbl.Text = "🖥️ EXTRATOR DE INTERFACES (GUIs & HUDs)"
    headerLbl.Font = Theme.FontTitle
    headerLbl.TextSize = 13
    headerLbl.TextColor3 = Theme.AccentCyan
    headerLbl.TextXAlignment = Enum.TextXAlignment.Left
    headerLbl.Size = UDim2.new(1, -24, 0, 24)
    headerLbl.Position = UDim2.new(0, 16, 0, 16)
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
    desc.Size = UDim2.new(1, -32, 0, 60)
    desc.Position = UDim2.new(0, 16, 0, 48)
    desc.BackgroundTransparency = 1
    desc.Parent = card

    local exportGuiBtn = Instance.new("TextButton")
    exportGuiBtn.Text = "🖥️ SALVAR TODAS AS GUIs (.rbxmx)"
    exportGuiBtn.Font = Theme.FontTitle
    exportGuiBtn.TextSize = 12
    exportGuiBtn.TextColor3 = Theme.AccentSkull
    exportGuiBtn.BackgroundColor3 = Theme.AccentPrimary
    exportGuiBtn.Size = UDim2.new(1, -32, 0, 46)
    exportGuiBtn.Position = UDim2.new(0, 16, 0, 120)
    Theme.AddCorner(exportGuiBtn, Theme.CornerMedium)
    Theme.AddStroke(exportGuiBtn, Theme.BorderNeon, 1.2)
    Theme.AddGradient(exportGuiBtn, Color3.fromRGB(147, 51, 234), Color3.fromRGB(88, 28, 135), 45)
    exportGuiBtn.Parent = card

    local guiStatus = Instance.new("TextLabel")
    guiStatus.Text = "Status: Pronto para salvar GUIs"
    guiStatus.Font = Theme.FontRegular
    guiStatus.TextSize = 11
    guiStatus.TextColor3 = Theme.TextMuted
    guiStatus.TextXAlignment = Enum.TextXAlignment.Left
    guiStatus.Size = UDim2.new(1, -32, 0, 24)
    guiStatus.Position = UDim2.new(0, 16, 0, 180)
    guiStatus.BackgroundTransparency = 1
    guiStatus.Parent = card

    Theme.AnimateButton(exportGuiBtn, function()
        guiStatus.Text = "Extraindo e descompilando interfaces..."
        guiStatus.TextColor3 = Theme.AccentCyan

        task.spawn(function()
            local success, file = GuiRipper.ExportAllGuis(self.Config)
            if success then
                guiStatus.Text = "✓ Pacote de GUIs salvo com sucesso: " .. file
                guiStatus.TextColor3 = Theme.AccentSuccess
                Environment.SetClipboard(file)
            else
                guiStatus.Text = "❌ Erro: " .. tostring(file)
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

    local netLayout = Instance.new("UIListLayout")
    netLayout.FillDirection = Enum.FillDirection.Horizontal
    netLayout.Padding = UDim.new(0, 8)
    netLayout.SortOrder = Enum.SortOrder.LayoutOrder
    netLayout.Parent = topBar

    local toggleSnifferBtn = Instance.new("TextButton")
    toggleSnifferBtn.Text = "📡 INICIAR GRAVAÇÃO"
    toggleSnifferBtn.Font = Theme.FontSemiBold
    toggleSnifferBtn.TextSize = 11
    toggleSnifferBtn.TextColor3 = Theme.AccentSkull
    toggleSnifferBtn.BackgroundColor3 = Theme.AccentPrimary
    toggleSnifferBtn.Size = UDim2.new(0.5, -4, 1, 0)
    toggleSnifferBtn.LayoutOrder = 1
    Theme.AddCorner(toggleSnifferBtn, Theme.CornerMedium)
    Theme.AddStroke(toggleSnifferBtn, Theme.BorderNeon, 1)
    toggleSnifferBtn.Parent = topBar

    local exportSnifferBtn = Instance.new("TextButton")
    exportSnifferBtn.Text = "📄 EXPORTAR (.json)"
    exportSnifferBtn.Font = Theme.FontSemiBold
    exportSnifferBtn.TextSize = 11
    exportSnifferBtn.TextColor3 = Theme.TextPrimary
    exportSnifferBtn.BackgroundColor3 = Theme.CardBg
    exportSnifferBtn.BackgroundTransparency = Theme.CardTransparency
    exportSnifferBtn.Size = UDim2.new(0.5, -4, 1, 0)
    exportSnifferBtn.LayoutOrder = 2
    Theme.AddCorner(exportSnifferBtn, Theme.CornerMedium)
    Theme.AddStroke(exportSnifferBtn, Theme.Border, 1)
    exportSnifferBtn.Parent = topBar

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -32, 1, -64)
    scroll.Position = UDim2.new(0, 16, 0, 56)
    scroll.BackgroundColor3 = Theme.CardBg
    scroll.BackgroundTransparency = Theme.CardTransparency
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Theme.BorderLight
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    Theme.AddCorner(scroll, Theme.CornerLarge)
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
    card.BackgroundTransparency = Theme.CardTransparency
    Theme.AddCorner(card, Theme.CornerLarge)
    Theme.AddStroke(card, Theme.Border, 1)
    card.Parent = parent

    local headerLbl = Instance.new("TextLabel")
    headerLbl.Text = "🌌 RASTREADOR DE UNIVERSO (MULTI-PLACES)"
    headerLbl.Font = Theme.FontTitle
    headerLbl.TextSize = 13
    headerLbl.TextColor3 = Theme.AccentCyan
    headerLbl.TextXAlignment = Enum.TextXAlignment.Left
    headerLbl.Size = UDim2.new(1, -24, 0, 24)
    headerLbl.Position = UDim2.new(0, 16, 0, 16)
    headerLbl.BackgroundTransparency = 1
    headerLbl.Parent = card

    local scanBtn = Instance.new("TextButton")
    scanBtn.Text = "🌌 BUSCAR SUB-PLACES DO UNIVERSO"
    scanBtn.Font = Theme.FontTitle
    scanBtn.TextSize = 11
    scanBtn.TextColor3 = Theme.AccentSkull
    scanBtn.BackgroundColor3 = Theme.AccentPrimary
    scanBtn.Size = UDim2.new(1, -32, 0, 36)
    scanBtn.Position = UDim2.new(0, 16, 0, 46)
    Theme.AddCorner(scanBtn, Theme.CornerMedium)
    Theme.AddStroke(scanBtn, Theme.BorderNeon, 1)
    scanBtn.Parent = card

    local placeScroll = Instance.new("ScrollingFrame")
    placeScroll.Size = UDim2.new(1, -32, 1, -100)
    placeScroll.Position = UDim2.new(0, 16, 0, 90)
    placeScroll.BackgroundColor3 = Color3.fromRGB(10, 8, 18)
    placeScroll.BackgroundTransparency = 0.3
    placeScroll.ScrollBarThickness = 4
    placeScroll.ScrollBarImageColor3 = Theme.BorderLight
    Theme.AddCorner(placeScroll, Theme.CornerMedium)
    Theme.AddStroke(placeScroll, Theme.Border, 1)
    placeScroll.Parent = card

    local placeLayout = Instance.new("UIListLayout")
    placeLayout.SortOrder = Enum.SortOrder.LayoutOrder
    placeLayout.Padding = UDim.new(0, 6)
    placeLayout.Parent = placeScroll

    Theme.AnimateButton(scanBtn, function()
        scanBtn.Text = "Buscando sub-places..."
        for _, child in ipairs(placeScroll:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end

        task.spawn(function()
            local list = UniverseTracker.GetUniversePlaces()
            scanBtn.Text = string.format("✓ %d lugares encontrados no Universo", #list)

            for idx, pInfo in ipairs(list) do
                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, -12, 0, 32)
                row.BackgroundColor3 = Theme.CardBg
                row.BackgroundTransparency = 0.2
                Theme.AddCorner(row, Theme.CornerSmall)
                Theme.AddStroke(row, Theme.Border, 1)
                row.Parent = placeScroll

                local pName = Instance.new("TextLabel")
                pName.Text = string.format("📍 %s (ID: %d)", pInfo.Name, pInfo.PlaceId)
                pName.Font = Theme.FontRegular
                pName.TextSize = 10
                pName.TextColor3 = pInfo.IsRoot and Theme.AccentCyan or Theme.TextPrimary
                pName.TextXAlignment = Enum.TextXAlignment.Left
                pName.Size = UDim2.new(0.7, 0, 1, 0)
                pName.Position = UDim2.new(0, 10, 0, 0)
                pName.BackgroundTransparency = 1
                pName.Parent = row

                local copyIdBtn = Instance.new("TextButton")
                copyIdBtn.Text = "Copiar ID"
                copyIdBtn.Font = Theme.FontSemiBold
                copyIdBtn.TextSize = 10
                copyIdBtn.TextColor3 = Theme.TextSecondary
                copyIdBtn.BackgroundColor3 = Theme.CardHover
                copyIdBtn.Size = UDim2.new(0, 80, 0, 22)
                copyIdBtn.Position = UDim2.new(1, -88, 0.5, -11)
                Theme.AddCorner(copyIdBtn, Theme.CornerPill)
                copyIdBtn.Parent = row

                Theme.AnimateButton(copyIdBtn, function()
                    Environment.SetClipboard(tostring(pInfo.PlaceId))
                    copyIdBtn.Text = "✓ Copiado"
                    task.delay(1.5, function() copyIdBtn.Text = "Copiar ID" end)
                end)
            end

            placeScroll.CanvasSize = UDim2.new(0, 0, 0, #list * 40)
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
    card.BackgroundTransparency = Theme.CardTransparency
    Theme.AddCorner(card, Theme.CornerLarge)
    Theme.AddStroke(card, Theme.Border, 1)
    card.Parent = parent

    local headerLbl = Instance.new("TextLabel")
    headerLbl.Text = "🧊 EXPORTADOR 3D WAVEFRONT (.OBJ + .MTL)"
    headerLbl.Font = Theme.FontTitle
    headerLbl.TextSize = 13
    headerLbl.TextColor3 = Theme.AccentCyan
    headerLbl.TextXAlignment = Enum.TextXAlignment.Left
    headerLbl.Size = UDim2.new(1, -24, 0, 24)
    headerLbl.Position = UDim2.new(0, 16, 0, 16)
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
    desc.Size = UDim2.new(1, -32, 0, 48)
    desc.Position = UDim2.new(0, 16, 0, 48)
    desc.BackgroundTransparency = 1
    desc.Parent = card

    local exportObjBtn = Instance.new("TextButton")
    exportObjBtn.Text = "🧊 EXPORTAR MAPA 3D (.OBJ + .MTL)"
    exportObjBtn.Font = Theme.FontTitle
    exportObjBtn.TextSize = 12
    exportObjBtn.TextColor3 = Theme.AccentSkull
    exportObjBtn.BackgroundColor3 = Theme.AccentPrimary
    exportObjBtn.Size = UDim2.new(1, -32, 0, 46)
    exportObjBtn.Position = UDim2.new(0, 16, 0, 108)
    Theme.AddCorner(exportObjBtn, Theme.CornerMedium)
    Theme.AddStroke(exportObjBtn, Theme.BorderNeon, 1.2)
    Theme.AddGradient(exportObjBtn, Color3.fromRGB(147, 51, 234), Color3.fromRGB(88, 28, 135), 45)
    exportObjBtn.Parent = card

    local objStatus = Instance.new("TextLabel")
    objStatus.Text = "Status: Pronto para exportar"
    objStatus.Font = Theme.FontRegular
    objStatus.TextSize = 11
    objStatus.TextColor3 = Theme.TextMuted
    objStatus.TextXAlignment = Enum.TextXAlignment.Left
    objStatus.Size = UDim2.new(1, -32, 0, 24)
    objStatus.Position = UDim2.new(0, 16, 0, 166)
    objStatus.BackgroundTransparency = 1
    objStatus.Parent = card

    Theme.AnimateButton(exportObjBtn, function()
        objStatus.Text = "Gerando geometria .obj e biblioteca de materiais .mtl..."
        objStatus.TextColor3 = Theme.AccentCyan

        task.spawn(function()
            local success, file = ObjExporter.ExportWorkspaceToObj()
            if success then
                objStatus.Text = "✓ Exportado com sucesso: " .. file
                objStatus.TextColor3 = Theme.AccentSuccess
                Environment.SetClipboard(file)
            else
                objStatus.Text = "❌ Erro ao exportar: " .. tostring(file)
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
    scroll.ScrollBarImageColor3 = Theme.BorderLight
    scroll.CanvasSize = UDim2.new(0, 0, 0, 480)
    scroll.Parent = parent

    local steps = {
        {"📌 Passo 1: Iniciar a Cópia", "Basta ir na aba ' Clonar Tudo' e clicar no botão roxo 'CLONAR JOGO INTEIRO'. O HyperSaveInstance vai começar a varrer o mapa."},
        {"⏳ Passo 2: Aguardar o Progresso", "A barra de progresso vai indicar o que está sendo salvo em tempo real: áudios, texturas, meshes 3D, terreno e scripts descompilados."},
        {"📁 Passo 3: Onde o Arquivo Fica?", "O arquivo .rbxlx e a pasta de assets são salvos automaticamente dentro da pasta 'workspace' do seu executor no seu computador."},
        {"🚀 Passo 4: Como Abrir no Roblox Studio", "1. Abra o Roblox Studio.\n2. Clique em 'File' (Arquivo) -> 'Open from File...'\n3. Selecione o arquivo gerado e clique em Abrir.\n4. Pronto! O jogo inteiro abrirá 100% editável!"},
    }

    for i, step in ipairs(steps) do
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -12, 0, 80)
        card.Position = UDim2.new(0, 0, 0, (i - 1) * 88)
        card.BackgroundColor3 = Theme.CardBg
        card.BackgroundTransparency = Theme.CardTransparency
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
        desc.Size = UDim2.new(1, -24, 0, 46)
        desc.Position = UDim2.new(0, 12, 0, 30)
        desc.BackgroundTransparency = 1
        desc.Parent = card
    end

    -- Copy Universal Command Button
    local copyScriptCard = Instance.new("TextButton")
    copyScriptCard.Text = "📋 Copiar Comando de Execução (loadstring) para a Área de Transferência"
    copyScriptCard.Font = Theme.FontSemiBold
    copyScriptCard.TextSize = 11
    copyScriptCard.TextColor3 = Theme.AccentSkull
    copyScriptCard.BackgroundColor3 = Theme.AccentPrimary
    copyScriptCard.Size = UDim2.new(1, -12, 0, 38)
    copyScriptCard.Position = UDim2.new(0, 0, 0, 360)
    Theme.AddCorner(copyScriptCard, Theme.CornerPill)
    Theme.AddStroke(copyScriptCard, Theme.BorderNeon, 1.2)
    copyScriptCard.Parent = scroll

    Theme.AnimateButton(copyScriptCard, function()
        Environment.SetClipboard('loadstring(game:HttpGet("https://raw.githubusercontent.com/theopadilha2009-hash/HyperSaveInstance/main/dist/HyperSaveInstance.luau"))()')
        copyScriptCard.Text = "✓ Comando Copiado!"
        task.delay(2, function()
            copyScriptCard.Text = "📋 Copiar Comando de Execução (loadstring) para a Área de Transferência"
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
    scroll.ScrollBarImageColor3 = Theme.BorderLight
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
        row.Size = UDim2.new(1, -12, 0, 34)
        row.Position = UDim2.new(0, 0, 0, (i - 1) * 38)
        row.BackgroundColor3 = Theme.CardBg
        row.BackgroundTransparency = Theme.CardTransparency
        Theme.AddCorner(row, Theme.CornerMedium)
        Theme.AddStroke(row, Theme.Border, 1)
        row.Parent = scroll

        local lbl = Instance.new("TextLabel")
        lbl.Text = title
        lbl.Font = Theme.FontRegular
        lbl.TextSize = 11
        lbl.TextColor3 = (key == "OptimizeGeometry") and Theme.AccentWarning or Theme.TextPrimary
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Size = UDim2.new(0.75, 0, 1, 0)
        lbl.Position = UDim2.new(0, 12, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Parent = row

        local switch = Instance.new("TextButton")
        switch.Text = defaultVal and "ATIVADO" or "DESATIVADO"
        switch.Font = Theme.FontSemiBold
        switch.TextSize = 10
        switch.TextColor3 = defaultVal and Theme.AccentSkull or Theme.TextMuted
        switch.BackgroundColor3 = defaultVal and Theme.AccentPrimary or Theme.CardHover
        switch.Size = UDim2.new(0, 84, 0, 24)
        switch.Position = UDim2.new(1, -92, 0.5, -12)
        Theme.AddCorner(switch, Theme.CornerPill)
        Theme.AddStroke(switch, defaultVal and Theme.BorderNeon or Theme.Border, 1)
        switch.Parent = row

        Theme.AnimateButton(switch, function()
            local current = self.Config[key]
            local new = not current
            self.Config[key] = new
            switch.Text = new and "ATIVADO" or "DESATIVADO"
            switch.TextColor3 = new and Theme.AccentSkull or Theme.TextMuted
            switch.BackgroundColor3 = new and Theme.AccentPrimary or Theme.CardHover
            local stroke = switch:FindFirstChildOfClass("UIStroke")
            if stroke then
                stroke.Color = new and Theme.BorderNeon or Theme.Border
            end
            self:Log("Opção alterada: " .. key .. " = " .. tostring(new))
        end)
    end
end

-- 11. Console Tab
function Interface:BuildConsoleTab()
    local parent = self.TabFrames["Console"]

    local consoleBox = Instance.new("ScrollingFrame")
    consoleBox.Size = UDim2.new(1, -32, 1, -68)
    consoleBox.Position = UDim2.new(0, 16, 0, 16)
    consoleBox.BackgroundColor3 = Theme.CardBg
    consoleBox.BackgroundTransparency = Theme.CardTransparency
    consoleBox.ScrollBarThickness = 4
    consoleBox.ScrollBarImageColor3 = Theme.BorderLight
    consoleBox.CanvasSize = UDim2.new(0, 0, 0, 0)
    Theme.AddCorner(consoleBox, Theme.CornerLarge)
    Theme.AddStroke(consoleBox, Theme.Border, 1)
    consoleBox.Parent = parent
    self.ConsoleScroll = consoleBox

    local consoleList = Instance.new("UIListLayout")
    consoleList.SortOrder = Enum.SortOrder.LayoutOrder
    consoleList.Padding = UDim.new(0, 4)
    consoleList.Parent = consoleBox

    local copyLogsBtn = Instance.new("TextButton")
    copyLogsBtn.Text = "📋 Copiar Logs para Área de Transferência"
    copyLogsBtn.Font = Theme.FontSemiBold
    copyLogsBtn.TextSize = 11
    copyLogsBtn.TextColor3 = Theme.AccentSkull
    copyLogsBtn.BackgroundColor3 = Theme.AccentPrimary
    copyLogsBtn.Size = UDim2.new(1, -32, 0, 36)
    copyLogsBtn.Position = UDim2.new(0, 16, 1, -44)
    Theme.AddCorner(copyLogsBtn, Theme.CornerPill)
    Theme.AddStroke(copyLogsBtn, Theme.BorderNeon, 1.2)
    copyLogsBtn.Parent = parent

    Theme.AnimateButton(copyLogsBtn, function()
        local fullLog = table.concat(self.Logs, "\n")
        Environment.SetClipboard(fullLog)
        copyLogsBtn.Text = "✓ Logs Copiados!"
        task.delay(2, function()
            copyLogsBtn.Text = "📋 Copiar Logs para Área de Transferência"
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
    scroll.BackgroundTransparency = Theme.CardTransparency
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Theme.BorderLight
    scroll.CanvasSize = UDim2.new(0, 0, 0, 490)
    Theme.AddCorner(scroll, Theme.CornerLarge)
    Theme.AddStroke(scroll, Theme.BorderLight, 1)
    scroll.Parent = parent

    -- Developer Profile Header Card
    local devCard = Instance.new("Frame")
    devCard.Size = UDim2.new(1, -24, 0, 120)
    devCard.Position = UDim2.new(0, 12, 0, 12)
    devCard.BackgroundColor3 = Color3.fromRGB(15, 11, 26)
    devCard.BackgroundTransparency = 0.2
    Theme.AddCorner(devCard, Theme.CornerLarge)
    Theme.AddStroke(devCard, Theme.BorderNeon, 1.2)
    Theme.AddGradient(devCard, Color3.fromRGB(15, 11, 26), Color3.fromRGB(30, 20, 48), 45)
    devCard.Parent = scroll

    -- Avatar Emblem (Bubble Pill)
    local avatar = Instance.new("Frame")
    avatar.Size = UDim2.new(0, 52, 0, 52)
    avatar.Position = UDim2.new(0, 16, 0, 16)
    avatar.BackgroundColor3 = Theme.AccentPrimary
    Theme.AddCorner(avatar, Theme.CornerPill)
    Theme.AddGradient(avatar, Color3.fromRGB(168, 85, 247), Color3.fromRGB(126, 34, 206), 45)
    avatar.Parent = devCard

    local avatarTxt = Instance.new("TextLabel")
    avatarTxt.Text = "TLP"
    avatarTxt.Font = Theme.FontTitle
    avatarTxt.TextSize = 16
    avatarTxt.TextColor3 = Theme.AccentSkull
    avatarTxt.Size = UDim2.new(1, 0, 1, 0)
    avatarTxt.BackgroundTransparency = 1
    avatarTxt.Parent = avatar

    -- Developer Name & Title
    local devName = Instance.new("TextLabel")
    devName.Text = "Theo Lorentz Padilha"
    devName.Font = Theme.FontTitle
    devName.TextSize = 15
    devName.TextColor3 = Theme.TextPrimary
    devName.TextXAlignment = Enum.TextXAlignment.Left
    devName.Size = UDim2.new(1, -84, 0, 20)
    devName.Position = UDim2.new(0, 78, 0, 16)
    devName.BackgroundTransparency = 1
    devName.Parent = devCard

    local devRole = Instance.new("TextLabel")
    devRole.Text = "⭐ Criador & Engenheiro Principal • HyperSaveInstance"
    devRole.Font = Theme.FontSemiBold
    devRole.TextSize = 11
    devRole.TextColor3 = Theme.TextTheo
    devRole.TextXAlignment = Enum.TextXAlignment.Left
    devRole.Size = UDim2.new(1, -84, 0, 16)
    devRole.Position = UDim2.new(0, 78, 0, 38)
    devRole.BackgroundTransparency = 1
    devRole.Parent = devCard

    -- Action Container for Buttons (UIListLayout Grid)
    local devBtnBar = Instance.new("Frame")
    devBtnBar.Size = UDim2.new(1, -94, 0, 30)
    devBtnBar.Position = UDim2.new(0, 78, 0, 68)
    devBtnBar.BackgroundTransparency = 1
    devBtnBar.Parent = devCard

    local devBtnLayout = Instance.new("UIListLayout")
    devBtnLayout.FillDirection = Enum.FillDirection.Horizontal
    devBtnLayout.Padding = UDim.new(0, 8)
    devBtnLayout.SortOrder = Enum.SortOrder.LayoutOrder
    devBtnLayout.Parent = devBtnBar

    -- GitHub Link Button
    local btnGithub = Instance.new("TextButton")
    btnGithub.Text = "🔗 GitHub Profile"
    btnGithub.Font = Theme.FontSemiBold
    btnGithub.TextSize = 10
    btnGithub.TextColor3 = Theme.AccentSkull
    btnGithub.BackgroundColor3 = Theme.AccentPrimary
    btnGithub.Size = UDim2.new(0.5, -4, 1, 0)
    btnGithub.LayoutOrder = 1
    Theme.AddCorner(btnGithub, Theme.CornerPill)
    Theme.AddStroke(btnGithub, Theme.BorderNeon, 1)
    btnGithub.Parent = devBtnBar

    Theme.AnimateButton(btnGithub, function()
        Environment.SetClipboard("https://github.com/theopadilha2009-hash")
        btnGithub.Text = "✓ Perfil Copiado!"
        task.delay(2, function()
            btnGithub.Text = "🔗 GitHub Profile"
        end)
    end)

    -- Repository Link Button
    local btnRepo = Instance.new("TextButton")
    btnRepo.Text = "⭐ Repositório"
    btnRepo.Font = Theme.FontSemiBold
    btnRepo.TextSize = 10
    btnRepo.TextColor3 = Theme.TextPrimary
    btnRepo.BackgroundColor3 = Theme.CardHover
    btnRepo.Size = UDim2.new(0.5, -4, 1, 0)
    btnRepo.LayoutOrder = 2
    Theme.AddCorner(btnRepo, Theme.CornerPill)
    Theme.AddStroke(btnRepo, Theme.Border, 1)
    btnRepo.Parent = devBtnBar

    Theme.AnimateButton(btnRepo, function()
        Environment.SetClipboard("https://github.com/theopadilha2009-hash/HyperSaveInstance")
        btnRepo.Text = "✓ Repo Copiado!"
        task.delay(2, function()
            btnRepo.Text = "⭐ Repositório"
        end)
    end)

    -- System Diagnostics Card
    local sysCard = Instance.new("Frame")
    sysCard.Size = UDim2.new(1, -24, 0, 180)
    sysCard.Position = UDim2.new(0, 12, 0, 142)
    sysCard.BackgroundColor3 = Color3.fromRGB(12, 9, 20)
    sysCard.BackgroundTransparency = 0.3
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
    featCard.BackgroundColor3 = Color3.fromRGB(12, 9, 20)
    featCard.BackgroundTransparency = 0.3
    Theme.AddCorner(featCard, Theme.CornerMedium)
    Theme.AddStroke(featCard, Theme.Border, 1)
    featCard.Parent = scroll

    local featTitle = Instance.new("TextLabel")
    featTitle.Text = "⚡ RECURSOS EXCLUSIVOS INCLUÍDOS"
    featTitle.Font = Theme.FontTitle
    featTitle.TextSize = 12
    featTitle.TextColor3 = Theme.AccentCyan
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
