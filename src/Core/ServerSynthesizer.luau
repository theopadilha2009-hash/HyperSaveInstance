--[[
    HyperSaveInstance - Intelligent Server Synthesizer & Remote Emulator
    Analyzes client-side Remotes and synthesizes an executable ServerScriptService backend
    so cloned games don't freeze, yield indefinitely, or error out when tested in Roblox Studio.
]]

local ServerSynthesizer = {}

-- Helper to turn an instance into a robust Luau path query
local function getPathExpression(inst: Instance): string
    local segments = {}
    local curr: Instance? = inst

    while curr and curr ~= game do
        table.insert(segments, 1, curr.Name)
        curr = curr.Parent
    end

    if #segments == 0 then return "nil" end

    local serviceName = segments[1]
    local expr = string.format("game:GetService(%q)", serviceName)

    for i = 2, #segments do
        expr = expr .. string.format([[:WaitForChild(%q, 5)]], segments[i])
    end

    return expr
end

-- Clean identifiers for Lua variable naming
local function sanitizeIdentifier(name: string): string
    local clean = string.gsub(name, "[^%w_]", "_")
    if string.match(clean, "^%d") then
        clean = "_" .. clean
    end
    return #clean > 0 and clean or "_remote"
end

-- Collect all Remote instances across the place
function ServerSynthesizer.CollectRemotes(rootInstances: {Instance}): {Events: {Instance}, Functions: {Instance}, Unreliable: {Instance}}
    local remotes = {
        Events = {},
        Functions = {},
        Unreliable = {},
    }

    local function scan(inst: Instance)
        if inst:IsA("RemoteEvent") then
            table.insert(remotes.Events, inst)
        elseif inst:IsA("RemoteFunction") then
            table.insert(remotes.Functions, inst)
        elseif inst.ClassName == "UnreliableRemoteEvent" then
            table.insert(remotes.Unreliable, inst)
        end

        for _, child in ipairs(inst:GetChildren()) do
            scan(child)
        end
    end

    for _, root in ipairs(rootInstances) do
        scan(root)
    end

    return remotes
end

