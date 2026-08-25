--[[
    HyperSaveInstance - Advanced Multi-Worker Script Decompiler Engine
    Decompiles LocalScripts, ModuleScripts and reconstructs Server Script stubs.
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
    [HyperSaveInstance - Decompiled Script]
    Class: %s
    Path: %s
    Status: %s
    Executor: %s
    Exported At: %s
]]

]=], scriptInstance.ClassName, path, status, execName, dateStr)
end

-- Decompile single script safely with timeout & retries
function Decompiler.DecompileSingle(scriptInstance: LuaSourceContainer, options: table): string
    local decompileFn = Environment.GetDecompilerFunction()
    local bytecodeFn = Environment.GetBytecodeFunction()
    local timeout = options.DecompileTimeout or 10

    -- Server Scripts (Roblox FilteringEnabled prevents client from downloading server script bytecode)
    if scriptInstance:IsA("Script") then
        if options.SaveServerScriptPlaceholders then
            local path = getScriptPath(scriptInstance)
            return generateHeader(scriptInstance, "Server-Side Placeholder (Protected by FilteringEnabled)") ..
                string.format([=[
-- NOTE: Server script bytecode is stored exclusively on Roblox Game Servers and cannot be downloaded by clients.
-- HyperSaveInstance preserved this script's full hierarchy, properties, attributes, and tags.

local scriptName = %q
local scriptParent = script.Parent

print("[HyperSaveInstance] Placeholder active for server script: " .. scriptName)
]=], scriptInstance.Name)
        else
            return "-- [Server Script - Bytecode unavailable on client]\n"
        end
    end

    -- Attempt decompiler function
    if decompileFn then
        for attempt = 1, (options.DecompileMaxRetries or 2) + 1 do
            local result = nil
            local finished = false

            local thread = task.spawn(function()
                local success, output = pcall(decompileFn, scriptInstance)
                if success and type(output) == "string" and #output > 0 then
                    result = output
                end
                finished = true
            end)

            local elapsed = 0
            while not finished and elapsed < timeout do
                task.wait(0.1)
                elapsed = elapsed + 0.1
            end

            if finished and result then
                return generateHeader(scriptInstance, "Decompiled Successfully") .. result
            end
        end
    end

    -- Fallback: Bytecode dump
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
