--[[
    HyperSave Studio Importer & Repair Suite - Official Roblox Studio Plugin
    Author: Theo Lorentz Padilha
    Features:
    1. 1-Click Master Repair
    2. Synthetic Server Dispatcher & DataStore Emulation
    3. HTTP 403 Forbidden Sound Sanitizer
    4. Decompiled Script Shielding
    5. PackageLink and Lock Permission Unlocker
    6. Future & PBR Cinematic Lighting Setup
    7. Rig & NPC Physical Stabilizer
    8. Asset Reference Auditor
    9. Manual Luau Code Runner
    10. Manifest-driven Asset Reconnection
]]

local Selection = game:GetService("Selection")
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")

local ContentProvider = game:GetService("ContentProvider")
local StudioService = game:GetService("StudioService")

-- Walks the tree in slices so a large place does not freeze Studio. The repair
-- actions used to call game:GetDescendants() four times back to back with no
-- yield at all.
local function forEachDescendant(root, callback, onProgress)
    local descendants = root:GetDescendants()
    local total = #descendants
    for i = 1, total do
        callback(descendants[i])
        if i % 2000 == 0 then
            if onProgress then onProgress(i, total) end
            task.wait()
        end
    end
    return total
end

-- Which sounds are actually unplayable. The previous check matched every
-- `rbxassetid://` SoundId, so "fix blocked audio" replaced the entire
-- soundtrack of the place with one beep.
local function findUnplayableSounds(sounds)
    local failed = {}
    if #sounds == 0 then return failed, true end

    local ok = pcall(function()
        ContentProvider:PreloadAsync(sounds, function(contentId, status)
            if status == Enum.AssetFetchStatus.Failure
                or status == Enum.AssetFetchStatus.TimedOut then
                failed[contentId] = true
            end
        end)
    end)

    -- Without a reliable verdict we replace nothing: silently flattening the
    -- audio is worse than leaving it alone.
    return failed, ok
end

-- Fallback audio library (verified 100% public Roblox core sounds)
local FALLBACK_SOUNDS = {
    Click = "rbxassetid://6895079853",
    Footstep = "rbxassetid://9114223171",
    Whoosh = "rbxassetid://9114227073",
    Generic = "rbxassetid://9069609200",
}

-- Create Toolbar & Button in Studio
local toolbar = plugin:CreateToolbar("HyperSave Studio Suite")
local openBtn = toolbar:CreateButton(
    "Reparo Mestre",
    "Abre a central de diagnóstico, reparo de assets e reconstrução de mapas.",
    "rbxassetid://9069609200"
)

-- Create DockWidget GUI inside Studio
local widgetInfo = DockWidgetPluginGuiInfo.new(
    Enum.InitialDockState.Float,
    false,
    false,
    460,
    520,
    380,
    400
)

local widget = plugin:CreateDockWidgetPluginGui("HyperSave_StudioImporterSuite", widgetInfo)
widget.Title = "HyperSave Studio Suite"

openBtn.Click:Connect(function()
    widget.Enabled = not widget.Enabled
end)

-- Main UI Root (Clean Dark Slate Theme)
local root = Instance.new("Frame")
root.Size = UDim2.new(1, 0, 1, 0)
root.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
root.BorderSizePixel = 0
root.Parent = widget

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 44)
header.BackgroundColor3 = Color3.fromRGB(26, 30, 40)
header.BorderSizePixel = 0
header.Parent = root

local headerLine = Instance.new("Frame")
headerLine.Size = UDim2.new(1, 0, 0, 1)
headerLine.Position = UDim2.new(0, 0, 1, -1)
headerLine.BackgroundColor3 = Color3.fromRGB(44, 50, 66)
headerLine.BorderSizePixel = 0
headerLine.Parent = header

local headerTitle = Instance.new("TextLabel")
headerTitle.Text = "HyperSave Studio Suite • Theo Lorentz Padilha"
headerTitle.Font = Enum.Font.GothamBold
headerTitle.TextSize = 13
headerTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
headerTitle.TextXAlignment = Enum.TextXAlignment.Left
headerTitle.Size = UDim2.new(1, -20, 1, 0)
headerTitle.Position = UDim2.new(0, 14, 0, 0)
headerTitle.BackgroundTransparency = 1
headerTitle.Parent = header

-- Scroll Container
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, 0, 1, -100)
scroll.Position = UDim2.new(0, 0, 0, 44)
scroll.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = Color3.fromRGB(44, 50, 66)
-- Was a hardcoded 1180 for ~1408px of content, so the last two cards could not
-- be reached at all.
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.Parent = root

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroll

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 10)
padding.PaddingBottom = UDim.new(0, 10)
padding.PaddingLeft = UDim.new(0, 12)
padding.PaddingRight = UDim.new(0, 12)
padding.Parent = scroll

-- Log / Status Bar at bottom
local statusCard = Instance.new("Frame")
statusCard.Size = UDim2.new(1, 0, 0, 56)
statusCard.Position = UDim2.new(0, 0, 1, -56)
statusCard.BackgroundColor3 = Color3.fromRGB(26, 30, 40)
statusCard.BorderSizePixel = 0
statusCard.Parent = root

