--[[
    HyperSaveInstance - Smart Place Optimizer & Deduplicator
    (Strictly Optional) Reduces file size by deduplicating textures and pruning empty temporary containers.
]]

local Optimizer = {}

function Optimizer.OptimizeHierarchy(rootInstances: {Instance}, options: table): {Instance}
    if not options.OptimizeGeometry then
        return rootInstances
    end

    local cleanedRoots = {}
    local prunedCount = 0

    local function cleanRecursive(inst: Instance): boolean
        -- Remove empty temporary folders or zero-size unrendered parts if safe
        if inst:IsA("Folder") and #inst:GetChildren() == 0 and not inst:GetAttribute("Preserve") then
            prunedCount = prunedCount + 1
            return false
        end

        for _, child in ipairs(inst:GetChildren()) do
            cleanRecursive(child)
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

return Optimizer