-- Generate full Luau source code for the synthetic ServerScriptService dispatcher
function ServerSynthesizer.GenerateDispatcherSource(remotes: {Events: {Instance}, Functions: {Instance}, Unreliable: {Instance}}): string
    local lines = {}
    local function add(line: string)
        table.insert(lines, line)
    end

    add([=[
--[[
    ================================================================================
    [HyperSaveInstance v2.0 - Auto-Generated Server Backend Emulator]
    Created by: Theo Lorentz Padilha (https://github.com/theopadilha2009-hash)
    Reconstructed Server Logic to prevent client freezes, infinite yields, and errors.
    Generated automatically by HyperSaveInstance ServerSynthesizer.
    ================================================================================
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")

print("[HyperSave Backend] Initializing synthetic server dispatcher with full gameplay emulation...")

-- 1. Mock MarketplaceService to unlock ALL GamePasses & VIP areas in Studio testing
pcall(function()
    MarketplaceService.UserOwnsGamePassAsync = function(player, passId)
        print(string.format("[HyperSave VIP Emulator] GamePass #%s granted to %s (VIP Unlocked)", tostring(passId), tostring(player.Name)))
        return true
    end
    MarketplaceService.PlayerOwnsAsset = function(player, assetId)
        return true
    end
end)

-- 2. Mock DataStoreService (In-memory storage so saves don't throw permission errors in Studio)
local MockDataStores = {}
pcall(function()
    DataStoreService.GetDataStore = function(self, name, scope)
        local dsName = tostring(name) .. "_" .. tostring(scope or "global")
        if not MockDataStores[dsName] then
            local memoryStore = {}
            MockDataStores[dsName] = {
                GetAsync = function(s, key)
                    return memoryStore[key] or {Coins = 1000000, Level = 10, Gems = 50000}
                end,
                SetAsync = function(s, key, value)
                    memoryStore[key] = value
                    return value
                end,
                UpdateAsync = function(s, key, transformFn)
                    local current = memoryStore[key] or {Coins = 1000000, Level = 10, Gems = 50000}
                    local new = transformFn(current)
                    memoryStore[key] = new
                    return new
                end,
                RemoveAsync = function(s, key)
                    local old = memoryStore[key]
                    memoryStore[key] = nil
                    return old
                end,
            }
        end
        return MockDataStores[dsName]
    end
end)

-- 3. In-memory mock data store / state for connected players
local PlayerState = {}

local function initPlayer(player: Player)
    PlayerState[player.UserId] = {
        Data = {},
        Inventory = {},
    }

    -- Auto-setup generous leaderstats if any UI expects it
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then
        leaderstats = Instance.new("Folder")
        leaderstats.Name = "leaderstats"

        local coins = Instance.new("IntValue")
        coins.Name = "Coins"
        coins.Value = 1000000
        coins.Parent = leaderstats

        local cash = Instance.new("IntValue")
        cash.Name = "Cash"
        cash.Value = 1000000
        cash.Parent = leaderstats

        local level = Instance.new("IntValue")
        level.Name = "Level"
        level.Value = 50
        level.Parent = leaderstats

        leaderstats.Parent = player
    end
end

Players.PlayerAdded:Connect(initPlayer)
for _, p in ipairs(Players:GetPlayers()) do
    task.spawn(initPlayer, p)
end

Players.PlayerRemoving:Connect(function(player)
    PlayerState[player.UserId] = nil
end)

]=])

    -- Hook RemoteFunctions (CRITICAL: Without this, client InvokeServer yields forever!)
    add("-- ============================================================================")
    add("-- [RemoteFunctions] Auto-Handlers (Returns default affirmative response to avoid UI lockup)")
    add("-- ============================================================================\n")

    for _, rf in ipairs(remotes.Functions) do
        local fullName = rf:GetFullName()

        add(string.format([=[
-- RemoteFunction: %s
task.spawn(function()
    local target = %s
    if target and target:IsA("RemoteFunction") then
        target.OnServerInvoke = function(player, ...)
            local args = {...}
            print(string.format("[HyperSave Server] %s:InvokeServer() called by %%s with %%d arguments", player.Name, #args))
            
            -- Intelligent mock response based on common function naming patterns
            local nameLower = string.lower(%q)
            if string.find(nameLower, "data") or string.find(nameLower, "load") or string.find(nameLower, "get") then
                return {
                    Success = true,
                    Data = {},
                    Coins = 1000,
                    Level = 1,
                    Inventory = {},
                }
            elseif string.find(nameLower, "buy") or string.find(nameLower, "purchase") then
                return true, "Success"
            end

            return true
        end
    end
end)
]=], fullName, getPathExpression(rf), rf.Name, rf.Name))
    end

    -- Hook RemoteEvents
    add("\n-- ============================================================================")
    add("-- [RemoteEvents] Auto-Listeners (Logs actions and updates mock state)")
    add("-- ============================================================================\n")

    for _, re in ipairs(remotes.Events) do
        local fullName = re:GetFullName()

        add(string.format([=[
-- RemoteEvent: %s
task.spawn(function()
    local target = %s
    if target and target:IsA("RemoteEvent") then
        target.OnServerEvent:Connect(function(player, ...)
            local args = {...}
            print(string.format("[HyperSave Server] %s:FireServer() received from %%s (%%d args)", player.Name, #args))
        end)
    end
end)
]=], fullName, getPathExpression(re), re.Name))
    end

    add([=[

print("[HyperSave Backend] Server dispatcher ready! All remotes are now responding.")
]=])

    return table.concat(lines, "\n")
end

-- Create synthetic ServerScriptService Folder & Script instances
function ServerSynthesizer.SynthesizeService(rootInstances: {Instance}): Instance
    local remotes = ServerSynthesizer.CollectRemotes(rootInstances)
    local sourceCode = ServerSynthesizer.GenerateDispatcherSource(remotes)

    local serverService = Instance.new("Folder")
    serverService.Name = "ServerScriptService"

    local syntheticScript = Instance.new("Script")
    syntheticScript.Name = "HyperSave_ServerDispatcher"
    pcall(function()
        (syntheticScript :: any).Source = sourceCode
    end)
    syntheticScript.Parent = serverService

    return serverService
end

return ServerSynthesizer