local statusLine = Instance.new("Frame")
statusLine.Size = UDim2.new(1, 0, 0, 1)
statusLine.BackgroundColor3 = Color3.fromRGB(44, 50, 66)
statusLine.BorderSizePixel = 0
statusLine.Parent = statusCard

local statusLbl = Instance.new("TextLabel")
statusLbl.Text = "Pronto para diagnosticar e reparar o mapa."
statusLbl.Font = Enum.Font.Gotham
statusLbl.TextSize = 11
statusLbl.TextColor3 = Color3.fromRGB(160, 174, 192)
statusLbl.TextXAlignment = Enum.TextXAlignment.Left
statusLbl.TextYAlignment = Enum.TextYAlignment.Top
statusLbl.TextWrapped = true
statusLbl.Size = UDim2.new(1, -24, 1, -12)
statusLbl.Position = UDim2.new(0, 12, 0, 8)
statusLbl.BackgroundTransparency = 1
statusLbl.Parent = statusCard

local function setStatus(text: string, color: Color3?)
    statusLbl.Text = text
    statusLbl.TextColor3 = color or Color3.fromRGB(160, 174, 192)
end

-- Helper: Create UI Card
local function createCard(title: string, desc: string, layoutOrder: number)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 104)
    card.BackgroundColor3 = Color3.fromRGB(26, 30, 40)
    card.BorderSizePixel = 0
    card.LayoutOrder = layoutOrder

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(44, 50, 66)
    stroke.Thickness = 1
    stroke.Parent = card

    local cardTitle = Instance.new("TextLabel")
    cardTitle.Text = title
    cardTitle.Font = Enum.Font.GothamBold
    cardTitle.TextSize = 12
    cardTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    cardTitle.TextXAlignment = Enum.TextXAlignment.Left
    cardTitle.Size = UDim2.new(1, -24, 0, 20)
    cardTitle.Position = UDim2.new(0, 12, 0, 8)
    cardTitle.BackgroundTransparency = 1
    cardTitle.Parent = card

    local cardDesc = Instance.new("TextLabel")
    cardDesc.Text = desc
    cardDesc.Font = Enum.Font.Gotham
    cardDesc.TextSize = 10
    cardDesc.TextColor3 = Color3.fromRGB(160, 174, 192)
    cardDesc.TextXAlignment = Enum.TextXAlignment.Left
    cardDesc.TextYAlignment = Enum.TextYAlignment.Top
    cardDesc.TextWrapped = true
    cardDesc.Size = UDim2.new(1, -24, 0, 30)
    cardDesc.Position = UDim2.new(0, 12, 0, 28)
    cardDesc.BackgroundTransparency = 1
    cardDesc.Parent = card

    return card
end

-- Helper: Create Action Button
local function createButton(parent: Instance, text: string, bgColor: Color3?)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 11
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundColor3 = bgColor or Color3.fromRGB(37, 99, 235)
    btn.Size = UDim2.new(1, -24, 0, 32)
    btn.Position = UDim2.new(0, 12, 0, 62)
    btn.BorderSizePixel = 0
    btn.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = btn

    return btn
end

-- ============================================================================
-- FEATURE 0: 1-CLIQUE: REPARO MESTRE TOTAL & TORNAR JOGO JOGÁVEL
-- ============================================================================
local cardMaster = createCard(
    "Reparo Mestre Total (1-Clique)",
    "Executa todas as correções em sequência: destrava permissões, conserta áudios 403, blinda scripts e emula DataStores/VIP para deixar o jogo pronto.",
    0
)
cardMaster.Size = UDim2.new(1, 0, 0, 110)
cardMaster.Parent = scroll

local btnMaster = createButton(cardMaster, "Executar Reparo Mestre Total", Color3.fromRGB(37, 99, 235))
btnMaster.Size = UDim2.new(1, -24, 0, 36)

