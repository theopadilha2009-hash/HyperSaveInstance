--[[
    HyperSaveInstance - Comprehensive Raw Asset Downloader Engine
    Downloads raw audios (.mp3), textures (.png), 3D meshes (.mesh/.obj) and animations to local disk.
    Equipped with Dynamic Network & FPS Throttling, Exponential Backoff and Ping Guard.
]]

local Environment = require(script.Parent.Parent.Utils.Environment)

local AssetDownloader = {}

-- Safe HTTP Request polyfill with clean official headers (Prevents executor fingerprinting)
local function httpRequest(url: string): string?
    local req = (syn and syn.request) or (http and http.request) or http_request or request
    if req then
        local s, res = pcall(req, {
            Url = url,
            Method = "GET",
            Headers = {
                ["User-Agent"] = "Roblox/WinInet",
                ["Accept"] = "*/*",
                ["Accept-Encoding"] = "gzip, deflate",
                ["Connection"] = "keep-alive"
            }
        })
        if s and res and (res.StatusCode == 200 or res.Success) then
            return res.Body
        end
    end

    -- Fallback to game:HttpGet
    local s, body = pcall(function()
        return game:HttpGet(url)
    end)
    if s and type(body) == "string" and #body > 0 then
        return body
    end

    return nil
end

-- Extract clean asset ID numbers from urls or strings
function AssetDownloader.ExtractId(assetUrl: string | number): string?
    if type(assetUrl) == "number" then
        return tostring(assetUrl)
    end
    if type(assetUrl) ~= "string" or #assetUrl == 0 then
        return nil
    end

    local id = string.match(assetUrl, "%d+")
    return id
end

-- Collect all unique asset URLs and IDs from game hierarchy
function AssetDownloader.CollectAssets(instances: {Instance}): {[string]: {Type: string, Id: string, Url: string, SourceName: string}}
    local assets = {}

    local function registerAsset(assetType: string, rawVal: any, sourceName: string)
        local id = AssetDownloader.ExtractId(rawVal)
        if id and #id > 0 and not assets[id] then
            local downloadUrl = string.format("https://assetdelivery.roblox.com/v1/asset/?id=%s", id)
            assets[id] = {
                Type = assetType,
                Id = id,
                Url = downloadUrl,
                SourceName = sourceName
            }
        end
    end

    for _, inst in ipairs(instances) do
        if inst:IsA("Sound") then
            registerAsset("Audio", inst.SoundId, inst.Name)
        elseif inst:IsA("Decal") or inst:IsA("Texture") then
            registerAsset("Texture", inst.Texture, inst.Name)
        elseif inst:IsA("MeshPart") then
            registerAsset("Mesh", inst.MeshId, inst.Name .. "_Mesh")
            registerAsset("Texture", inst.TextureID, inst.Name .. "_Tex")
        elseif inst:IsA("SpecialMesh") then
            registerAsset("Mesh", inst.MeshId, inst.Name .. "_Mesh")
            registerAsset("Texture", inst.TextureId, inst.Name .. "_Tex")
        elseif inst:IsA("SurfaceAppearance") then
            registerAsset("Texture", inst.ColorMap, inst.Name .. "_Color")
            registerAsset("Texture", inst.NormalMap, inst.Name .. "_Normal")
            registerAsset("Texture", inst.RoughnessMap, inst.Name .. "_Roughness")
            registerAsset("Texture", inst.MetalnessMap, inst.Name .. "_Metalness")
        elseif inst:IsA("Sky") then
            registerAsset("Texture", inst.SkyboxBk, "SkyboxBk")
            registerAsset("Texture", inst.SkyboxDn, "SkyboxDn")
            registerAsset("Texture", inst.SkyboxFt, "SkyboxFt")
            registerAsset("Texture", inst.SkyboxLf, "SkyboxLf")
            registerAsset("Texture", inst.SkyboxRt, "SkyboxRt")
            registerAsset("Texture", inst.SkyboxUp, "SkyboxUp")
        elseif inst:IsA("ParticleEmitter") or inst:IsA("Beam") or inst:IsA("Trail") then
            registerAsset("Texture", (inst :: any).Texture, inst.Name)
        elseif inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
            registerAsset("Texture", (inst :: any).Image, inst.Name)
        elseif inst:IsA("Animation") then
            registerAsset("Animation", inst.AnimationId, inst.Name)
        elseif inst:IsA("Shirt") then
            registerAsset("Texture", inst.ShirtTemplate, inst.Name)
        elseif inst:IsA("Pants") then
            registerAsset("Texture", inst.PantsTemplate, inst.Name)
        elseif inst:IsA("VideoFrame") then
            registerAsset("Video", (inst :: any).Video, inst.Name)
        elseif inst:IsA("PackageLink") then
            registerAsset("Package", (inst :: any).PackageId, inst.Name)
        end
    end

    return assets
end

-- Measure real-time client ping to prevent server desync/heartbeat disconnects
function AssetDownloader.GetClientPing(): number
    local ping = 45
    pcall(function()
        local clonerefFn = cloneref or function(obj) return obj end
        local stats = clonerefFn(game:GetService("Stats"))
        local net = stats and stats:FindFirstChild("Network")
        local ssi = net and net:FindFirstChild("ServerStatsItem")
        local dp = ssi and ssi:FindFirstChild("Data Ping")
        if dp and dp:IsA("ValueBase") then
            ping = (dp :: any).Value or 45
        end
    end)
    return ping
end

