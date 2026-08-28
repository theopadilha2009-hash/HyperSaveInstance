--[[
    HyperSaveInstance - Modern Glassmorphic Design System & Theme
]]

local TweenService = game:GetService("TweenService")

local Theme = {
    -- Pure Purple & Black Palette (Roxo e Preto - Gothic Skull Edition)
    Background = Color3.fromRGB(5, 4, 9),          -- Pure Obsidian Black
    BackgroundGlass = Color3.fromRGB(9, 7, 16),     -- Black with Purple Haze
    CardBg = Color3.fromRGB(14, 11, 23),            -- Deep Purple-Black Card
    CardHover = Color3.fromRGB(27, 20, 45),         -- Dark Violet Hover
    CardActive = Color3.fromRGB(43, 27, 70),        -- Electric Violet Active
    Border = Color3.fromRGB(47, 29, 75),            -- Deep Purple Border
    BorderLight = Color3.fromRGB(126, 34, 206),     -- Electric Purple Stroke
    BorderNeon = Color3.fromRGB(168, 85, 247),      -- Vivid Neon Purple Glow
    
    -- Accents & Gradients (Strictly Purple / Violet / Black)
    AccentPrimary = Color3.fromRGB(147, 51, 234),   -- Royal Electric Purple (#9333ea)
    AccentSecondary = Color3.fromRGB(192, 132, 252), -- Radiant Violet (#c084fc)
    AccentCyan = Color3.fromRGB(216, 180, 254),     -- Light Lavender (#d8b4fe)
    AccentSuccess = Color3.fromRGB(168, 85, 247),   -- Neon Purple Glow (#a855f7)
    AccentWarning = Color3.fromRGB(232, 121, 249),   -- Vivid Magenta Purple (#e879f9)
    AccentDanger = Color3.fromRGB(244, 63, 94),     -- Crimson Rose (#f43f5e)
    AccentTheo = Color3.fromRGB(240, 171, 252),     -- Bright Lavender (#f0abfc)
    AccentSkull = Color3.fromRGB(250, 245, 255),    -- Pure Bone White (#faf5ff)

    -- Text Colors
    TextPrimary = Color3.fromRGB(250, 245, 255),    -- Bone White (#faf5ff)
    TextSecondary = Color3.fromRGB(216, 180, 254),  -- Soft Lavender (#d8b4fe)
    TextMuted = Color3.fromRGB(147, 130, 169),      -- Muted Ash Purple
    TextAccent = Color3.fromRGB(192, 132, 252),     -- Vibrant Purple
    TextCyan = Color3.fromRGB(233, 213, 255),       -- Pale Lavender
    TextTheo = Color3.fromRGB(245, 208, 254),       -- Hot Lavender

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
