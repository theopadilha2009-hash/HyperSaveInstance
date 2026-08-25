--[[
    HyperSaveInstance - Asset & Solid Modeling (CSG) Handler
    Preserves CSG Unions, MeshParts, SpecialMeshes, SurfaceAppearances, Textures and Sounds.
]]

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

-- Process MeshParts and Unions
function AssetHandler.ProcessMeshOrUnion(instance: Instance, options: table)
    local info = {
        ClassName = instance.ClassName,
        MeshId = "",
        TextureId = "",
        RenderFidelity = Enum.RenderFidelity.Precise,
        CollisionFidelity = Enum.CollisionFidelity.Default,
        DoubleSided = false,
        AssetId = ""
    }

    if instance:IsA("MeshPart") then
        pcall(function() info.MeshId = instance.MeshId end)
        pcall(function() info.TextureId = instance.TextureID end)
        pcall(function() info.RenderFidelity = instance.RenderFidelity end)
        pcall(function() info.CollisionFidelity = instance.CollisionFidelity end)
        pcall(function() info.DoubleSided = instance.DoubleSided end)
    elseif instance:IsA("UnionOperation") then
        pcall(function() info.AssetId = instance.AssetId end)
        pcall(function() info.RenderFidelity = instance.RenderFidelity end)
        pcall(function() info.CollisionFidelity = instance.CollisionFidelity end)
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
        MetalnessMap = "",
        AlphaMode = Enum.AlphaMode.Overlay
    }
    pcall(function() pbr.ColorMap = instance.ColorMap end)
    pcall(function() pbr.NormalMap = instance.NormalMap end)
    pcall(function() pbr.RoughnessMap = instance.RoughnessMap end)
    pcall(function() pbr.MetalnessMap = instance.MetalnessMap end)
    pcall(function() pbr.AlphaMode = instance.AlphaMode end)
    return pbr
end

return AssetHandler
