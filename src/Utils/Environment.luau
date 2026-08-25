--[[
    HyperSaveInstance - Universal Environment & Polyfill Module
    Supports Mac (MacSploit, Hydrogen), Windows (Wave, Synapse Z, Solara, Celery, etc.), Mobile (Delta, Codex, Arceus X)
]]

local Environment = {}

-- Service references
local cloneref = cloneref or function(obj) return obj end
local HttpService = cloneref(game:GetService("HttpService"))
local Players = cloneref(game:GetService("Players"))
local CoreGui = cloneref(game:GetService("CoreGui"))

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

-- Decompiler capability detection
local _decompile = decompile or (syn and syn.decompile) or (getscriptclosure and function(s) return "-- [Fallback Closure Extracted]\n" end) or disassemble
local _getscriptbytecode = getscriptbytecode or (syn and syn.getscriptbytecode) or (get_script_bytecode) or dumpstring

function Environment.HasDecompiler(): boolean
    return type(_decompile) == "function" or type(_getscriptbytecode) == "function"
end

function Environment.GetDecompilerFunction()
    if type(_decompile) == "function" then
        return _decompile
    end
    return nil
end

function Environment.GetBytecodeFunction()
    if type(_getscriptbytecode) == "function" then
        return _getscriptbytecode
    end
    return nil
end

-- Safe UI Parent (Protects GUI from detection/detection hooks)
function Environment.GetSafeGuiParent(): Instance
    local success, hui = pcall(function()
        if gethui then
            return gethui()
        elseif syn and syn.protect_gui then
            local folder = Instance.new("Folder")
            syn.protect_gui(folder)
            folder.Parent = CoreGui
            return folder
        elseif CoreGui and pcall(function() return CoreGui.Name end) then
            return CoreGui
        else
            return Players.LocalPlayer:WaitForChild("PlayerGui")
        end
    end)

    if success and hui then
        return hui
    end
    return Players.LocalPlayer:WaitForChild("PlayerGui")
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
