--[[
    HyperSaveInstance - Game Universe & Multi-Place Tracker
    Discovers all sub-places in multi-place experiences (Dungeons, Lobbies, Arenas, Sub-maps).
]]

local UniverseTracker = {}

export type SubPlaceInfo = {
    PlaceId: number,
    Name: string,
    IsRoot: boolean
}

-- Fetch all places belonging to current Game Universe
function UniverseTracker.GetUniversePlaces(): {SubPlaceInfo}
    local places = {}
    local currentPlaceId = game.PlaceId or 0
    local rootName = "Root Place"

    pcall(function()
        local mp = game:GetService("MarketplaceService")
        if mp then
            rootName = mp:GetProductInfo(currentPlaceId).Name
        end
    end)

    -- Add current place
    table.insert(places, {
        PlaceId = currentPlaceId,
        Name = rootName,
        IsRoot = true
    })

    -- Query AssetService for places in universe
    local success, pages = pcall(function()
        local assetService = game:GetService("AssetService")
        return assetService and assetService:GetGamePlacesAsync()
    end)

    if success and pages then
        local function processPage()
            local currentList = pages:GetCurrentPage()
            for _, item in ipairs(currentList) do
                if item.PlaceId ~= currentPlaceId then
                    table.insert(places, {
                        PlaceId = item.PlaceId,
                        Name = item.Name or ("Sub-Place " .. tostring(item.PlaceId)),
                        IsRoot = false
                    })
                end
            end
        end

        processPage()
        while not pages.IsFinished do
            local nextSuccess = pcall(function() pages:AdvanceToNextPageAsync() end)
            if not nextSuccess then break end
            processPage()
        end
    end

    return places
end

return UniverseTracker
