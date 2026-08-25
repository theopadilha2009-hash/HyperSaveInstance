--[[
    HyperSaveInstance - Comprehensive Raw Asset Downloader Engine
    Downloads raw audios (.mp3), textures (.png), 3D meshes (.mesh/.obj) and animations to local disk.
]]

local Environment = require(script.Parent.Parent.Utils.Environment)

local AssetDownloader = {}

-- Safe HTTP Request polyfill for executors
local function httpRequest(url: string): string?
    local req = (syn and syn.request) or (http and http.request) or http_request or request
    if req then
        local s, res = pcall(req, {
            Url = url,
            Method = "GET"
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
        end
    end

    return assets
end

-- Download all collected assets to local folder structure
function AssetDownloader.DownloadAll(assets: {[string]: table}, baseFolder: string, options: table, progressCallback: (current: number, total: number, asset: table) -> ()): (number, number)
    -- Create subdirectories
    Environment.MakeFolder(baseFolder)
    Environment.MakeFolder(baseFolder .. "/audios")
    Environment.MakeFolder(baseFolder .. "/textures")
    Environment.MakeFolder(baseFolder .. "/meshes")
    Environment.MakeFolder(baseFolder .. "/animations")

    local assetList = {}
    for _, asset in pairs(assets) do
        table.insert(assetList, asset)
    end

    local total = #assetList
    local downloaded = 0
    local failed = 0
    local currentIndex = 1

    local workers = math.clamp(options.AssetDownloadWorkers or 6, 1, 12)
    local threads = {}

    for w = 1, workers do
        local t = task.spawn(function()
            while currentIndex <= total do
                local myIndex = currentIndex
                currentIndex = currentIndex + 1

                local item = assetList[myIndex]
                if item then
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

                    -- Download raw bytes
                    local body = httpRequest(item.Url)
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
                task.wait(0.02)
            end
        end)
        table.insert(threads, t)
    end

    while (downloaded + failed) < total do
        task.wait(0.1)
    end

    return downloaded, failed
end

return AssetDownloader
