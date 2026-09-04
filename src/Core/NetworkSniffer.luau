--[[
    HyperSaveInstance - Live Network Traffic Sniffer & RemoteSpy
    Logs and intercepts RemoteEvent / RemoteFunction calls to reverse-engineer client-server network protocols.
]]

local clonerefFn = cloneref or function(obj) return obj end
local HttpService = nil
pcall(function() HttpService = clonerefFn(game:GetService("HttpService")) end)
local Environment = require(script.Parent.Parent.Utils.Environment)

local NetworkSniffer = {}
NetworkSniffer.IsActive = false
NetworkSniffer.CapturedLogs = {}
NetworkSniffer.Listeners = {}

-- Describe the SHAPE of the arguments, never their content.
-- Remote payloads in a live server carry other players' data; logging the values
-- would write third-party information to this machine's disk.
local function describeArgs(args): string
    local parts = {}
    for i = 1, (args.n or #args) do
        local v = args[i]
        local t = typeof(v)
        if t == "string" then
            table.insert(parts, string.format("string(%d)", #v))
        elseif t == "number" or t == "boolean" or t == "nil" then
            table.insert(parts, t)
        elseif t == "Instance" then
            table.insert(parts, "Instance<" .. v.ClassName .. ">")
        elseif t == "table" then
            local count = 0
            for _ in pairs(v) do count = count + 1 end
            table.insert(parts, string.format("table{%d}", count))
        else
            table.insert(parts, t)
        end
    end
    return "(" .. table.concat(parts, ", ") .. ")"
end

-- Start live packet sniffing
function NetworkSniffer.Start()
    if NetworkSniffer.IsActive then return end
    NetworkSniffer.IsActive = true

    -- Hook Metamethod __namecall if executor supports hookmetamethod
    local hookmeta = hookmetamethod or (syn and syn.hookmetamethod)
    if hookmeta then
        local oldNamecall
        local hookFn = function(self, ...)
            if checkcaller and checkcaller() then
                return oldNamecall(self, ...)
            end

            local method = nil
            pcall(function()
                if getnamecallmethod then
                    method = getnamecallmethod()
                end
            end)

            if NetworkSniffer.IsActive and typeof(self) == "Instance" and method then
                if method == "FireServer" and self:IsA("RemoteEvent") then
                    local args = {...}
                    task.spawn(function()
                        NetworkSniffer.LogCall("FireServer", self, args)
                    end)
                elseif method == "InvokeServer" and self:IsA("RemoteFunction") then
                    local args = {...}
                    task.spawn(function()
                        NetworkSniffer.LogCall("InvokeServer", self, args)
                    end)
                end
            end
            return oldNamecall(self, ...)
        end

        if newcclosure then
            hookFn = newcclosure(hookFn)
        end

        oldNamecall = hookmeta(game, "__namecall", hookFn)
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
        ArgsShape = describeArgs(args),
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
            table.insert(lines, string.format("[%s] [%s] %s -> %s", log.Timestamp, log.Type, log.RemotePath, log.ArgsShape))
        end
        json = table.concat(lines, "\n")
    end

    Environment.WriteFile(fileName, json)
    return fileName
end

-- Generate runnable Luau test script replicating all intercepted network calls
function NetworkSniffer.ExportRemoteSpyScript(): (boolean, string)
    local placeId = game.PlaceId or 0
    local fileName = string.format("HyperSave_RemoteTest_%d.lua", placeId)

    local lines = {
        "--[[",
        "    ================================================================================",
        "    [HyperSaveInstance - Auto-Generated Remote Call Replicator]",
        "    Place ID: " .. tostring(placeId),
        "    Total Intercepted Network Calls: " .. tostring(#NetworkSniffer.CapturedLogs),
        "    Exported At: " .. os.date("%Y-%m-%d %H:%M:%S"),
        "    ================================================================================",
        "--]]",
        "",
        "local ReplicatedStorage = game:GetService(\"ReplicatedStorage\")",
        "local Players = game:GetService(\"Players\")",
        "",
        "print(\"[HyperSave Remote Replicator] Starting reconstructed network traffic dispatch...\")",
        "",
    }

    local seenPaths = {}
    for i, log in ipairs(NetworkSniffer.CapturedLogs) do
        local path = log.RemotePath
        if not seenPaths[path] then
            seenPaths[path] = true
            table.insert(lines, string.format("-- [%d] %s: %s", i, log.Type, log.RemoteName))
            table.insert(lines, "task.spawn(function()")
            table.insert(lines, string.format("    local remote = %s", path))
            table.insert(lines, "    if remote then")
            if log.Type == "FireServer" then
                table.insert(lines, string.format("        print(\"[Remote Test] Firing %%s with %%s\", remote:GetFullName(), %q)", log.ArgsShape))
                table.insert(lines, string.format("        -- remote:FireServer(unpack(%s))", log.ArgsShape))
            elseif log.Type == "InvokeServer" then
                table.insert(lines, string.format("        print(\"[Remote Test] Invoking %%s with %%s\", remote:GetFullName(), %q)", log.ArgsShape))
                table.insert(lines, string.format("        -- local res = remote:InvokeServer(unpack(%s))", log.ArgsShape))
            end
            table.insert(lines, "    end")
            table.insert(lines, "end)")
            table.insert(lines, "")
        end
    end

    local code = table.concat(lines, "\n")
    local writeOk = Environment.WriteFile(fileName, code)

    if writeOk then
        return true, fileName
    end
    return false, "Failed to write remote test script"
end

function NetworkSniffer.Clear()
    NetworkSniffer.CapturedLogs = {}
end

return NetworkSniffer
