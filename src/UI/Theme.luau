--[[
    HyperSaveInstance - Modern Glassmorphic Design System & Theme
]]

local TweenService = game:GetService("TweenService")

local Theme = {
    -- Colors
    Background = Color3.fromRGB(15, 17, 23),
    CardBg = Color3.fromRGB(24, 27, 36),
    CardHover = Color3.fromRGB(32, 36, 48),
    Border = Color3.fromRGB(45, 52, 70),
    BorderLight = Color3.fromRGB(65, 75, 100),
    
    -- Accents & Gradients
    AccentPrimary = Color3.fromRGB(99, 102, 241),    -- Indigo
    AccentSecondary = Color3.fromRGB(168, 85, 247),  -- Purple
    AccentCyan = Color3.fromRGB(6, 182, 212),        -- Cyan
    AccentSuccess = Color3.fromRGB(34, 197, 94),     -- Green
    AccentWarning = Color3.fromRGB(234, 179, 8),     -- Amber
    AccentDanger = Color3.fromRGB(239, 68, 68),      -- Red

    -- Text Colors
    TextPrimary = Color3.fromRGB(248, 250, 252),
    TextSecondary = Color3.fromRGB(148, 163, 184),
    TextMuted = Color3.fromRGB(100, 116, 139),
    TextAccent = Color3.fromRGB(129, 140, 248),

    -- Fonts
    FontTitle = Enum.Font.GothamBold,
    FontSemiBold = Enum.Font.GothamSemibold,
    FontRegular = Enum.Font.Gotham,
    FontCode = Enum.Font.Code,

    -- Radii
    CornerLarge = UDim.new(0, 14),
    CornerMedium = UDim.new(0, 10),
    CornerSmall = UDim.new(0, 6),
    CornerPill = UDim.new(1, 0),
}

-- Tween animation helper
function Theme.Tween(instance: Instance, duration: number, properties: {[string]: any}, easingStyle: Enum.EasingStyle?, easingDirection: Enum.EasingDirection?): Tween
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration or 0.2, easingStyle or Enum.EasingStyle.Quad, easingDirection or Enum.EasingDirection.Out),
        properties
    )
    tween:Play()
    return tween
end

-- Create rounded corner
function Theme.AddCorner(instance: Instance, radius: UDim?): UICorner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or Theme.CornerMedium
    corner.Parent = instance
    return corner
end

-- Create stroke / border
function Theme.AddStroke(instance: Instance, color: Color3?, thickness: number?, transparency: number?): UIStroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Border
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = instance
    return stroke
end

-- Create gradient
function Theme.AddGradient(instance: Instance, c1: Color3, c2: Color3, rotation: number?): UIGradient
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, c1),
        ColorSequenceKeypoint.new(1, c2)
    })
    grad.Rotation = rotation or 45
    grad.Parent = instance
    return grad
end

return Theme
