--[[
    HyperSaveInstance - Universal Environment & Polyfill Module
    Supports Mac (MacSploit, Hydrogen), Windows (Wave, Synapse Z, Solara, Celery, etc.), Mobile (Delta, Codex, Arceus X)
]]

local Environment = {}

-- Service references (Safely wrapped in pcalls for all execution identities)
local cloneref = cloneref or function(obj) return obj end
local HttpService = nil
pcall(function() HttpService = cloneref(game:GetService("HttpService")) end)
local Players = nil
pcall(function() Players = cloneref(game:GetService("Players")) end)
local CoreGui = nil
pcall(function() CoreGui = cloneref(game:GetService("CoreGui")) end)

-- Universal Task polyfill
local task = task or {
    spawn = spawn or function(fn, ...) return coroutine.wrap(fn)(...) end,
    wait = wait or function(t) return coroutine.yield(t) end,
    delay = delay or function(t, fn) return task.spawn(function() task.wait(t); fn() end) end,
    defer = function(fn, ...) return (spawn or task.spawn)(function(...) fn(...) end, ...) end
}

-- Table & Math polyfills
table.clone = table.clone or function(t)
    if type(t) ~= "table" then return t end
    local clone = {}
    for k, v in pairs(t) do
        clone[k] = v
    end
    return clone
end

table.create = table.create or function(count, val)
    local t = {}
    for i = 1, (count or 0) do
        t[i] = val
    end
    return t
end

table.clear = table.clear or function(t)
    if type(t) ~= "table" then return end
    for k in pairs(t) do
        t[k] = nil
    end
end

table.find = table.find or function(t, val, init)
    if type(t) ~= "table" then return nil end
    for i = (init or 1), #t do
        if t[i] == val then return i end
    end
    return nil
end

math.clamp = math.clamp or function(x, min, max)
    return math.max(min, math.min(max, x))
end
math.round = math.round or function(x)
    return math.floor(x + 0.5)
end

-- Identify executor & platform
function Environment.GetExecutorName(): string
    if identifyexecutor then
        local name, ver = identifyexecutor()
        return tostring(name) .. (ver and (" " .. tostring(ver)) or "")
    elseif getexecutorname then
        return tostring(getexecutorname())
    elseif syn and type(syn) == "table" then
        return "Synapse V3/Legacy"
    elseif KRNL_LOADED then
        return "KRNL"
    elseif fluxus then
        return "Fluxus"
    elseif is_sirhurt_closure then
        return "Sirhurt"
    elseif OXYGEN_LOADED then
        return "Oxygen U"
    elseif MACSPLOIT_LOADED or (identifyexecutor and string.find(string.lower(tostring(identifyexecutor())), "mac")) then
        return "MacSploit"
    elseif HYDROGEN_LOADED or (identifyexecutor and string.find(string.lower(tostring(identifyexecutor())), "hydrogen")) then
        return "Hydrogen"
    else
        return "Universal / Unknown Executor"
    end
end

function Environment.GetPlatform(): string
    local isMac = false
    local isWindows = false
    local isMobile = false

    local exec = string.lower(Environment.GetExecutorName())
    if string.find(exec, "mac") or string.find(exec, "apple") or (getexecutorinfo and getexecutorinfo().platform == "macOS") then
        isMac = true
    elseif string.find(exec, "delta") or string.find(exec, "codex") or string.find(exec, "arceus") or string.find(exec, "hydrogen mobile") then
        isMobile = true
    else
        isWindows = true
    end

    if isMac then return "macOS" end
    if isMobile then return "Mobile" end
    return "Windows / Desktop"
end

-- File system polyfills
local _writefile = writefile or (syn and syn.writefile)
local _readfile = readfile or (syn and syn.readfile)
local _appendfile = appendfile or (syn and syn.appendfile)
local _makefolder = makefolder or (syn and syn.makefolder)
local _isfolder = isfolder or (syn and syn.isfolder)
local _isfile = isfile or (syn and syn.isfile)
local _delfile = delfile or (syn and syn.delfile) or (delfile)
local _listfiles = listfiles or (syn and syn.listfiles)

function Environment.HasFileSystem(): boolean
    return type(_writefile) == "function"
end

function Environment.WriteFile(path: string, content: string): boolean
    if _writefile then
        local success, err = pcall(_writefile, path, content)
        if not success then
            warn("[HyperSaveInstance] WriteFile failed: " .. tostring(err))
            return false
        end
        return true
    end
    warn("[HyperSaveInstance] No writefile capability detected in current executor!")
    return false
end