btnMaster.MouseButton1Click:Connect(function()
    ChangeHistoryService:SetWaypoint("Before HyperSave Master Repair")
    setStatus("Executando reparo mestre total...", Color3.fromRGB(59, 130, 246))

    -- 1. Destravar permissões & packages
    local unlockedPackages = 0
    local unlockedParts = 0
    for _, desc in ipairs(game:GetDescendants()) do
        if desc:IsA("PackageLink") then
            pcall(function() desc:Destroy() unlockedPackages = unlockedPackages + 1 end)
        elseif desc:IsA("BasePart") and desc.Locked then
            desc.Locked = false
            unlockedParts = unlockedParts + 1
        end
    end

    -- 2. Consertar áudios 403 (mesma regra do botão isolado: só o que de fato
    -- não carrega, e sempre guardando o id original para dar undo)
    local fixedAudio = 0
    local soundCandidates = {}
    forEachDescendant(game, function(desc)
        if desc:IsA("Sound") and #desc.SoundId > 0 and string.find(desc.SoundId, "rbxassetid://") then
            table.insert(soundCandidates, desc)
        end
    end)

    local failedSounds, soundVerdictOk = findUnplayableSounds(soundCandidates)
    if soundVerdictOk then
        for _, desc in ipairs(soundCandidates) do
            if failedSounds[desc.SoundId] then
                desc:SetAttribute("OriginalPrivateSoundId", desc.SoundId)
                desc.SoundId = FALLBACK_SOUNDS.Generic
                fixedAudio = fixedAudio + 1
            end
        end
    end

    -- 3. Blindar scripts
    local protectedScripts = 0
    for _, desc in ipairs(game:GetDescendants()) do
        if desc:IsA("LocalScript") or desc:IsA("ModuleScript") then
            local s, src = pcall(function() return desc.Source end)
            if s and src and (string.find(src, "Failed to decompile") or string.find(src, "decompilation failed")) then
                desc.Source = "-- [HyperSave Safe Stub]\nreturn function(...) return true end\n"
                protectedScripts = protectedScripts + 1
            end
        end
    end

    -- 4. Criar backend sintético com DataStores & VIP
    local remotesFolder = ServerScriptService:FindFirstChild("HyperSave_ServerBackend")
    if not remotesFolder then
        remotesFolder = Instance.new("Folder")
        remotesFolder.Name = "HyperSave_ServerBackend"
        remotesFolder.Parent = ServerScriptService
    end

    local serverScript = remotesFolder:FindFirstChild("ServerDispatcher")
    if not serverScript then
        serverScript = Instance.new("Script")
        serverScript.Name = "ServerDispatcher"
        serverScript.Parent = remotesFolder
    end

    local countFuncs = 0
    local countEvents = 0
    local code = [=[
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")

print("[HyperSave Master Backend] Servidor ativo! VIP & DataStore liberados.")

pcall(function()
    MarketplaceService.UserOwnsGamePassAsync = function(player, passId) return true end
    MarketplaceService.PlayerOwnsAsset = function(player, assetId) return true end
end)

local MockStores = {}
pcall(function()
    DataStoreService.GetDataStore = function(self, name, scope)
        local id = tostring(name) .. "_" .. tostring(scope or "global")
        if not MockStores[id] then
            local mem = {}
            MockStores[id] = {
                GetAsync = function(s, k) return mem[k] or {Coins = 1000000, Level = 50, Cash = 1000000} end,
                SetAsync = function(s, k, v) mem[k] = v return v end,
                UpdateAsync = function(s, k, fn) local curr = mem[k] or {Coins = 1000000, Level = 50, Cash = 1000000} local n = fn(curr) mem[k] = n return n end,
                RemoveAsync = function(s, k) local o = mem[k] mem[k] = nil return o end,
            }
        end
        return MockStores[id]
    end
end)

Players.PlayerAdded:Connect(function(player)
    local ls = player:FindFirstChild("leaderstats")
    if not ls then
        ls = Instance.new("Folder")
        ls.Name = "leaderstats"
        local coins = Instance.new("IntValue")
        coins.Name = "Coins"
        coins.Value = 1000000
        coins.Parent = ls
        local cash = Instance.new("IntValue")
        cash.Name = "Cash"
        cash.Value = 1000000
        cash.Parent = ls
        local level = Instance.new("IntValue")
        level.Name = "Level"
        level.Value = 50
        level.Parent = ls
        ls.Parent = player
    end
end)
]=]

    for _, desc in ipairs(game:GetDescendants()) do
        if desc:IsA("RemoteFunction") then
            countFuncs = countFuncs + 1
            code = code .. string.format("\npcall(function() (%s).OnServerInvoke = function(p, ...) return true, {Success=true} end end)", desc:GetFullName())
        elseif desc:IsA("RemoteEvent") then
            countEvents = countEvents + 1
            code = code .. string.format("\npcall(function() (%s).OnServerEvent:Connect(function(p, ...) end) end)", desc:GetFullName())
        end
    end

    pcall(function() serverScript.Source = code end)

    ChangeHistoryService:SetWaypoint("After HyperSave Master Repair")
    local summary = string.format("✓ Reparo concluído: %d pacotes desvinculados, %d áudios corrigidos, %d scripts blindados e %d remotes conectados.",
        unlockedPackages, fixedAudio, protectedScripts, countFuncs + countEvents)
    setStatus(summary, Color3.fromRGB(16, 185, 129))
end)

-- ============================================================================
-- FEATURE 1: SINTETIZAR SERVIDOR
-- ============================================================================
local cardServer = createCard(
    "1. Gerar Servidor Inteligente (ServerScriptService)",
    "Cria o backend automático para RemoteEvents e RemoteFunctions, evitando congelamento no InvokeServer.",
    1
)
cardServer.Parent = scroll

local btnServer = createButton(cardServer, "Gerar Backend de Servidor", Color3.fromRGB(37, 99, 235))

