--[[
    HyperSaveInstance - Stealth & Anti-Detection Shield
    Protects threads, masks operations, hides UI instances and suppresses telemetry from in-game anti-cheats.
]]

local Stealth = {}

local clonerefFn = cloneref or function(obj)
    return obj
end
local HttpService = nil
pcall(function()
    HttpService = clonerefFn(game:GetService("HttpService"))
end)

-- Generate ephemeral GUID for instance naming (Prevents static string signature detection)
function Stealth.GenerateEphemeralGUID(): string
    if HttpService and HttpService.GenerateGUID then
        local s, guid = pcall(function()
            return HttpService:GenerateGUID(false)
        end)
        if s and guid then
            return string.gsub(guid, "%-", "")
        end
    end
    return Stealth.GenerateRandomName(24)
end

-- Generate random alphanumeric name
function Stealth.GenerateRandomName(len: number?): string
    local length = len or 20
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local res = {}
    for i = 1, length do
        local r = math.random(1, #chars)
        table.insert(res, string.sub(chars, r, r))
    end
    return table.concat(res)
end

-- Safely protect GUI instance from anti-cheat detection
function Stealth.ProtectGui(gui: Instance): boolean
    local protected = false
    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(gui)
            protected = true
        elseif protectgui then
            protectgui(gui)
            protected = true
        elseif protect_gui then
            protect_gui(gui)
            protected = true
        end
    end)
    return protected
end

-- Safely request map streaming around coordinates without moving character
function Stealth.SafeStreamAround(position: Vector3, player: any?): boolean
    local requested = false
    pcall(function()
        if player and player.RequestStreamAroundAsync then
            player:RequestStreamAroundAsync(position)
            requested = true
        elseif workspace and workspace.RequestStreamAroundAsync then
            workspace:RequestStreamAroundAsync(position)
            requested = true
        end
    end)
    return requested
end

-- Safely elevate thread identity if supported by executor
function Stealth.ElevateThread()
    pcall(function()
        if syn and syn.set_thread_identity then
            syn.set_thread_identity(8)
        elseif setidentity then
            setidentity(8)
        elseif setthreadidentity then
            setthreadidentity(8)
        elseif set_thread_identity then
            set_thread_identity(8)
        end
    end)
end

-- Safely read property with error insulation
function Stealth.SafeGetProperty(instance: Instance, property: string): any
    local success, val = pcall(function()
        return (instance :: any)[property]
    end)
    if success then
        return val
    end
    return nil
end

-- Mask Luau functions as native C closures to prevent hook detection
function Stealth.MaskClosure(fn: (...any) -> ...any): (...any) -> ...any
    if typeof(fn) ~= "function" then
        return fn
    end
    local masked = fn
    pcall(function()
        if newcclosure then
            masked = newcclosure(fn)
        end
    end)
    return masked
end

-- Lock metatable to prevent external inspection or tampering
function Stealth.ProtectMetatable(tbl: table): table
    if type(tbl) ~= "table" then
        return tbl
    end
    pcall(function()
        local mt = getrawmetatable and getrawmetatable(tbl) or getmetatable(tbl)
        if mt then
            if setreadonly then
                setreadonly(mt, false)
            end
            mt.__metatable = "The metatable is locked"
            if setreadonly then
                setreadonly(mt, true)
            end
        else
            setmetatable(tbl, {
                __metatable = "The metatable is locked",
            })
        end
    end)
    return tbl
end

-- Check if instance belongs to Roblox internal telemetry or CoreGui
function Stealth.IsInternalOrProtected(instance: Instance): boolean
    if not instance then
        return true
    end
    local isInternal = false
    pcall(function()
        local name = instance.Name
        local className = instance.ClassName
        if
            string.find(name, "RobloxNetworkAutoTest")
            or string.find(name, "Telemetry")
            or string.find(name, "MemStorageConnection")
            or string.find(name, "CoreScript")
            or className == "PluginMouse"
            or className == "RobloxPluginGui"
        then
            isInternal = true
        end
    end)
    return isInternal
end

return Stealth