function Environment.AppendFile(path: string, content: string): boolean
    if _appendfile then
        local success, err = pcall(_appendfile, path, content)
        return success
    elseif _readfile and _writefile then
        local existing = ""
        pcall(function() existing = _readfile(path) or "" end)
        return Environment.WriteFile(path, existing .. content)
    end
    return false
end

function Environment.ReadFile(path: string): string?
    if _readfile then
        local success, result = pcall(_readfile, path)
        if success then return result end
    end
    return nil
end

function Environment.MakeFolder(path: string): boolean
    if _makefolder then
        local success = pcall(_makefolder, path)
        return success
    end
    return false
end

function Environment.IsFolder(path: string): boolean
    if _isfolder then
        local success, res = pcall(_isfolder, path)
        return success and (res == true)
    end
    return false
end

function Environment.IsFile(path: string): boolean
    if _isfile then
        local success, res = pcall(_isfile, path)
        return success and (res == true)
    end
    return false
end

-- Decompiler capability detection (Dynamic lookup supporting MacSploit, Hydrogen, Synapse Z, Wave, Delta, Codex, etc.)
function Environment.GetDecompilerFunction()
    local genv = (getgenv and getgenv()) or {}
    local renv = (getrenv and getrenv()) or {}
    
    -- Check functions in order of fidelity
    local candidates = {
        genv.decompile,
        decompile,
        renv.decompile,
        (syn and syn.decompile),
        genv.custom_decompile,
        custom_decompile,
        (syn and syn.custom_decompile),
        genv.disassemble,
        disassemble,
    }
    
    for _, fn in ipairs(candidates) do
        if type(fn) == "function" then
            return fn
        end
    end
    return nil
end

function Environment.GetBytecodeFunction()
    local genv = (getgenv and getgenv()) or {}
    local renv = (getrenv and getrenv()) or {}
    
    local candidates = {
        genv.getscriptbytecode,
        getscriptbytecode,
        genv.get_script_bytecode,
        get_script_bytecode,
        renv.getscriptbytecode,
        (syn and syn.getscriptbytecode),
        genv.dumpstring,
        dumpstring,
    }
    
    for _, fn in ipairs(candidates) do
        if type(fn) == "function" then
            return fn
        end
    end
    return nil
end

function Environment.HasDecompiler(): boolean
    return Environment.GetDecompilerFunction() ~= nil or Environment.GetBytecodeFunction() ~= nil
end

-- Safe UI Parent (Protects GUI from detection/detection hooks, universal across Delta, Hydrogen, MacSploit, Solara, etc.)
function Environment.GetSafeGuiParent(): Instance
    -- 1. Try gethui() if supported (Delta, Wave, Hydrogen, MacSploit)
    if gethui then
        local success, res = pcall(gethui)
        if success and res and typeof(res) == "Instance" then
            return res
        end
    end

    -- 2. Try CoreGui if accessible
    local coreGui = nil
    pcall(function()
        coreGui = game:GetService("CoreGui")
    end)
    if coreGui then
        local canAccess, name = pcall(function()
            return coreGui.Name
        end)
        if canAccess and name then
            return coreGui
        end
    end

    -- 3. Fallback to LocalPlayer's PlayerGui (Safe non-blocking)
    local pgui = nil
    pcall(function()
        local plrs = game:GetService("Players")
        local lp = plrs.LocalPlayer or plrs:FindFirstChildOfClass("Player")
        if lp then
            pgui = lp:FindFirstChildOfClass("PlayerGui")
        end
    end)
    if pgui then
        return pgui
    end

    -- 4. Fallback to CoreGui or return game
    return coreGui or game
end

-- Clipboard copy
function Environment.SetClipboard(text: string): boolean
    local setclip = setclipboard or (syn and syn.setclipboard) or toclipboard or (Clipboard and Clipboard.set)
    if setclip then
        pcall(setclip, text)
        return true
    end
    return false
end

-- Nil instances extraction
function Environment.GetNilInstances(): {Instance}
    local getnil = getnilinstances or (syn and syn.get_nil_instances) or (get_nil_instances)
    if getnil then
        local success, res = pcall(getnil)
        if success and type(res) == "table" then
            return res
        end
    end
    return {}
end

-- Hidden UI elements / CorePackages check
function Environment.GetHiddenProperties(instance: Instance, property: string): any
    local gethidden = gethiddenproperty or (syn and syn.get_hidden_property)
    if gethidden then
        local success, val = pcall(gethidden, instance, property)
        if success then return val end
    end
    local s, v = pcall(function() return (instance :: any)[property] end)
    if s then return v end
    return nil
end

return Environment
