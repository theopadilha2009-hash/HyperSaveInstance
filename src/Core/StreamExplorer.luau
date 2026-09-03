--[[
    HyperSaveInstance - StreamingEnabled Auto-Map Explorer (Camera-Only Stealth Mode)
    Sweeps spatial coordinates across the map via camera manipulation & RequestStreamAroundAsync.
    Zero physical character displacement to prevent movement/speed anti-cheat detections (Adonis, HD Admin, etc.).
    Includes a Snapshot Memory Accumulator to preserve streamed-out chunks in memory.
]]

local Players = nil
pcall(function() Players = game:GetService("Players") end)

local StreamExplorer = {
    CapturedInstances = {}
}

-- Scan map bounds and calculate bounding box
function StreamExplorer.GetMapBoundingBox(): (Vector3, Vector3)
    local minVec = Vector3.new(-1024, -100, -1024)
    local maxVec = Vector3.new(1024, 500, 1024)

    -- Check if Terrain exists
    local terrain = workspace.Terrain
    if terrain then
        local s, extents = pcall(function() return terrain.MaxExtents end)
        if s and extents then
            minVec = Vector3.new(extents.Min.X * 4, -100, extents.Min.Z * 4)
            maxVec = Vector3.new(extents.Max.X * 4, 500, extents.Max.Z * 4)
            return minVec, maxVec
        end
    end

    -- Check workspace models/parts
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

-- Index currently loaded instances in workspace into memory accumulator
function StreamExplorer.AccumulateCurrentInstances()
    for _, desc in ipairs(workspace:GetDescendants()) do
        if not StreamExplorer.CapturedInstances[desc] then
            StreamExplorer.CapturedInstances[desc] = true
        end
    end
end

-- Get all accumulated instances across all visited chunks
function StreamExplorer.GetAccumulatedInstances(): {Instance}
    local list = {}
    for inst, _ in pairs(StreamExplorer.CapturedInstances) do
        table.insert(list, inst)
    end
    return list
end

-- Clear accumulator
function StreamExplorer.ClearAccumulator()
    table.clear(StreamExplorer.CapturedInstances)
end

-- Perform stealth grid sweep to load chunks safely without moving character
function StreamExplorer.ExploreMap(stepSize: number?, progressCallback: (current: number, total: number, pos: Vector3) -> (), allowPhysicalTeleport: boolean?): boolean
    if not workspace.StreamingEnabled then
        StreamExplorer.AccumulateCurrentInstances()
        return true
    end

    local player = nil
    pcall(function() player = Players and Players.LocalPlayer end)
    local camera = workspace.CurrentCamera
    local originalCameraCFrame = camera and camera.CFrame
    local originalCameraType = camera and camera.CameraType

    local hrp = nil
    if allowPhysicalTeleport and player and player.Character then
        hrp = player.Character:FindFirstChild("HumanoidRootPart")
    end
    local originalHrpCFrame = hrp and hrp.CFrame
    local minVec, maxVec = StreamExplorer.GetMapBoundingBox()

    local step = stepSize or 512
    local points = {}

    for x = minVec.X, maxVec.X, step do
        for z = minVec.Z, maxVec.Z, step do
            table.insert(points, Vector3.new(x, math.max(60, (minVec.Y + maxVec.Y) / 2), z))
        end
    end

    local total = #points
    local completed = 0

    -- Put camera in Scriptable mode to focus on chunks without character movement
    if camera and not allowPhysicalTeleport then
        pcall(function()
            camera.CameraType = Enum.CameraType.Scriptable
        end)
    end

    -- Initial capture of spawn region
    StreamExplorer.AccumulateCurrentInstances()

    for i, targetPos in ipairs(points) do
        -- 1. Stealth Camera focus (Moves observation vector without triggering movement anti-cheat)
        if camera and not allowPhysicalTeleport then
            pcall(function()
                camera.CFrame = CFrame.new(targetPos + Vector3.new(0, 120, 0), targetPos)
            end)
        end

        -- 2. Non-intrusive stream request
        local requested = false
        if player and player.RequestStreamAroundAsync then
            local s = pcall(function() player:RequestStreamAroundAsync(targetPos) end)
            if s then requested = true end
        end
        if not requested and workspace and workspace.RequestStreamAroundAsync then
            pcall(function() workspace:RequestStreamAroundAsync(targetPos) end)
        end

        -- 3. Optional physical teleport (Only if user explicitly forced it)
        if allowPhysicalTeleport and hrp then
            pcall(function()
                hrp.CFrame = CFrame.new(targetPos)
            end)
        end

        -- Natural jitter delay (70ms to 110ms)
        local jitter = 0.07 + (math.random(1, 40) / 1000)
        task.wait(jitter)

        -- 4. Accumulate newly streamed instances into memory buffer before potential stream-out
        StreamExplorer.AccumulateCurrentInstances()

        completed = i
        if progressCallback then
            pcall(progressCallback, completed, total, targetPos)
        end
    end

    -- Restore camera to normal gameplay state
    if camera and originalCameraType then
        pcall(function()
            camera.CameraType = originalCameraType
            if originalCameraCFrame then
                camera.CFrame = originalCameraCFrame
            end
        end)
    end

    -- Restore character if physically moved
    if allowPhysicalTeleport and hrp and originalHrpCFrame then
        pcall(function()
            hrp.CFrame = originalHrpCFrame
        end)
    end

    return true
end

return StreamExplorer
