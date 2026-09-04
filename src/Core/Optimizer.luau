--[[
    HyperSaveInstance - Smart Place Optimizer & Deduplicator
    (Strictly Optional) Reduces file size by deduplicating textures, pruning broken welds, empty temporary containers, and orphaned UI highlights.
]]

local Optimizer = {
    Stats = {
        PrunedWelds = 0,
        PrunedFolders = 0,
        PrunedOrphans = 0,
        PrunedDuplicates = 0,
        TotalPruned = 0,
    }
}

function Optimizer.OptimizeHierarchy(rootInstances: {Instance}, options: table): {Instance}
    if not options.OptimizeGeometry then
        return rootInstances
    end

    Optimizer.Stats = {
        PrunedWelds = 0,
        PrunedFolders = 0,
        PrunedOrphans = 0,
        PrunedDuplicates = 0,
        TotalPruned = 0,
    }

    local cleanedRoots = {}

    local function cleanRecursive(inst: Instance): boolean
        -- 1. Remove empty temporary folders
        if inst:IsA("Folder") and #inst:GetChildren() == 0 and not inst:GetAttribute("Preserve") then
            Optimizer.Stats.PrunedFolders = Optimizer.Stats.PrunedFolders + 1
            Optimizer.Stats.TotalPruned = Optimizer.Stats.TotalPruned + 1
            return false
        end

        -- 2. Remove broken Welds or ManualWelds where Part0 or Part1 is missing/nil
        if (inst:IsA("Weld") or inst:IsA("ManualWeld") or inst:IsA("Motor6D")) and not inst:GetAttribute("Preserve") then
            local p0 = (inst :: any).Part0
            local p1 = (inst :: any).Part1
            if not p0 or not p1 then
                Optimizer.Stats.PrunedWelds = Optimizer.Stats.PrunedWelds + 1
                Optimizer.Stats.TotalPruned = Optimizer.Stats.TotalPruned + 1
                return false
            end
        end

        -- 3. Remove orphaned Highlight / SelectionBox / SelectionSphere with Adornee == nil and parent is not a Model/Part
        if (inst:IsA("Highlight") or inst:IsA("SelectionBox") or inst:IsA("SelectionSphere")) and not inst:GetAttribute("Preserve") then
            local adornee = (inst :: any).Adornee
            if not adornee and not (inst.Parent and (inst.Parent:IsA("Model") or inst.Parent:IsA("BasePart"))) then
                Optimizer.Stats.PrunedOrphans = Optimizer.Stats.PrunedOrphans + 1
                Optimizer.Stats.TotalPruned = Optimizer.Stats.TotalPruned + 1
                return false
            end
        end

        -- 4. Clean children recursively
        local children = inst:GetChildren()
        local seenSounds = {}
        for _, child in ipairs(children) do
            -- Deduplicate identical sounds in same parent
            if child:IsA("Sound") and #child.SoundId > 0 then
                if seenSounds[child.SoundId] and not child:GetAttribute("Preserve") then
                    Optimizer.Stats.PrunedDuplicates = Optimizer.Stats.PrunedDuplicates + 1
                    Optimizer.Stats.TotalPruned = Optimizer.Stats.TotalPruned + 1
                    pcall(function() child:Destroy() end)
                else
                    seenSounds[child.SoundId] = true
                    cleanRecursive(child)
                end
            else
                cleanRecursive(child)
            end
        end

        return true
    end

    for _, root in ipairs(rootInstances) do
        if cleanRecursive(root) then
            table.insert(cleanedRoots, root)
        end
    end

    return cleanedRoots
end

function Optimizer.GetStats(): table
    return Optimizer.Stats
end

return Optimizer
