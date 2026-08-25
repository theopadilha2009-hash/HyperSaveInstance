--[[
    HyperSaveInstance - StreamingEnabled Auto-Map Explorer
    Sweeps spatial coordinates across the map to force server chunk replication into memory.
]]

local Players = game:GetService("Players")

local StreamExplorer = {}

-- Scan map bounds and calculate bounding box
function StreamExplorer.GetMapBoundingBox(): (Vector3, Vector3)
    local minVec = Vector3.new(-1024, -100, -1024)
    local maxVec = Vector3.new(1024, 500, 1024)

    -- Check if Terrain or Spawns exist
    local terrain = workspace.Terrain
    if terrain then
        local s, extents = pcall(function() return terrain.MaxExtents end)
        if s and extents then
            minVec = Vector3.new(extents.Min.X * 4, -100, extents.Min.Z * 4)
            maxVec = Vector3.new(extents.Max.X * 4, 500, extents.Max.Z * 4)
            return minVec, maxVec
        end
    end

    -- Check spawn locations or workspace children
    for _, child in ipairs(workspace:GetChildren()) do
        if child:IsA("BasePart") or child:IsA("Model") then
            pcall(function()
                local cf, sz
                if child:IsA("Model") then
                    cf, sz = child:GetBoundingBox()
                else
                    cf, sz = child.CFrame, child.Size
                end
                local pos = cf.Position
                minVec = Vector3.new(math.min(minVec.X, pos.X - sz.X), math.min(minVec.Y, pos.Y - sz.Y), math.min(minVec.Z, pos.Z - sz.Z))
                maxVec = Vector3.new(math.max(maxVec.X, pos.X + sz.X), math.max(maxVec.Y, pos.Y + sz.Y), math.max(maxVec.Z, pos.Z + sz.Z))
            end)
        end
    end

    return minVec, maxVec
end

-- Perform automated grid sweep to load chunks
function StreamExplorer.ExploreMap(stepSize: number?, progressCallback: (current: number, total: number, pos: Vector3) -> ()): boolean
    if not workspace.StreamingEnabled then return true end

    local player = Players.LocalPlayer
    if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return false
    end

    local hrp = player.Character.HumanoidRootPart
    local originalCFrame = hrp.CFrame
    local minVec, maxVec = StreamExplorer.GetMapBoundingBox()

    local step = stepSize or 512
    local points = {}

    for x = minVec.X, maxVec.X, step do
        for z = minVec.Z, maxVec.Z, step do
            table.insert(points, Vector3.new(x, math.max(50, (minVec.Y + maxVec.Y) / 2), z))
        end
    end

    local total = #points
    local completed = 0

    for i, targetPos in ipairs(points) do
        pcall(function()
            hrp.CFrame = CFrame.new(targetPos)
        end)
        task.wait(0.12) -- Wait for server replication chunk
        completed = i

        if progressCallback then
            pcall(progressCallback, completed, total, targetPos)
        end
    end

    -- Return to original position
    pcall(function()
        hrp.CFrame = originalCFrame
    end)

    return true
end

return StreamExplorer
