--[[
    HyperSaveInstance - 3D In-World Raycast & Model Selector
    Allows the user to hover and click directly on any 3D model, vehicle, weapon or structure
    in the game world to inspect its hierarchy and save it with all internal scripts.
]]

local UserInputService = nil
pcall(function() UserInputService = game:GetService("UserInputService") end)
local RunService = nil
pcall(function() RunService = game:GetService("RunService") end)
local Players = nil
pcall(function() Players = game:GetService("Players") end)

local RaycastSelector = {}
RaycastSelector.__index = RaycastSelector

function RaycastSelector.new(options: table?)
    local self = setmetatable({}, RaycastSelector)
    self.Options = options or {}
    self.IsActive = false
    self.HoveredInstance = nil
    self.SelectedInstance = nil
    self.Highlight = nil
    self.SelectionBox = nil
    self.Connections = {}
    self.OnSelectedCallback = nil
    self.OnHoverCallback = nil

    self:InitVisuals()
    return self
end

-- Initialize the visual highlight indicators
function RaycastSelector:InitVisuals()
    pcall(function()
        local hl = Instance.new("Highlight")
        hl.Name = "HyperSave_SelectorHighlight"
        hl.FillColor = Color3.fromRGB(37, 99, 235)
        hl.FillTransparency = 0.5
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.OutlineTransparency = 0
        hl.Enabled = false
        
        -- Store in gethui, CoreGui or workspace safely
        local parent = nil
        if gethui then
            pcall(function() parent = gethui() end)
        end
        if not parent then
            pcall(function() parent = game:GetService("CoreGui") end)
        end
        hl.Parent = parent or workspace
        self.Highlight = hl
    end)
end

-- Find the most meaningful parent Model or Tool from a clicked BasePart
function RaycastSelector:ResolveTarget(part: BasePart): Instance
    if not part then return nil end

    local current: Instance? = part
    local bestModel: Instance = part

    while current and current ~= workspace and current ~= game do
        if current:IsA("Model") and current.Parent == workspace then
            bestModel = current
            break
        elseif current:IsA("Tool") or current:IsA("Accessory") or current:IsA("Model") then
            bestModel = current
        end
        current = current.Parent
    end

    return bestModel
end

-- Perform raycast from mouse screen position into 3D world
function RaycastSelector:RaycastMouse(): (Instance?, Vector3?)
    local camera = workspace.CurrentCamera
    if not camera then return nil, nil end

    local mousePos = UserInputService:GetMouseLocation()
    local unitRay = camera:ViewportPointToRay(mousePos.X, mousePos.Y)

    local params = RaycastParams.new()
    pcall(function()
        params.FilterType = (Enum.RaycastFilterType and (Enum.RaycastFilterType.Exclude or Enum.RaycastFilterType.Blacklist)) or 0
    end)

    local filterList = {}
    local localPlayer = Players.LocalPlayer
    if localPlayer and localPlayer.Character then
        table.insert(filterList, localPlayer.Character)
    end
    if self.Highlight then
        table.insert(filterList, self.Highlight)
    end

    params.FilterDescendantsInstances = filterList
    params.IgnoreWater = true

    local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 2000, params)
    if result and result.Instance then
        local target = self:ResolveTarget(result.Instance)
        return target, result.Position
    end

    return nil, nil
end

-- Start interactive click-to-select mode in 3D world
function RaycastSelector:Start(onSelected: (Instance) -> (), onHover: ((Instance?) -> ())?)
    if self.IsActive then self:Stop() end

    self.IsActive = true
    self.OnSelectedCallback = onSelected
    self.OnHoverCallback = onHover

    -- RenderStepped hover raycast
    local hoverConn = RunService.RenderStepped:Connect(function()
        if not self.IsActive then return end

        local target = self:RaycastMouse()
        if target ~= self.HoveredInstance then
            self.HoveredInstance = target
            
            if self.Highlight then
                if target and (target:IsA("Model") or target:IsA("BasePart")) then
                    self.Highlight.Adornee = target
                    self.Highlight.Enabled = true
                else
                    self.Highlight.Adornee = nil
                    self.Highlight.Enabled = false
                end
            end

            if self.OnHoverCallback then
                self.OnHoverCallback(target)
            end
        end
    end)
    table.insert(self.Connections, hoverConn)

    -- Click listener
    local clickConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not self.IsActive then return end

        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local target = self.HoveredInstance or self:RaycastMouse()
            if target then
                self.SelectedInstance = target
                local cb = self.OnSelectedCallback
                self:Stop()
                if cb then
                    cb(target)
                end
            end
        elseif input.KeyCode == Enum.KeyCode.Escape then
            self:Stop()
        end
    end)
    table.insert(self.Connections, clickConn)
end

-- Stop click-to-select mode and clean up
function RaycastSelector:Stop()
    self.IsActive = false
    for _, conn in ipairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    self.Connections = {}

    if self.Highlight then
        self.Highlight.Adornee = nil
        self.Highlight.Enabled = false
    end
    self.HoveredInstance = nil
end

-- Destroy visual elements permanently
function RaycastSelector:Destroy()
    self:Stop()
    if self.Highlight then
        pcall(function() self.Highlight:Destroy() end)
        self.Highlight = nil
    end
end

return RaycastSelector
