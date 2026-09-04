--[[
    HyperSaveInstance - Live Animation Keyframe Capturer
    Solves the Roblox Asset Permission / HTTP 403 issue for Animations by capturing
    real-time Motor6D joint transformations (CFrame / Transform) and baking them into
    native KeyframeSequence instances that can be published to the user's account in Studio.
]]

local clonerefFn = cloneref or function(obj) return obj end
local RunService = nil
pcall(function() RunService = clonerefFn(game:GetService("RunService")) end)
local Players = nil
pcall(function() Players = clonerefFn(game:GetService("Players")) end)

local AnimationRecorder = {}
AnimationRecorder.IsRecording = false
AnimationRecorder.RecordedSequences = {}
AnimationRecorder.ActiveConnection = nil

-- Record an active animation track from a Humanoid by sampling joint transforms
function AnimationRecorder.RecordTrack(humanoid: Humanoid, trackName: string, durationSeconds: number, onComplete: (keyframeSeq: KeyframeSequence) -> ())
    local character = humanoid.Parent
    if not character then return end

    -- Collect all Motor6D joints
    local motors = {}
    for _, desc in ipairs(character:GetDescendants()) do
        if desc:IsA("Motor6D") then
            table.insert(motors, desc)
        end
    end

    if #motors == 0 then return end

    local keyframeSeq = Instance.new("KeyframeSequence")
    keyframeSeq.Name = trackName or "RecordedAnimation"

    local sampleRate = 30 -- 30 FPS sampling
    local interval = 1 / sampleRate
    local elapsed = 0
    local timer = 0

    local frames = {}

    local conn
    conn = RunService.Heartbeat:Connect(function(dt)
        elapsed = elapsed + dt
        timer = timer + dt

        if timer >= interval then
            timer = 0
            local timePos = math.floor(elapsed * 1000) / 1000

            local kf = Instance.new("Keyframe")
            kf.Time = timePos

            -- Create pose hierarchy
            local posesByPart = {}
            for _, motor in ipairs(motors) do
                local p0 = motor.Part0
                local p1 = motor.Part1
                if p0 and p1 then
                    local pose = Instance.new("Pose")
                    pose.Name = p1.Name
                    pose.CFrame = motor.Transform
                    posesByPart[p1.Name] = pose
                end
            end

            -- Assemble tree structure
            for _, motor in ipairs(motors) do
                local p0 = motor.Part0
                local p1 = motor.Part1
                if p0 and p1 and posesByPart[p0.Name] and posesByPart[p1.Name] then
                    posesByPart[p1.Name].Parent = posesByPart[p0.Name]
                elseif p1 and posesByPart[p1.Name] and not posesByPart[p1.Name].Parent then
                    posesByPart[p1.Name].Parent = kf
                end
            end

            kf.Parent = keyframeSeq
        end

        if elapsed >= (durationSeconds or 3) then
            conn:Disconnect()
            table.insert(AnimationRecorder.RecordedSequences, keyframeSeq)
            if onComplete then
                onComplete(keyframeSeq)
            end
        end
    end)

    return conn
end

-- Auto-hook into character animation playback
function AnimationRecorder.StartAutoCapture()
    if AnimationRecorder.IsRecording then return end
    AnimationRecorder.IsRecording = true

    local function hookHumanoid(humanoid: Humanoid)
        humanoid.AnimationPlayed:Connect(function(track)
            local animName = track.Name or "Animation"
            pcall(function()
                if track.Animation then
                    animName = track.Animation.Name
                end
            end)
            
            -- Prevent duplicate recordings
            if not AnimationRecorder.RecordedSequences[animName] then
                AnimationRecorder.RecordedSequences[animName] = true
                AnimationRecorder.RecordTrack(humanoid, animName, math.min(track.Length > 0 and track.Length or 3, 10))
            end
        end)
    end

    local localPlayer = Players.LocalPlayer
    if localPlayer then
        if localPlayer.Character then
            local hum = localPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hookHumanoid(hum) end
        end
        localPlayer.CharacterAdded:Connect(function(char)
            local hum = char:WaitForChild("Humanoid", 5)
            if hum and hum:IsA("Humanoid") then
                hookHumanoid(hum)
            end
        end)
    end
end

-- Scan all currently playing animation tracks across the local player and NPCs
function AnimationRecorder.ScanActiveTracks(): { { Name: string, Length: number, Speed: number, Humanoid: Humanoid } }
    local tracks = {}
    local seen = {}

    local function checkHumanoid(hum: Humanoid)
        local animator = hum:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                local name = track.Name or "Animation"
                pcall(function()
                    if track.Animation and #track.Animation.Name > 0 then
                        name = track.Animation.Name
                    end
                end)
                if not seen[name] then
                    seen[name] = true
                    table.insert(tracks, {
                        Name = name,
                        Length = track.Length,
                        Speed = track.Speed,
                        Humanoid = hum,
                        Track = track
                    })
                end
            end
        end
    end

    local localPlayer = Players and Players.LocalPlayer
    if localPlayer and localPlayer.Character then
        local hum = localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then checkHumanoid(hum) end
    end

    if workspace then
        for _, desc in ipairs(workspace:GetDescendants()) do
            if desc:IsA("Humanoid") then
                checkHumanoid(desc)
            end
        end
    end

    return tracks
end

-- Export all captured KeyframeSequences to a .rbxm model package
function AnimationRecorder.ExportRecordedAnimations(): (boolean, string)
    local Environment = require(script.Parent.Parent.Utils.Environment)
    local SerializerXml = require(script.Parent.SerializerXml)

    local animFolder = Instance.new("Folder")
    animFolder.Name = "RecordedAnimations"

    local count = 0
    for _, item in ipairs(AnimationRecorder.RecordedSequences) do
        if typeof(item) == "Instance" and item:IsA("KeyframeSequence") then
            local clone = item:Clone()
            clone.Parent = animFolder
            count = count + 1
        end
    end

    if count == 0 then
        -- Create a placeholder KeyframeSequence if none recorded yet
        local placeholder = Instance.new("KeyframeSequence")
        placeholder.Name = "Idle_Sample"
        local kf0 = Instance.new("Keyframe")
        kf0.Time = 0
        kf0.Parent = placeholder
        placeholder.Parent = animFolder
        count = 1
    end

    local fileName = string.format("HyperSave_Animations_%s.rbxm", tostring(game.PlaceId or "0"))
    local xml = SerializerXml.Serialize(animFolder, {
        SaveTerrain = false,
        DecompileScripts = false
    })

    if Environment.HasFileSystem() then
        local success, err = pcall(function()
            Environment.WriteFile(fileName, xml)
        end)
        if success then
            return true, fileName
        else
            return false, tostring(err)
        end
    end

    return true, fileName
end

return AnimationRecorder
