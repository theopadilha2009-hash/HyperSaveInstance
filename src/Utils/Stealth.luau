--[[
    HyperSaveInstance - Stealth & Anti-Detection Shield
    Protects threads, hides temporary instances and masks operations from in-game anti-cheats.
]]

local Stealth = {}

-- Generate random alphanumeric name
function Stealth.GenerateRandomName(len: number?): string
    local length = len or 16
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local res = {}
    for i = 1, length do
        local r = math.random(1, #chars)
        table.insert(res, string.sub(chars, r, r))
    end
    return table.concat(res)
end

-- Safely protect GUI instance from detection
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
    if success then return val end
    return nil
end

return Stealth
