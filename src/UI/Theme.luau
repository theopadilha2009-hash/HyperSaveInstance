--[[
    HyperSaveInstance - Modern Glassmorphic Design System & Theme
]]

local TweenService = game:GetService("TweenService")

local Theme = {
    -- Dark Gothic Obsidian Palette (Ram Skull Aesthetic)
    Background = Color3.fromRGB(6, 7, 10),
    BackgroundGlass = Color3.fromRGB(12, 13, 18),
    CardBg = Color3.fromRGB(16, 18, 26),
    CardHover = Color3.fromRGB(25, 28, 40),
    CardActive = Color3.fromRGB(35, 40, 58),
    Border = Color3.fromRGB(36, 40, 56),
    BorderLight = Color3.fromRGB(80, 68, 115),
    BorderNeon = Color3.fromRGB(168, 85, 247), -- Spectral Violet Glow
    
    -- Accents & Gradients
    AccentPrimary = Color3.fromRGB(124, 58, 237),   -- Royal Violet
    AccentSecondary = Color3.fromRGB(147, 51, 234), -- Dark Purple
    AccentCyan = Color3.fromRGB(147, 197, 253),     -- Bone Ice Silver
    AccentSuccess = Color3.fromRGB(34, 197, 94),     -- Spectral Emerald
    AccentWarning = Color3.fromRGB(245, 158, 11),   -- Amber
    AccentDanger = Color3.fromRGB(225, 29, 72),     -- Crimson Blood
    AccentTheo = Color3.fromRGB(192, 132, 252),     -- Mystic Lavender
    AccentSkull = Color3.fromRGB(245, 245, 250),    -- Bone White

    -- Text Colors
    TextPrimary = Color3.fromRGB(248, 250, 252),    -- Pure Bone White
    TextSecondary = Color3.fromRGB(156, 163, 175),  -- Silver Mist
    TextMuted = Color3.fromRGB(100, 116, 139),      -- Dark Slate
    TextAccent = Color3.fromRGB(192, 132, 252),     -- Violet Glow
    TextCyan = Color3.fromRGB(147, 197, 253),
    TextTheo = Color3.fromRGB(216, 180, 254),

    -- Fonts
    FontTitle = Enum.Font.GothamBold,
    FontSemiBold = Enum.Font.GothamSemibold,
    FontRegular = Enum.Font.Gotham,
    FontCode = Enum.Font.Code,

    -- Radii
    CornerLarge = UDim.new(0, 12),
    CornerMedium = UDim.new(0, 8),
    CornerSmall = UDim.new(0, 5),
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
