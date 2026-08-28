--[[
    HyperSaveInstance - Modern Glassmorphic Design System & Theme
]]

local TweenService = game:GetService("TweenService")

local Theme = {
    -- Colors & Rich Dark Glassmorphism Palette
    Background = Color3.fromRGB(11, 13, 20),
    BackgroundGlass = Color3.fromRGB(16, 19, 30),
    CardBg = Color3.fromRGB(20, 24, 38),
    CardHover = Color3.fromRGB(28, 34, 52),
    CardActive = Color3.fromRGB(36, 44, 68),
    Border = Color3.fromRGB(42, 50, 75),
    BorderLight = Color3.fromRGB(70, 84, 125),
    BorderNeon = Color3.fromRGB(0, 229, 255),
    
    -- Vibrant Accents & Gradients
    AccentPrimary = Color3.fromRGB(124, 58, 237),   -- Royal Violet
    AccentSecondary = Color3.fromRGB(168, 85, 247), -- Bright Purple
    AccentCyan = Color3.fromRGB(0, 229, 255),       -- Neon Cyber Cyan
    AccentSuccess = Color3.fromRGB(16, 185, 129),   -- Emerald Green
    AccentWarning = Color3.fromRGB(245, 158, 11),   -- Amber Gold
    AccentDanger = Color3.fromRGB(239, 68, 68),     -- Vivid Crimson
    AccentTheo = Color3.fromRGB(236, 72, 153),       -- Hot Pink / Neon Fuchsia

    -- Text Colors
    TextPrimary = Color3.fromRGB(248, 250, 252),
    TextSecondary = Color3.fromRGB(148, 163, 184),
    TextMuted = Color3.fromRGB(100, 116, 139),
    TextAccent = Color3.fromRGB(167, 139, 250),
    TextCyan = Color3.fromRGB(103, 232, 249),
    TextTheo = Color3.fromRGB(244, 114, 182),

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