btnServer.MouseButton1Click:Connect(function()
    ChangeHistoryService:SetWaypoint("Before HyperSave Server Synthesizer")
    setStatus("Varrendo Remotes e gerando backend...", Color3.fromRGB(59, 130, 246))

    local remotesFolder = ServerScriptService:FindFirstChild("HyperSave_ServerBackend")
    if not remotesFolder then
        remotesFolder = Instance.new("Folder")
        remotesFolder.Name = "HyperSave_ServerBackend"
        remotesFolder.Parent = ServerScriptService
    end

    local countEvents = 0
    local countFuncs = 0

    local code = [=[
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")

print("[HyperSave Server] Servidor ativo com emulador de DataStore & VIP.")

pcall(function()
    MarketplaceService.UserOwnsGamePassAsync = function(player, passId) return true end
    MarketplaceService.PlayerOwnsAsset = function(player, assetId) return true end
end)

local MockStores = {}
pcall(function()
    DataStoreService.GetDataStore = function(self, name, scope)
        local id = tostring(name) .. "_" .. tostring(scope or "global")
        if not MockStores[id] then
            local mem = {}
            MockStores[id] = {
                GetAsync = function(s, k) return mem[k] or {Coins = 1000000, Level = 50, Cash = 1000000, Gems = 50000} end,
                SetAsync = function(s, k, v) mem[k] = v return v end,
                UpdateAsync = function(s, k, fn) local curr = mem[k] or {Coins = 1000000, Level = 50, Cash = 1000000, Gems = 50000} local n = fn(curr) mem[k] = n return n end,
                RemoveAsync = function(s, k) local o = mem[k] mem[k] = nil return o end,
            }
        end
        return MockStores[id]
    end
end)

-- Global Mock Frameworks (Knit & ReplicaService compatibility)
_G.KnitServices = _G.KnitServices or {}
_G.KnitControllers = _G.KnitControllers or {}

Players.PlayerAdded:Connect(function(player)
    local ls = player:FindFirstChild("leaderstats")
    if not ls then
        ls = Instance.new("Folder")
        ls.Name = "leaderstats"
        local coins = Instance.new("IntValue")
        coins.Name = "Coins"
        coins.Value = 1000000
        coins.Parent = ls
        local cash = Instance.new("IntValue")
        cash.Name = "Cash"
        cash.Value = 1000000
        cash.Parent = ls
        local gems = Instance.new("IntValue")
        gems.Name = "Gems"
        gems.Value = 50000
        gems.Parent = ls
        local level = Instance.new("IntValue")
        level.Name = "Level"
        level.Value = 50
        level.Parent = ls
        ls.Parent = player
    end
end)
]=]

    for _, desc in ipairs(game:GetDescendants()) do
        if desc:IsA("RemoteFunction") then
            countFuncs = countFuncs + 1
            code = code .. string.format("\npcall(function() (%s).OnServerInvoke = function(p, ...) return true, {Success=true} end end)", desc:GetFullName())
        elseif desc:IsA("RemoteEvent") then
            countEvents = countEvents + 1
            code = code .. string.format("\npcall(function() (%s).OnServerEvent:Connect(function(p, ...) end) end)", desc:GetFullName())
        end
    end

    local serverScript = remotesFolder:FindFirstChild("ServerDispatcher")
    if not serverScript then
        serverScript = Instance.new("Script")
        serverScript.Name = "ServerDispatcher"
        serverScript.Parent = remotesFolder
    end

    pcall(function()
        serverScript.Source = code
    end)

    ChangeHistoryService:SetWaypoint("After HyperSave Server Synthesizer")
    setStatus(string.format("✓ Servidor gerado com %d RemoteEvents e %d RemoteFunctions.", countEvents, countFuncs), Color3.fromRGB(16, 185, 129))
end)

-- ============================================================================
-- FEATURE 2: CORRIGIR SONS E ASSETS COM ERRO 403
-- ============================================================================
local cardAudio = createCard(
    "2. Consertar Áudios Bloqueados (Erro HTTP 403)",
    "Substitui sons de criadores privados por áudios públicos funcionais, eliminando erros no console.",
    2
)
cardAudio.Parent = scroll

local btnAudio = createButton(cardAudio, "Reparar Áudios Bloqueados", Color3.fromRGB(37, 99, 235))

