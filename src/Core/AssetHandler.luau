--[[
    HyperSaveInstance - Asset & Solid Modeling (CSG) Deep Geometry Handler
    Preserves CSG Unions, PhysicsData, ChildData, MeshParts, SpecialMeshes, SurfaceAppearances, Textures and Sounds.
]]

local Environment = require(script.Parent.Parent.Utils.Environment)
local Base64 = require(script.Parent.Parent.Utils.Base64)

local AssetHandler = {}

-- Sanitize and format asset URLs
function AssetHandler.FormatAssetId(id: string | number): string
    if type(id) == "number" then
        return "rbxassetid://" .. tostring(id)
    end
    if type(id) == "string" then
        if string.match(id, "^%d+$") then
            return "rbxassetid://" .. id
        end
        return id
    end
    return ""
end

-- Extract CSG Hidden Data (PhysicsData, ChildData, AssetId)
function AssetHandler.ExtractUnionData(union: UnionOperation | NegateOperation)
    local data = {
        AssetId = "",
        PhysicsData = nil,
        ChildData = nil,
        InitialSize = nil,
        RenderFidelity = Enum.RenderFidelity.Precise,
        CollisionFidelity = Enum.CollisionFidelity.Default,
        UsePartColor = false,
        SmoothingAngle = 0
    }

    pcall(function() data.AssetId = union.AssetId end)
    pcall(function() data.RenderFidelity = union.RenderFidelity end)
    pcall(function() data.CollisionFidelity = union.CollisionFidelity end)
    pcall(function() data.UsePartColor = union.UsePartColor end)
    pcall(function() data.SmoothingAngle = union.SmoothingAngle end)

    -- Extract hidden CSG geometry buffers if executor supports gethiddenproperty or getspecialinfo
    local getspecial = getspecialinfo or (syn and syn.get_special_info)
    if getspecial then
        local s, specialInfo = pcall(getspecial, union)
        if s and type(specialInfo) == "table" then
            if specialInfo.PhysicsData then
                data.PhysicsData = Base64.Encode(specialInfo.PhysicsData)
            end
            if specialInfo.ChildData then
                data.ChildData = Base64.Encode(specialInfo.ChildData)
            end
            if specialInfo.InitialSize then
                data.InitialSize = specialInfo.InitialSize
            end
            if specialInfo.AssetId and #data.AssetId == 0 then
                data.AssetId = specialInfo.AssetId
            end
        end
    end

    if not data.PhysicsData then
        local phys = Environment.GetHiddenProperties(union, "PhysicsData")
        if phys and type(phys) == "string" then
            data.PhysicsData = Base64.Encode(phys)
        end
    end

    if not data.ChildData then
        local child = Environment.GetHiddenProperties(union, "ChildData")
        if child and type(child) == "string" then
            data.ChildData = Base64.Encode(child)
        end
    end

    return data
end

-- Process MeshParts and Meshes
function AssetHandler.ProcessMeshOrUnion(instance: Instance, options: table)
    local info = {
        ClassName = instance.ClassName,
        MeshId = "",
        TextureId = "",
        RenderFidelity = Enum.RenderFidelity.Precise,
        CollisionFidelity = Enum.CollisionFidelity.Default,
        DoubleSided = false,
        VertexColor = Vector3.new(1, 1, 1),
        AssetId = "",
        UnionData = nil
    }

    if instance:IsA("MeshPart") then
        pcall(function() info.MeshId = instance.MeshId end)
        pcall(function() info.TextureId = instance.TextureID end)
        pcall(function() info.RenderFidelity = instance.RenderFidelity end)
        pcall(function() info.CollisionFidelity = instance.CollisionFidelity end)
        pcall(function() info.DoubleSided = instance.DoubleSided end)
        pcall(function() info.VertexColor = instance.VertexColor end)
    elseif instance:IsA("UnionOperation") or instance:IsA("NegateOperation") then
        info.UnionData = AssetHandler.ExtractUnionData(instance :: any)
        info.AssetId = info.UnionData.AssetId
    elseif instance:IsA("SpecialMesh") then
        pcall(function() info.MeshId = instance.MeshId end)
        pcall(function() info.TextureId = instance.TextureId end)
        pcall(function() info.MeshType = instance.MeshType end)
        pcall(function() info.Scale = instance.Scale end)
        pcall(function() info.Offset = instance.Offset end)
        pcall(function() info.VertexColor = instance.VertexColor end)
    end

    return info
end

-- Process SurfaceAppearance (PBR Textures)
function AssetHandler.ProcessSurfaceAppearance(instance: SurfaceAppearance)
    local pbr = {
        ColorMap = "",
        NormalMap = "",
        RoughnessMap = "",
        AlphaMode = 0
    }
    pcall(function()
        if Enum.AlphaMode and Enum.AlphaMode.Overlay then
            pbr.AlphaMode = Enum.AlphaMode.Overlay
        end
    end)
    pcall(function() pbr.ColorMap = instance.ColorMap end)
    pcall(function() pbr.NormalMap = instance.NormalMap end)
    pcall(function() pbr.RoughnessMap = instance.RoughnessMap end)
    pcall(function() pbr.MetalnessMap = instance.MetalnessMap end)
    pcall(function() pbr.AlphaMode = instance.AlphaMode end)
    return pbr
end

-- Preload & warm assets in memory
function AssetHandler.WarmAssets(instances: {Instance})
    pcall(function()
        local ContentProvider = game:GetService("ContentProvider")
        if not ContentProvider then return end

        local batch = {}
        for _, inst in ipairs(instances) do
            if inst:IsA("MeshPart") or inst:IsA("Decal") or inst:IsA("Texture") or inst:IsA("SurfaceAppearance") or inst:IsA("SpecialMesh") then
                table.insert(batch, inst)
                if #batch >= 80 then
                    pcall(function() ContentProvider:PreloadAsync(batch) end)
                    table.clear(batch)
                end
            end
        end
        if #batch > 0 then
            pcall(function() ContentProvider:PreloadAsync(batch) end)
        end
    end)
end

return AssetHandler