-- Measure real-time client FPS
function AssetDownloader.GetClientFPS(): number
    local fps = 60
    pcall(function()
        local clonerefFn = cloneref or function(obj) return obj end
        local ws = clonerefFn(game:GetService("Workspace"))
        if ws and ws.GetRealPhysicsFPS then
            local val = ws:GetRealPhysicsFPS()
            if val and val > 0 then
                fps = val
            end
        end
    end)
    return fps
end

-- Export structured JSON manifest for offline downloading
function AssetDownloader.ExportManifest(assets: {[string]: table}, manifestPath: string): (boolean, string)
    local clonerefFn = cloneref or function(obj) return obj end
    local HttpService = clonerefFn(game:GetService("HttpService"))
    local list = {}
    local summary = {
        Audio = 0,
        Texture = 0,
        Mesh = 0,
        Animation = 0,
        Video = 0,
        Package = 0,
        Other = 0,
    }

    for id, item in pairs(assets) do
        table.insert(list, {
            Id = id,
            Type = item.Type,
            Url = item.Url,
            SourceName = item.SourceName
        })
        if summary[item.Type] ~= nil then
            summary[item.Type] = summary[item.Type] + 1
        else
            summary.Other = summary.Other + 1
        end
    end

    local success, json = pcall(function()
        return HttpService:JSONEncode({
            PlaceId = game.PlaceId or 0,
            TotalAssets = #list,
            CategorySummary = summary,
            ExportDate = os.date("%Y-%m-%d %H:%M:%S"),
            Assets = list
        })
    end)

    if success and json then
        local wOk = Environment.WriteFile(manifestPath, json)
        return wOk, manifestPath
    end

    return false, "Failed to encode JSON manifest"
end

-- Download all collected assets safely with Ping Guard, FPS Throttling & Exponential Backoff
function AssetDownloader.DownloadAll(assets: {[string]: table}, baseFolder: string, options: table, progressCallback: (current: number, total: number, asset: table) -> ()): (number, number)
    local opts = options or {}
    Environment.MakeFolder(baseFolder)
    Environment.MakeFolder(baseFolder .. "/audios")
    Environment.MakeFolder(baseFolder .. "/textures")
    Environment.MakeFolder(baseFolder .. "/meshes")
    Environment.MakeFolder(baseFolder .. "/animations")

    local manifestPath = string.format("%s/HyperSave_Manifest_%d.json", baseFolder, game.PlaceId or 0)
    AssetDownloader.ExportManifest(assets, manifestPath)

    local assetList = {}
    for _, asset in pairs(assets) do
        table.insert(assetList, asset)
    end

    local total = #assetList
    if total == 0 then return 0, 0 end

    local downloaded = 0
    local failed = 0
    local currentIndex = 1

    -- In safe mode, constrain workers to 3-4 to keep network and CPU usage imperceptible
    local maxWorkers = opts.SafeAssetDownload ~= false and math.clamp(opts.AssetDownloadWorkers or 3, 1, 4) or math.clamp(opts.AssetDownloadWorkers or 6, 2, 8)
    local activeWorkers = maxWorkers

    for w = 1, maxWorkers do
        task.spawn(function()
            while currentIndex <= total do
                local myIndex = currentIndex
                currentIndex = currentIndex + 1

                local item = assetList[myIndex]
                if item then
                    -- 1. Adaptive Ping & FPS Guard: Pause if ping > 160ms or FPS < 35
                    if opts.SafeAssetDownload ~= false then
                        local currentPing = AssetDownloader.GetClientPing()
                        local currentFps = AssetDownloader.GetClientFPS()
                        local retryCount = 0
                        while (currentPing > 160 or currentFps < 35) and retryCount < 12 do
                            task.wait(0.25)
                            currentPing = AssetDownloader.GetClientPing()
                            currentFps = AssetDownloader.GetClientFPS()
                            retryCount = retryCount + 1
                        end
                    end

                    local extension = ".dat"
                    local subDir = "textures"

                    if item.Type == "Audio" then
                        extension = ".mp3"
                        subDir = "audios"
                    elseif item.Type == "Texture" then
                        extension = ".png"
                        subDir = "textures"
                    elseif item.Type == "Mesh" then
                        extension = ".mesh"
                        subDir = "meshes"
                    elseif item.Type == "Animation" then
                        extension = ".rbxanim"
                        subDir = "animations"
                    end

                    local fileName = string.format("%s/%s/%s_%s%s", baseFolder, subDir, item.Id, string.gsub(item.SourceName, "[^%w_%-]", "_"), extension)

                    -- 2. Exponential backoff retry handler
                    local body = nil
                    local maxRetries = 2
                    for attempt = 1, maxRetries + 1 do
                        body = httpRequest(item.Url)
                        if not body or #body == 0 then
                            local v2Url = string.format("https://assetdelivery.roblox.com/v2/assetId/%s", item.Id)
                            body = httpRequest(v2Url)
                        end

                        if body and #body > 0 then
                            break
                        end

                        if attempt <= maxRetries then
                            task.wait(0.3 * attempt)
                        end
                    end

                    if body and #body > 0 then
                        local writeOk = Environment.WriteFile(fileName, body)
                        if writeOk then
                            downloaded = downloaded + 1
                        else
                            failed = failed + 1
                        end
                    else
                        failed = failed + 1
                    end

                    if progressCallback then
                        pcall(progressCallback, downloaded + failed, total, item)
                    end
                end

                -- Jittered rate limiting delay (40ms to 80ms)
                local jitter = math.random(40, 80) / 1000
                task.wait(jitter)
            end
            activeWorkers = activeWorkers - 1
        end)
    end

    while activeWorkers > 0 and (downloaded + failed) < total do
        task.wait(0.05)
    end

    return downloaded, failed
end

return AssetDownloader
