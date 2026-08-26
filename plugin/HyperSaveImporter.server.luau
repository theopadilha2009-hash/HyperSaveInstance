--[[
    HyperSave Studio Importer - Official Roblox Studio Plugin
    Place this script in your Studio Plugins folder or run as Local Plugin to import & rebuild cloned games.
]]

local Selection = game:GetService("Selection")
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local HttpService = game:GetService("HttpService")

-- Create Toolbar & Button in Studio
local toolbar = plugin:CreateToolbar(" HyperSave Importer")
local openBtn = toolbar:CreateButton(
    "Importar Jogo",
    "Abre o menu para importar e reconstruir mapas e scripts do HyperSaveInstance",
    "rbxassetid://9069609200"
)

-- Create DockWidget GUI inside Studio
local widgetInfo = DockWidgetPluginGuiInfo.new(
    Enum.InitialDockState.Float,
    false,
    false,
    420,
    380,
    350,
    300
)

local widget = plugin:CreateDockWidgetPluginGui("HyperSave_StudioImporter", widgetInfo)
widget.Title = " HyperSave Studio Importer"

openBtn.Click:Connect(function()
    widget.Enabled = not widget.Enabled
end)

-- Build Plugin GUI
local background = Instance.new("Frame")
background.Size = UDim2.new(1, 0, 1, 0)
background.BackgroundColor3 = Color3.fromRGB(20, 23, 32)
background.BorderSizePixel = 0
background.Parent = widget

local title = Instance.new("TextLabel")
title.Text = " Reconstruir Jogo / Importar Assets"
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextColor3 = Color3.fromRGB(240, 245, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Size = UDim2.new(1, -24, 0, 30)
title.Position = UDim2.new(0, 12, 0, 10)
title.BackgroundTransparency = 1
title.Parent = background

local info = Instance.new("TextLabel")
info.Text = "Cole abaixo o código do script '.lua' gerado pelo HyperSaveInstance para reconstruir o mapa inteiro no Studio:"
info.Font = Enum.Font.Gotham
info.TextSize = 11
info.TextColor3 = Color3.fromRGB(160, 175, 200)
info.TextXAlignment = Enum.TextXAlignment.Left
info.TextYAlignment = Enum.TextYAlignment.Top
info.TextWrapped = true
info.Size = UDim2.new(1, -24, 0, 36)
info.Position = UDim2.new(0, 12, 0, 42)
info.BackgroundTransparency = 1
info.Parent = background

local codeBox = Instance.new("TextBox")
codeBox.PlaceholderText = "-- Cole o código .lua aqui..."
codeBox.Font = Enum.Font.Code
codeBox.TextSize = 11
codeBox.TextColor3 = Color3.fromRGB(220, 230, 245)
codeBox.PlaceholderColor3 = Color3.fromRGB(100, 110, 130)
codeBox.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
codeBox.ClearTextOnFocus = false
codeBox.MultiLine = true
codeBox.Size = UDim2.new(1, -24, 0, 180)
codeBox.Position = UDim2.new(0, 12, 0, 82)
codeBox.Parent = background

local buildBtn = Instance.new("TextButton")
buildBtn.Text = " EXECUTAR RECONSTRUÇÃO COMPLETA"
buildBtn.Font = Enum.Font.GothamBold
buildBtn.TextSize = 12
buildBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
buildBtn.BackgroundColor3 = Color3.fromRGB(99, 102, 241)
buildBtn.Size = UDim2.new(1, -24, 0, 42)
buildBtn.Position = UDim2.new(0, 12, 0, 270)
buildBtn.Parent = background

local statusLbl = Instance.new("TextLabel")
statusLbl.Text = "Status: Aguardando código..."
statusLbl.Font = Enum.Font.Gotham
statusLbl.TextSize = 11
statusLbl.TextColor3 = Color3.fromRGB(140, 150, 170)
statusLbl.TextXAlignment = Enum.TextXAlignment.Left
statusLbl.Size = UDim2.new(1, -24, 0, 20)
statusLbl.Position = UDim2.new(0, 12, 0, 320)
statusLbl.BackgroundTransparency = 1
statusLbl.Parent = background

buildBtn.MouseButton1Click:Connect(function()
    local code = codeBox.Text
    if #code == 0 then
        statusLbl.Text = " Cole o código do arquivo .lua antes de executar!"
        statusLbl.TextColor3 = Color3.fromRGB(255, 180, 50)
        return
    end

    statusLbl.Text = " Reconstruindo instâncias e hierarquia..."
    statusLbl.TextColor3 = Color3.fromRGB(6, 182, 212)

    local fn, err = loadstring(code)
    if not fn then
        statusLbl.Text = " Erro na sintaxe do código: " .. tostring(err)
        statusLbl.TextColor3 = Color3.fromRGB(239, 68, 68)
        return
    end

    ChangeHistoryService:SetWaypoint("Before HyperSave Import")
    local s, execErr = pcall(fn)
    if s then
        ChangeHistoryService:SetWaypoint("After HyperSave Import")
        statusLbl.Text = "✓ Jogo reconstruído com sucesso no Roblox Studio!"
        statusLbl.TextColor3 = Color3.fromRGB(34, 197, 94)
    else
        statusLbl.Text = " Erro durante a execução: " .. tostring(execErr)
        statusLbl.TextColor3 = Color3.fromRGB(239, 68, 68)
    end
end)
