--[[
    HyperSaveInstance - Live Network Traffic Sniffer & RemoteSpy
    Logs and intercepts RemoteEvent / RemoteFunction calls to reverse-engineer client-server network protocols.
]]

local HttpService = nil
pcall(function() HttpService = game:GetService("HttpService") end)
local Environment = require(script.Parent.Parent.Utils.Environment)

local NetworkSniffer = {}
NetworkSniffer.IsActive = false
NetworkSniffer.CapturedLogs = {}
NetworkSniffer.Listeners = {}

local originalFireServer = nil
local originalInvokeServer = nil

-- Format arguments safely into readable string / json
local function serializeArgs(args: table): string
    local s, json = pcall(function()
        return HttpService:JSONEncode(args)
    end)
    if s and json then return json end

    local parts = {}
    for i, v in ipairs(args) do
        table.insert(parts, tostring(v) .. " (" .. typeof(v) .. ")")
    end
    return "{" .. table.concat(parts, ", ") .. "}"
end

-- Start live packet sniffing
function NetworkSniffer.Start()
    if NetworkSniffer.IsActive then return end
    NetworkSniffer.IsActive = true

    -- Hook Metamethod __namecall if executor supports hookmetamethod
    local hookmeta = hookmetamethod or (syn and syn.hookmetamethod)
    if hookmeta then
        local oldNamecall
        oldNamecall = hookmeta(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if NetworkSniffer.IsActive and typeof(self) == "Instance" then
                if method == "FireServer" and self:IsA("RemoteEvent") then
                    local args = {...}
                    NetworkSniffer.LogCall("FireServer", self, args)
                elseif method == "InvokeServer" and self:IsA("RemoteFunction") then
                    local args = {...}
                    NetworkSniffer.LogCall("InvokeServer", self, args)
                end
            end
            return oldNamecall(self, ...)
        end)
    end
end

-- Stop packet sniffing
function NetworkSniffer.Stop()
    NetworkSniffer.IsActive = false
end

-- Record a network event
function NetworkSniffer.LogCall(callType: string, remote: Instance, args: table)
    local entry = {
        Timestamp = os.date("%H:%M:%S"),
        Type = callType,
        RemoteName = remote.Name,
        RemotePath = remote:GetFullName(),
        ArgCount = #args,
        ArgsPreview = serializeArgs(args),
        RawArgs = args,
    }

    table.insert(NetworkSniffer.CapturedLogs, entry)

    -- Notify listeners (HUD)
    for _, cb in ipairs(NetworkSniffer.Listeners) do
        task.spawn(cb, entry)
    end
end

-- Register UI listener
function NetworkSniffer.OnCall(callback: (entry: table) -> ())
    table.insert(NetworkSniffer.Listeners, callback)
end

-- Export captured network protocol to file
function NetworkSniffer.ExportLogs(): string
    local placeId = game.PlaceId or 0
    local fileName = string.format("HyperSave_Network_%d.json", placeId)

    local s, json = pcall(function()
        return HttpService:JSONEncode(NetworkSniffer.CapturedLogs)
    end)

    if not s or not json then
        local lines = {}
        for _, log in ipairs(NetworkSniffer.CapturedLogs) do
            table.insert(lines, string.format("[%s] [%s] %s -> %s", log.Timestamp, log.Type, log.RemotePath, log.ArgsPreview))
        end
        json = table.concat(lines, "\n")
    end

    Environment.WriteFile(fileName, json)
    return fileName
end

function NetworkSniffer.Clear()
    NetworkSniffer.CapturedLogs = {}
end

return NetworkSniffer
