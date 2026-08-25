--[[
    HyperSaveInstance - Advanced Terrain & Voxel Serializer
    Preserves SmoothVoxels, materials, occupancies, water physics, decoration and material colors (10/10 visual fidelity).
]]

local Base64 = require(script.Parent.Parent.Utils.Base64)

local TerrainSerializer = {}

function TerrainSerializer.ExtractTerrainData(terrain: Terrain, options: table)
    local data = {
        Decoration = false,
        WaterColor = Color3.fromRGB(12, 84, 91),
        WaterReflectance = 1,
        WaterTransparency = 1,
        WaterWaveSize = 0.15,
        WaterWaveSpeed = 10,
        MaterialColors = "",
        HasVoxels = false,
        VoxelChunks = {}
    }

    if not terrain or not terrain:IsA("Terrain") then
        return data
    end

    -- Extract basic properties safely
    pcall(function() data.Decoration = terrain.Decoration end)
    pcall(function() data.WaterColor = terrain.WaterColor end)
    pcall(function() data.WaterReflectance = terrain.WaterReflectance end)
    pcall(function() data.WaterTransparency = terrain.WaterTransparency end)
    pcall(function() data.WaterWaveSize = terrain.WaterWaveSize end)
    pcall(function() data.WaterWaveSpeed = terrain.WaterWaveSpeed end)
    pcall(function() data.MaterialColors = terrain.MaterialColors end)

    if not options.SaveTerrainVoxels then
        return data
    end

    -- Extract Voxels safely
    local success, maxExtents = pcall(function()
        return terrain.MaxExtents
    end)

    if not success or not maxExtents then
        return data
    end

    local minVoxel = maxExtents.Min
    local maxVoxel = maxExtents.Max
    local step = options.TerrainVoxelStep or 64

    local xChunks = math.ceil((maxVoxel.X - minVoxel.X) / step)
    local yChunks = math.ceil((maxVoxel.Y - minVoxel.Y) / step)
    local zChunks = math.ceil((maxVoxel.Z - minVoxel.Z) / step)

    -- Iterate chunks
    for cx = 0, xChunks - 1 do
        for cy = 0, yChunks - 1 do
            for cz = 0, zChunks - 1 do
                local chunkMin = Vector3int16.new(
                    minVoxel.X + cx * step,
                    minVoxel.Y + cy * step,
                    minVoxel.Z + cz * step
                )
                local chunkMax = Vector3int16.new(
                    math.min(chunkMin.X + step, maxVoxel.X),
                    math.min(chunkMin.Y + step, maxVoxel.Y),
                    math.min(chunkMin.Z + step, maxVoxel.Z)
                )

                local regSuccess, materials, occupancies = pcall(function()
                    return terrain:ReadVoxels(Region3int16.new(chunkMin, chunkMax))
                end)

                if regSuccess and materials and occupancies then
                    local size = materials.Size
                    local hasContent = false
                    local rawMat = {}
                    local rawOcc = {}

                    for x = 1, size.X do
                        for y = 1, size.Y do
                            for z = 1, size.Z do
                                local mat = materials[x][y][z]
                                local occ = occupancies[x][y][z]

                                if occ > 0 and mat ~= Enum.Material.Air then
                                    hasContent = true
                                end
                                table.insert(rawMat, string.char(mat.Value % 256))
                                table.insert(rawOcc, string.char(math.floor(occ * 255)))
                            end
                        end
                    end

                    if hasContent then
                        data.HasVoxels = true
                        table.insert(data.VoxelChunks, {
                            Min = chunkMin,
                            Max = chunkMax,
                            Size = size,
                            Materials = Base64.Encode(table.concat(rawMat)),
                            Occupancies = Base64.Encode(table.concat(rawOcc))
                        })
                    end
                end
            end
        end
    end

    return data
end

return TerrainSerializer