btnAudio.MouseButton1Click:Connect(function()
    ChangeHistoryService:SetWaypoint("Before HyperSave Audio Sanitizer")
    setStatus("Analisando instâncias de Sound no jogo...", Color3.fromRGB(59, 130, 246))

    local candidates = {}
    forEachDescendant(game, function(desc)
        if desc:IsA("Sound") and #desc.SoundId > 0 and string.find(desc.SoundId, "rbxassetid://") then
            table.insert(candidates, desc)
        end
    end)

    local failed, verdictOk = findUnplayableSounds(candidates)
    if not verdictOk then
        setStatus("Não foi possível verificar quais áudios estão bloqueados; nada foi alterado.", Color3.fromRGB(245, 158, 11))
        return
    end

    local fixedCount = 0
    for _, desc in ipairs(candidates) do
        if failed[desc.SoundId] then
            desc:SetAttribute("OriginalPrivateSoundId", desc.SoundId)
            desc.SoundId = FALLBACK_SOUNDS.Generic
            fixedCount = fixedCount + 1
        end
    end

    ChangeHistoryService:SetWaypoint("After HyperSave Audio Sanitizer")
    setStatus(string.format("✓ %d de %d sons estavam inacessíveis e foram substituídos (os demais foram mantidos).", fixedCount, #candidates), Color3.fromRGB(16, 185, 129))
end)

-- ============================================================================
-- FEATURE 3: BLINDAGEM DE SCRIPTS DESCOMPILADOS
-- ============================================================================
local cardScripts = createCard(
    "3. Blindar Scripts Descompilados",
    "Adiciona proteções a scripts com falhas de descompilação para não interromper a execução.",
    3
)
cardScripts.Parent = scroll

local btnScripts = createButton(cardScripts, "Blindar Scripts Locais", Color3.fromRGB(37, 99, 235))

btnScripts.MouseButton1Click:Connect(function()
    ChangeHistoryService:SetWaypoint("Before HyperSave Script Shield")
    setStatus("Verificando scripts...", Color3.fromRGB(59, 130, 246))

    local protected = 0
    for _, desc in ipairs(game:GetDescendants()) do
        if desc:IsA("LocalScript") or desc:IsA("ModuleScript") then
            local s, src = pcall(function() return desc.Source end)
            if s and src then
                if string.find(src, "Failed to decompile") or string.find(src, "decompilation failed") then
                    desc.Source = "-- [HyperSave Safe Stub]\nreturn function(...) return true end\n"
                    protected = protected + 1
                end
            end
        end
    end

    ChangeHistoryService:SetWaypoint("After HyperSave Script Shield")
    setStatus(string.format("✓ %d scripts protegidos contra travamentos.", protected), Color3.fromRGB(16, 185, 129))
end)

-- ============================================================================
-- FEATURE 4: DESTRAVAR PERMISSÕES E REMOVER BLOQUEIOS DE PACOTES
-- ============================================================================
local cardUnlock = createCard(
    "4. Destravar Permissões e Peças",
    "Remove PackageLinks e desbloqueia peças travadas (Locked=false) para edição livre no Studio.",
    4
)
cardUnlock.Parent = scroll

local btnUnlock = createButton(cardUnlock, "Destravar Todas as Permissões", Color3.fromRGB(37, 99, 235))

btnUnlock.MouseButton1Click:Connect(function()
    ChangeHistoryService:SetWaypoint("Before HyperSave Permission Unlock")
    setStatus("Destravando modelos e removendo PackageLinks...", Color3.fromRGB(59, 130, 246))

    local unlockedPackages = 0
    local unlockedParts = 0

    for _, desc in ipairs(game:GetDescendants()) do
        if desc:IsA("PackageLink") then
            pcall(function()
                desc:Destroy()
                unlockedPackages = unlockedPackages + 1
            end)
        elseif desc:IsA("BasePart") then
            if desc.Locked then
                desc.Locked = false
                unlockedParts = unlockedParts + 1
            end
        end
    end

    ChangeHistoryService:SetWaypoint("After HyperSave Permission Unlock")
    setStatus(string.format("✓ %d pacotes desvinculados e %d peças destravadas.", unlockedPackages, unlockedParts), Color3.fromRGB(16, 185, 129))
end)

-- ============================================================================
-- FEATURE 5: INJETOR DE CÓDIGO LUA
-- ============================================================================
local cardCode = createCard(
    "5. Executar Código Luau Manual",
    "Permite colar blocos de script para reconstruir instâncias ou manipular objetos.",
    5
)
cardCode.Size = UDim2.new(1, 0, 0, 150)
cardCode.Parent = scroll

local codeBox = Instance.new("TextBox")
codeBox.PlaceholderText = "-- Cole seu código Luau aqui..."
codeBox.Font = Enum.Font.Gotham
codeBox.TextSize = 10
codeBox.TextColor3 = Color3.fromRGB(255, 255, 255)
codeBox.PlaceholderColor3 = Color3.fromRGB(113, 128, 150)
codeBox.BackgroundColor3 = Color3.fromRGB(14, 16, 22)
codeBox.ClearTextOnFocus = false
codeBox.MultiLine = true
codeBox.Size = UDim2.new(1, -24, 0, 44)
codeBox.Position = UDim2.new(0, 12, 0, 60)
codeBox.Parent = cardCode

local codeCorner = Instance.new("UICorner")
codeCorner.CornerRadius = UDim.new(0, 4)
codeCorner.Parent = codeBox

local btnExec = createButton(cardCode, "Executar Código", Color3.fromRGB(37, 99, 235))
btnExec.Position = UDim2.new(0, 12, 0, 110)

btnExec.MouseButton1Click:Connect(function()
    local text = codeBox.Text
    if #text == 0 then
        setStatus("Cole um código antes de executar.", Color3.fromRGB(220, 38, 38))
        return
    end

    local fn, err = loadstring(text)
    if not fn then
        setStatus("Erro de sintaxe no código: " .. tostring(err), Color3.fromRGB(220, 38, 38))
        return
    end

    ChangeHistoryService:SetWaypoint("Before Manual Exec")
    local ok, execErr = pcall(fn)
    if ok then
        ChangeHistoryService:SetWaypoint("After Manual Exec")
        setStatus("✓ Código executado com sucesso no Studio.", Color3.fromRGB(16, 185, 129))
    else
        setStatus("Erro ao executar: " .. tostring(execErr), Color3.fromRGB(220, 38, 38))
    end
end)

-- ============================================================================
-- FEATURE 6: ILUMINAÇÃO PBR + FUTURE
-- ============================================================================
local cardLight = createCard(
    "6. Atualizar Iluminação para PBR / Future",
    "Configura a tecnologia do Lighting para Future, ativa sombras suaves e efeitos atmosféricos.",
    6
)
cardLight.Parent = scroll

local btnLight = createButton(cardLight, "Aplicar Iluminação Future / PBR", Color3.fromRGB(37, 99, 235))

btnLight.MouseButton1Click:Connect(function()
    ChangeHistoryService:SetWaypoint("Before HyperSave Cinematic Lighting")
    setStatus("Aplicando tecnologia Future e efeitos visuais...", Color3.fromRGB(59, 130, 246))

    local Lighting = game:GetService("Lighting")
    pcall(function()
        Lighting.Technology = Enum.Technology.Future
        Lighting.ShadowSoftness = 0.2
        Lighting.EnvironmentDiffuseScale = 1
        Lighting.EnvironmentSpecularScale = 1
        Lighting.GlobalShadows = true

        local bloom = Lighting:FindFirstChildOfClass("BloomEffect") or Instance.new("BloomEffect", Lighting)
        bloom.Intensity = 0.8
        bloom.Size = 24
        bloom.Threshold = 1.2

        local sunrays = Lighting:FindFirstChildOfClass("SunRaysEffect") or Instance.new("SunRaysEffect", Lighting)
        sunrays.Intensity = 0.15
        sunrays.Spread = 0.8

        local colorCorr = Lighting:FindFirstChildOfClass("ColorCorrectionEffect") or Instance.new("ColorCorrectionEffect", Lighting)
        colorCorr.Brightness = 0.02
        colorCorr.Contrast = 0.05
        colorCorr.Saturation = 0.1
    end)

    ChangeHistoryService:SetWaypoint("After HyperSave Cinematic Lighting")
    setStatus("✓ Iluminação atualizada para qualidade Future / PBR.", Color3.fromRGB(16, 185, 129))
end)

-- ============================================================================
-- FEATURE 7: ESTABILIZADOR DE RIGS & NPCS
-- ============================================================================
local cardRigs = createCard(
    "7. Estabilizador de NPCs & Rigs de Personagens",
    "Garante que NPCs e personagens do mapa não desmontem ao dar Play no Studio.",
    7
)
cardRigs.Parent = scroll

local btnRigs = createButton(cardRigs, "Estabilizar NPCs e Rigs", Color3.fromRGB(37, 99, 235))

btnRigs.MouseButton1Click:Connect(function()
    ChangeHistoryService:SetWaypoint("Before HyperSave Rig Stabilizer")
    setStatus("Estabilizando Humanoids e Rigs no Workspace...", Color3.fromRGB(59, 130, 246))

    local stabilized = 0
    for _, desc in ipairs(workspace:GetDescendants()) do
        if desc:IsA("Humanoid") then
            local model = desc.Parent
            if model and model:IsA("Model") then
                local hrp = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model.PrimaryPart
                if hrp and hrp:IsA("BasePart") and not hrp.Anchored then
                    hrp.Anchored = true
                    stabilized = stabilized + 1
                end
            end
        end
    end

    ChangeHistoryService:SetWaypoint("After HyperSave Rig Stabilizer")
    setStatus(string.format("✓ %d NPCs/Rigs estabilizados com sucesso.", stabilized), Color3.fromRGB(16, 185, 129))
end)

-- ============================================================================
-- FEATURE 8: AUDITORIA DE ASSETS
-- ============================================================================
local cardManifest = createCard(
    "8. Auditoria de Texturas, Malhas e Sons",
    "Analisa as referências de assets no lugar e lista a quantidade de IDs identificados.",
    8
)
cardManifest.Parent = scroll

local btnAudit = createButton(cardManifest, "Auditar Assets do Mapa", Color3.fromRGB(37, 99, 235))

btnAudit.MouseButton1Click:Connect(function()
    setStatus("Auditando referências de assets...", Color3.fromRGB(59, 130, 246))

    local meshes = 0
    local textures = 0
    local sounds = 0
    local animations = 0

    for _, desc in ipairs(game:GetDescendants()) do
        if desc:IsA("MeshPart") or desc:IsA("SpecialMesh") then
            meshes = meshes + 1
        elseif desc:IsA("Decal") or desc:IsA("Texture") then
            textures = textures + 1
        elseif desc:IsA("Sound") then
            sounds = sounds + 1
        elseif desc:IsA("Animation") then
            animations = animations + 1
        end
    end

    local summary = string.format("✓ Auditoria concluída: %d Malhas, %d Texturas, %d Sons, %d Animações identificadas.",
        meshes, textures, sounds, animations)
    setStatus(summary, Color3.fromRGB(16, 185, 129))
end)

-- ============================================================================
-- FEATURE 9: AUTO-ANCORAR FÍSICA E ARQUITETURA ESTÁTICA
-- ============================================================================
local cardPhysics = createCard(
    "9. Estabilizador de Física & Arquitetura",
    "Ancora automaticamente peças e construções estáticas no Workspace para evitar que o mapa desmorone ao dar Play no Studio.",
    9
)
cardPhysics.Parent = scroll

local btnPhysics = createButton(cardPhysics, "Ancorar Construções do Workspace", Color3.fromRGB(37, 99, 235))

btnPhysics.MouseButton1Click:Connect(function()
    ChangeHistoryService:SetWaypoint("Before HyperSave Physics Stabilizer")
    setStatus("Ancorando partes do mapa...", Color3.fromRGB(59, 130, 246))

    local anchoredCount = 0
    local workspace = game:GetService("Workspace")
    for _, desc in ipairs(workspace:GetDescendants()) do
        if desc:IsA("BasePart") and not desc.Anchored then
            local isCharacter = false
            local model = desc:FindFirstAncestorOfClass("Model")
            if model and model:FindFirstChildOfClass("Humanoid") then
                isCharacter = true
            end
            if not isCharacter then
                desc.Anchored = true
                anchoredCount = anchoredCount + 1
            end
        end
    end

    ChangeHistoryService:SetWaypoint("After HyperSave Physics Stabilizer")
    setStatus(string.format("✓ %d peças estáticas ancoradas com sucesso para estabilidade física.", anchoredCount), Color3.fromRGB(16, 185, 129))
end)

-- ============================================================================
-- FEATURE 10: RESTAURAR SPAWNLOCATION & ÁREA SEGURA
-- ============================================================================
local cardSpawn = createCard(
    "10. Restaurar SpawnLocation & Área Inicial",
    "Garante que o mapa tenha um SpawnLocation neutro funcional no centro para evitar que o jogador caia no void.",
    10
)
cardSpawn.Parent = scroll

local btnSpawn = createButton(cardSpawn, "Verificar e Criar SpawnLocation", Color3.fromRGB(37, 99, 235))

btnSpawn.MouseButton1Click:Connect(function()
    ChangeHistoryService:SetWaypoint("Before HyperSave Spawn Restorer")
    local workspace = game:GetService("Workspace")
    local existingSpawn = workspace:FindFirstChildWhichIsA("SpawnLocation", true)

    if existingSpawn then
        setStatus(string.format("✓ SpawnLocation existente já encontrado em: %s", existingSpawn:GetFullName()), Color3.fromRGB(16, 185, 129))
    else
        local spawn = Instance.new("SpawnLocation")
        spawn.Name = "SafeSpawnLocation"
        spawn.Size = Vector3.new(12, 1, 12)
        spawn.Position = Vector3.new(0, 10, 0)
        spawn.Anchored = true
        spawn.Neutral = true
        spawn.Parent = workspace
        ChangeHistoryService:SetWaypoint("After HyperSave Spawn Restorer")
        setStatus("✓ SafeSpawnLocation neutro criado no centro do mapa (0, 10, 0)!", Color3.fromRGB(16, 185, 129))
    end
end)

-- ============================================================================
-- FEATURE 12: RECONECTAR ASSETS BAIXADOS (o elo que faltava)
--
-- O AssetDownloader grava HyperSave_Manifest_<PlaceId>.json junto dos arquivos
-- em audios/ textures/ meshes/ animations/, e ate agora nada lia esse manifesto
-- de volta: o README prometia "reconnecting supported local assets" e nao havia
-- uma linha de import no plugin.
--
-- Use apenas com conteudo que voce tem direito de reconstruir. Os ids
-- resultantes (rbxtemp://) valem para a sessao atual do Studio; para algo
-- permanente e preciso publicar os assets na sua propria conta.
-- ============================================================================
local cardImport = createCard(
    "12. Reconectar Assets Baixados",
    "Le o HyperSave_Manifest_<PlaceId>.json e os arquivos baixados e religa as referencias rbxassetid:// da arvore aberta aos arquivos locais.",
    12
)
cardImport.Parent = scroll

local btnImport = createButton(cardImport, "Escolher Manifesto e Arquivos...", Color3.fromRGB(16, 185, 129))

-- Which properties on which classes hold a content id. Anything not listed here
-- is simply left alone.
local CONTENT_PROPERTIES = {
    Decal = { "Texture" },
    Texture = { "Texture" },
    ImageLabel = { "Image" },
    ImageButton = { "Image" },
    Sound = { "SoundId" },
    MeshPart = { "MeshId", "TextureID" },
    SpecialMesh = { "MeshId", "TextureId" },
    ParticleEmitter = { "Texture" },
    Beam = { "Texture" },
    Trail = { "Texture" },
    Animation = { "AnimationId" },
    Sky = { "SkyboxBk", "SkyboxDn", "SkyboxFt", "SkyboxLf", "SkyboxRt", "SkyboxUp", "SunTextureId", "MoonTextureId" },
    SurfaceAppearance = { "ColorMap", "NormalMap", "MetalnessMap", "RoughnessMap" },
}

-- Files land as "<id>_<sanitized source name>.<ext>", so the id is the prefix.
local function assetIdFromFileName(name: string): string?
    return string.match(name, "^(%d+)_") or string.match(name, "^(%d+)%.")
end

local function numericId(contentId: string): string?
    if type(contentId) ~= "string" then return nil end
    return string.match(contentId, "rbxassetid://(%d+)")
        or string.match(contentId, "rbxasset://.-(%d+)")
        or string.match(contentId, "^(%d+)$")
end

btnImport.MouseButton1Click:Connect(function()
    local okManifest, manifestFiles = pcall(function()
        return StudioService:PromptImportFilesAsync({ "json" })
    end)

    if not okManifest then
        setStatus("Não foi possível abrir o seletor de arquivos: " .. tostring(manifestFiles), Color3.fromRGB(239, 68, 68))
        return
    end
    if not manifestFiles or #manifestFiles == 0 then
        setStatus("Nenhum manifesto selecionado.", Color3.fromRGB(245, 158, 11))
        return
    end

    local decoded
    local okDecode, decodeErr = pcall(function()
        decoded = HttpService:JSONDecode(manifestFiles[1]:GetBinaryContents())
    end)
    if not okDecode or type(decoded) ~= "table" or type(decoded.Assets) ~= "table" then
        setStatus("Manifesto inválido ou ilegível: " .. tostring(decodeErr), Color3.fromRGB(239, 68, 68))
        return
    end

    local manifestById = {}
    local manifestCount = 0
    for _, entry in ipairs(decoded.Assets) do
        if entry and entry.Id then
            manifestById[tostring(entry.Id)] = entry
            manifestCount = manifestCount + 1
        end
    end

    if manifestCount == 0 then
        setStatus("O manifesto não lista nenhum asset.", Color3.fromRGB(245, 158, 11))
        return
    end

    setStatus(string.format("Manifesto lido: %d assets. Selecione agora os arquivos baixados.", manifestCount), Color3.fromRGB(59, 130, 246))

    local okAssets, assetFiles = pcall(function()
        return StudioService:PromptImportFilesAsync({ "png", "jpg", "jpeg", "mp3", "ogg", "mesh", "rbxanim", "dat" })
    end)
    if not okAssets or not assetFiles or #assetFiles == 0 then
        setStatus("Nenhum arquivo de asset selecionado; nada foi alterado.", Color3.fromRGB(245, 158, 11))
        return
    end

    -- Map asset id -> temporary content id, skipping files the manifest does not
    -- know about instead of guessing.
    local tempIdByAsset = {}
    local matchedFiles, unmatchedFiles = 0, 0
    for _, file in ipairs(assetFiles) do
        local id = assetIdFromFileName(file.Name)
        if id and manifestById[id] then
            local okTemp, tempId = pcall(function()
                return file:GetTemporaryId()
            end)
            if okTemp and tempId then
                tempIdByAsset[id] = tempId
                matchedFiles = matchedFiles + 1
            else
                unmatchedFiles = unmatchedFiles + 1
            end
        else
            unmatchedFiles = unmatchedFiles + 1
        end
    end

    if matchedFiles == 0 then
        setStatus("Nenhum arquivo bateu com o manifesto (esperado: <id>_<nome>.<ext>).", Color3.fromRGB(239, 68, 68))
        return
    end

    local recording = ChangeHistoryService:TryBeginRecording("HyperSaveReconnectAssets", "Reconectar assets do manifesto")
    if not recording then
        setStatus("Não foi possível iniciar o registro de undo; nada foi alterado.", Color3.fromRGB(239, 68, 68))
        return
    end

    local rewritten, instancesTouched = 0, 0
    local okScan, scanErr = pcall(function()
        forEachDescendant(game, function(inst)
            local props = CONTENT_PROPERTIES[inst.ClassName]
            if not props then return end

            local touched = false
            for _, propName in ipairs(props) do
                local okRead, value = pcall(function()
                    return (inst :: any)[propName]
                end)
                if okRead and type(value) == "string" and #value > 0 then
                    local id = numericId(value)
                    local tempId = id and tempIdByAsset[id]
                    if tempId then
                        local okWrite = pcall(function()
                            -- Keep the original so this is reversible even
                            -- outside the undo stack.
                            inst:SetAttribute("HyperSaveOriginal_" .. propName, value)
                            ;(inst :: any)[propName] = tempId
                        end)
                        if okWrite then
                            rewritten = rewritten + 1
                            touched = true
                        end
                    end
                end
            end
            if touched then
                instancesTouched = instancesTouched + 1
            end
        end, function(done, total)
            setStatus(string.format("Religando assets... %d/%d instâncias", done, total), Color3.fromRGB(59, 130, 246))
        end)
    end)

    ChangeHistoryService:FinishRecording(
        recording,
        okScan and Enum.FinishRecordingOperation.Commit or Enum.FinishRecordingOperation.Cancel
    )

    if not okScan then
        setStatus("Falha durante a varredura, alterações revertidas: " .. tostring(scanErr), Color3.fromRGB(239, 68, 68))
        return
    end

    setStatus(string.format(
        "✓ %d referências religadas em %d instâncias (%d arquivos usados, %d ignorados). Ids rbxtemp:// valem nesta sessão do Studio.",
        rewritten, instancesTouched, matchedFiles, unmatchedFiles
    ), Color3.fromRGB(16, 185, 129))
end)

-- ============================================================================
-- FEATURE 11: DESENVOLVEDOR
-- ============================================================================
local cardDev = createCard(
    "Theo Lorentz Padilha",
    "Desenvolvido por Theo Lorentz Padilha. O link do repositório está abaixo.",
    13
)
cardDev.Parent = scroll

-- O botão anterior dizia "copiado" sem tocar em clipboard nenhum. Plugins não
-- têm API de clipboard, então o link é apenas exibido para ser copiado à mão.
local btnDevGithub = createButton(cardDev, "Mostrar Link do Repositório", Color3.fromRGB(36, 42, 56))

btnDevGithub.MouseButton1Click:Connect(function()
    setStatus("github.com/theopadilha2009-hash/HyperSaveInstance", Color3.fromRGB(16, 185, 129))
end)

print("[HyperSave Suite] Plugin carregado com sucesso!")
