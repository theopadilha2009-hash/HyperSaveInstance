--[[
    HyperSaveInstance - Advanced Multi-Worker Script Decompiler & RemoteSpy Server Reconstructor
    Decompiles LocalScripts/ModuleScripts and generates functional backend dispatchers for Server Scripts.
]]

local Environment = require(script.Parent.Parent.Utils.Environment)
local Base64 = require(script.Parent.Parent.Utils.Base64)

local Decompiler = {}

-- Helper to get clean script path
local function getScriptPath(scriptInstance: LuaSourceContainer): string
    local names = {}
    local current: Instance? = scriptInstance
    while current and current ~= game do
        table.insert(names, 1, current.Name)
        current = current.Parent
    end
    return "game." .. table.concat(names, ".")
end

-- Generate banner comment for decompiled scripts
local function generateHeader(scriptInstance: LuaSourceContainer, status: string): string
    local path = getScriptPath(scriptInstance)
    local dateStr = os.date("%Y-%m-%d %H:%M:%S")
    local execName = Environment.GetExecutorName()
    
    return string.format([=[
--[[
    ================================================================================
    [HyperSaveInstance v2.0 - Decompiled Script]
    Created by: Theo Lorentz Padilha (https://github.com/theopadilha2009-hash)
    Class: %s
    Path: %s
    Status: %s
    Executor: %s
    Exported At: %s
    ================================================================================
]]

]=], scriptInstance.ClassName, path, status, execName, dateStr)
end

-- Intelligent script beautifier & variable name recoverer
function Decompiler.Beautify(code: string): string
    if not code or #code == 0 then return "" end

    local commonServices = {
        "Players", "ReplicatedStorage", "ReplicatedFirst", "RunService", "TweenService",
        "UserInputService", "HttpService", "SoundService", "Lighting", "Debris",
        "MarketplaceService", "TeleportService", "StarterGui", "ContextActionService"
    }

    local replacements = {}
    for _, service in ipairs(commonServices) do
        -- Match patterns: local v1 = game:GetService("Players")
        for varName in string.gmatch(code, "local%s+([%w_]+)%s*=%s*game:GetService%([\"']" .. service .. "[\"']%)") do
            if varName ~= service and string.match(varName, "^[vu_]%d+$") then
                replacements[varName] = service
            end
        end
    end

    local beautified = code
    for oldVar, newVar in pairs(replacements) do
        beautified = string.gsub(beautified, "([%s%(%[{,;=])" .. oldVar .. "([%s%)%]}:;%.])", "%1" .. newVar .. "%2")
        beautified = string.gsub(beautified, "local%s+" .. oldVar .. "%s*=", "local " .. newVar .. " =")
    end

    return beautified
end

-- Generate Intelligent Server Backend Dispatcher (RemoteSpy Auto-Generator)
local function generateServerDispatcher(scriptInstance: LuaSourceContainer): string
    local parent = scriptInstance.Parent
    local remotes = {}
    local functions = {}

    if parent then
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("RemoteEvent") then
                table.insert(remotes, child.Name)
            elseif child:IsA("RemoteFunction") then
                table.insert(functions, child.Name)
            end
        end
    end

    -- Look in ReplicatedStorage as well for common shared remotes
    local repStorage = game:GetService("ReplicatedStorage")
    local globalRemotes = {}
    if repStorage then
        for _, child in ipairs(repStorage:GetChildren()) do
            if child:IsA("RemoteEvent") then
                table.insert(globalRemotes, child.Name)
            end
        end
    end

    local code = [=[
-- [HyperSaveInstance RemoteSpy Backend Auto-Generator]
-- Reconstructed server-side logic and network event dispatcher.

local scriptName = %q
local parent = script.Parent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

print(string.format("[HyperSaveInstance Backend] Server script %%s initialized.", scriptName))

]=]

    code = string.format(code, scriptInstance.Name)

    -- Attach listeners for local remotes
    for _, remoteName in ipairs(remotes) do
        code = code .. string.format([=[
local %s = parent:FindFirstChild(%q)
if %s and %s:IsA("RemoteEvent") then
    %s.OnServerEvent:Connect(function(player, ...)
        local args = {...}
        print(string.format("[%s:OnServerEvent] Received from %%s (%%d args)", player.Name, #args))
        -- Backend logic dispatcher
    end)
end

]=], string.gsub(remoteName, "[^%w_]", "_"), remoteName, string.gsub(remoteName, "[^%w_]", "_"), string.gsub(remoteName, "[^%w_]", "_"), string.gsub(remoteName, "[^%w_]", "_"), remoteName)
    end

    -- Attach listeners for local RemoteFunctions
    for _, funcName in ipairs(functions) do
        code = code .. string.format([=[
local %s = parent:FindFirstChild(%q)
if %s and %s:IsA("RemoteFunction") then
    %s.OnServerInvoke = function(player, ...)
        local args = {...}
        print(string.format("[%s:OnServerInvoke] Invoked by %%s", player.Name))
        return true -- Default affirmative response
    end
end

]=], string.gsub(funcName, "[^%w_]", "_"), funcName, string.gsub(funcName, "[^%w_]", "_"), string.gsub(funcName, "[^%w_]", "_"), string.gsub(funcName, "[^%w_]", "_"), funcName)
    end

    return code
end

-- Decompile single script safely with timeout & retries
function Decompiler.DecompileSingle(scriptInstance: LuaSourceContainer, options: table): string
    -- 1. Check if source is directly readable (e.g. Studio, Mock, or unprotected environment)
    local directSource = nil
    pcall(function()
        local s = (scriptInstance :: any).Source
        if type(s) == "string" and #s > 0 then
            directSource = s
        end
    end)
    if directSource then
        return directSource
    end

    -- Check DecompileIgnore rules (USSI / Synapse X / Dino-V parity)
    if options.DecompileIgnore and type(options.DecompileIgnore) == "table" then
        local fullName = scriptInstance:GetFullName()
        for k, v in pairs(options.DecompileIgnore) do
            local pattern = (type(k) == "string" and k) or (type(v) == "string" and v) or nil
            local targetInst = (typeof(k) == "Instance" and k) or (typeof(v) == "Instance" and v) or nil
            if targetInst and (scriptInstance == targetInst or scriptInstance:IsDescendantOf(targetInst)) then
                return generateHeader(scriptInstance, "Decompile Skipped by Rule") ..
                    string.format("-- [Decompilation skipped by DecompileIgnore rule: %s]\n", targetInst:GetFullName())
            elseif pattern and (string.find(scriptInstance.Name, pattern, 1, true) or string.find(fullName, pattern, 1, true)) then
                return generateHeader(scriptInstance, "Decompile Skipped by Rule") ..
                    string.format("-- [Decompilation skipped by DecompileIgnore rule: %s]\n", tostring(pattern))
            end
        end
    end

    local isServerScript = scriptInstance:IsA("Script")
    if isServerScript then
        pcall(function()
            if (scriptInstance :: any).RunContext == Enum.RunContext.Client then
                isServerScript = false
            end
        end)
    end

    -- Server Scripts with server execution (Protected by FilteringEnabled -> Generate RemoteSpy Dispatcher)
    if isServerScript then
        if options.SaveServerScriptPlaceholders then
            return generateHeader(scriptInstance, "Reconstructed Server Backend (RemoteSpy Dispatcher)") ..
                generateServerDispatcher(scriptInstance)
        else
            return "-- [Server Script - Protected by FilteringEnabled]\n"
        end
    end

    local decompileFn = Environment.GetDecompilerFunction()
    local bytecodeFn = Environment.GetBytecodeFunction()
    local timeout = options.DecompileTimeout or 12

    -- 2. Attempt decompiler function
    if decompileFn then
        for attempt = 1, (options.DecompileMaxRetries or 2) + 1 do
            local result = nil
            local finished = false

            task.spawn(function()
                local success, output = pcall(decompileFn, scriptInstance)
                if success and type(output) == "string" and #output > 0 then
                    -- Filter out common tiny decompiler error stubs
                    local lower = string.lower(output)
                    if not (string.find(lower, "decompilation failed") or string.find(lower, "decompiler error")) or #output > 100 then
                        result = output
                    end
                end
                finished = true
            end)

            local elapsed = 0
            while not finished and elapsed < timeout do
                task.wait(0.05)
                elapsed = elapsed + 0.05
            end

            if finished and result then
                local beautified = Decompiler.Beautify(result)
                return generateHeader(scriptInstance, "Decompiled Successfully") .. beautified
            end
        end
    end

    -- 3. Fallback: Bytecode dump
    if bytecodeFn and options.ExtractBytecodeFallback then
        local success, bytecode = pcall(bytecodeFn, scriptInstance)
        if success and bytecode and #bytecode > 0 then
            local b64 = Base64.Encode(bytecode)
            return generateHeader(scriptInstance, "Extracted Raw Bytecode (Decompiler Unavailable)") ..
                string.format([=[
-- Raw Luau Bytecode (Base64 Encoded, Size: %d bytes):
-- You can disassemble or inspect this bytecode using any Luau bytecode viewer.

local rawBytecodeBase64 = %q
return rawBytecodeBase64
]=], #bytecode, b64)
        end
    end

    return generateHeader(scriptInstance, "Decompilation Failed / Unsupported Executor") ..
        "-- [Decompilation failed or not supported by current executor]\n"
end

-- Batch decompile multiple scripts concurrently with worker pool
function Decompiler.DecompileBatch(scripts: {LuaSourceContainer}, options: table, progressCallback: (current: number, total: number, script: LuaSourceContainer) -> ()): {[LuaSourceContainer]: string}
    local results = {}
    local total = #scripts
    local completed = 0
    local workers = math.clamp(options.DecompileParallelWorkers or 8, 1, 16)

    local queue = table.clone(scripts)
    local queueIndex = 1

    local threads = {}
    for w = 1, workers do
        local t = task.spawn(function()
            while queueIndex <= total do
                local myIndex = queueIndex
                queueIndex = queueIndex + 1

                local targetScript = queue[myIndex]
                if targetScript then
                    local code = Decompiler.DecompileSingle(targetScript, options)
                    results[targetScript] = code
                    completed = completed + 1

                    if progressCallback then
                        pcall(progressCallback, completed, total, targetScript)
                    end
                end
                task.wait(0.01)
            end
        end)
        table.insert(threads, t)
    end

    -- Wait for all scripts to finish
    while completed < total do
        task.wait(0.1)
    end

    return results
end

return Decompiler
